;;; pm-nvfind.el --- NValt-style full-text search using ripgrep -*- lexical-binding: t; -*-

;; Author: Pat Maddox
;; Keywords: search, notes

;;; Commentary:

;; Multi-word full-text file search using chained ripgrep.
;; Searching "foo bar" finds files containing both "foo" and "bar"
;; anywhere in the file, in any order.

;;; Code:

(defcustom pm-nvfind-scopes nil
  "Alist of named search scopes.
Each entry is (NAME . (DIR ...)) where NAME is a string
and each DIR is a directory path."
  :type '(alist :key-type string :value-type (repeat directory))
  :group 'pm-nvfind)

(defcustom pm-nvfind-default-scope nil
  "Default scope for `pm-nvfind'.
A scope name string or a list of scope name strings."
  :type '(choice string (repeat string))
  :group 'pm-nvfind)

(defun pm-nvfind--resolve-scopes (scope-names)
  "Resolve SCOPE-NAMES to a deduplicated list of directories.
SCOPE-NAMES is a list of scope name strings.
Returns the union of all directories across the named scopes."
  (let ((dirs '()))
    (dolist (name scope-names)
      (let ((scope (assoc name pm-nvfind-scopes)))
        (if scope
            (dolist (dir (cdr scope))
              (let ((expanded (expand-file-name dir)))
                (unless (member expanded dirs)
                  (push expanded dirs))))
          (error "pm-nvfind: unknown scope \"%s\"" name))))
    (nreverse dirs)))

(defun pm-nvfind--split-query (query)
  "Split QUERY string into a list of non-empty words."
  (split-string query " " t))

(defun pm-nvfind--build-rg-command (words directories)
  "Build a chained rg shell command from WORDS searching DIRECTORIES.
DIRECTORIES is a list of directory paths.
Returns a shell command string that pipes rg -l calls to find
files containing all WORDS.  Returns nil if WORDS is empty."
  (when words
    (let ((first (car words))
          (rest (cdr words))
          (dirs (mapconcat (lambda (d) (shell-quote-argument (expand-file-name d))) directories " ")))
      (concat "rg -l " (shell-quote-argument first)
              " " dirs
              (mapconcat (lambda (word)
                           (concat " | xargs rg -l " (shell-quote-argument word)))
                         rest "")))))

(defun pm-nvfind--search (directories query)
  "Search DIRECTORIES for files containing all words in QUERY.
DIRECTORIES is a list of directory paths.
Returns a list of matching file paths.
Signals an error if rg fails."
  (let* ((words (pm-nvfind--split-query query))
         (cmd (pm-nvfind--build-rg-command words directories)))
    (if cmd
        (with-temp-buffer
          (let ((exit-code (call-process-region nil nil shell-file-name nil t nil "-c" cmd)))
            (cond
             ((= exit-code 0)
              (split-string (buffer-string) "\n" t))
             ((= exit-code 1) ; rg returns 1 for no matches
              nil)
             (t
              (error "pm-nvfind: rg failed (exit %d): %s" exit-code (buffer-string))))))
      nil)))

(defun pm-nvfind-in (directory query)
  "Search DIRECTORY for files containing all words in QUERY.
Prompts for a directory and query, then opens the selected file."
  (interactive "DDirectory: \nsSearch: ")
  (let ((results (pm-nvfind--search (list directory) query)))
    (if results
        (find-file (completing-read "Open: " results nil t))
      (message "No matches for \"%s\"" query))))

(provide 'pm-nvfind)