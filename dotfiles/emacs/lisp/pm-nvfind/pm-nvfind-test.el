;;; pm-nvfind-test.el --- Tests for pm-nvfind -*- lexical-binding: t; -*-

(require 'ert)
(require 'pm-nvfind)

(defvar pm-nvfind-test--dir
  (file-name-directory (or load-file-name buffer-file-name)))

(defun pm-nvfind-test--fixtures ()
  "Return path to test fixtures directory."
  (concat pm-nvfind-test--dir "fixtures/"))

;;; Split query tests

(ert-deftest pm-nvfind-split-single-word ()
  (should (equal (pm-nvfind--split-query "foo") '("foo"))))

(ert-deftest pm-nvfind-split-multiple-words ()
  (should (equal (pm-nvfind--split-query "foo bar baz") '("foo" "bar" "baz"))))

(ert-deftest pm-nvfind-split-extra-spaces ()
  (should (equal (pm-nvfind--split-query "  foo   bar  ") '("foo" "bar"))))

(ert-deftest pm-nvfind-split-empty ()
  (should (null (pm-nvfind--split-query ""))))

;;; Integration tests using fixtures

(ert-deftest pm-nvfind-search-single-word-foo ()
  (let ((results (pm-nvfind--search (pm-nvfind-test--fixtures) "foo")))
    (should (= (length results) 2))
    (should (cl-some (lambda (f) (string-match-p "foo\\.md$" f)) results))
    (should (cl-some (lambda (f) (string-match-p "foo-bar\\.md$" f)) results))))

(ert-deftest pm-nvfind-search-single-word-bar ()
  (let ((results (pm-nvfind--search (pm-nvfind-test--fixtures) "bar")))
    (should (= (length results) 2))
    (should (cl-some (lambda (f) (string-match-p "bar\\.org$" f)) results))
    (should (cl-some (lambda (f) (string-match-p "foo-bar\\.md$" f)) results))))

(ert-deftest pm-nvfind-search-two-words ()
  (let ((results (pm-nvfind--search (pm-nvfind-test--fixtures) "bar foo")))
    (should (= (length results) 1))
    (should (string-match-p "foo-bar\\.md$" (car results)))))

(ert-deftest pm-nvfind-search-no-match ()
  (let ((results (pm-nvfind--search (pm-nvfind-test--fixtures) "nonexistent")))
    (should (null results))))

(ert-deftest pm-nvfind-search-empty-query ()
  (let ((results (pm-nvfind--search (pm-nvfind-test--fixtures) "")))
    (should (null results))))
