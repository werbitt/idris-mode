;;; idris-commands.el --- Commands for Emacs passed to idris

;; Copyright (C) 2013 Hannes Mehnert

;; Author: Hannes Mehnert <hannes@mehnert.org>

;; License:
;; Inspiration is taken from SLIME/DIME (http://common-lisp.net/project/slime/) (https://github.com/dylan-lang/dylan-mode)
;; Therefore license is GPL

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING. If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

(require 'inferior-idris)
(require 'idris-repl)
(require 'idris-warnings)

(defun idris-load-file ()
  "Pass the current buffer's file to the inferior Idris process."
  (interactive)
  (save-buffer)
  (idris-warning-reset)
  (idris-repl-buffer)
  (idris-run)
  (if (buffer-file-name)
      (idris-eval-async `(:load-file ,(buffer-file-name))
                        (lambda (result)
                          (pop-to-buffer (idris-repl-buffer))
                          (message result)))
    (error "Cannot find file for current buffer")))

(defun string-no-properties (str)
  (substring-no-properties str 0 (length str)))

(defun idris-get-line-num ()
  "Get the current line number"
  (save-restriction
    (widen)
    (save-excursion
      (beginning-of-line)
      (1+ (count-lines 1 (point))))))

(defun idris-thing-at-point ()
  "Return the line number and name at point"
  (let ((name (symbol-at-point))
        (line (idris-get-line-num)))
    (if name
        (cons (string-no-properties (symbol-name name)) line)
      (error "Nothing identifiable under point"))))

(defun idris-type-at-point ()
  "Display the type of the name at point, considered as a global variable"
  (interactive)
  (let* ((name (car (idris-thing-at-point)))
         (result (idris-eval `(:type-of ,name))))
    (message "%s" result)))

(provide 'idris-commands)
