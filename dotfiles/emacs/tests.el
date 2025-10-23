(defun test-file-mode (file expected-mode)
  (write-region "" nil file) ; touch
  (find-file file)
  (if (eq major-mode expected-mode)
      ()
    (progn
      (error "%s: expected %s, got %s" file expected-mode major-mode)
      (kill-emacs 1))))

(test-file-mode "foo.c" 'c-ts-mode)
(test-file-mode "foo.ex" 'elixir-ts-mode)
(test-file-mode "foo.exs" 'elixir-ts-mode)
(test-file-mode "foo.md" 'markdown-mode)
;;(test-file-mode "foo.md" 'gfm-mode) ;; not sure what to do here
(test-file-mode "foo.heex" 'heex-ts-mode)
(test-file-mode "foo.go" 'go-ts-mode)
(test-file-mode "go.mod" 'go-mod-ts-mode)
(test-file-mode "foo.lua" 'lua-ts-mode)
(test-file-mode "foo.py" 'python-ts-mode)
(test-file-mode "foo.rs" 'rust-ts-mode)
(test-file-mode "foo.sh" 'bash-ts-mode) ; also for POSIX
;;(test-file-mode "foo.zig" 'zig-ts-mode) ;; need to install a mode
