;;; pm-jj.el --- jj (Jujutsu) extensions for vc-jj  -*- lexical-binding: t; -*-

;; Custom commands for working with jj log views.
;; Requires vc-jj to be loaded.

(defvar pm-jj--log-config
  '("--config" "ui.graph.style=\"ascii\"")
  "Extra jj config flags for Emacs log buffers.")

(defun pm-jj--root ()
  "Return the jj repo root, working from any buffer."
  (or (vc-jj-root default-directory)
      (vc-root-dir)))

;;; Describe (edit commit message)

;; log-view-extract-comment and vc-start-logentry assume per-file
;; logs, which breaks in root log buffers.  These functions bypass
;; that machinery and drive jj describe directly.

(defun pm-vc-jj-describe-save ()
  "Save the jj description and close the edit buffer."
  (interactive)
  (let ((new-desc (buffer-string))
        (rev pm-vc-jj--rev)
        (log-buf pm-vc-jj--log-buf))
    (vc-jj-modify-change-comment nil rev new-desc)
    (quit-window t)
    (when (buffer-live-p log-buf)
      (with-current-buffer log-buf
        (revert-buffer)))))

(defun pm-vc-jj-describe-cancel ()
  "Cancel editing the jj description."
  (interactive)
  (quit-window t))

(defun pm-vc-jj-edit-comment ()
  "Edit the change comment at point in a jj log buffer."
  (interactive)
  (let* ((rev (log-view-current-tag))
         (desc (shell-command-to-string
                (format "jj log --no-graph -r %s -T description" rev)))
         (log-buf (current-buffer))
         (buf (get-buffer-create "*jj-describe*")))
    (pop-to-buffer buf)
    (erase-buffer)
    (insert desc)
    (goto-char (point-min))
    (text-mode)
    ;; Highlight embedded diffs in :FEEDBACK: drawers
    (font-lock-add-keywords nil
      '(("^\\+.*$" . 'diff-added)
        ("^-.*$" . 'diff-removed)
        ("^@@.*@@.*$" . 'diff-hunk-header)
        ("^diff --git.*$" . 'diff-file-header))
      'append)
    (font-lock-flush)
    ;; Fold diff sections with outline on diff --git and @@ lines
    (setq-local outline-regexp "^\\(diff --git\\|@@\\)")
    (outline-minor-mode 1)
    (local-set-key (kbd "TAB") #'outline-toggle-children)
    (local-set-key (kbd "<backtab>") #'outline-cycle-buffer)
    (setq-local pm-vc-jj--rev rev)
    (setq-local pm-vc-jj--log-buf log-buf)
    (setq-local header-line-format
                (format "Editing description for %s.  C-c C-c to save, C-c C-k to cancel."
                        rev))
    (local-set-key (kbd "C-c C-c") #'pm-vc-jj-describe-save)
    (local-set-key (kbd "C-c C-k") #'pm-vc-jj-describe-cancel)))

;;; Log view actions

(defun pm-vc-jj-show ()
  "Show the commit at point with full description and diff."
  (interactive)
  (let* ((rev (log-view-current-tag))
         (buf (get-buffer-create "*jj-show*"))
         (default-directory (pm-jj--root)))
    (with-current-buffer buf
      (let ((inhibit-read-only t))
        (erase-buffer)
        (call-process "jj" nil t nil "show" "--git" "-r" rev))
      (special-mode)
      (font-lock-add-keywords nil
        '(("^\\+.*$" . 'diff-added)
          ("^-.*$" . 'diff-removed)
          ("^@@.*@@.*$" . 'diff-hunk-header)
          ("^diff --git.*$" . 'diff-file-header))
        'append)
      (font-lock-flush)
      (setq-local outline-regexp "^\\(diff --git\\|@@\\)")
      (outline-minor-mode 1)
      (local-set-key (kbd "TAB") #'outline-toggle-children)
      (local-set-key (kbd "<backtab>") #'outline-cycle-buffer)
      (local-set-key (kbd "q") (lambda () (interactive) (quit-window t)))
      (goto-char (point-min)))
    (pop-to-buffer buf)))

(defun pm-vc-jj-sign-off ()
  "Add a Signed-off-by line to the commit at point."
  (interactive)
  (let* ((rev (log-view-current-tag))
         (desc (shell-command-to-string
                (format "jj log --no-graph -r %s -T description" rev)))
         (signoff "Signed-off-by: Pat Maddox <pat@patmaddox.com>"))
    (if (string-match-p (regexp-quote signoff) desc)
        (message "Already signed off")
      (let* ((cleaned (replace-regexp-in-string
                       "\\[SIGNOFF\\] *" "" desc))
             (new-desc (concat (string-trim-right cleaned) "\n\n" signoff "\n")))
        (vc-jj-modify-change-comment nil rev new-desc)
        (let ((revert-fn revert-buffer-function))
          (when revert-fn
            (funcall revert-fn nil t)))
        (message "Signed off %s" rev)))))

(defun pm-vc-jj-submit ()
  "Submit the commit at point for review."
  (interactive)
  (let* ((rev (log-view-current-tag))
         (default-directory (pm-jj--root))
         (output (shell-command-to-string
                  (format "./libexec/just/submit.sh %s" rev))))
    (let ((revert-fn revert-buffer-function))
      (when revert-fn
        (funcall revert-fn nil t)))
    (let ((last-line (car (last (split-string (string-trim output) "\n")))))
      (message "%s" last-line))))

;;; Shell commands

(defun pm-jj--run (name cmd args)
  "Run CMD with ARGS in an eat terminal buffer named NAME.
NAME should include surrounding *s (e.g. \"*jj-promote*\")."
  (let* ((default-directory (pm-jj--root))
         (eat-name (string-trim name "\\*" "\\*"))
         (buf (get-buffer-create (concat "*" eat-name "*"))))
    ;; Kill existing process so eat-make restarts
    (let ((proc (get-buffer-process buf)))
      (when (and proc (process-live-p proc))
        (set-process-query-on-exit-flag proc nil)
        (kill-process proc)
        (accept-process-output proc 1)))
    (with-current-buffer buf
      (let ((inhibit-read-only t))
        (erase-buffer)))
    (apply #'eat-make eat-name
           (expand-file-name cmd default-directory)
           nil args)
    (with-current-buffer buf
      (setq-local header-line-format (format "--- %s ---" name)))
    (pop-to-buffer buf)))

(defun pm-vc-jj-promote ()
  "Promote the commit at point."
  (interactive)
  (let ((rev (log-view-current-tag)))
    (pm-jj--run "*jj-promote*" "./libexec/just/promote.sh" (list rev))))

(defun pm-vc-jj-promote-all ()
  "Promote all promotable commits."
  (interactive)
  (pm-jj--run "*jj-promote*" "./libexec/just/promote.sh" nil))

(defun pm-vc-jj-feedback ()
  "Apply feedback for the commit at point."
  (interactive)
  (let ((rev (log-view-current-tag)))
    (pm-jj--run "*jj-feedback*" "./libexec/just/feedback.sh" (list rev))))

(defun pm-vc-jj-feedback-auto ()
  "Auto-select a feedback commit and apply it."
  (interactive)
  (pm-jj--run "*jj-feedback*" "./libexec/just/feedback.sh" nil))

;;; Keybindings

(keymap-set vc-jj-log-view-mode-map "e" #'pm-vc-jj-edit-comment)
(keymap-set vc-jj-log-view-mode-map "TAB" #'pm-vc-jj-show)
(keymap-set vc-jj-log-view-mode-map "C-c s" #'pm-vc-jj-submit)
(keymap-set vc-jj-log-view-mode-map "C-c o" #'pm-vc-jj-sign-off)
(keymap-set vc-jj-log-view-mode-map "C-c p" #'pm-vc-jj-promote)
(keymap-set vc-jj-log-view-mode-map "C-c P" #'pm-vc-jj-promote-all)
(keymap-set vc-jj-log-view-mode-map "C-c f" #'pm-vc-jj-feedback)
(keymap-set vc-jj-log-view-mode-map "C-c F" #'pm-vc-jj-feedback-auto)

;;; Log commands

(defun pm-jj--log-view (name revset &optional extra-args)
  "Show a jj log in buffer NAME filtered by REVSET.
EXTRA-ARGS are passed to jj log."
  (let* ((template (car vc-jj-root-log-format))
         (buf (get-buffer-create name))
         (default-directory (pm-jj--root))
         (args (append pm-jj--log-config
                       extra-args
                       (when revset (list "-r" revset))
                       (list "-T" template))))
    (with-current-buffer buf
      (let ((inhibit-read-only t))
        (erase-buffer)
        (apply #'call-process "jj" nil t nil "log" args))
      (vc-jj-log-view-mode)
      (goto-char (point-min)))
    (pop-to-buffer buf)
    buf))

(defun pm-jj-log ()
  "Show the jj log, respecting the configured default revset."
  (interactive)
  (let ((buf (pm-jj--log-view "*jj-log*" nil)))
    (with-current-buffer buf
      (setq-local revert-buffer-function
                  (lambda (_ignore-auto _noconfirm)
                    (pm-jj-log))))))

(defun pm-jj-actionable ()
  "Show actionable commits."
  (interactive)
  (let ((buf (pm-jj--log-view "*jj-actionable*"
              "mutable() & ~empty() & ~blocked() & ~description(substring:\"Signed-off-by:\")"
              '("--reversed"))))
    (with-current-buffer buf
      (setq-local revert-buffer-function
                  (lambda (_ignore-auto _noconfirm)
                    (pm-jj-actionable))))))

(defun pm-jj-blocked ()
  "Show blocked commits."
  (interactive)
  (let ((buf (pm-jj--log-view "*jj-blocked*" "blocked() | trunk() | dev")))
    (with-current-buffer buf
      (setq-local revert-buffer-function
                  (lambda (_ignore-auto _noconfirm)
                    (pm-jj-blocked))))))

(defun pm-jj-blockers ()
  "Show commits that are blocking others."
  (interactive)
  (let ((buf (pm-jj--log-view "*jj-blockers*" "blockers() | trunk() | dev")))
    (with-current-buffer buf
      (setq-local revert-buffer-function
                  (lambda (_ignore-auto _noconfirm)
                    (pm-jj-blockers))))))

(provide 'pm-jj)
;;; pm-jj.el ends here
