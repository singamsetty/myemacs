;; File              : hippie-config.el
;; Author            : Sampath Singamsetty <Singamsetty.Sampat@gmail.com>
;; Date              : 12.04.2019
;; Last Modified Date: 12.04.2019
;; Last Modified By  : Sampath Singamsetty <Singamsetty.Sampat@gmail.com>
;;; package  --- hippie-config.el
;;;
;;; Commentary:
;;;
;;; Filename   : hippie-config.el
;;; Description: Modular hippie expand configuration for Emacs
;;;
;;;
;;; elisp code for customizing the hippie expansion
;;;
;;; Code:
;;;

(global-set-key (kbd "C-c /") 'hippie-expand)

(setq hippie-expand-try-functions-list
      '(
        ;; Try to expand word "dynamically", searching the current buffer.
        try-expand-dabbrev
        ;; Try to expand word "dynamically", searching all other buffers.
        try-expand-dabbrev-all-buffers
        ;; Try to expand word "dynamically", searching the kill ring.
        try-expand-dabbrev-from-kill
        ;; Try to complete text as a file name, as many characters as unique.
        try-complete-file-name-partially
        ;; Try to complete text as a file name.
        try-complete-file-name
        ;; Try to expand word before point according to all abbrev tables.
        try-expand-all-abbrevs
        ;; Try to complete the current line to an entire line in the buffer.
        try-expand-list
        ;; Try to complete the current line to an entire line in the buffer.
        try-expand-line
        ;; Try to complete as an Emacs Lisp symbol, as many characters as
        ;; unique.
        try-complete-lisp-symbol-partially
        ;; Try to complete word as an Emacs Lisp symbol.
        try-complete-lisp-symbol))

(provide 'hippie-config)

;; Local Variables:
;; coding: utf-8
;; mode: emacs-lisp
;; byte-compile-warnings: (not cl-functions)
;; End:

;;; hippie-config.el ends here
