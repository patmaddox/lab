;;; freebsd-style-ts.el --- FreeBSD style for tree-sitter modes

;; Usage in init.el:
;;   (require 'freebsd-style-ts)
;;   (add-hook 'c-ts-mode-hook 'freebsd-c-style-ts)
;;   (add-hook 'bash-ts-mode-hook 'freebsd-sh-style-ts)

(require 'c-ts-mode)
(require 'sh-script)

(defun freebsd-c-style-ts--rules ()
  "Return FreeBSD style(9) indent rules extending the built-in BSD style.
Primary indent: 8 spaces (1 tab).
Continuation indent: 4 spaces."
  (let ((continuation 4))
    (append
     `(;; Continuation: 4-space indent for wrapped arguments/parameters
       ((parent-is "argument_list") standalone-parent ,continuation)
       ((parent-is "parameter_list") standalone-parent ,continuation)
       ((parent-is "init_declarator") standalone-parent ,continuation)
       ((parent-is "binary_expression") standalone-parent ,continuation)
       ((parent-is "conditional_expression") standalone-parent ,continuation)
       ((parent-is "assignment_expression") standalone-parent ,continuation)
       ((parent-is "concatenated_string") first-sibling 0))
     ;; Include the built-in BSD rules
     (alist-get 'bsd (c-ts-mode--indent-styles 'c)))))

;; Set the indent style globally when this file loads
(setq c-ts-mode-indent-style #'freebsd-c-style-ts--rules)
(setq c-ts-mode-indent-offset 8)

(defun freebsd-c-style-ts ()
  "Set buffer-local settings for FreeBSD style(9).
The indent rules are set globally; this sets tab display and usage."
  (interactive)
  (setq tab-width 8)
  (setq indent-tabs-mode t))

;;; Shell

;; bash-ts-mode is used for tree-sitter highlighting (no POSIX grammar
;; exists), but we reconfigure the shell type from the shebang via
;; sh-set-shell.  Indentation uses SMIE (not tree-sitter), controlled
;; by sh-basic-offset.

(defun freebsd-sh-style-ts ()
  "Set up FreeBSD style for shell scripts.
Uses bash-ts-mode for tree-sitter highlighting but detects the
actual shell from the shebang (e.g., #!/bin/sh -> POSIX sh).
Uses tabs and 8-space indentation per FreeBSD style."
  (interactive)
  (sh-set-shell (sh--guess-shell) nil nil)
  (setq tab-width 8)
  (setq indent-tabs-mode t)
  (setq sh-basic-offset 8)
  (setq sh-indent-for-case-label 0)
  (setq sh-indent-for-case-alt '+)
  (setq sh-indent-for-continuation 4)
  (setq sh-indent-after-continuation 'always))

(provide 'freebsd-style-ts)
