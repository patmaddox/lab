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
         (buf (get-buffer-create buf-name)))
    (with-current-buffer buf
      (erase-buffer)
      (insert (format "Running claude-handle-message %s\n\n" msg-id)))
    (start-process "claude-handle-message" buf
                   pm-notmuch-claude-handle-message-program msg-id)
    (display-buffer buf)))

(define-key notmuch-show-mode-map "H" #'pm-notmuch-claude-handle-message)

(provide 'pm-notmuch)
;;; pm-notmuch.el ends here
