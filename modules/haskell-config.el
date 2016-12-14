;;; package --- haskell configuration
;;; -*- coding: utf-8 -*-
;;;
;;; Commentary:
;;;
;;; configuration file for haskell mode
;;; Filename: haskell-config.el
;;; Description: A major mode haskell language support in Emacs
;;; ref: http://haskell.github.io/haskell-mode/manual/latest/index.html#Top
;;
;; elisp code for haskell language support and handling
;;;==========================================================================
;;;
;;; Code:
;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;; Haskell settings for Emacs ;;;;;;;;;;;;;;;;;;;;;;;;;;
;; templates used from the below links.  Thanks to both                    ;;
;; https://github.com/serras/emacs-haskell-tutorial/                       ;;
;; https://github.com/chrisdone/emacs-haskell-config/                      ;;
;; -----------------------        references       ------------------------;;
;; http://www.mew.org/~kazu/proj/ghc-mod/en/                               ;;
;; http://haskell.github.io/haskell-mode/manual/latest/                    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
; load all the pre-requisite libraries
;;
(require 'cl)
(require 'cl-lib)
;;
; load necessary libraries for haskell and company (for auto completion)
;;
(require 'haskell-mode)               ; haskell editing mode for Emacs
(require 'hindent)                    ; indentation for haskell program
(require 'haskell-font-lock)          ; font lock mode for haskell
(require 'ghc)                        ; sub mode for haskell mode
(require 'inf-haskell)                ; haskell inferior mode
(require 'haskell-interactive-mode)   ; haskell ghci support
(require 'haskell-process)            ; haskell ghci repl support
(require 'hi2)                        ; indentation module for haskell mode
(require 'company)                    ; modular text completion framework
(require 'company-ghc)                ; company backend haskell-mode via ghc-mod
(require 'company-ghci)               ; company backend which uses the current ghci process
(require 'shm)                        ; structured haskell mode
; (require 'intero)                   ; complete development mode for haskell


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; set up the required $PATH for the haskell and cabal environment       ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
; (setenv "PATH" (concat "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:"
;                (getenv "HOME") "/Library/Haskell/bin"
;                (getenv "PATH")))
; (add-to-list 'exec-path (concat (getenv "HOME") "~/Library/Haskell/bin"))
;
; Make Emacs look in to the Cabal directory for installed binaries
; and set the same into the classpath for ready access
;;
;;
(let ((my-cabal-path (expand-file-name (concat (getenv "HOME") "/Library/Haskell/bin"))))
  ; setup the cabal path and put into classpath
  (setenv "PATH" (concat "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:"
                 my-cabal-path ":"
                 (getenv "PATH")))
  (add-to-list 'exec-path my-cabal-path))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;                emacs haskell-mode configuration setup                 ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
; choose the indentation mode (using haskell-mode indentation)
;;
(add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)
(add-hook 'haskell-mode-hook 'haskell-auto-insert-module-template)
(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
(add-hook 'haskell-mode-hook 'haskell-decl-scan-mode)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; hoogle executable for documentation                                     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar hoogle-url-base "http://haskell.org/hoogle/?q="
  "The base for the URL that will be used for web Hoogle lookups.")
(defvar hoogle-local-command  (concat (getenv "HOME") "/Library/Haskell/bin/hoogle")
  "The name of the executable used for hoogle not found in $PATH (using `executable-find'), then a web lookup is used.")
(defvar hoogle-always-use-web nil
  "Set to non-nil to always use web lookups.")
(defvar hoogle-history nil
  "The history of what you've hoogled for.")
(defvar hoogle-result-count 15
  "How many results should be shown (when running locally.")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; auto-complete-mode for interacting with inferior haskell mode and popup ;;
;; completion turn on when needed; haskell completion source for the       ;;
;; necessary auto-complete is provided by ac-haskell-process               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq ac-delay 1.0) ; reducing auto-complete value to not conflict with company
(add-hook 'haskell-mode-hook
          (lambda () (auto-complete-mode 1)))
;;
; haskell completion source for Emacs auto-complete package
; https://github.com/purcell/ac-haskell-process
;;
(require 'ac-haskell-process)
(add-hook 'interactive-haskell-mode-hook 'ac-haskell-process-setup)
(add-hook 'haskell-interactive-mode-hook 'ac-haskell-process-setup)
(eval-after-load "auto-complete"
  '(add-to-list 'ac-modes 'haskell-interactive-mode))
;;
; using ac-haskell-process-popup-doc to pop up documentation for the symbol at point
;;
(eval-after-load 'haskell-mode
  '(define-key haskell-mode-map (kbd "C-c C-d") 'ac-haskell-process-popup-doc))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; use hi2 for haskell indentation                                         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-hook 'haskell-mode-hook 'turn-on-hi2)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; haskell syntax checking, indentation and snippets                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-hook 'haskell-mode-hook 'yas-minor-mode)
(add-hook 'haskell-mode-hook 'haskell-indentation-mode)
(add-hook 'haskell-mode-hook 'interactive-haskell-mode)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; add F8 key combination for going to imports block                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(eval-after-load 'haskell-mode
  '(define-key haskell-mode-map [f8] 'haskell-navigate-imports))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; set or unset variables needed for customization                         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(custom-set-variables
 ; Set up hasktags (part 2)
 '(haskell-tags-on-save nil)
 ; Set up interactive mode (part 2)
 '(haskell-process-log t)
 '(haskell-process-suggest-remove-import-lines t)
 '(haskell-process-auto-import-loaded-modules t)
 ; set interpreter to be "cabal repl" or ghci
 ;'(haskell-process-type 'cabal-repl)
 '(haskell-process-type 'ghci)
 ; haskell font-lock
 '(haskell-font-lock-symbols t)
 '(haskell-stylish-on-save t)
 '(haskell-process-use-presentation-mode t)
 '(shm-use-hdevtools t)
 '(shm-use-presentation-mode t)
 '(shm-auto-insert-skeletons t)
 '(shm-auto-insert-bangs t)
 '(haskell-process-show-debug-tips t)
 '(haskell-process-suggest-hoogle-imports t)
 '(haskell-process-suggest-haskell-docs-imports t)
 ; using chris-done style for code indenting
 '(hindent-style "chris-done")
 '(inferior-haskell-find-haddock)
 )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; standard haskell module completions                                     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq haskell-complete-module-preferred
      '("Data.ByteString"
        "Data.ByteString.Lazy"
        "Data.Conduit"
        "Data.Function"
        "Data.List"
        "Data.Map"
        "Data.Maybe"
        "Data.Monoid"
        "Data.Text"
        "Data.Ord"))

(setq haskell-session-default-modules
      '("Control.Monad.Reader"
        "Data.Text"
        "Control.Monad.Logger"))

(setq haskell-interactive-mode-eval-mode 'haskell-mode)
(setq haskell-process-generate-tags nil)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Add key combinations for interactive haskell-mode                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(eval-after-load 'haskell-mode '(progn
  (define-key haskell-mode-map (kbd "C-c C-l") 'haskell-process-load-or-reload)
  (define-key haskell-mode-map (kbd "C-c C-z") 'haskell-interactive-switch)
  (define-key haskell-mode-map (kbd "C-c C-t") 'haskell-process-do-type)
  (define-key haskell-mode-map (kbd "C-c C-i") 'haskell-process-do-info)
  (define-key haskell-mode-map (kbd "C-c C-c") 'haskell-process-cabal-build)
  (define-key haskell-mode-map (kbd "C-c C-k") 'haskell-interactive-mode-clear)
  (define-key haskell-mode-map (kbd "C-c c") 'haskell-process-cabal)))

(eval-after-load 'haskell-cabal '(progn
  (define-key haskell-cabal-mode-map (kbd "C-c C-n C-z") 'haskell-interactive-switch)
  (define-key haskell-cabal-mode-map (kbd "C-c C-n C-k") 'haskell-interactive-mode-clear)
  (define-key haskell-cabal-mode-map (kbd "C-c C-n C-c") 'haskell-process-cabal-build)
  (define-key haskell-cabal-mode-map (kbd "C-c C-n c") 'haskell-process-cabal)))

(eval-after-load 'haskell-mode
  '(define-key haskell-mode-map (kbd "C-c C-o") 'haskell-compile))

(eval-after-load 'haskell-cabal
  '(define-key haskell-cabal-mode-map (kbd "C-c C-n C-o") 'haskell-compile))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ghc-mod configuration (initializer for ghc-mod)                         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(autoload 'ghc-init "ghc" nil t)
(autoload 'ghc-debug "ghc" nil t)
(add-hook 'haskell-mode-hook (lambda () (ghc-init)))
;;
; with the below setting, we can watch the communication between Emacs
; front-end and ghc-modi in the "*GHC Debug*" buffer.
;;
(setq ghc-debug t)
;;
; if using a refactor tool hare along
; (autoload 'hare-init "hare" nil t)
; (add-hook 'haskell-mode-hook (lambda () (ghc-init) (hare-init)))
;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; company-ghc configuration                                               ;;
;; enable company-mode for auto-completion                                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; (add-hook 'haskell-mode-hook 'company-mode)
; (add-hook 'after-init-hook 'global-company-mode) ; Use company in all buffers
(setq company-ghc-hoogle-command (concat (getenv "HOME") "/Library/Haskell/bin/hoogle"))
(setq company-ghc-component-prefix-match t)
(setq company-ghc-turn-on-autoscan t)
(add-to-list 'company-backends 'company-ghc)
; to get completions from ghc-mod set below
(custom-set-variables '(company-ghc-show-info t))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; company-ghci configuration                                              ;;
;; company-ghci is a company backend that provides completions for the     ;;
;; haskell programming language by talking to a ghci process               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(push 'company-ghci company-backends)
(add-hook 'haskell-mode-hook 'company-mode)
;;; to get auto completions in the ghci REPL
(add-hook 'haskell-interactive-mode-hook 'company-mode)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; shm (structured-haskell-mode) configuration                             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-hook 'haskell-mode-hook 'structured-haskell-mode)
;; ** customize colors while running shm (good colors for solarized) **
;(set-face-background 'shm-current-face "#eee8d5")
;(set-face-background 'shm-quarantine-face "lemonchiffon")
;; ** disabling the faces **
(set-face-background 'shm-current-face nil)
(set-face-background 'shm-quarantine-face nil)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; flymake handler for checking Haskell source code with hlint.             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'flymake-hlint) ;; not needed if installed via package
(add-hook 'haskell-mode-hook 'flymake-hlint-load)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; haskell standard module imports                                         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq haskell-import-mapping
      '(("Data.Text" . "import qualified Data.Text as T
                        import Data.Text (Text)
                       ")
        ("Data.Text.Lazy" . "import qualified Data.Text.Lazy as LT
                            ")
        ("Data.ByteString" . "import qualified Data.ByteString as S
                              import Data.ByteString (ByteString)
                             ")
        ("Data.ByteString.Char8" . "import qualified Data.ByteString.Char8 as S8
                                    import Data.ByteString (ByteString)
                                   ")
        ("Data.ByteString.Lazy" . "import qualified Data.ByteString.Lazy as L
                                  ")
        ("Data.ByteString.Lazy.Char8" . "import qualified Data.ByteString.Lazy.Char8 as L8
                                        ")
        ("Data.Map" . "import qualified Data.Map.Strict as M
                       import Data.Map.Strict (Map)
                      ")
        ("Data.Map.Strict" . "import qualified Data.Map.Strict as M
                              import Data.Map.Strict (Map)
                             ")
        ("Data.Set" . "import qualified Data.Set as S
                       import Data.Set (Set)
                      ")
        ("Data.Vector" . "import qualified Data.Vector as V
                          import Data.Vector (Vector)
                         ")
        ("Data.Vector.Storable" . "import qualified Data.Vector.Storable as SV
                                   import Data.Vector (Vector)
                                  ")
        ("Data.Conduit.List" . "import qualified Data.Conduit.List as CL
                               ")
        ("Data.Conduit.Binary" . "import qualified Data.Conduit.Binary as CB
                                 ")
))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; custom set variables for haskell                                        ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq haskell-language-extensions '())
(setq haskell-process-type 'ghci)
(setq haskell-process-path-ghci "/usr/local/bin/ghci")
(setq haskell-process-use-ghci t)
(setq haskell-hoogle-command (concat (getenv "HOME") "/Library/Haskell/bin/hoogle"))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; intero (not used, so commented)                                         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; (defun haskell-process-cabal-build-and-restart ()
;   "Build and restart the Cabal project."
;   (interactive)
;   (intero-devel-reload))
;
; (add-hook 'haskell-mode-hook 'intero-mode)
; ;; key map
; (define-key intero-mode-map (kbd "C-`") 'flycheck-list-errors)
; (define-key intero-mode-map [f12] 'intero-devel-reload)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(provide 'haskell-config)

;;; haskell-config.el ends here
