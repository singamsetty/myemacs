;;; package  --- nxml-config.el
;;; -*- coding: utf-8 -*-
;;;
;;; Commentary:
;;;
;;; Filename   : nxml-config.el
;;; Description: Editing XML in Emacs
;;;
;;; elisp code for customizing the nxml settings
;;; http://lgfang.github.io/mynotes/emacs/emacs-xml.html
;;;
;;; Code:
;;;

(require 'cl)
(require 'nxml-mode)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; nXML mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-to-list 'auto-mode-alist
             (cons (concat "\\." (regexp-opt
                                  '("xml" "xsd" "sch" "rng"
                                    "svg" "rss"
                                    "jelly" "jnlp" "fo"
                                    ) t)
                           "\\'") 'nxml-mode))

(unify-8859-on-decoding-mode)

(when (> emacs-major-version 21)
  (setq magic-mode-alist
        (cons '("<\\?xml " . nxml-mode) magic-mode-alist)))

;; if first line of file matches, activate nxml-mode
(add-to-list 'magic-mode-alist
             '("<!DOCTYPE html .+DTD XHTML .+>" . nxml-mode) )

(fset 'xml-mode 'nxml-mode)
;;(fset 'html-mode 'nxml-mode)
(require 'rng-loc nil t)

;; pom files should be treated as xml files
(add-to-list 'auto-mode-alist '("\\.pom$" . nxml-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; encoding, auto complete etc...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq nxml-slash-auto-complete-flag t             ; </ to complete
      nxml-bind-meta-tab-to-complete-flag t       ; M-Tab to complete
      nxml-auto-insert-xml-declaration-flag t
      nxml-child-indent 4
      nxml-attribute-indent 4
      nxml-default-buffer-file-coding-system 'utf-8)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; indentation setup for xml ref: https://www.emacswiki.org/emacs/CustomizeAquamacs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun sgml-mode-indent-setup ()
   (setq sgml-basic-offset 4))

 (defun nxml-mode-indent-setup ()
   (setq nxml-child-indent 4))

(add-hook 'nxml-mode-hook 'nxml-mode-indent-setup)
(add-hook 'sgml-mode-hook 'sgml-mode-indent-setup)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; company-nxml
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(after 'company
  (defun my-company-nxml-settings ()
    "Add company backends for xml."
    (setq-local company-minimum-prefix-length 1)
    (add-to-list (make-local-variable 'company-backends)
                 'company-nxml))
  (add-hook 'nxml-mode-hook 'my-company-nxml-settings))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; hide show
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-to-list 'hs-special-modes-alist
             '(nxml-mode
               "<!--\\|<[^/>]*[^/]>" ;; regexp for start block
               "-->\\|</[^/>]*[^/]>" ;; regexp for end block
               "<!--"
               nxml-forward-element
               nil))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; xpath display where are we in buffer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun nxml-where ()
  "Display the hierarchy of XML elements the point is on as a path, from http://www.emacswiki.org/emacs/NxmlMode."
  (interactive)
  (let ((path nil))
    (save-excursion
      (save-restriction
        (widen)
        (while
            (and (< (point-min) (point)) ;; Doesn't error if point is at
                                         ;; beginning of buffer
                 (condition-case nil
                     (progn
                       (nxml-backward-up-element) ; always returns nil
                       t)
                   (error nil)))
          ;; (setq path (cons (xmltok-start-tag-local-name) path))
          (setq path
                (cons
                 (if (xmltok-start-tag-prefix)
                     (concat (xmltok-start-tag-prefix) ":"
                             (xmltok-start-tag-local-name))
                   (xmltok-start-tag-local-name))
                 path)))
        (if (called-interactively-p t)
            (message "/%s" (mapconcat 'identity path "/"))
          (format "/%s" (mapconcat 'identity path "/")))))))


(after "nxml-mode"
  '(progn
     (defun nxml-which-xpath ()
       (let (path)
         (save-excursion
           (save-restriction
             (widen)
             (while (condition-case nil
                        (progn
                          (nxml-backward-up-element)
                          t)
                      (error nil))
               (push (xmltok-start-tag-local-name) path)))
           (concat "/" (mapconcat 'identity path "/")))))

     (after "which-func"
       '(pushnew #'nxml-which-xpath which-func-functions))))

(defun tidy-up-xml()
  (interactive)
  (goto-char 0)
  (replace-string "><" ">
<")
  (indent-region (point-min) (point-max)))
(local-set-key (kbd "C-x t") 'tidy-up-xml)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; [ x-path-walker ] -- navigation for JSON/XML/HTML based on path (imenu like)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package x-path-walker
  :ensure t
  :defer t
  :config
  (dolist (hook '(html-mode-hook
                  web-mode-hook
                  nxml-mode-hook
                  json-mode-hook))
    (add-hook hook
              (lambda ()
                (local-set-key (kbd "C-c C-j") 'helm-x-path-walker)))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; key-bindings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun lgfang-toggle-level ()
  "Mainly to be used in nxml mode."
  (interactive) (hs-show-block) (hs-hide-level 1))
(eval-after-load "nxml-mode"
  '(progn
     (define-key nxml-mode-map (kbd "M-'") 'lgfang-toggle-level)
     (define-key nxml-mode-map [mouse-3] 'lgfang-toggle-level)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; format xml data with xmllint
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun format-xml ()
  "Format an XML buffer with `xmllint'."
  (interactive)
  (shell-command-on-region (point-min) (point-max)
                           "/usr/bin/xmllint -format -"
                           (current-buffer) t
                           "*Xmllint Error Buffer*" t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; for auto-complete of nXml
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'auto-complete-nxml nil t)
;; customize
;; Keystroke for popup help about something at point.
;(setq auto-complete-nxml-popup-help-key "C-:")
;; Keystroke for toggle on/off automatic completion.
;(setq auto-complete-nxml-toggle-automatic-key "C-c C-t")
;; If you want to start completion manually from the beginning
(setq auto-complete-nxml-automatic-p nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(provide 'nxml-config)

;; Local Variables:
;; coding: utf-8
;; mode: emacs-lisp
;; byte-compile-warnings: (not cl-functions)
;; End:

;;; nxml-config.el ends here
