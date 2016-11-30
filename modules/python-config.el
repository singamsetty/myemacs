;;; package --- customize python configuration for Emacs
;;;
;;; Commentary:
;;;            Python 3 support
;;;
;;; Filename   : python-config.el
;;; Description: Python configuration for Emacs
;;;              A full featured python ide and language support for Aquamacs
;;;===========================================================================
;;
; load all the pre-requisites first
;;
(require 'cl)
(require 'cl-lib)
;;
; load all the syntax specific packages needed for python3
;;
(require 'jedi)                 ; a Python auto-completion for Emacs
(require 'company-jedi)         ; company-mode completion back-end for Python JEDI
(require 'jedi-core)            ; Common code of jedi.el and company-jedi.el
(require 'ring)                 ; browse the kill ring
(require 'epc)                  ; RPC stack for the Emacs Lisp
(require 'elpy)                 ; Emacs Python Development Environment
(require 'python-pylint)        ; minor mode for running pylint
(require 'py-yapf)              ; Use yapf to beautify a Python buffer
(require 'virtualenvwrapper)    ; python virtualenv wrapper
;;;
;;; Code:
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; python default shell completion disable                                  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq-default python-shell-completion-native-enable nil)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; python virtual environment setup                                         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(venv-initialize-interactive-shells) ;; if you want interactive shell support
(venv-initialize-eshell)             ;; if you want eshell support
(setq venv-location
      (expand-file-name (concat (getenv "HOME") ".virtualenvs/")))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; flymake handler for syntax-checking Python source code using             ;;
;; pyflakes or flake8                                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'flymake-python-pyflakes)
;; (add-hook 'python-mode-hook 'flymake-python-pyflakes-load)
;; using flake8 for flycheck
(setq flymake-python-pyflakes-executable "/usr/local/bin/flake8")
;; set flymake log level
(setq flymake-log-level 3)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; python jedi setup                                                        ;;
;; reference@http://tkf.github.io/emacs-jedi/latest/#                       ;;
;; python development with auto-completion and intelli-sense                ;;
;; for running inferior process when loading major mode python              ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun run-python-once ()
  "Python specific hook settings."
  (remove-hook 'python-mode-hook 'run-python-once)
  (run-python (python-shell-parse-command)))

(add-hook 'python-mode-hook 'run-python-once)


;;
; hook up to autocomplete
; (add-to-list ’ac-sources ’ac-source-jedi-direct)
;;
; (autoload 'jedi:setup "jedi" nil t)
; ;; enable python-mode
; (add-hook 'python-mode-hook 'jedi:setup)
; (setq jedi-config:set-python-executable "/usr/local/bin/python3")
; ;(setq jedi:setup-keys t)
; (setq jedi:complete-on-dot t)
; ; hack to never show in-function call automatically
; (setq jedi:get-in-function-call-delay 300)
; (setq jedi:server-command (list "/usr/local/bin/python3" jedi:server-script))
; (setq jedi:tooltip-method '(pos-tip))
; (jedi-mode 1)
; (setq jedi:environment-root "env")
; ; (setq jedi:environment-virtualenv
; ;   (append python-environment-virtualenv
; ;     '(' "--python" "/usr/local/bin/python3")))


;; enable python-mode with jedi
(add-hook 'python-mode-hook
          '(lambda ()
             ;; python common
             (setq indent-tabs-mode nil)
             (setq indent-level 4)
             (setq python-indent 4)
             (setq tab-width 4)
             ;; jedi
             (setq jedi:setup-keys t)
             (setq jedi:complete-on-dot t)
             ; hack to never show in-function call automatically
             (setq jedi:get-in-function-call-delay 0.2)
             (setq jedi:tooltip-method '(pos-tip))
             (jedi-mode 1)
             (jedi:setup)
             (define-key jedi-mode-map (kbd "M-TAB") 'jedi:complete)
             (setq jedi:complete-on-dot t)
             (setq jedi:environment-root "env")
             (setq jedi:environment-virtualenv
                   (append python-environment-virtualenv
                           '("--python" "/usr/local/bin/python3")))))
;;
; load jedi
;;
(eval-after-load "jedi"
  '(progn
     (setq jedi:server-command
           (list "/usr/local/bin/python3" jedi:server-script))))

;; jedi keyboard mappings
(defun jedi-config:setup-keys ()
  "Custom keyboard mapping for jedi."
   (local-set-key (kbd "M-.") 'jedi:goto-definition)
   (local-set-key (kbd "M-,") 'jedi:goto-definition-pop-marker)
   (local-set-key (kbd "M-?") 'jedi:show-doc)
   (local-set-key (kbd "M-/") 'jedi:get-in-function-call))
(add-hook 'python-mode-hook 'jedi-config:setup-keys)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; company backend(s) setup for python jedi                                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun my-python-hooks()
    (eval-after-load "company"
        '(progn
            (unless (member 'company-jedi (car company-backends))
                (setq comp-back (car company-backends))
                (push 'company-jedi comp-back)
                (setq company-backends (list comp-back)))
            )))
(add-hook 'python-mode-hook 'my-python-hooks)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  python3 shell interpreter                                              ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq python-shell-interpreter "/usr/local/bin/ipython3"
      ;; if extras are needed with ipython3
      ; (setq python-shell-interpreter-args "--pylab")
      python-shell-interpreter-args "-i"
      ;; additional shell options added
      python-shell-prompt-regexp "In \\[[0-9]+\\]: "
      python-shell-prompt-output-regexp "Out\\[[0-9]+\\]: "
      python-shell-completion-setup-code "from IPython.core.completerlib import module_completion"
      python-shell-completion-module-string-code  "';'.join(module_completion('''%s'''))\n"
      python-shell-completion-string-code "';'.join(get_ipython().Completer.all_completions('''%s'''))\n"
      ;; python3 command
      py-python-command "/usr/local/bin/python3")
;; below line specified for handling the args-out-of-range error in buffer
(setenv "IPY_TEST_SIMPLE_PROMPT" "1")
(setq python-check-command "/usr/local/bin/pyflakes")
(setq python-environment-directory (concat (getenv "HOME") "/.emacs.d/.python-environments"))
;; handling whitespaces in python mode
(add-hook 'before-save-hook 'delete-trailing-whitespace)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; system path in the lisp                                                 ;;
;; set PATH, because we don't load .bashrc                                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setenv
 "PATH" (concat
   "$HOME/bin:"
   "/bin:"
   "/usr/bin:"
   "/sbin:"
   "/usr/sbin:"
   "/usr/local/bin:"
   "/usr/local/sbin"))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; set PYTHONPATH, because we don't load from .bashrc                      ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setenv "PYTHONPATH" "/usr/local/lib/python3.5/site-packages:")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; start elpy ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;; Emacs Python Development Environment  ;;;;;;;;;;;;;;;;;;;
;;                                                                          ;;
;; elpy mode can be disabled or commented out if running 2 completion(s)    ;;
;; simultaneously is considered an overkill and right now the jedi setup    ;;
;; has been working more than satisfactorily... but leaving for now         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; (elpy-enable)

;;
; python completion and code checking
;;
(setq elpy-modules '(elpy-module-company
                     elpy-module-eldoc
                     elpy-module-flymake
                     elpy-module-pyvenv
                     elpy-module-highlight-indentation ;breaks older emacs
                     elpy-module-sane-defaults))

;;
; use ipython if available
; (elpy-use-ipython)
;;
(if (executable-find "ipython")
    (elpy-use-ipython))

;;
; enable elpy
;;
(elpy-enable)

(setq
  elpy-rpc-backend "jedi"
  elpy-rpc-python-command "/usr/local/bin/python3"
  elpy-rpc-python-path "/usr/local/lib/python3.5/site-packages"
  flycheck-python-flake8-executable "/usr/local/bin/flake8"
  python-check-command "/usr/local/bin/pyflakes"
  python-environment-directory "~/.emacs.d/.python-environments")

;;
;; Note
;; elpy auto-completion can be manually triggerred using M-Tab
;; M-TAB (elpy-company-backend) as per the below documentation
;; https://elpy.readthedocs.io/en/latest/ide.html#completion
;;

;; make sure elpy python completions don't start automatically
(add-hook 'elpy-mode-hook
           (lambda ()
;;              (require 'eval-in-repl-python)
;;              (define-key elpy-mode-map "\C-c\C-c" 'eir-eval-in-python)
              (setq company-idle-delay nil)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; end elpy ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; python linting                                                           ;;
;; using flycheck with pylint                                               ;;
;; http://liuluheng.github.io/wiki/public_html/Python                       ;;
;;                                /flycheck-pylint-emacs-with-python.html   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun flycheck-python-setup ()
  "Flycheck python lint support."
  (flycheck-mode))
(add-hook 'python-mode-hook #'flycheck-python-setup)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; pylint integration through flymake                                       ;;
;; Configure flymake for Python                                             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(when (load "flymake" t)
  (defun flymake-pylint-init ()
    (let* ((temp-file (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
           (local-file (file-relative-name
                        temp-file
                        (file-name-directory buffer-file-name))))
      (list "epylint" (list local-file))))
  (add-to-list 'flymake-allowed-file-name-masks
               '("\\.py\\'" flymake-pylint-init)))

;; Set as a minor mode for Python
(add-hook 'python-mode-hook '(lambda () (flymake-mode)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; To avoid having to mouse hover for the error message, these functions   ;;
;; make flymake error messages appear in the minibuffer                    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun show-fly-err-at-point ()
  "If the cursor is sitting on a flymake error, display the message in the minibuffer."
  (require 'cl)
  (interactive)
  (let ((line-no (line-number-at-pos)))
    (dolist (elem flymake-err-info)
      (if (eq (car elem) line-no)
      (let ((err (car (second elem))))
        (message "%s" (flymake-ler-text err)))))))

(add-hook 'post-command-hook 'show-fly-err-at-point)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; yapf mode for beautifying a python buffer                                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-hook 'python-mode-hook 'py-yapf-enable-on-save)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; enable eldoc                                                             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(eldoc-mode t)
;;


(provide 'python-config)

;;; python-config.el ends here
