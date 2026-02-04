;; settings used only in test mode

;; use-package will lazily load things when possible, leading to a
;; config that might not actually work. Force all packages to load
;; when emacs does.
(setq use-package-always-demand t)

(defun test-file-mode (file expected-mode)
  "Verify major mode is EXPECTED-MODE. Exit 1 if wrong."
  (unless (eq major-mode expected-mode)
    (message "Mode check failed: expected %s, got %s" expected-mode major-mode)
    (kill-emacs 1)))

(defun test-file-highlighting ()
  "Verify buffer has syntax highlighting. Exit 1 if no faces found."
  (font-lock-ensure)
  (let ((has-faces nil))
    (save-excursion
      (goto-char (point-min))
      (while (and (not has-faces) (< (point) (point-max)))
        (when (get-text-property (point) 'face)
          (setq has-faces t))
        (forward-char 1)))
    (unless has-faces
      (message "Highlighting check failed: no syntax highlighting found")
      (kill-emacs 1))))

(defun test-file-formatter ()
  "Run formatter on buffer, exit 1 if buffer was modified."
  (indent-region (point-min) (point-max))
  (when (buffer-modified-p)
    (message "Formatter check failed: buffer was modified")
    (kill-emacs 1)))

(defun test-file (file expected-mode)
  "Load FILE, verify mode, highlighting, and formatter."
  (find-file file)
  (test-file-mode file expected-mode)
  (test-file-highlighting)
  (test-file-formatter)
  (kill-emacs 0))

(defun test-file-no-formatter (file expected-mode)
  "Load FILE, verify mode and highlighting only (skip formatter check)."
  (find-file file)
  (test-file-mode file expected-mode)
  (test-file-highlighting)
  (kill-emacs 0))

(defun test-file-format-on-save (file expected-mode)
  "Load FILE, strip leading whitespace, save to trigger formatter, verify restored.
Tests that format-on-save hooks correctly reformat the file."
  (find-file file)
  (test-file-mode file expected-mode)
  (test-file-highlighting)
  ;; Save original content
  (let ((original (buffer-string)))
    ;; Strip leading whitespace from all lines
    (goto-char (point-min))
    (while (not (eobp))
      (delete-horizontal-space)
      (forward-line 1))
    ;; Save file (triggers format-on-save hooks)
    (save-buffer)
    ;; Compare with original
    (unless (string= (buffer-string) original)
      (message "Format-on-save check failed: content differs from original")
      (kill-emacs 1)))
  (kill-emacs 0))
