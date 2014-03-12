;;; epod.el ---

;; Copyright 2012 Sebastian Willert
;;
;; Author: willert@prometheus
;; Version: $Id: epod.el,v 0.0 2012/03/04 00:48:16 willert Exp $
;; Keywords:
;; X-URL: not distributed yet

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

;;; Commentary:

;;

;; Put this file into your load-path and the following into your ~/.emacs:
;;   (require 'epod)

;;; Code:

(provide 'epod)
(eval-when-compile
  (require 'cl))

(require 'w3m)


(setq w3m-use-toolbar nil)
(setq w3m-async-exec nil)
(setq w3m-use-tab nil)
(setq w3m-show-error-information t)
(setq w3m-use-header-line nil)


(let ((map (make-keymap)))
  (suppress-keymap map)
  (define-key map [backspace] 'w3m-scroll-down-or-previous-url)
  (define-key map [delete] 'w3m-scroll-down-or-previous-url)
  (define-key map "\C-?" 'w3m-scroll-down-or-previous-url)
  (define-key map "\t" 'w3m-next-anchor)
  (define-key map [(shift tab)] 'w3m-previous-anchor)
  (define-key map [(shift iso-left-tab)] 'w3m-previous-anchor)
  (define-key map "\C-m" 'w3m-view-this-url)
  (define-key map [(shift return)] 'w3m-view-this-url-new-session)
  (define-key map [(shift kp-enter)] 'w3m-view-this-url-new-session)
  (define-key map [(button2)] 'w3m-mouse-view-this-url)
  (define-key map [(shift button2)] 'w3m-mouse-view-this-url-new-session)
  (define-key map " " 'scroll-up)
  (define-key map "a" 'w3m-bookmark-add-current-url)
  (define-key map "\M-a" 'w3m-bookmark-add-this-url)
  (define-key map "+" 'w3m-antenna-add-current-url)
  (define-key map "A" 'w3m-antenna)
  (define-key map "c" 'w3m-print-this-url)
  (define-key map "C" 'w3m-print-current-url)
  (define-key map "d" 'w3m-download)
  (define-key map "D" 'w3m-download-this-url)
  ;; (define-key map "D" 'w3m-download-with-wget)
  ;; (define-key map "D" 'w3m-download-with-curl)
  (define-key map "g" 'w3m-goto-url)
  (define-key map "G" 'w3m-goto-url-new-session)
  (define-key map "h" 'describe-mode)
  (define-key map "H" 'w3m-gohome)
  (define-key map "I" 'w3m-toggle-inline-images)
  (define-key map "\M-i" 'w3m-save-image)
  (define-key map "M" 'w3m-view-url-with-external-browser)
  (define-key map "n" 'w3m-view-next-page)
  (define-key map "\M-n" 'w3m-view-next-page)
  (define-key map "N" 'w3m-namazu)
  (define-key map "o" 'w3m-history)
  (define-key map "O" 'w3m-db-history)
  (define-key map "p" 'w3m-view-previous-page)
  (define-key map "\M-p" 'w3m-view-previous-page)
  (define-key map "q" 'w3m-close-window)
  (define-key map "Q" 'w3m-quit)
  (define-key map "R" 'w3m-reload-this-page)
  (define-key map "s" 'w3m-search)
  (define-key map "S" (lambda ()
                        (interactive)
                        (let ((current-prefix-arg t))
                          (call-interactively 'w3m-search))))
  (define-key map "u" 'w3m-view-parent-page)
  (define-key map "v" 'w3m-bookmark-view)
  (define-key map "W" 'w3m-weather)
  (define-key map "=" 'w3m-view-header)
  (define-key map "\\" 'w3m-view-source)
  (define-key map "?" 'describe-mode)
  (define-key map ">" 'scroll-left)
  (define-key map "<" 'scroll-right)
  (define-key map "." 'beginning-of-buffer)
  (define-key map "^" 'w3m-view-parent-page)
  (define-key map "]" 'w3m-next-form)
  (define-key map "[" 'w3m-previous-form)
  (define-key map "}" 'w3m-next-image)
  (define-key map "{" 'w3m-previous-image)
  (define-key map "\C-c\C-c" 'w3m-submit-form)

  (setq epod/w3m-map map)
  )

(defvar epod-local-lib-dirs nil "Project or local lib directories to search.");
(defvar epod-module-history nil "History list of perl modules entered in the minibuffer.")

(defun epod/shell-command-to-string (&rest cmd)
  (replace-regexp-in-string
   "\r?\n$" ""
   (shell-command-to-string (concat (mapconcat 'identity cmd " ") " 2>/dev/null" ))))

(defun epod-perldoc ( module )
  "Display POD for module, defaulting to `cperl-word-at-point'."
  (interactive
   (list (read-string
          (format "Perl module [%s]: " (cperl-word-at-point))
          nil 'epod-module-history (cperl-word-at-point))))
  (add-hook 'w3m-mode-hook '(lambda () (use-local-map epod/w3m-map)) t t)
  (let ((url
         (mapconcat (lambda (e) e)
                    (list*
                     (format "perldoc:module?name=%s" module)
                     (mapcar
                      (lambda (e) (if e (format "include=%s" e)))
                      (let ((mist-libs (epod/shell-command-to-string "mist lib_paths")))
                        (if (> (length mist-libs) 0)
                            (split-string mist-libs)
                          ))))
                    "&")))
    (w3m-goto-url url)))




;;; epod.el ends here
