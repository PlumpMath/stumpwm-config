;;; sound.lisp --- Set sound parameters and show them in OSD

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

;; This file provides a couple of commands to set sound parameters
;; (volume and muteness).  It looks mostly like a wrapper around
;; 'amixer' command, except that 'osd-sound' is called instead.
;;
;; This 'osd-sound' is a simple shell script that sends some Guile
;; expression to Guile-Daemon <https://github.com/alezost/guile-daemon>.
;; 2 things eventually happen: amixer is called and the sound value is
;; displayed in OSD.
;;
;; 'osd-sound' script can be found in my Guile-Daemon config:
;; <https://github.com/alezost/guile-daemon-config/blob/master/scripts/osd-sound>.

;;; Code:

(in-package :stumpwm)

(defvar *sound-program* "osd-sound"
  "Name of a program to be called with amixer arguments.")

(defvar *sound-scontrols* '("Master" "Line")
  "List of simple controls for managing.")

(defvar *sound-current-scontrol-num* 0
  "The number of the currently used simple control.")

(defun sound-get-current-scontrol ()
  "Return the current simple control from `*sound-scontrols*'."
  (nth *sound-current-scontrol-num* *sound-scontrols*))

(defun sound-get-next-scontrol ()
  "Return next simple control from `*sound-scontrols*'."
  (setq *sound-current-scontrol-num*
        (if (>= *sound-current-scontrol-num*
                (- (length *sound-scontrols*) 1))
            0
            (+ 1 *sound-current-scontrol-num*)))
  (sound-get-current-scontrol))

(defun sound-call (&rest args)
  "Execute `*sound-program*' using amixer ARGS."
  (run-prog *sound-program*
            :args args :wait nil :search t))

(defcommand sound-set-current-scontrol (&rest args) (:rest)
  "Set sound value for the current simple control.
ARGS are the rest amixer arguments after 'sset CONTROL'."
  (apply #'sound-call "sset" (sound-get-current-scontrol) args))

(defcommand sound-current-scontrol () ()
  "Show sound value of the current simple control."
  (sound-call "sget" (sound-get-current-scontrol)))

(defcommand sound-next-scontrol () ()
  "Switch simple control and show its sound value."
  (sound-call "sget" (sound-get-next-scontrol)))

;;; sound.lisp ends here
