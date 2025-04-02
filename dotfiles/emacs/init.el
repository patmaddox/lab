;; -*-no-byte-compile: t; -*-
(use-package emacs
  :init
  (add-to-list 'load-path (expand-file-name "packages/consult-2.2" user-emacs-directory))
  (add-to-list 'load-path (expand-file-name "packages/consult-project-extra-982e800" user-emacs-directory))

  :config
  (add-hook 'emacs-lisp-mode-hook
	    (lambda ()
	      (setq indent-tabs-mode nil)
	      (define-key emacs-lisp-mode-map
                          "\C-x\C-e" 'pp-eval-last-sexp)
	      (add-hook 'before-save-hook 'delete-trailing-whitespace nil t)
	      (add-hook 'after-save-hook (lambda () (byte-compile-file buffer-file-name)) nil t)))

  (add-to-list 'completion-styles 'flex)
  (add-to-list 'auto-mode-alist '("\\.jjdescription\\'" . org-mode))
  (delete ".git/" completion-ignored-extensions)
  (dolist (i '(".core"
               ".fslckout"
               ".so"
               "auto-save-list/"
               "history"
               "ido.last"
               "transient/"))
    (add-to-list 'completion-ignored-extensions i))
  (put 'downcase-region 'disabled nil)
  (put 'upcase-region 'disabled nil)

  (electric-pair-mode 1)
  (global-display-line-numbers-mode 1)
  (global-hl-line-mode 1)
  (menu-bar-mode -1)
  (require 'eglot)
  (show-paren-mode 1)

  :bind
  ("M-RET" . project-find-file)
  ("M-i" . consult-imenu)
  ("M-I" . consult-imenu-multi)

  :custom
  (load-prefer-newer t)
  (warning-minimum-level :error)
  (read-file-name-completion-ignore-case t))

(use-package project
  :custom
  (project-vc-extra-root-markers
   '(".emacs-project"
     ".fslckout"
     ".jj"
     "mix.exs"))
  (project-vc-ignores
   '("#*#"
     "*~"
     "*.elc"
     ".elixir_ls"
     "*.jj"
     ".fslckout"
     ".jj"
     "_build"
     "deps"
     "node_modules"
     "packages"
     "plz-out"
     "postgres/data"
     "priv/static"
     "auto-save-list"
     "transient"
     "tree-sitter")))

;; consult - better search and navigation (consulting completing-read)
;; https://github.com/minad/consult
(use-package consult
  :bind
  ("C-x b" . consult-buffer)
  ("C-x p b" . consult-project-buffer)
  :init
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)
  (advice-add #'register-preview :override #'consult-register-window)
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref))

(use-package consult-imenu)
(use-package consult-org)
(use-package consult-xref)

;; consult-project-extra - consult extension for project.el
;; https://github.com/Qkessler/consult-project-extra
(use-package consult-project-extra)
