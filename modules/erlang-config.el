;;; package --- erlang configuration settings
;;;
;;; Commentary:
;;;
;;; Filename: erlang-config.el
;;; Description: A major mode erlang language support in Emacs
;;;
;;; elisp code for erlang language support and handling
;;===========================================================================
;;; first load the standard and erlang specific libraries
(require 'cl)
(require 'cl-lib)
(require 'imenu)
(require 'company-erlang)
(require 'ivy-erlang-complete)
;;;
;;; Code:
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; start defining the emacs bindings for erlang                                ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-to-list 'auto-mode-alist '("\\.erl?$"        . erlang-mode))
(add-to-list 'auto-mode-alist '("\\.hrl?$"        . erlang-mode))
(add-to-list 'auto-mode-alist '(".*\\.app\\'"     . erlang-mode))
(add-to-list 'auto-mode-alist '(".*app\\.src\\'"  . erlang-mode))
(add-to-list 'auto-mode-alist '(".*\\.config\\'"  . erlang-mode))
(add-to-list 'auto-mode-alist '(".*\\.rel\\'"     . erlang-mode))
(add-to-list 'auto-mode-alist '(".*\\.script\\'"  . erlang-mode))
(add-to-list 'auto-mode-alist '(".*\\.escript\\'" . erlang-mode))
(add-to-list 'auto-mode-alist '(".*\\.es\\'"      . erlang-mode))
(add-to-list 'auto-mode-alist '(".*\\.xrl\\'"     . erlang-mode))
(add-to-list 'auto-mode-alist '(".*\\.yrl\\'"     . erlang-mode))
(add-to-list 'auto-mode-alist '(".[eh]rl'"        . erlang-mode))
(add-to-list 'auto-mode-alist '(".yaws?'"         . erlang-mode))
(add-to-list 'auto-mode-alist '(".escript?'"      . erlang-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; erlang compilation options                                                  ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; add include directory to default compile path.
(defvar erlang-compile-extra-opts
  '(bin_opt_info debug_info (i . "../include")
                            (i . "../deps")
                            (i . "../../")
                            (i . "../../../deps")))
; define where to put beam files.
(setq erlang-compile-outdir "../ebin")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; erlang binaries path setup                                                ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq erlang-root-dir "/usr/local/opt/erlang/lib/erlang")
(setq load-path
      (cons "/usr/local/opt/erlang/lib/erlang/lib/tools-*/emacs"
            load-path))
(load "erlang_appwiz" t nil)
(message "--> loading erlang root %s" erlang-root-dir)
;; below conditional code is needed for loading proper erlang vm
(if
    (not (boundp 'erlang-root-dir))
    (message "discarding the erlang-mode: erlang-root-dir not defined")
  (progn
    (set 'erlang-bin (concat erlang-root-dir "/bin/"))
    (set 'erlang-lib (concat erlang-root-dir "/lib/"))
    (if
        (not (boundp 'erlang-mode-path))
        (set 'erlang-mode-path
             (concat
              erlang-lib
              (file-name-completion "tools-" erlang-lib)
              "emacs/erlang.el")))
    (if
        (and
         (file-readable-p erlang-mode-path)
         (file-readable-p erlang-bin))
        (progn
          (message "--> setting up erlang-mode from %s" erlang-root-dir)
          (set 'exec-path (cons erlang-bin exec-path))
          (set 'load-path (cons
                           (concat
                            erlang-lib
                            (file-name-completion "tools-" erlang-lib)
                            "emacs")
                           load-path))
          (set 'load-path (cons (file-name-directory erlang-mode-path) load-path))
          (require 'erlang-start)
          (require 'erlang-eunit)
          (require 'erlang-flymake)
          )
      (message "--> discarding the erlang-mode: %s and/or %s not readable"
               erlang-bin erlang-mode-path))))

(setq erlang-man-root-dir (expand-file-name "man" erlang-root-dir))
(setq exec-path (cons "/usr/local/opt/erlang/bin" exec-path))

;(require 'erlang-start)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; wrangler refactoring support for erlang                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defcustom wrangler-path nil
  "Location of the wrangler elisp directory."
  :group 'erlang-config
  :type 'string
  :safe 'stringp)

(setq wrangler-path "/usr/local/lib/erlang/lib/wrangler-1.2.0/elisp")

(when (require 'erlang-start nil t)
  (when (not (null wrangler-path))
    (add-to-list 'load-path wrangler-path)
    (require 'wrangler))
  (add-hook 'erlang-mode-hook 'erlang-wrangler-on)
  ;; some wrangler functionalities generate a .dot file and inorder
  ;; to compile the same and view in graphviz specify the below.
  (load-file (concat wrangler-path "/graphviz-dot-mode.el"))
  )

;; Intellisense
;; (setq load-path (cons "/opt/erlang/esense-1.12" load-path))
;; (require 'esense-start)
;; (setq esense-indexer-program "/opt/erlang/esense-1.12/esense.sh")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; distel setup for erlang code auto-completion                              ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(let ((distel-dir "/usr/local/share/distel/elisp"))
    (unless (member distel-dir load-path)
      ;; add distel-dir to the end of load-path
      (setq load-path (append load-path (list distel-dir)))))

; prevent annoying hang-on-compile
(defvar inferior-erlang-prompt-timeout t)

; {{{
; distel-node
; distel node connection launch with (^C-^D-n)
(when (locate-library "distel")
  ; distel invoked by wrangler step
  ;(require 'distel)
  (distel-setup)
  ;; (add-hook 'erlang-mode-hook 'distel-erlang-mode-hook)
  (add-hook 'erlang-mode-hook
            '(lambda ()
               (unless erl-nodename-cache
                 (distel-load-shell))))

  (defun distel-load-shell ()
    "Load/reload the erlang shell connection to a distel node"
    (interactive)
    ;; Set default distel node name
    (setq erl-nodename-cache 'distel@localhost)
    (setq distel-modeline-node "distel")
    (force-mode-line-update)
    ;; Start up an inferior erlang with node name `distel'
    (let ((file-buffer (current-buffer))
          (file-window (selected-window)))
      (setq inferior-erlang-machine-options
            '("-name" "distel@localhost"
              ; "-pz" "ebin deps/*/ebin apps/*/ebin"
              ; "-boot" "start_sasl"
              ))
      (message "--> connecting to %s" erl-nodename-cache)
      (message "--> connecting with %s" inferior-erlang-machine-options)
      (switch-to-buffer-other-window file-buffer)
      (inferior-erlang)
      (select-window file-window)
      (switch-to-buffer file-buffer))))
;; ==================================================================
;; (add-to-list 'load-path "/opt/erlang/distel/elisp")
;;       (require 'distel)
;;       (distel-setup)
;; ;; prevent annoying hang-on-compile
;; (defvar inferior-erlang-prompt-timeout t)
;; ;; default node name to emacs@localhost
;; (setq inferior-erlang-machine-options '("-sname" "emacs"))
;; ;; tell distel to default to that node
;; (setq erl-nodename-cache
;;       (make-symbol
;;        (concat
;;         "emacs@"
;;         ;; Mac OS X uses "name.local" instead of "name", this should work
;;         ;; pretty much anywhere without having to muck with NetInfo
;;         ;; ... but I only tested it on Mac OS X.
;;         (car (split-string (replace-regexp-in-string "\n\\'" "" (shell-command-to-string "hostname"))))
;;         ;(car (split-string (shell-command-to-string "hostname")))
;;         )))
;; ==================================================================

; }}}

;; for imenu
(defun imenu-erlang-mode-hook()
    (imenu-add-to-menubar "imenu"))
(add-hook 'erlang-mode-hook 'imenu-erlang-mode-hook)

(add-hook 'erlang-shell-mode-hook
  (lambda ()
    ;; add some Distel bindings to the Erlang shell
    (dolist (spec distel-shell-keys)
    (define-key erlang-shell-mode-map (car spec) (cadr spec)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; erlang ide set-up and erlang auto-completion using auto-complete and distel   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'auto-complete-distel)
(ac-config-default)
(add-to-list 'ac-sources 'auto-complete-distel)
(setq ac-auto-show-menu    0.2)
(setq ac-delay             0.2)
(setq ac-menu-height       20)
; tart auto-completion after 2 characters of a word
(setq ac-auto-start 2)
; case sensitivity is important when finding matches
(setq ac-ignore-case nil)
(setq ac-show-menu-immediately-on-auto-complete t)
; Erlang auto-complete
(add-to-list 'ac-modes 'erlang-mode)

;;
; auto-complete-mode so can interact with inferior erlang and
; popup completion turn on when needed.
;;
(add-hook 'erlang-mode-hook
          (lambda () (auto-complete-mode 1)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; erlang auto completion using company mode and distel                          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'company-distel)
(add-hook 'after-init-hook 'global-company-mode)
(with-eval-after-load 'company
  (add-to-list 'company-backends '(company-distel :with company-yasnippet)))

; render company's doc-buffer (default <F1> when on a completion-candidate)
; in a small popup (using popup.el) instead of showing the whole help-buffer.
(setq company-distel-popup-help t)
; specify the height of the help popup created by company
(setq company-distel-popup-height 30)
; get documentation from internet
(setq distel-completion-get-doc-from-internet t)
; Change completion symbols
(setq distel-completion-valid-syntax "a-zA-Z:_-")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; A number of the erlang-extended-mode key bindings are useful in the shell too ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defconst distel-shell-keys
  '(("\C-\M-i"   erl-complete)
    ("\M-?"      erl-complete)
    ("\M-."      erl-find-source-under-point)
    ("\M-,"      erl-find-source-unwind)
    ("\M-*"      erl-find-source-unwind)
    )
  "Additional keys to bind when in Erlang shell.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; on the fly source code checking through flymake                               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq flymake-log-level 3)
(setq erlang-flymake-location (concat emacs-dir "/flymake/eflymake"))

(defun flymake-syntaxerl ()
  "Erlang syntax checker for flymake."
  (flymake-compile-script-path "/opt/erlang/syntaxerl"))

(defun flymake-erlang-init ()
  "Erlang flymake compilation settings."
  (let* ((temp-file (flymake-init-create-temp-buffer-copy
                     'flymake-create-temp-inplace))
         (local-file (file-relative-name temp-file
                                         (file-name-directory buffer-file-name)))
         (list (concat (getenv "HOME") "/.emacs.d/flymake/eflymake"))
         (escript-exe (concat erlang-root-dir "/bin/escript"))
         (eflymake-loc (expand-file-name erlang-flymake-location)))
    (if (not (file-exists-p eflymake-loc))
        (error "Please set erlang-flymake-location to an actual location")
      (list escript-exe (list eflymake-loc local-file)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; enable flymake only for erlang mode                                           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-to-list 'flymake-allowed-file-name-masks '("\\.erl\\'" flymake-erlang-init))
(defun flymake-erlang-mode-hook ()
  "Set erlang flymake mode."
  (flymake-mode 1))
(add-hook 'erlang-mode-hook 'flymake-erlang-mode-hook)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; https://github.com/ten0s/syntaxerl                                            ;;
;; see /usr/local/lib/erlang/lib/tools-<Ver>/emacs/erlang-flymake.erl            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun erlang-flymake-only-on-save ()
  "Trigger flymake only when the buffer is saved - clears syntax checker on a newline and when there is no change."
  (interactive)
  (setq flymake-no-changes-timeout most-positive-fixnum)
  (setq flymake-start-syntax-check-on-newline nil))

(erlang-flymake-only-on-save)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; enable flymake for rebar projects                                             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun ebm-find-rebar-top-recr (dirname)
  "Get rebar.config filename based on DIRNAME."
  (let* ((project-dir (locate-dominating-file dirname "rebar.config")))
    (if project-dir
        (let* ((parent-dir (file-name-directory (directory-file-name project-dir)))
               (top-project-dir (if (and parent-dir (not (string= parent-dir "/")))
                                    (ebm-find-rebar-top-recr parent-dir)
                                  nil)))
          (if top-project-dir
              top-project-dir
            project-dir))
      project-dir)))

(defun ebm-find-rebar-top ()
  "Find top directory of rebar project."
  (interactive)
  (let* ((dirname (file-name-directory (buffer-file-name)))
         (project-dir (ebm-find-rebar-top-recr dirname)))
    (if project-dir
        project-dir
      (erlang-flymake-get-app-dir))))

(defun ebm-directory-dirs (dir name)
  "Find all directories in DIR with NAME."
  (unless (file-directory-p dir)
    (error "Not a directory `%s'" dir))
  (let ((dir (directory-file-name dir))
        (dirs '())
        (files (directory-files dir nil nil t)))
    (dolist (file files)
      (unless (member file '("." ".."))
        (let ((absolute-path (expand-file-name (concat dir "/" file))))
          (when (file-directory-p absolute-path)
            (if (string= file name)
                (setq dirs (append (cons absolute-path
                                         (ebm-directory-dirs absolute-path name))
                                   dirs))
              (setq dirs (append
                          (ebm-directory-dirs absolute-path name)
                          dirs)))))))
    dirs))

(defun ebm-get-deps-code-path-dirs ()
  "Get the files under deps directory."
  (ebm-directory-dirs (ebm-find-rebar-top) "ebin"))

(defun ebm-get-deps-include-dirs ()
  "Include directories under deps."
  (ebm-directory-dirs (ebm-find-rebar-top) "include"))

(fset 'erlang-flymake-get-code-path-dirs 'ebm-get-deps-code-path-dirs)
(fset 'erlang-flymake-get-include-dirs-function 'ebm-get-deps-include-dirs)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; context sensitive completion for erlang without connecting to erlang nodes    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (setq ivy-erlang-complete-erlang-root "/usr/local/opt/erlang/lib/erlang")
;; (add-hook 'erlang-mode-hook #'ivy-erlang-complete-init)
;; ;; automatic update completion data after save
;; (add-hook 'after-save-hook #'ivy-erlang-complete-reparse)

;; (defun my-erlang-hook ()
;;   "IVY configuration settings for Erlang."
;;   (require 'wrangler)
;;   (ivy-erlang-complete-init)
;;   (defvar erlang-extended-mode-map)
;;   (define-key erlang-extended-mode-map (kbd "M-.") nil)
;;   (define-key erlang-extended-mode-map (kbd "M-,") nil)
;;   (define-key erlang-extended-mode-map (kbd "M-?") nil)
;;   (define-key erlang-extended-mode-map (kbd "(") nil)
;;   (local-set-key (kbd "C-c C-p") #'align-erlang-record))
;; (add-hook 'erlang-mode-hook #'my-erlang-hook)
;; (add-hook 'after-save-hook #'ivy-erlang-complete-reparse)

;; (add-to-list 'auto-mode-alist '("rebar\\.config$"  . erlang-mode))
;; (add-to-list 'auto-mode-alist '("relx\\.config$"   . erlang-mode))
;; (add-to-list 'auto-mode-alist '("system\\.config$" . erlang-mode))
;; (add-to-list 'auto-mode-alist '("\\.app\\.src$"    . erlang-mode))

;; ;; company-erlang for ivy
;; (add-hook 'erlang-mode-hook #'company-erlang-init)

;;
; format the erlang records
;;
(defun align-erlang-record ()
  "Formatting the erlang record data structure."
  (interactive)
  (let ((from (line-beginning-position)))
    (goto-char from)
    (search-forward "-record" )
    (search-forward "{")
    (goto-char (- (point) 1))
    (ignore-errors (er/expand-region 1))
    (my-align-region-by "=")
    (goto-char from)
    (search-forward "-record" )
    (search-forward "{")
    (goto-char (- (point) 1))
    (ignore-errors (er/expand-region 1))
    (my-align-region-by "::")))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; prettify symbols in erlang                                               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-hook 'erlang-mode-hook 'erlang-font-lock-level-4)

(defun erlang-prettify-symbols ()
  "Prettify common erlang symbols."
  (setq prettify-symbols-alist
        '(
          ("fun" . ?ƒ)
          ("->" . ?➔)
          ("<-" . ?∈)
          ("=/=" . ?≠)
          ("=:=" . ?≡)
          ("==" . ?≈)
          ("and" . ?∧)
          ("or" . ?∨)
          (">=" . ?≥)
          ("=<" . ?≤)
          ("lists:sum" . ?∑)
          )))

(defun my-delayed-prettify ()
  "Mode is guaranteed to run after the style hooks."
  (run-with-idle-timer 0 nil (lambda () (prettify-symbols-mode 1))))
(add-hook 'erlang-mode-hook 'my-delayed-prettify)
(add-hook 'erlang-mode-hook 'erlang-prettify-symbols)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(provide 'erlang-config)
;;; erlang-config.el ends here
