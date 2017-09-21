;;; package  --- flyspell-config.el
;;; -*- coding: utf-8 -*-
;;;
;;; Commentary:
;;;
;;; Filename   : flyspell-config.el
;;; Description: Emacs enable spell checking for comments & text
;;;              spell checking on the fly.
;;;===========================================================================
(require 'flyspell)                                           ; flyspell mode
(require 'flyspell-lazy)

;;;
;;; Code:
;;;
(setq flyspell-issue-message-flg nil)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;           find aspell load                                             ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq ispell-program-name "/usr/local/bin/aspell"
      ispell-dictionary "american" ; better for aspell
      ispell-extra-args '("--sug-mode=ultra" "--lang=en_US")
      ispell-list-command "--list")

(defun enable-flyspell ()
  "Enable command `flyspell-mode' if `prelude-flyspell' is not nil."
  (when (and prelude-flyspell (executable-find ispell-program-name))
    (flyspell-mode +1)))

(add-to-list 'ispell-local-dictionary-alist '(nil
                                              "[[:alpha:]]"
                                              "[^[:alpha:]]"
                                              "['‘’]"
                                              t
                                              ("-d" "en_US")
                                              nil
                                              utf-8))

(with-eval-after-load 'flyspell
    (require 'flyspell-lazy)
    (flyspell-lazy-mode 1)
    (setq ;; Be a little more aggressive than the lazy defaults
     flyspell-lazy-idle-seconds 2 ;; This scans just the recent changes
     flyspell-lazy-window-idle-seconds 6 ;; This scans the whole window
     ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; flyspell checking for comments and text mode                             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(if (fboundp 'prog-mode)
    (add-hook 'prog-mode-hook 'flyspell-prog-mode)

  (dolist (hook '(text-mode-hook org-mode-hook))
    (add-hook hook (lambda () (flyspell-mode 1))))

  (dolist (hook '(change-log-mode-hook log-edit-mode-hook org-agenda-mode-hook))
    (add-hook hook (lambda () (flyspell-mode -1))))

  ;; (dolist (hook '(lisp-mode-hook
  ;;                 emacs-lisp-mode-hook
  ;;                 clojure-mode-hook
  ;;                 yaml-mode
  ;;                 python-mode-hook
  ;;                 haskell-mode-hook
  ;;                 javascript-mode-hook
  ;;                 erlang-mode-hook
  ;;                 go-mode-hook
  ;;                 c++-mode-hook
  ;;                 c-mode-hook
  ;;                 shell-mode-hook
  ;;                 css-mode-hook
  ;;                 html-mode-hook
  ;;                 nxml-mode-hook
  ;;                 LaTeX-mode-hook
  ;;                 markdown-mode-hook))
  ;;   (add-hook hook 'flyspell-prog-mode))
  )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; improve performance by not printing messages for every word              ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq flyspell-issue-message-flag nil
      flyspell-issue-welcome-flag nil
      flyspell-use-meta-tab nil)

;; Don't consider that a word repeated twice is an error
(setq flyspell-mark-duplications-flag nil)
;; Lower (for performance reasons) the maximum distance for finding
;; duplicates of unrecognized words (default: 400000)
(setq flyspell-duplicate-distance 12000)
;; Dash character (`-') is considered as a word delimiter
(setq flyspell-consider-dash-as-word-delimiter-flag t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(provide 'flyspell-config)
;;; flyspell-config.el ends here
