;;; package  --- neotree-config.el
;;; -*- coding: utf-8 -*-
;;;
;;; Commentary:
;;;
;;; Filename: neotree-config.el
;;; Description: Emacs tree plugin like NerdTree for Vim
;;;              configuration file for neotree custom settings.
;;;
;;; elisp code for customizing the neotree settings
;;;
;;; Code:
;;;
;;;===========================================================================
(require 'neotree)
(require 'all-the-icons) ; collect various Icon Fonts and propertize them within Emacs

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; a tree plugin like NerdTree for Vim (themes and modes)                   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq neo-theme (if (display-graphic-p) 'icons 'arrow))
(custom-set-faces
 '(neo-banner-face ((t . (:inherit shadow))) t)
 '(neo-header-face ((t . (:inherit shadow))) t)
 '(neo-root-dir-face ((t . (:inherit link-visited :underline nil))) t)
 '(neo-dir-link-face ((t . (:inherit dired-directory))) t)
 '(neo-file-link-face ((t . (:inherit default))) t)
 '(neo-button-face ((t . (:inherit dired-directory))) t)
 '(neo-expand-btn-face ((t . (:inherit button))) t))

(provide 'neotree-config)

;; Local Variables:
;; coding: utf-8
;; mode: emacs-lisp
;; byte-compile-warnings: (not cl-functions)
;; End:

;;; neotree-config.el ends here
