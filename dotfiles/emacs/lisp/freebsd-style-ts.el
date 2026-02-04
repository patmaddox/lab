;;; freebsd-style-ts.el --- FreeBSD style(9) indentation for tree-sitter

;; Usage in init.el:
;;   (require 'freebsd-style-ts)
;;   (add-hook 'c-ts-mode-hook 'freebsd-c-style-ts)

(require 'c-ts-mode)

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

(provide 'freebsd-style-ts)
