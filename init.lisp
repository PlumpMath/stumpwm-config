;;; init.lisp --- Vital settings and loading other files

;; Copyright © 2013-2016 Alex Kost <alezost@gmail.com>

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This file should be symlinked by "~/.stumpwmrc".
;; I compile stumpwm with swank, so i don't need to load it.

;;; Code:

(in-package :stumpwm)

(defvar al/display-number
  (multiple-value-bind (_ array)
      (cl-ppcre:scan-to-strings ":([0-9]+)" (getenv "DISPLAY"))
    (declare (ignore _))
    (if (vectorp array)
        (parse-integer (aref array 0))
        0))
  "The number of the current DISPLAY.")

(swank:create-server
 :dont-close t
 :port (+ swank::default-server-port al/display-number))


;;; Loading additional rc files

(defvar al/init-directory
  (directory-namestring
   (truename (merge-pathnames (user-homedir-pathname)
                              ".stumpwmrc")))
  "A directory with initially loaded files.")

(defun al/load (filename)
  "Load a file FILENAME (without extension) from `al/init-directory'."
  (let ((file (merge-pathnames (concat filename ".lisp")
                               al/init-directory)))
    (if (probe-file file)
        (load file)
        (format *error-output* "File '~a' doesn't exist." file))))

(set-module-dir
 (pathname-as-directory (concat (getenv "HOME")
                                "/src/stumpwm-contrib")))
(al/load "keys")
(al/load "utils")
(al/load "layouts")
(al/load "mana")
(al/load "sound")
(al/load "settings")
(al/load "visual")

;;; init.lisp ends here
