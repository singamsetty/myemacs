;;; package  --- flyspell-config.el
;;; -*- coding: utf-8 -*-
;;;
;;; Commentary:
;;;
;;; Filename   : flyspell-config.el
;;; Description: Emacs enable spell checking for comments & text
;;;              spell checking on the fly.
;;;
;;; Code:
;;;
;;;

;; {{ flyspell setup for web-mode
(defun web-mode-flyspell-verify ()
  "Flyspell veriification setup for web-mode."
  (let* ((f (get-text-property (- (point) 1) 'face))
         rlt)
    (cond
     ;; Check the words with these font faces, possibly.
     ;; This *blacklist* will be tweaked in next condition
     ((not (memq f '(web-mode-html-attr-value-face
                     web-mode-html-tag-face
                     web-mode-html-attr-name-face
                     web-mode-constant-face
                     web-mode-doctype-face
                     web-mode-keyword-face
                     web-mode-comment-face ;; focus on get html label right
                     web-mode-function-name-face
                     web-mode-variable-name-face
                     web-mode-css-property-name-face
                     web-mode-css-selector-face
                     web-mode-css-color-face
                     web-mode-type-face
                     web-mode-block-control-face)))
      (setq rlt t))
     ;; check attribute value under certain conditions
     ((memq f '(web-mode-html-attr-value-face))
      (save-excursion
        (search-backward-regexp "=['\"]" (line-beginning-position) t)
        (backward-char)
        (setq rlt (string-match "^\\(value\\|class\\|ng[A-Za-z0-9-]*\\)$"
                                (thing-at-point 'symbol)))))
     ;; finalize the blacklist
     (t
      (setq rlt nil)))
    rlt))
(put 'web-mode 'flyspell-mode-predicate 'web-mode-flyspell-verify)
;; }}

;; {{ flyspell setup for js2-mode
(defun js-flyspell-verify ()
  "Flyspell verification setup for js mode."
  (let* ((f (get-text-property (- (point) 1) 'face)))
    ;; *whitelist*
    ;; only words with following font face will be checked
    (memq f '(js2-function-call
              js2-function-param
              js2-object-property
              font-lock-variable-name-face
              font-lock-string-face
              font-lock-function-name-face
              font-lock-builtin-face
              rjsx-tag
              rjsx-attr))))
(put 'js2-mode 'flyspell-mode-predicate 'js-flyspell-verify)
(put 'rjsx-mode 'flyspell-mode-predicate 'js-flyspell-verify)
;; }}

(use-package flyspell-lazy
  :config
  (flyspell-lazy-mode 1)
  :custom
  (flyspell-lazy-changes-threshold 10)
  (flyspell-lazy-idle-seconds 1)
  (flyspell-lazy-less-feedback t)
  (flyspell-lazy-mode t)
  (flyspell-lazy-size-threshold 5)
  (flyspell-lazy-use-flyspell-word nil)
  (flyspell-lazy-window-idle-seconds 3))

;; improve performance by not printing messages for every word
(setq flyspell-issue-message-flag nil
      flyspell-issue-welcome-flag nil
      flyspell-use-meta-tab nil)

;; if (aspell is installed) { use aspell}
;; else if (hunspell is installed) { use hunspell }
;; whatever spell checker is active, always use English dictionary
;; aspell can be a better choice as:
;; 1. aspell is older
;; 2. looks Kevin Atkinson still get some road map for aspell:
;; @see http://lists.gnu.org/archive/html/aspell-announce/2011-09/msg00000.html
(defun flyspell-detect-ispell-args (&optional run-together)
  "If RUN-TOGETHER is true, spell check the CamelCase words.
Please note RUN-TOGETHER will make aspell less capable.  So it should only be used in `prog-mode-hook'"
  (let (args)
    (when ispell-program-name
      (cond
       ((string-match "aspell$" ispell-program-name)
        ;; force the English dictionary, support Camel Case spelling check (tested with aspell 0.6)
        (setq args (list "--sug-mode=ultra" "--lang=en_US"))
        (if run-together
            (setq args (append args '("--run-together" "--run-together-limit=16" "--run-together-min=2")))))
       ((string-match "hunspell$" ispell-program-name)
        (setq args nil))))
    args))

;; @ref redguard
;; Aspell Setup (recommended):
;; Skipped because it's easy.
;;
;; Hunspell Setup:
;; 1. Install hunspell from http://hunspell.sourceforge.net/
;; 2. Download openoffice dictionary extension from
;; http://extensions.openoffice.org/en/project/english-dictionaries-apache-openoffice
;; 3. That is download `dict-en.oxt'. Rename that to `dict-en.zip' and unzip
;; the contents to a temporary folder.
;; 4. Copy `en_US.dic' and `en_US.aff' files from there to a folder where you
;; save dictionary files; I saved it to `~/usr_local/share/hunspell/'
;; 5. Add that path to shell env variable `DICPATH':
;; setenv DICPATH $MYLOCAL/share/hunspell
;; 6. Restart emacs so that when hunspell is run by ispell/flyspell, that env
;; variable is effective.
;;
;; hunspell will search for a dictionary called `en_US' in the path specified by
;; `$DICPATH'

(cond
 ((executable-find "aspell")
  (setq ispell-program-name "aspell"))
 ((executable-find "hunspell")
  (setq ispell-program-name "hunspell")
  (setq ispell-local-dictionary "en_US")
  (setq ispell-local-dictionary-alist
        '(("en_US" "[[:alpha:]]" "[^[:alpha:]]" "[']" nil ("-d" "en_US") nil utf-8))))
 (t (setq ispell-program-name nil)
    (message "You need install either aspell or hunspell for ispell")))

;; `ispell-cmd-args' contains *extra* arguments appending to CLI process
;; when (ispell-send-string). Useless!
;; `ispell-extra-args' is *always* used when start CLI aspell process
(setq-default ispell-extra-args (flyspell-detect-ispell-args t))
;; (setq ispell-cmd-args (flyspell-detect-ispell-args))
(defadvice ispell-word (around my-ispell-word activate)
  (let ((old-ispell-extra-args ispell-extra-args))
    (ispell-kill-ispell t)
    ;; use emacs original arguments
    (setq ispell-extra-args (flyspell-detect-ispell-args))
    ad-do-it
    ;; restore our own ispell arguments
    (setq ispell-extra-args old-ispell-extra-args)
    (ispell-kill-ispell t)))

(defadvice flyspell-auto-correct-word (around my-flyspell-auto-correct-word activate)
  (let* ((old-ispell-extra-args ispell-extra-args))
    (ispell-kill-ispell t)
    ;; use emacs original arguments
    (setq ispell-extra-args (flyspell-detect-ispell-args))
    ad-do-it
    ;; restore our own ispell arguments
    (setq ispell-extra-args old-ispell-extra-args)
    (ispell-kill-ispell t)))

(defun text-mode-hook-setup ()
  "Turn off RUN-TOGETHER option when spell check `text-mode'."
  (setq-local ispell-extra-args (flyspell-detect-ispell-args)))
(add-hook 'text-mode-hook 'text-mode-hook-setup)

;; Add auto spell-checking in comments for all programming language modes
;; if and only if there is enough memory, you may use prog-mode-hook instead.
(defun can-enable-flyspell-mode ()
  "Enable flyspell mode based on the program availability."
  (and (not *no-memory*)
       ispell-program-name
       (executable-find ispell-program-name)))

(defun enable-flyspell-mode-conditionally ()
  "Conditionally enable FlySpell."
  (if (can-enable-flyspell-mode)
      (flyspell-mode 1)))

;; turn on flyspell-mode for programming languages
(if (can-enable-flyspell-mode)
    (add-hook 'prog-mode-hook 'flyspell-prog-mode))

;; you can also use "M-x ispell-word" or hotkey "M-$". It pops up a multi choice
;; @see http://frequal.com/Perspectives/EmacsTip03-FlyspellAutoCorrectWord.html
(global-set-key (kbd "C-c s") 'flyspell-auto-correct-word)

;; {{ avoid spell-checking doublon (double word) in certain major modes
(defvar flyspell-check-doublon t
  "Check doublon (double word) when calling `flyspell-highlight-incorrect-region'.")
 (make-variable-buffer-local 'flyspell-check-doublon)

(defadvice flyspell-highlight-incorrect-region (around flyspell-highlight-incorrect-region-hack activate)
  "Highlight the incorrect words."
  (if (or flyspell-check-doublon (not (eq 'doublon (ad-get-arg 2))))
      ad-do-it))
;; }}

(defun my-clean-aspell-dict ()
  "Clean ~/.aspell.pws (dictionary used by aspell)."
  (interactive)
  (let* ((dict (file-truename "~/.aspell.en.pws"))
         (lines (read-lines dict))
         ;; sort words
         (aspell-words (sort (cdr lines) 'string<)))
    (with-temp-file dict
      (insert (format "%s %d\n%s"
                      "personal_ws-1.1 en"
                      (length aspell-words)
                      (mapconcat 'identity aspell-words "\n"))))))

;; Using Helm with flyspell
(after "flyspell-correct-helm"
  (setq flyspell-correct-interface #'flyspell-correct-helm)
  ;;(define-key flyspell-mode-map (kbd "<f8>") 'helm-flyspell-correct)
  )

;; flyspell popup configuration
(require-package 'flyspell-correct-popup)
(setq flyspell-correct-interface #'flyspell-correct-popup)

(require-package 'flyspell-popup)
;;(define-key flyspell-mode-map (kbd "C-:") #'flyspell-popup-correct)
;;(setq flyspell-popup-correct-delay 1.0)
(add-hook 'flyspell-mode-hook #'flyspell-popup-auto-correct-mode)

;; flyspell line styles
;; (custom-set-faces
;;  '(flyspell-duplicate ((t (:underline (:color "Blue" :style wave)))))
;;  '(flyspell-incorrect ((t (:underline (:color "Purple" :style wave))))))

(after 'flyspell
  (set-face-attribute 'flyspell-duplicate nil
                      :foreground "white"
                      :background "orange" :box t :underline t)
  (set-face-attribute 'flyspell-incorrect nil
                      :foreground "white"
                      :background "red" :box t :underline t))


;;** auto dictionary switcher for flyspell
(after 'flyspell
  (require-package 'auto-dictionary)
  (require 'auto-dictionary)
  ;;(add-hook 'flyspell-mode-hook (lambda () (auto-dictionary-mode 1)))
  (add-hook 'auto-dictionary-mode-hook
            (lambda ()
              (when (and
                     (fboundp 'adict-change-dictionary)
                     ispell-local-dictionary)
                (adict-change-dictionary ispell-local-dictionary))) 'append))


;; spell checking on all open files
;; (add-hook 'find-file-hook 'flyspell-mode)
;; (add-hook 'find-file-hook 'flyspell-buffer)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(provide 'flyspell-config)

;; Local Variables:
;; coding: utf-8
;; mode: emacs-lisp
;; no-byte-compile t
;; End:

;;; flyspell-config.el ends here
