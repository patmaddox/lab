;;; freebsd-style-ts.el --- FreeBSD style for tree-sitter modes

;; Usage in init.el:
;;   (require 'freebsd-style-ts)
;;   (add-hook 'c-ts-mode-hook 'freebsd-c-style-ts)
;;   (add-hook 'bash-ts-mode-hook 'freebsd-sh-style-ts)

(require 'c-ts-mode)
(require 'sh-script)

(defun freebsd-c-style-ts--rules (&optional language)
  "Return FreeBSD style(9) indent rules extending the built-in BSD style.
LANGUAGE is 'c or 'cpp, passed by the mode.  Defaults to 'c.
Primary indent: 8 spaces (1 tab).
Continuation indent: 4 spaces."
  (let ((continuation 4)
        (offset 8)
        (lang (or language 'c)))
    (append
     `(;; C++ access specifiers (public:, private:, protected:) at column 0
       ((node-is "access_specifier") parent-bol 0)
       ;; Closing braces at same level as opening construct
       ((node-is "}") standalone-parent 0)
       ;; C++ class members (after access specifier) at standard indent
       ((parent-is "field_declaration_list") parent-bol ,offset)
       ;; C++ field initializer list uses continuation indent
       ((node-is "field_initializer_list") parent-bol ,continuation)
       ;; Continuation: 4-space indent for wrapped arguments/parameters
       ((parent-is "argument_list") standalone-parent ,continuation)
       ((parent-is "parameter_list") standalone-parent ,continuation)
       ((parent-is "init_declarator") standalone-parent ,continuation)
       ((parent-is "binary_expression") standalone-parent ,continuation)
       ((parent-is "conditional_expression") standalone-parent ,continuation)
       ((parent-is "assignment_expression") standalone-parent ,continuation)
       ((parent-is "concatenated_string") first-sibling 0))
     ;; Include the built-in BSD rules for the appropriate language
     (alist-get 'bsd (c-ts-mode--indent-styles lang)))))

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
