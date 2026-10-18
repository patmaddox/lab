;;; pm-notmuch.el --- Notmuch extensions -*- lexical-binding: t; -*-

;; Custom commands for working with notmuch mail.
;; Requires notmuch to be loaded.

(require 'notmuch)

;;; Raw message editing

(defun notmuch-edit-raw-message ()
  (interactive)
  (let ((id (notmuch-show-get-message-id))
        (filename (notmuch-show-get-filename)))
    (find-file filename)
    (message-mode)
    (setq-local notmuch-edit-message-id id)
    (add-hook 'after-save-hook #'notmuch-reindex-after-save nil t)))

(defun notmuch-reindex-after-save ()
  (when notmuch-edit-message-id
    (call-process "notmuch" nil nil nil "reindex" notmuch-edit-message-id)))

(define-key notmuch-show-mode-map "E" #'notmuch-edit-raw-message)

;;; Diff highlighting in notmuch-show

(defun pm-notmuch-diff-line-type ()
  "Return the diff line type for the current line, or nil."
  (save-excursion
    (beginning-of-line)
    (cond
     ((looking-at "^diff ") 'file-header)
     ((looking-at "^--- ") 'file-header)
     ((looking-at "^\\+\\+\\+ ") 'file-header)
     ((looking-at "^@@ ") 'hunk-header)
     ((looking-at "^\\+") 'added)
     ((looking-at "^-") 'removed)
     ((looking-at "^ ") 'context)
     (t nil))))

(defun pm-notmuch-highlight-diff-regions (_msg _depth)
  "Highlight diff regions in notmuch text/plain parts.
Added to `notmuch-show-insert-text/plain-hook'."
  (save-excursion
    (goto-char (point-min))
    (let (in-diff)
      (while (not (eobp))
        (let ((type (pm-notmuch-diff-line-type)))
          (cond
           ;; Entering a diff region
           ((and (not in-diff)
                 (memq type '(file-header hunk-header)))
            (setq in-diff t)
            (pm-notmuch--apply-diff-face type))
           ;; Inside a diff region
           (in-diff
            (if type
                (pm-notmuch--apply-diff-face type)
              ;; Non-diff line - check if it's blank (context can have
              ;; empty lines) or truly exits the diff
              (if (looking-at "^$")
                  nil ; blank line, stay in diff
                (setq in-diff nil))))))
        (forward-line 1)))))

(defun pm-notmuch--apply-diff-face (type)
  "Apply the appropriate diff face overlay to the current line."
  (let ((face (pcase type
                ('file-header 'diff-file-header)
                ('hunk-header 'diff-hunk-header)
                ('added 'diff-added)
                ('removed 'diff-removed)
                (_ nil))))
    (when face
      (let ((ov (make-overlay (line-beginning-position) (line-end-position))))
        (overlay-put ov 'face face)
        (overlay-put ov 'pm-notmuch-diff t)))))

(add-hook 'notmuch-show-insert-text/plain-hook
          #'pm-notmuch-highlight-diff-regions)

;;; Claude message handling

(defvar pm-notmuch-claude-handle-message-program "claude-handle-message"
  "Path to the claude-handle-message script.")

(defun pm-notmuch-claude-handle-message ()
  "Run claude-handle-message on the current notmuch message.
The process runs asynchronously in a dedicated buffer."
  (interactive)
  (let* ((msg-id (notmuch-show-get-message-id))
         (buf-name (format "*claude-handle: %s*" msg-id))
         (buf (get-buffer-create buf-name))
         (proc))
    (with-current-buffer buf
      (erase-buffer)
      (insert (format "Running claude-handle-message %s\n\n" msg-id)))
    (setq proc (start-process "claude-handle-message" buf
                              pm-notmuch-claude-handle-message-program msg-id))
    (set-process-sentinel proc #'pm-notmuch--claude-handle-sentinel)
    (display-buffer buf)))

(defun pm-notmuch--claude-handle-sentinel (process event)
  "Report the outcome of a claude-handle-message PROCESS.
EVENT is the process status string."
  (let ((buf (process-buffer process))
        (success (eq 0 (process-exit-status process))))
    (when (buffer-live-p buf)
      (with-current-buffer buf
        (goto-char (point-max))
        (insert "\n"
                (propertize (if success
                                "claude-handle-message finished"
                              (format "claude-handle-message failed (exit %d)"
                                      (process-exit-status process)))
                            'face (if success 'success 'error))
                "\n"))
      (let* ((old-name (buffer-name buf))
             (tag (if success "done" "FAIL"))
             (new-name (replace-regexp-in-string
                        "\\`\\*claude-handle:"
                        (format "*claude-handle:%s:" tag)
                        old-name)))
        (with-current-buffer buf
          (rename-buffer new-name t))))
    (message "claude-handle-message %s"
             (if success "finished" "failed"))))

;;; Filing mail in the list's folders

;; On the list synced from lab-mail, the folder a message is in is its
;; state, and the post-new hook derives the inbox, next, later, and
;; archived tags from it. Filing a message moves its file; a tag
;; alone would be undone by the next notmuch new.

(defvar pm-notmuch-list-folders '("INBOX" "Next" "Later" "Archive")
  "The folders of the list, which mbsync syncs with lab-mail.")

(defun pm-notmuch--list-files (query)
  "Return the files of the messages matching QUERY in the list's folders."
  (let ((root (file-name-as-directory
               (notmuch-config-get "database.mail_root"))))
    (seq-filter
     (lambda (file)
       (let ((rel (file-relative-name file root)))
         (seq-some (lambda (folder)
                     (string-prefix-p (concat folder "/") rel))
                   pm-notmuch-list-folders)))
     (process-lines notmuch-command "search" "--output=files" query))))

(defun pm-notmuch--file-name-in (file folder)
  "Return the name FILE takes in FOLDER's cur/.
mbsync's ,U= part is dropped, so mbsync takes the file for a new
message in FOLDER and moves it on lab-mail."
  (let ((name (replace-regexp-in-string
               ",U=[0-9]+" "" (file-name-nondirectory file))))
    (expand-file-name
     (if (string-match-p ":2," name) name (concat name ":2,"))
     (expand-file-name
      "cur" (expand-file-name
             folder (notmuch-config-get "database.mail_root"))))))

(defun pm-notmuch-move-to-folder (query folder)
  "Move the messages matching QUERY to the list folder FOLDER.
Then run notmuch new, so the tags follow at once."
  (dolist (file (pm-notmuch--list-files query))
    (let ((dest (pm-notmuch--file-name-in file folder)))
      (unless (string= file dest)
        (make-directory (file-name-directory dest) t)
        (rename-file file dest))))
  (call-process notmuch-command nil nil nil "new" "--quiet"))

(defun pm-notmuch--move-at-point (folder)
  "Move the message or thread at point to FOLDER, and refresh the view."
  (pcase major-mode
    ('notmuch-show-mode
     (pm-notmuch-move-to-folder (notmuch-show-get-message-id) folder)
     (notmuch-show-refresh-view))
    ('notmuch-search-mode
     (pm-notmuch-move-to-folder (notmuch-search-find-thread-id) folder)
     (notmuch-search-refresh-view))
    ('notmuch-tree-mode
     (pm-notmuch-move-to-folder (notmuch-tree-get-message-id) folder)
     (notmuch-tree-refresh-view)))
  (message "Moved to %s" folder))

(defun pm-notmuch-move-to-inbox ()
  "Move the message or thread at point to INBOX."
  (interactive)
  (pm-notmuch--move-at-point "INBOX"))

(defun pm-notmuch-move-to-next ()
  "Move the message or thread at point to Next."
  (interactive)
  (pm-notmuch--move-at-point "Next"))

(defun pm-notmuch-move-to-later ()
  "Move the message or thread at point to Later."
  (interactive)
  (pm-notmuch--move-at-point "Later"))

(defun pm-notmuch-move-to-archive ()
  "Move the message or thread at point to Archive."
  (interactive)
  (pm-notmuch--move-at-point "Archive"))

(defvar pm-notmuch-move-map
  (let ((map (make-sparse-keymap)))
    (define-key map "i" #'pm-notmuch-move-to-inbox)
    (define-key map "n" #'pm-notmuch-move-to-next)
    (define-key map "l" #'pm-notmuch-move-to-later)
    (define-key map "a" #'pm-notmuch-move-to-archive)
    map)
  "Keys that move mail between the list's folders, under M.")

(dolist (map (list notmuch-show-mode-map notmuch-search-mode-map
                   notmuch-tree-mode-map))
  (define-key map "M" pm-notmuch-move-map))

;;; Leaf message search

(defvar pm-notmuch-leaves-program "notmuch-leaves"
  "Path to the notmuch-leaves script.")

(defun pm-notmuch-search-leaves ()
  "Search for leaf messages - thread endpoints with no replies."
  (interactive)
  (let* ((ids (with-temp-buffer
                (call-process pm-notmuch-leaves-program nil t nil "tag:inbox")
                (string-trim (buffer-string)))))
    (if (string-empty-p ids)
        (message "No leaf messages found")
      (notmuch-search (mapconcat #'identity (split-string ids "\n") " or ")))))

(defun pm-notmuch-hello-insert-leaves ()
  "Insert a button on the notmuch hello page to search leaf messages."
  (widget-insert "  ")
  (widget-create 'push-button
                 :notify (lambda (&rest _) (pm-notmuch-search-leaves))
                 "Leaf messages")
  (widget-insert "\n"))

(provide 'pm-notmuch)
;;; pm-notmuch.el ends here
