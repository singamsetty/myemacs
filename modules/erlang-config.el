;;; Erlang Configuration
;;; -*- coding: utf-8 -*-
;;;
;;; Commentary:
;;;
;;; Filename: erlang-config.el
;;; Description: A major mode erlang language support in Emacs
;;; Configuration with Distel,
;;;                    Esense (Intelligent Code Completion) and
;;;                    EDTS
;;;
;;; elisp code for erlang language support and handling
;;=================================================================================

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
;; utility function to handle versioned dirs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun wild (dir stem)
   "returns the last (alphabetically) filename that matches dir/stem*."
   (car
    (reverse
     (sort
      (let (value)
        (dolist (element (file-name-all-completions stem dir) value)
	 (setq value (cons (concat dir element) value)))) 'string-lessp))))

;; we need to find the paths to OTP, distel and esense
;;
;; for OTP, we need the dir containing man and lib.
;; on debian, that would be /usr/lib/erlang
;; for esense, we need the dir where esense.el lives
;; e.g. $HOME/code/esense-1.9
;; for distel, we need distel.el
;; e.g. $HOME/jungerl/lib/distel/elisp
;; you also need to add the corresponding bit to $HOME/.erlang
;; code:add_patha(os:getenv("HOME")++"/jungerl/lib/distel/ebin").

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; setup the locations for erlang root
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar erlang-erl-path "/usr/local/opt/erlang/lib/erlang")
(defvar erlang-esense-path (wild "/opt/erlang/" "esense-"))
(defvar erlang-distel-path "/opt/erlang/distel/elisp")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Wrangler refactoring support for Erlang                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;{{{ custom function to specify the Wrangler location
(defcustom erlang-wrangler-path nil
  "Location of the wrangler elisp directory."
  :group 'erlang-config
  :type 'string
  :safe 'stringp)
;}}}

;{{{ setup the erlang path for Wrangler
;    start Wrangler and load the graphviz
(setq erlang-wrangler-path "/usr/local/lib/erlang/lib/wrangler-1.2.0/elisp")
(message "wrangler path %s" erlang-wrangler-path)
;}}}

;{{{ A number of the erlang-extended-mode key bindings are useful in the shell too
;    setup shortcut keys
(defconst distel-shell-keys
  '(("\C-\M-i"   erl-complete)
    ("\M-?"      erl-complete)
    ("\M-."      erl-find-source-under-point)
    ("\M-,"      erl-find-source-unwind)
    ("\M-*"      erl-find-source-unwind))
  "Additional keys to bind when in Erlang shell.")
;}}}


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; short host name, like `hostname -s`, remote shell likes this better
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun short-host-name ()
  "Get the short hostname of system."
  (interactive)
  (string-match "[^\.]+" system-name)
  (substring system-name (match-beginning 0) (match-end 0)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; set default nodename for distel (= also for erlang-shell-remote)
;; for imenu and start an erlang shell with boot flags
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; {{{ setup for imenu and shell
(add-hook 'erlang-mode-hook
  (lambda ()
    ;; when starting an Erlang shell in Emacs, default in the node name
    ;; (setq inferior-erlang-machine-options (list "-sname" "emacs" "-remsh" (string erl-nodename-cache))
    ;; (setq erl-nodename-cache (intern (concat "dev" "@" (short-host-name))))
    (setq erl-nodename-cache (intern (concat "distel" "@" (short-host-name))))))

(add-hook 'erlang-shell-mode-hook
  (lambda ()
    ;; add some Distel bindings to the Erlang shell
    (dolist (spec distel-shell-keys)
    (define-key erlang-shell-mode-map (car spec) (cadr spec)))))

(add-hook 'erlang-mode-hook 'my-erlang-hook-function)
(defun my-erlang-hook-function ()
    (interactive)
    (imenu-add-to-menubar "Functions"))
; }}}


;; hopefully no further configuration is needed

;;---------------------------------------------------------------------------------
;; find the erlang mode .el file
;;---------------------------------------------------------------------------------
(defvar erlang-erlmode-path
  (concat (wild (concat erlang-erl-path "/lib/") "tools-") "emacs"))

(add-to-list 'load-path erlang-erlmode-path)           ;; add erlang toos to the path
(add-to-list 'load-path erlang-esense-path)            ;; add esense to path
(add-to-list 'load-path erlang-distel-path)            ;; add distel to path
(add-to-list 'load-path erlang-wrangler-path)          ;; add wrangler to path

;; man pages
(setq erlang-man-root-dir (expand-file-name "man" erlang-erl-path))


;; (add-hook 'erlang-mode-hook 'erlang-wrangler-on)
;; some wrangler functionalities generate a .dot file and in order
;; to compile the same and view in graphviz specify the below.
(load-file (concat erlang-wrangler-path "/graphviz-dot-mode.el"))

(show-paren-mode t)
(global-font-lock-mode t)
(add-hook 'erlang-load-hook 'my-erlang-load-hook)

;; use to start an erlang shell with boot flags
(defun erl-shell (flags)
   "Start an erlang shell with flags"
   (interactive (list (read-string "Flags: ")))
   (set 'inferior-erlang-machine-options (split-string flags))
   (erlang-shell))


(defun init-esense ()
  "Set esense configuration."
  ;; (add-to-list 'load-path "~/emacs/esense")
  (require 'esense-start)
  (setq esense-indexer-program
        (concat erlang-esense-path "esense.sh"))
  (setq esense-setup-otp-search-directories t)
  (setq esense-module-search-directories (concat erlang-root-dir "/lib/*/src"))
  (setq esense-include-search-directories (concat erlang-root-dir "/lib/*/include"))
  (setq esense-distel-node "distel@apple"))


(defun my-erlang-load-hook ()
  "Erlang hook for Distel and Esense."
  (require 'distel)
  (distel-setup)

  ;; when loading a beam file from emacs, add the path to erlang
  (setq erl-reload-dwim t)

  ;; esense specific settings
  ;; (require 'esense)
  ;; (setq esense-indexer-program
  ;;   (concat erlang-esense-path "esense.sh"))
  ;; (setq esense-completion-display-method 'frame)

  (init-esense)

  ;; find the man pages
  (setq erlang-root-dir erlang-erl-path)
  (message "#### loading the ERLANG root %s ####" erlang-root-dir)
  (setq erlang-compile-extra-opts (list 'debug_info)))

(add-hook 'erlang-mode-hook 'my-erlang-mode-hook)

(defun my-erlang-mode-hook ()
  "Erlang hook for Esense Mode."
  (esense-mode)
  ;; distel The Right Way(tm)
  (local-set-key [(meta l)] 'erl-find-mod)
  (local-set-key [(meta \()] 'erl-openparent)
  (local-set-key [(meta /)]  'erl-complete)
  (local-set-key [(control x) (\?)] 'erlang-man-function)
  ;; make hack for compile command
  ;; uses Makefile if it exists, else looks for ../inc & ../ebin
  (unless (null buffer-file-name)
    (make-local-variable 'compile-command)
    (setq compile-command
      (if (file-exists-p "Makefile") "make -k"
        (concat
          (concat
            "erlc "
            (concat
              (if (file-exists-p "../ebin") "-o ../ebin " "")
              (if (file-exists-p "../inc") "-I ../inc " ""))
            "+debug_info -W " buffer-file-name))))))

(add-hook 'comint-mode-hook 'my-comint)

(defun my-comint ()
  ;; try to make the shell more like the real shell
  (local-set-key [tab] 'comint-dynamic-complete)
  (local-set-key [(control up)] 'previous-line)
  (local-set-key [(control down)] 'next-line)
  (local-set-key [up] 'comint-previous-input)
  (local-set-key [down] 'comint-next-input))

(add-hook 'erlang-shell-mode-hook 'my-erlang-shell)

(defun my-erlang-shell ()
  "Erlang shell handler."
  (setq comint-dynamic-complete-functions
    '(my-erl-complete  comint-replace-by-expanded-history)))

(defun my-erl-complete ()
  "Call erl-complete if we have an Erlang node name"
  (if erl-nodename-cache
    (erl-complete erl-nodename-cache)
    nil))


;;-------------------------------------------------------------------------------
;; custom function for calling the distel node
;;-------------------------------------------------------------------------------
(defun distel-load-shell ()
  "Load/reload the erlang shell connection to a distel node"
  (interactive)
  ;; Set default distel node name
  ;; (setq erl-nodename-cache 'distel@localhost)
  (setq distel-modeline-node "distel")
  (force-mode-line-update)
  ;; Start up an inferior erlang with node name `distel'
  (let ((file-buffer (current-buffer))
         (file-window (selected-window)))
    (setq inferior-erlang-machine-options '("-sname" "distel"))
    ;; (setq inferior-erlang-machine-options '("-name" "distel"))
    (switch-to-buffer-other-window file-buffer)
    (inferior-erlang)
    (select-window file-window)
    (switch-to-buffer file-buffer)))


;;-------------------------------------------------------------------------------
;; erlang ide set-up and erlang auto-completion using auto-complete and distel
;;-------------------------------------------------------------------------------
;; {{{ setup auto complete for distel

;; (add-hook 'erlang-mode-hook (lambda () (erlang-extended-mode 1)))
(require 'auto-complete-distel)
(ac-config-default)

(setq-default ac-sources
              '( ac-source-yasnippet
                 ac-source-semantic
                 ac-source-imenu
                 ac-source-abbrev
                 ac-source-words-in-buffer
                 ac-source-files-in-current-dir
                 ac-source-filename))

(with-eval-after-load 'auto-complete
  (setq ac-modes (append ac-modes '(erlang-mode)))
  (setq ac-modes (append ac-modes '(erlang-shell-mode))))
;; }}}

;; {{{  auto-complete-mode so can interact with inferior erlang and
;;     popup completion turn on when needed.
(add-hook 'erlang-mode-hook
  (lambda () (auto-complete-mode 1)))
;; }}}

;;-------------------------------------------------------------------------------
;; erlang auto completion using company mode and distel
;;-------------------------------------------------------------------------------
;; {{{ setup company completions with distel

(require 'company-distel)
(add-to-list (make-local-variable 'company-backends)
  'company-distel)

; render company's doc-buffer (default <F1> when on a completion-candidate)
; in a small popup (using popup.el) instead of showing the whole help-buffer.
(setq company-distel-popup-help t)
; specify the height of the help popup created by company
(setq company-distel-popup-height 30)
; get documentation from internet
(setq distel-completion-get-doc-from-internet t)
; Change completion symbols
(setq distel-completion-valid-syntax "a-zA-Z:_-")
;; }}}

;;-------------------------------------------------------------------------------
;; format the erlang records
;;-------------------------------------------------------------------------------
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


;;-------------------------------------------------------------------------------
;; prettify symbols in erlang
;;-------------------------------------------------------------------------------
(add-hook 'erlang-mode-hook 'erlang-font-lock-level-4)
(defun erlang-prettify-symbols ()
  "Prettify common erlang symbols."
  (setq prettify-symbols-alist
        '(
          ("fun"       . ?ƒ)
          ("->"        . ?➔)
          ("<-"        . ?∈)
          ("=/="       . ?≠)
          ("=:="       . ?≡)
          ("=="        . ?≈)
          ("and"       . ?∧)
          ("or"        . ?∨)
          (">="        . ?≥)
          ("=<"        . ?≤)
          ("lists:sum" . ?∑)
          )))

;; Set face of exported functions
(when (boundp 'erlang-font-lock-exported-function-name-face)
  (set-face-attribute 'erlang-font-lock-exported-function-name-face nil
                      :underline t))

(defun my-delayed-prettify ()
  "Mode is guaranteed to run after the style hooks."
  (run-with-idle-timer 0 nil (lambda () (prettify-symbols-mode 1))))

(add-hook 'erlang-mode-hook 'my-delayed-prettify)
(add-hook 'erlang-mode-hook 'erlang-prettify-symbols)

;;-------------------------------------------------------------------------------
;; which function mode for displaying function names
;;-------------------------------------------------------------------------------
(eval-after-load "which-func"
  '(add-to-list 'which-func-modes 'erlang-mode))

;;-------------------------------------------------------------------------------
;; erlang flycheck support and custom helpers
;;-------------------------------------------------------------------------------
(load-file (concat module-dir "/erlang-flycheck-config.el"))
(load-file (concat module-dir "/erlang-helper-config.el"))
(require 'erlang-flycheck-config)
(require 'erlang-helper-config)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; start the erlang mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'erlang-start)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ERLANG IDE with EDTS                                                          ;;
;; EDTS - Erlang Development Tool Suite                                          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;{{{ start edts - place the configuration file .edts in the project

;; Indentation
(add-to-list 'safe-local-variable-values '(erlang-indent-level . 2))

(setq edts-code-issue-wrap-around t)

(defun start-edts ()
  "Initialize EDTS for ERLANG."
  (interactive)
  ;; Set the manual directory and indent level
  (setq edts-man-root erlang-root-dir
        erlang-indent-level 2)
  (setq edts-log-level 'debug)
  (message "starting EDTS...")
  (require 'edts-start))

(add-hook 'after-init-hook 'start-edts)
;;}}}

(provide 'erlang-config)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Local Variables:
;; coding: utf-8
;; mode: emacs-lisp
;; End:

;;; erlang-config.el ends here
