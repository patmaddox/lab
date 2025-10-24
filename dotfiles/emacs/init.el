;; -*-no-byte-compile: t; -*-

;; textproc/tree-sitter-grammars provides grammars for a ton of
;; languages.
(setq treesit-extra-load-path '("/usr/local/share/tree-sitter-grammars"))

;; Remap built-in modes that already have auto-mode-alist entries
(setq major-mode-remap-alist
      '((c-mode . c-ts-mode)
        (c++-mode . c++-ts-mode)
        (c-or-c++-mode . c-or-c++-ts-mode)
        (css-mode . css-ts-mode)
        (html-mode . html-ts-mode)
        (java-mode . java-ts-mode)
        (js-mode . js-ts-mode)
        (json-mode . json-ts-mode)
        (python-mode . python-ts-mode)
        (ruby-mode . ruby-ts-mode)
        (sh-mode . bash-ts-mode)))

;; Add auto-mode-alist entries for languages without built-in modes
;; or where the built-in mode doesn't have file associations
(add-to-list 'auto-mode-alist '("\\.cmake\\'" . cmake-ts-mode))
(add-to-list 'auto-mode-alist '("CMakeLists\\.txt\\'" . cmake-ts-mode))
(add-to-list 'auto-mode-alist '("\\(?:Dockerfile\\(?:\\..*\\)?\\|\\.[Dd]ockerfile\\)\\'" . dockerfile-ts-mode))
(add-to-list 'auto-mode-alist '("\\.ex\\'" . elixir-ts-mode))
(add-to-list 'auto-mode-alist '("\\.exs\\'" . elixir-ts-mode))
(add-to-list 'auto-mode-alist '("\\.go\\'" . go-ts-mode))
(add-to-list 'auto-mode-alist '("/go\\.mod\\'" . go-mod-ts-mode))
(add-to-list 'auto-mode-alist '("\\.heex\\'" . heex-ts-mode))
(add-to-list 'auto-mode-alist '("\\.lua\\'" . lua-ts-mode))
(add-to-list 'auto-mode-alist '("\\.php\\'" . php-ts-mode))
(add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-ts-mode))
(add-to-list 'auto-mode-alist '("\\.toml\\'" . toml-ts-mode))
(add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-ts-mode))
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))
(add-to-list 'auto-mode-alist '("\\.ya?ml\\'" . yaml-ts-mode))

;; Languages that do not have a built-in mode
(require 'markdown-mode)
(add-to-list 'auto-mode-alist '("\\.md\\'" . gfm-mode))

;; terminal emulators
(require 'eat)
(require 'vterm)

;;; Completion: Vertico + Orderless + Consult + Marginalia

;; Vertico: Vertical completion UI
(require 'vertico)
(vertico-mode)

;; vertico-directory: better file path navigation
(require 'vertico-directory)
(with-eval-after-load 'vertico
  (define-key vertico-map (kbd "RET") #'vertico-directory-enter)
  (define-key vertico-map (kbd "DEL") #'vertico-directory-delete-char)
  (define-key vertico-map (kbd "M-DEL") #'vertico-directory-delete-word))

;; Orderless: Flexible matching with space-separated patterns
(require 'orderless)
(setq completion-styles '(orderless basic)
      completion-category-defaults nil
      ;; Use partial-completion for files to handle paths better
      completion-category-overrides '((file (styles partial-completion))))

;; Marginalia: Rich annotations in the minibuffer
;; Shows file permissions, sizes, dates, docstrings, etc.
(require 'marginalia)
(marginalia-mode)

