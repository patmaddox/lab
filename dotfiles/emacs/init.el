;; -*-no-byte-compile: t; -*-

;; Custom extensions
(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

;; Third-party packages (checked into repo under contrib/)
(dolist (dir (directory-files (expand-file-name "contrib" user-emacs-directory) t "^[^.]"))
  (when (file-directory-p dir)
    (add-to-list 'load-path dir)))

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
        (mhtml-mode . html-ts-mode)
        (java-mode . java-ts-mode)
        (js-mode . js-ts-mode)
        (json-mode . json-ts-mode)
        (python-mode . python-ts-mode)
        (ruby-mode . ruby-ts-mode)
        (sh-mode . bash-ts-mode)))

;; Built-in tree-sitter modes that need file associations
(add-to-list 'auto-mode-alist '("\\.cmake\\'" . cmake-ts-mode))
(add-to-list 'auto-mode-alist '("CMakeLists\\.txt\\'" . cmake-ts-mode))
(add-to-list 'auto-mode-alist '("\\(?:Dockerfile\\(?:\\..*\\)?\\|\\.[Dd]ockerfile\\)\\'" . dockerfile-ts-mode))
(add-to-list 'auto-mode-alist '("\\.ex\\'" . elixir-ts-mode))
(add-to-list 'auto-mode-alist '("\\.exs\\'" . elixir-ts-mode))
(add-to-list 'auto-mode-alist '("\\.go\\'" . go-ts-mode))
(add-to-list 'auto-mode-alist '("/go\\.mod\\'" . go-mod-ts-mode))
(add-to-list 'auto-mode-alist '("\\.heex\\'" . heex-ts-mode))
(add-to-list 'auto-mode-alist '("\\.lua\\'" . lua-ts-mode))
(add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-ts-mode))
(add-to-list 'auto-mode-alist '("\\.toml\\'" . toml-ts-mode))
(add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-ts-mode))
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))
(add-to-list 'auto-mode-alist '("\\.ya?ml\\'" . yaml-ts-mode))
(add-to-list 'auto-mode-alist '("\\.js\\'" . js-ts-mode))
(add-to-list 'auto-mode-alist '("\\.json\\'" . json-ts-mode))

