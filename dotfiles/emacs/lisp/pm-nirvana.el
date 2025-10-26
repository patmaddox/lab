;;; pm-nirvana.el --- Import Nirvana checklist items to org-mode -*- lexical-binding: t; -*-

;; Author: Pat Maddox
;; Keywords: org, productivity

;;; Commentary:

;; Import markdown checklist items from Nirvana task manager into org-mode.
;; Opens a buffer for pasting and editing checklist items, then converts
;; them to org headings in inbox.org.

;;; Code:

(require 'org)

(defun pm/nirvana-to-org ()
  "Import markdown checklist items from Nirvana into inbox.org.
Each - [ ] item becomes a heading with its paragraph content.
Opens a buffer for pasting and editing. Use C-c C-c to import or C-c C-k to cancel."
  (interactive)
  (let ((buffer (generate-new-buffer "*Nirvana Import*")))
    (switch-to-buffer buffer)
    (insert "# Paste checklist items below, then press C-c C-c to import or C-c C-k to cancel\n\n")
    (local-set-key (kbd "C-c C-c")
                   (lambda ()
                     (interactive)
                     (pm/nirvana-to-org--process-buffer)
                     (kill-buffer)))
    (local-set-key (kbd "C-c C-k")
                   (lambda ()
                     (interactive)
                     (kill-buffer)
                     (message "Import cancelled")))))

(defun pm/nirvana-to-org--process-buffer ()
  "Process the current buffer and import items to inbox.org."
  (let* ((text (buffer-substring-no-properties (point-min) (point-max)))
         (lines (split-string text "\n"))
         (items '())
         (current-item nil)
         (base-indent nil))
    ;; Parse the input into items
    (dolist (line lines)
      (cond
       ;; Skip comment lines
       ((string-match "^#" line) nil)
       ;; New checklist item
       ((string-match "^- \\[ \\] \\(.+\\)" line)
        (when current-item
          (push (nreverse current-item) items))
        (setq current-item (list (match-string 1 line))
              base-indent nil))
       ;; Blank line within an item
       ((and current-item
             (string-match "^[[:space:]]*$" line))
        (push "" current-item))
       ;; Content line (non-empty, not a checkbox)
       ((and current-item
             (not (string-match "^- \\[ \\]" line)))
        ;; Detect base indentation from first non-blank content line
        (unless base-indent
          (string-match "^\\([[:space:]]*\\)" line)
          (setq base-indent (match-string 1 line)))
        ;; Remove base indentation, preserve any additional indentation
        (let ((content (if (string-prefix-p base-indent line)
                          (substring line (length base-indent))
                        line)))
          (push content current-item)))))
    ;; Don't forget the last item
    (when current-item
      (push (nreverse current-item) items))
    (setq items (nreverse items))
    ;; Write items to inbox.org
    (with-current-buffer (find-file-noselect org-default-notes-file)
      (goto-char (point-max))
      (unless (bolp) (insert "\n"))
      (dolist (item items)
        (let* ((heading (car item))
               (content (cdr item))
               ;; Trim leading blank lines
               (trimmed (seq-drop-while (lambda (s) (string-empty-p s)) content))
               ;; Trim trailing blank lines
               (trimmed (reverse (seq-drop-while (lambda (s) (string-empty-p s)) (reverse trimmed)))))
          (insert "* " heading "\n")
          (when trimmed
            (dolist (line trimmed)
              (insert line "\n")))))
      (save-buffer))
    (message "Imported %d items to %s" (length items) org-default-notes-file)))

(provide 'pm-nirvana)
;;; pm-nirvana.el ends here
