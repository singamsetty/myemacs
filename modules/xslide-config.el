;;; package  --- xslide-config.el
;;;
;;; Commentary:
;;;
;;; Filename   : xslide-config.el
;;; Description: Emacs major mode for editing XSL stylesheets
;;; elisp code for customizing the xslide settings
;;;==========================================================================
;;;
;;; Code:
;;;
(autoload 'xsl-mode "xslide" "Major mode for XSL stylesheets." t)

;; Uncomment if you want to use `xsl-grep' outside of XSL files.
;(autoload 'xsl-grep "xslide" "Grep for PATTERN in files matching FILESPEC." t)

;; Uncomment if you want to use `xslide-process' in `xml-mode'.
;(autoload 'xsl-process "xslide-process" "Process an XSL stylesheet." t)
;(add-hook 'xml-mode-hook
;     (lambda ()
;       (define-key xml-mode-map [(control c) (meta control p)]
;         'xsl-process)))

;; Turn on font lock when in XSL mode
(add-hook 'xsl-mode-hook
      'turn-on-font-lock)

(setq auto-mode-alist
      (append
       (list
    '("\\.fo" . xsl-mode)
    '("\\.xsl" . xsl-mode))
       auto-mode-alist))

;; Uncomment if using abbreviations
(abbrev-mode t)

(provide 'xslide-config)

;; Local Variables:
;; coding: utf-8
;; mode: emacs-lisp
;; End:

;;; xslide-config.el ends here
