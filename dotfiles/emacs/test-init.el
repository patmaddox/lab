;; settings used only in test mode

;; use-package will lazily load things when possible, leading to a
;; config that might not actually work. Force all packages to load
;; when emacs does.
(setq use-package-always-demand t)
