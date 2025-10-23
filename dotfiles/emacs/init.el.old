;; -*-no-byte-compile: t; -*-

(use-package emacs
  :init
  (setq patmaddox-packages
        '("consult-2.2"
          "consult-project-extra-982e800"
          "denote-7bb8b7c"
          "gptel-0.9.8"
          "llama-0.6.2" ; magit dependency
          "magit-4.3.3/lisp"
          "marginalia-2.0"
          "markdown-mode-2.7"
          "orderless-1.4"
          "term-keys-5677d06"
          "vertico-2.0"
          "vertico-2.0/extensions"
          "with-editor-3.4.3/lisp"
          "xclip-1.11.1"
          "zig-ts-mode-3898b70"))

  (dolist (p patmaddox-packages)
    (add-to-list 'load-path (expand-file-name (concat "packages/" p) user-emacs-directory)))

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
  (add-to-list 'auto-mode-alist '("\\.ex\\'" . elixir-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.exs\\'" . elixir-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.go\\'" . go-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.heex\\'" . heex-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.lua\\'" . lua-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-ts-mode))

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

(use-package eglot
  :init
  (setq eglot-ignored-server-capabilities '(:hoverProvider :signatureHelpProvider)))

(use-package elixir-ts-mode
  :init
  (add-hook 'elixir-ts-mode-hook 'eglot-ensure)
  (add-hook 'elixir-ts-mode-hook (lambda () (eldoc-mode 0)))
  (add-hook 'elixir-ts-mode-hook
            (lambda () (add-hook 'before-save-hook 'eglot-format nil t)))
  (add-to-list 'eglot-server-programs (list 'elixir-ts-mode (expand-file-name "dist/elixir-ls-v0.27.2/language_server.sh" user-emacs-directory))))

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

(use-package sh-script
  :init
  (add-hook 'sh-mode-hook
            (lambda () (add-hook 'before-save-hook 'delete-trailing-whitespace nil t))))

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

;; denote - simple notes with ID-based naming scheme
;; https://github.com/protesilaos/denote
(use-package denote
  :hook (dired-mode . denote-dired-mode)
  :bind
  ("C-c n n" . denote)
  ("C-c n r" . denote-rename-file)
  ("C-c n l" . denote-link)
  ("C-c n b" . denote-backlinks)
  ("C-c n d" . denote-dired)
  ("C-c n g" . denote-grep)
  :config
  (setq denote-directory (expand-file-name "~/lab.jj/notes"))

  ;; Automatically rename Denote buffers when opening them so that
  ;; instead of their long file name they have, for example, a literal
  ;; "[D]" followed by the file's title.  Read the doc string of
  ;; `denote-rename-buffer-format' for how to modify this.
  (denote-rename-buffer-mode 1))

;; gptel - LLM interface
;; https://github.com/karthink/gptel
(use-package gptel)

;; magit - git interface
;; https://github.com/magit/magit
(use-package magit)

;; marginalia - notes in the minibuffer (names, file sizes, etc)
;; https://github.com/minad/marginalia
(use-package marginalia
  :config
  (marginalia-mode 1))

;; markdown-mode
;; https://github.com/jrblevin/markdown-mode
(use-package markdown-mode)

;; orderless - completion style matching in any order
;; https://github.com/oantolin/orderless
(use-package orderless
  :custom
  (completion-styles '(orderless basic)))

;; term-keys - make terminal keyboard sequences work
;; https://github.com/CyberShadow/term-keys
(use-package term-keys
  :init
  (unbind-key "C-M-_")
  :config
  (term-keys-mode t))

;; vertico - vertical interactive completion
;; https://github.com/minad/vertico
(use-package vertico
  :custom
  (vertico-cycle t)
  (vertico-resize nil)
  (vertico-count 20)
  :config
  (vertico-mode 1))

(use-package vertico-directory
  :after vertico
  :bind (:map vertico-map
              ("RET" . vertico-directory-enter)
              ("DEL" . vertico-directory-delete-char)
              ("M-DEL" . vertico-directory-delete-word))
  ;; Tidy shadowed file names
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

;; xclip - copy and paste between X
;; https://elpa.gnu.org/packages/xclip.html
(use-package xclip
  :config
  (xclip-mode 1))

;; zig-ts-mode
;; https://codeberg.org/meow_king/zig-ts-mode
(use-package zig-ts-mode)
