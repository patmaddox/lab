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

;;; UI/UX
(blink-cursor-mode -1)
(electric-pair-mode 1)
(global-display-line-numbers-mode 1)
(global-hl-line-mode 1)
(menu-bar-mode -1)
(show-paren-mode 1)
(winner-mode 1)
(setq read-file-name-completion-ignore-case t)
(setq warning-minimum-level :error)
(setq load-prefer-newer t)

;; Enable disabled commands
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)

;; Completion ignored extensions
(delete ".git/" completion-ignored-extensions)
(dolist (i '(".core"
             ".fslckout"
             ".so"
             "auto-save-list/"
             "history"
             "ido.last"
             "transient/"))
  (add-to-list 'completion-ignored-extensions i))

;; terminal emulators
(require 'eat)
(require 'vterm)

;; eat configuration - make ESC work in vim while keeping M-x working
;; In GUI Emacs, <escape> is distinct from ESC (Meta prefix)
(with-eval-after-load 'eat
  (when (display-graphic-p)
    ;; Bind the physical <escape> key to send itself to terminal
    (define-key eat-semi-char-mode-map (kbd "<escape>") #'eat-self-input)
    ;; Pass through Ctrl-arrow for word navigation in shell
    (define-key eat-semi-char-mode-map (kbd "C-<left>") #'eat-self-input)
    (define-key eat-semi-char-mode-map (kbd "C-<right>") #'eat-self-input)
    (define-key eat-semi-char-mode-map (kbd "C-g") #'eat-self-input)
    ;; Add shift-arrow scrolling in semi-char mode
    (define-key eat-semi-char-mode-map (kbd "S-<up>") #'scroll-down-line)
    (define-key eat-semi-char-mode-map (kbd "S-<down>") #'scroll-up-line)
    (define-key eat-semi-char-mode-map (kbd "S-<prior>") #'scroll-down-command)
    (define-key eat-semi-char-mode-map (kbd "S-<next>") #'scroll-up-command)))

;; Disable line numbers and hl-line in terminal modes
(dolist (mode '(eat-mode-hook vterm-mode-hook term-mode-hook shell-mode-hook eshell-mode-hook))
  (add-hook mode (lambda ()
                   (display-line-numbers-mode -1)
                   (setq-local global-hl-line-mode nil)
                   (hl-line-mode -1))))

;;; Language-specific

;; Elixir
(add-hook 'elixir-ts-mode-hook
          (lambda ()
            (add-hook 'before-save-hook
                      (lambda ()
                        (when (eq major-mode 'elixir-ts-mode)
                          (shell-command-to-string
                           (format "mix format %s" (buffer-file-name)))
                          (revert-buffer t t t)))
                      nil t)))

;; HEEx
(add-hook 'heex-ts-mode-hook
          (lambda ()
            (add-hook 'before-save-hook
                      (lambda ()
                        (when (eq major-mode 'heex-ts-mode)
                          (shell-command-to-string
                           (format "mix format %s" (buffer-file-name)))
                          (revert-buffer t t t)))
                      nil t)))

;; Emacs Lisp
(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            (setq indent-tabs-mode nil)
            (define-key emacs-lisp-mode-map (kbd "C-x C-e") 'pp-eval-last-sexp)
            (add-hook 'before-save-hook 'delete-trailing-whitespace nil t)))

;; Shell scripts
(add-hook 'sh-mode-hook
          (lambda ()
            (add-hook 'before-save-hook 'delete-trailing-whitespace nil t)))

;;; Project management
(setq project-vc-extra-root-markers
      '(".emacs-project"
        ".fslckout"
        ".jj"
        "mix.exs"))

(setq project-vc-ignores
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
        "tree-sitter"))

;;; Completion: Vertico + Orderless + Consult + Marginalia

;; Vertico: Vertical completion UI
(require 'vertico)
(setq vertico-cycle t
      vertico-resize nil
      vertico-count 20)
(vertico-mode)

;; vertico-directory: better file path navigation
(require 'vertico-directory)
(with-eval-after-load 'vertico
  (define-key vertico-map (kbd "RET") #'vertico-directory-enter)
  (define-key vertico-map (kbd "DEL") #'vertico-directory-delete-char)
  (define-key vertico-map (kbd "M-DEL") #'vertico-directory-delete-word))
(add-hook 'rfn-eshadow-update-overlay-hook #'vertico-directory-tidy)

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

;; Consult: Enhanced completion commands
;; Provides better versions of switch-to-buffer, grep, imenu, etc.
(require 'consult)

;; Integrate with xref (jump-to-definition)
(setq xref-show-xrefs-function #'consult-xref
      xref-show-definitions-function #'consult-xref)

;; Integrate with register preview
(setq register-preview-delay 0.5
      register-preview-function #'consult-register-format)
(advice-add #'register-preview :override #'consult-register-window)

;; C-x bindings (ctl-x-map)
(global-set-key (kbd "C-x b") 'consult-buffer)
(global-set-key (kbd "C-x 4 b") 'consult-buffer-other-window)
(global-set-key (kbd "C-x 5 b") 'consult-buffer-other-frame)
(global-set-key (kbd "C-x r b") 'consult-bookmark)

;; M-g bindings (goto-map)
(global-set-key (kbd "M-g e") 'consult-compile-error)
(global-set-key (kbd "M-g g") 'consult-goto-line)
(global-set-key (kbd "M-g M-g") 'consult-goto-line)
(global-set-key (kbd "M-g o") 'consult-outline)
(global-set-key (kbd "M-g m") 'consult-mark)
(global-set-key (kbd "M-g k") 'consult-global-mark)
(global-set-key (kbd "M-g i") 'consult-imenu)
(global-set-key (kbd "M-g I") 'consult-imenu-multi)

;; M-s bindings (search-map)
(global-set-key (kbd "M-s d") 'consult-find)
(global-set-key (kbd "M-s D") 'consult-locate)
(global-set-key (kbd "M-s g") 'consult-grep)
(global-set-key (kbd "M-s G") 'consult-git-grep)
(global-set-key (kbd "M-s r") 'consult-ripgrep)
(global-set-key (kbd "M-s l") 'consult-line)
(global-set-key (kbd "M-s L") 'consult-line-multi)
(global-set-key (kbd "M-s k") 'consult-keep-lines)
(global-set-key (kbd "M-s u") 'consult-focus-lines)

;; Other useful bindings
(global-set-key (kbd "M-y") 'consult-yank-pop)
(global-set-key (kbd "C-c h") 'consult-history)
(global-set-key (kbd "C-c m") 'consult-mode-command)
(global-set-key (kbd "C-c k") 'consult-kmacro)

;; Consult customization
(setq consult-narrow-key "<") ;; Use < for narrowing in consult commands

;; Use project.el for project-based commands
(setq consult-project-function #'consult--default-project-function)

;;; Perspective: Named workspaces
(setq persp-mode-prefix-key (kbd "M-j")
      persp-state-default-file nil)  ; disable auto-save/restore
(require 'perspective)
(persp-mode)

;;; Integration with consult-buffer
(with-eval-after-load 'consult
  (consult-customize consult--source-buffer :hidden t :default nil)
  (add-to-list 'consult-buffer-sources persp-consult-source))

;;; IRC (rcirc)
(setq rcirc-server-alist
      '(("irc.libera.chat"
         :port 6697
         :encryption tls
         :channels ("#freebsd" "#freebsd-ports" "#freebsd-emacs"
                    "#freebsd-python" "#freebsd-pulse" "#freebsd-dev"))))

;; Hide join/part/quit spam (toggle with C-c C-o)
(setq rcirc-omit-responses '("JOIN" "PART" "QUIT" "NICK" "AWAY"))
(add-hook 'rcirc-mode-hook 'rcirc-omit-mode)

;; Track channel activity (show channel names, no counts)
(setq rcirc-track-minor-mode-lighter " IRC"
      rcirc-track-show-activity-flag t)
(rcirc-track-minor-mode 1)
