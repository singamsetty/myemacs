;;; package  --- whichkey-config.el
;;;
;;; Commentary:
;;;
;;; Filename   : whichkey-config.el
;;; Description: Emacs package that displays available keybindings in popup
;;;              https://github.com/justbur/emacs-which-key
;;; elisp code for customizing the which-key settings
;;;==========================================================================
(require 'which-key)
;;;
;;; Code:
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Emacs package that displays available keybindings in popup               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(which-key-mode +1)
;; set the time delay (in seconds) for the which-key popup to appear.
(setq which-key-idle-delay 0.4
      which-key-special-keys nil
      which-key-use-C-h-for-paging t
      which-key-prevent-C-h-from-cycling t
      which-key-echo-keystrokes 0.02
      which-key-max-description-length 32
      which-key-side-window-max-width 0.33
      which-key-sort-order 'which-key-key-order-alpha
      which-key-allow-evil-operators t
      ;; set the separator used between keys and descriptions.
      which-key-separator " → "
      ;; allow extra padding for Unicode character
      which-key-unicode-correction 3
      ;; for performance
      which-key-allow-imprecise-window-fit t
      which-key-key-replacement-alist '(("<\\([[:alnum:]-]+\\)>" . "\\1")
                                        ("left"                  . "◀")
                                        ("right"                 . "▶")
                                        ("up"                    . "▲")
                                        ("down"                  . "▼")
                                        ("delete"                . "DEL")   ;; delete
                                        ("\\`DEL\\'"             . "BS")    ;; backspace
                                        ("next"                  . "PgDn")
                                        ("prior"                 . "PgUp"))

      ;; List of "special" keys for which a KEY is displayed as just
      ;; K but with "inverted video" face
      which-key-special-keys '("RET" "DEL" ; delete key
                               "ESC" "BS" ; backspace key
                               "SPC" "TAB")
      ;; Underlines commands to emphasize some functions:
      which-key-highlighted-command-list
      '("\\(rectangle-\\)\\|\\(-rectangle\\)"
        "\\`org-"))


(push '(("\\(.*\\) 0" . "select-window-0") . ("\\1 0..9" . "window 0..9"))
      which-key-replacement-alist)
(push '((nil . "select-window-[1-9]") . t) which-key-replacement-alist)

(push '(("\\(.*\\) 1" . "buffer-to-window-1") . ("\\1 1..9" . "buffer to window 1..9"))
      which-key-replacement-alist)
(push '((nil . "buffer-to-window-[2-9]") . t) which-key-replacement-alist)


;; make the local map keys appear in bold
(set-face-attribute 'which-key-local-map-description-face nil :weight 'bold)

(provide 'whichkey-config)

;; Local Variables:
;; coding: utf-8
;; mode: emacs-lisp
;; End:

;;; whichkey-config.el ends here