;; Languages that do not have a built-in mode
(require 'markdown-mode)
(add-to-list 'auto-mode-alist '("\\.md\\'" . gfm-mode))

;;; UI/UX
(blink-cursor-mode -1)
(column-number-mode 1)
(electric-indent-mode 1)
(electric-pair-mode 1)
(global-display-line-numbers-mode 1)
(global-hl-line-mode 1)
(menu-bar-mode -1)
(tool-bar-mode -1)
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
; unlimited scrollback
(setq eat-term-scrollback-size nil)

;(require 'vterm)

;; eat configuration - make ESC work in vim while keeping M-x working
;; In GUI Emacs, <escape> is distinct from ESC (Meta prefix)
(with-eval-after-load 'eat
  ;; Make invisible cursor actually visible (otherwise can't see cursor in emacs mode)
  (setq eat-invisible-cursor-type '(box nil nil))

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

;; All programming modes
(add-hook 'prog-mode-hook
          (lambda ()
            (add-hook 'before-save-hook 'delete-trailing-whitespace nil t)))

;; C/C++ (FreeBSD style(9))
(require 'freebsd-style-ts)
(add-hook 'c-ts-mode-hook 'freebsd-c-style-ts)
(add-hook 'c++-ts-mode-hook 'freebsd-c-style-ts)

;; Elixir
(add-hook 'elixir-ts-mode-hook
          (lambda ()
            (add-hook 'after-save-hook
                      (lambda ()
                        (when (eq major-mode 'elixir-ts-mode)
                          (shell-command-to-string
                           (format "mix format %s" (buffer-file-name)))
                          (revert-buffer t t t)))
                      nil t)))

;; Elixir - HEEx
(add-hook 'heex-ts-mode-hook
          (lambda ()
            (add-hook 'before-save-hook
                      (lambda ()
                        (when (eq major-mode 'heex-ts-mode)
                          (shell-command-to-string
                           (format "mix format %s" (buffer-file-name)))
                          (revert-buffer t t t)))
                      nil t)))

;; Go (gofmt on save)
(add-hook 'go-ts-mode-hook
          (lambda ()
            (add-hook 'after-save-hook
                      (lambda ()
                        (when (eq major-mode 'go-ts-mode)
                          (shell-command-to-string
                           (format "gofmt -w %s" (buffer-file-name)))
                          (revert-buffer t t t)))
                      nil t)))

;; Rust (rustfmt on save)
(add-hook 'rust-ts-mode-hook
          (lambda ()
            (add-hook 'after-save-hook
                      (lambda ()
                        (when (eq major-mode 'rust-ts-mode)
                          (shell-command-to-string
                           (format "rustfmt %s" (buffer-file-name)))
                          (revert-buffer t t t)))
                      nil t)))

;; Emacs Lisp
(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            (setq indent-tabs-mode nil)
            (define-key emacs-lisp-mode-map (kbd "C-x C-e") 'pp-eval-last-sexp)))

;; JavaScript/TypeScript (2-space indent, JS convention)
(setq js-indent-level 2)
(setq typescript-ts-mode-indent-offset 2)

;; Shell scripts (FreeBSD style, detects shell from shebang)
(add-hook 'bash-ts-mode-hook 'freebsd-sh-style-ts)

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

;;; Version control: jj (Jujutsu)
(add-to-list 'load-path (expand-file-name "vendor/vc-jj" user-emacs-directory))
(require 'vc-jj)
(require 'project-jj)

(require 'pm-jj)
(global-set-key (kbd "C-c j l") #'pm-jj-log)
(global-set-key (kbd "C-c j a") #'pm-jj-actionable)
(global-set-key (kbd "C-c j b") #'pm-jj-blocked)
(global-set-key (kbd "C-c j B") #'pm-jj-blockers)

;;; Completion: Vertico + Orderless + Consult + Marginalia

;; Save minibuffer history across sessions
(savehist-mode 1)
(setq savehist-additional-variables '(kill-ring search-ring regexp-search-ring))

;; Vertico: Vertical completion UI
(require 'vertico)
(setq vertico-cycle t
      vertico-resize nil
      vertico-count 20)
(vertico-mode)

;; Prescient: Frequency and recency-based sorting
(require 'prescient)
(require 'vertico-prescient)
(vertico-prescient-mode 1)
(prescient-persist-mode 1)

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
(require 'consult-imenu)
(require 'consult-org)

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
  ;; Hide default buffer source, use perspective's instead
  (consult-customize consult-source-buffer :hidden t :default nil)
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

;;; Org-mode
(require 'org)
(require 'org-capture)

;; Set default notes file for quick capture
(setq org-default-notes-file (expand-file-name "~/safe/inbox.org"))

;; Todo keywords
(setq org-todo-keywords
      '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d)")))

;; Refile targets
(setq org-refile-targets '(("~/safe/files/pat.org" :maxlevel . 9)))

;; Agenda files
(setq org-agenda-files '("~/safe/files/pat.org"))

;; Tags
(setq org-tags-exclude-from-inheritance '("project"))

;; Show parent headings when viewing agenda items
(setq org-show-context-detail '((agenda . lineage)
                                 (default . ancestors)))

;; Stuck projects configuration
(setq org-stuck-projects
      '("+project-someday" ("TODO" "NEXT") nil ""))

;; Helper function to add counts to agenda section headers
(defun pm/org-agenda-add-item-counts ()
  "Add item counts to section headers in the agenda buffer.
Sections are identified as lines starting at column 0 ending with ':'.
Items are identified as indented lines (starting with whitespace)."
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "^\\(.+\\):[ \t]*$" nil t)
      (let* ((header-name (match-string 1))
             (match-start (match-beginning 0))
             (match-end (match-end 0))
             (section-start (point))
             (section-end (save-excursion
                            (if (re-search-forward "^[^ \t\n]" nil t)
                                (match-beginning 0)
                              (point-max))))
             (item-count 0))
        (save-excursion
          (goto-char section-start)
          (forward-line 1)
          (while (and (< (point) section-end)
                      (not (eobp)))
            (when (looking-at "^[ \t]+[^ \t\n]")
              (setq item-count (1+ item-count)))
            (forward-line 1)))
        (goto-char match-start)
        (delete-region match-start match-end)
        (insert (format "%s (%d):" header-name item-count))))))

;; Custom agenda views
(setq org-agenda-custom-commands
      '(("w" "Workflow view"
         ((todo "NEXT"
                ((org-agenda-overriding-header "Next Actions:")))
          (stuck ""
                 ((org-agenda-overriding-header "Stalled Projects:")))
          (todo "TODO"
                ((org-agenda-overriding-header "Todo Items:")
                 (org-agenda-skip-function
                  '(org-agenda-skip-entry-if 'regexp ":someday:")))))
         ((org-agenda-finalize-hook '(pm/org-agenda-add-item-counts))))))

;; Define capture templates
(setq org-capture-templates
      '(("t" "Todo" entry (file org-default-notes-file)
         "* TODO %?\n%i")
        ("n" "Note" entry (file org-default-notes-file)
         "* %?\n%i")))

;; Global keybinding for quick capture
(global-set-key (kbd "C-c c") 'org-capture)

;; Use consult-style hierarchical completion for refiling
(setq org-refile-use-outline-path 'file
      org-outline-path-complete-in-steps nil)

;; Auto-save destination buffer after refiling
(add-hook 'org-after-refile-insert-hook 'save-buffer)

(require 'pm-nirvana)

;; pm-nvfind: nvALT-style search
(add-to-list 'load-path (expand-file-name "lisp/pm-nvfind" user-emacs-directory))
(require 'pm-nvfind)

(setq pm-nvfind-scopes
      '(("doc" . ("~/lab.jj/doc"))
        ("infra" . ("~/lab.jj/infra"))
        ("freebsd-man" . ("~/lab.jj/oss/freebsd-src/main.jj/share/man"))))

(setq pm-nvfind-default-scope "doc")

;;; Claude Code
;; Claude Code sessions run inside a FreeBSD jail via a wrapper script
;; (lisp/claude-code/claude-jail.sh) using the eat terminal backend.
;;
;; Commands (all via M-x):
;;   claude-code            - start a Claude session in default-directory
;;   claude-code-send-region - send the selected region to the session
;;   claude-code-send-buffer - send the entire buffer to the session
;;   claude-code-new-instance - open an additional concurrent session
(add-to-list 'load-path (expand-file-name "vendor/claude-code" user-emacs-directory))
(add-to-list 'load-path (expand-file-name "vendor/inheritenv" user-emacs-directory))
(require 'claude-code)
(setq claude-code-terminal-backend 'eat)
(setq claude-code-display-window-fn
      (lambda (buffer) (pop-to-buffer-same-window buffer) (selected-window)))
(setq claude-code-program
      (expand-file-name "lisp/claude-code/claude-jail.sh" user-emacs-directory))
;; Restore C-g to normal Emacs behavior (upstream binds it to send ESC)
(add-hook 'claude-code-start-hook
          (lambda ()
            (define-key (current-local-map) (kbd "C-g") nil)))

(defun claude-code-oneshot ()
  "Run Claude with -p flag on region or prompted input.
If a region is active, send the region text.  Otherwise prompt for input.
Output streams into a new buffer displayed immediately."
  (interactive)
  (let* ((input (if (use-region-p)
                    (buffer-substring-no-properties (region-beginning) (region-end))
                  (read-string (format "Prompt [%s]: " (abbreviate-file-name default-directory)))))
         (buf (generate-new-buffer "*claude-oneshot*"))
         (proc (start-process "claude-oneshot" buf claude-code-program "-p" input)))
    (with-current-buffer buf
      (insert "--- claude-oneshot running ---\n\n"))
    (set-process-filter proc
      (lambda (p output)
        (when (buffer-live-p (process-buffer p))
          (with-current-buffer (process-buffer p)
            (goto-char (point-max))
            (insert (replace-regexp-in-string
                     "\r\\|\033\\[[?<>=!0-9;]*[a-zA-Z-~]\\|\033\\][^\007]*\007" ""
                     output))))))
    (set-process-sentinel proc
      (lambda (p _event)
        (when (eq (process-status p) 'exit)
          (when (buffer-live-p (process-buffer p))
            (with-current-buffer (process-buffer p)
              (goto-char (point-max))
              (insert "\n--- done ---\n"))))))
    (display-buffer buf)))

(defun claude-code-oneshot-kill-all ()
  "Kill all *claude-oneshot* buffers."
  (interactive)
  (let ((killed 0))
    (dolist (buf (buffer-list))
      (when (string-prefix-p "*claude-oneshot*" (buffer-name buf))
        (kill-buffer buf)
        (setq killed (1+ killed))))
    (message "Killed %d oneshot buffer(s)" killed)))

(defun claude-code-draft-reply (beg end)
  "Create a reply buffer with the region quoted like an email.
Copies the region between BEG and END, deletes trailing whitespace,
and prefixes every line with \"> \"."
  (interactive "r")
  (let ((text (buffer-substring-no-properties beg end))
        (dir default-directory)
        (buf (generate-new-buffer "*claude-draft-reply*")))
    (with-current-buffer buf
      (setq default-directory dir)
      (insert text)
      (delete-trailing-whitespace)
      (goto-char (point-min))
      (while (not (eobp))
        (insert "> ")
        (forward-line 1))
      (goto-char (point-min)))
    (switch-to-buffer buf)))

(global-set-key (kbd "C-c l c") 'claude-code-send-region)
(global-set-key (kbd "C-c l d") 'claude-code-draft-reply)
(global-set-key (kbd "C-c l o") 'claude-code-oneshot)
