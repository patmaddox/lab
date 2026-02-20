;;; pm-nvfind.el --- NValt-style full-text search using ripgrep -*- lexical-binding: t; -*-

;; Author: Pat Maddox
;; Keywords: search, notes

;;; Commentary:

;; Multi-word full-text file search using chained ripgrep.
;; Searching "foo bar" finds files containing both "foo" and "bar"
;; anywhere in the file, in any order.

;;; Code:

(defun pm-nvfind--split-query (query)
  "Split QUERY string into a list of non-empty words."
  (split-string query " " t))

(defun pm-nvfind--build-rg-command (words directory)
  "Build a chained rg shell command from WORDS searching DIRECTORY.
Returns a shell command string that pipes rg -l calls to find
files containing all WORDS.  Returns nil if WORDS is empty."
  (when words
    (let ((first (car words))
          (rest (cdr words)))
      (concat "rg -l " (shell-quote-argument first)
              " " (shell-quote-argument directory)
              (mapconcat (lambda (word)
                           (concat " | xargs rg -l " (shell-quote-argument word)))
                         rest "")))))

(defun pm-nvfind--search (directory query)
  "Search DIRECTORY for files containing all words in QUERY.
Returns a list of matching file paths."
  (let* ((words (pm-nvfind--split-query query))
         (cmd (pm-nvfind--build-rg-command words directory)))
    (if cmd
        (let ((output (shell-command-to-string cmd)))
          (split-string output "\n" t))
      nil)))

(provide 'pm-nvfind)