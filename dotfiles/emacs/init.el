;; -*-no-byte-compile: t; -*-
(use-package emacs
  :init
  (add-to-list 'load-path (expand-file-name "packages/consult-2.2" user-emacs-directory))

  :bind
  ("M-RET" . project-find-file)
  ("M-i" . consult-imenu))

;; Consult - better search and navigation (consulting completing-read)
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
