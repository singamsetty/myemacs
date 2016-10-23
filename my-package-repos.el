;;; package --- package respository information for Emacs
;;;
;;; name: my-package-repos.el
;;; description: This file contains all the packages to be laoded and installed
;;;              by Emacs during startup. Any new package required by the apps
;;;              or any custom settings needs to be specified here so that they
;;;              can be installed and loaded.
;;;
;;; Commentary:
;;;              Modules loading for Emacs
;;
;-------------------------------------------------------------------------------
;; Use M-x package-refresh-contents to reload the list of
;; packages after adding these for the first time
;; required default standard libraries
(require 'cl)
(require 'cl-lib)
(require 'package)
;-------------------------------------------------------------------------------

;;; Code:

;===============================================================================
; Package repositories (gnu, melpa, melpa-stable and marmalade)
;===============================================================================
(add-to-list 'package-archives
             '("gnu" . "http://elpa.gnu.org/packages/") t)
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/") t)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)
(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/") t)
;===============================================================================


;; package archive priorities
; (setq package-archive-priorities
;       '(("marmalade" . 20)
;         ("gnu" . 10)
;         ("melpa" . 0)
;         ("melpa-stable" . 0)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Define custom directories for the packages
;; packages/elpa will contain the standard packages
;; modules dir will contain the custom built and lang specific modules
;; vendor dir will contain 3rd party or unavailable packages
;; Define a top-level, vendor and custom files
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defconst home-dir "~")
(defvar emacs-dir (file-name-directory load-file-name)
  "Top level Emacs dir.")
(defvar emacs-dir (file-name-directory "~/.emacs.d")
  "Top level Emacs dir.")
(defvar vendor-dir (expand-file-name "vendor" emacs-dir)
  "Packages not yet available in ELPA.")
(defvar module-dir (expand-file-name "modules" emacs-dir)
  "Personal stuff.")
(defvar save-dir (expand-file-name "cache" emacs-dir)
  "Common directory for automatically generated save/history/files/etc.")
(defvar pkg-dir (expand-file-name "packages" emacs-dir)
    "Package installation directory for all Emacs packages.")

(add-to-list 'load-path pkg-dir)
(setq package-user-dir (concat pkg-dir "/elpa"))

;===============================================================================

;;
; initialize the packages
;;
(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
; packages to be installed
; defvar is the correct way to declare global variables
; setq is supposed to be use just to set variables and
; not create them.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar required-packages
  '(;;; appearance and visual customizations ;;;
    powerline                           ;; powerline smart mode
    rainbow-delimiters                  ;; colorful modes (delimiters and color codes)
    rainbow-mode                        ;; colored identifiers
    rainbow-identifiers                 ;; colored identifiers
    airline-themes                      ;; fancy vim airline themes
    ;;; color themes for emacs ;;;
    color-theme                         ;; install color themes
    sublime-themes                      ;; sublime themes
    darkokai-theme                      ;; dark theme based on monokai
    moe-theme                           ;; group of moe themes
    monokai-theme                       ;; monokai theme
    zenburn-theme                       ;; zenburn color theme
    material-theme                      ;; material themes
    color-theme-sanityinc-tomorrow      ;; tomorrow themes
    color-theme-sanityinc-solarized     ;; solarized themes
    colorsarenice-theme                 ;; a colorful color theme
    kooten-theme                        ;; a dark color theme by kootenpv
    ;;; auto completions ;;;
    company                             ;; cmopany autocompletion modes
    company-jedi                        ;; company jedi mode for python
    company-distel                      ;; company distel mode for erlang
    distel-completion-lib               ;; distel-completion is needed for company-distel
    auto-complete                       ;; auto completion for gnu emacs
    auto-complete-distel                ;; auto completion  distel for erlang
    company-dict                        ;; backend that emulates ac-source-dictionary
    company-quickhelp                   ;; documentation popup for company
    ;;; some utilities ;;;
    parent-mode                         ;; get major mode's parent modes
    ; ido                               ;; IDO mode
    ; smex
    ;;; essential utilities ;;;
    smartparens                         ;; parenthesis management
    paredit                             ;; minor mode for editing parentheses
    ;;; documentation and help ;;;
    markdown-mode                       ;; markdown language support
    ;; auctex                           ;; AUCTEX and LATEX
    ;;; syntax checkers
    flycheck                            ;; flycheck on the fly syntax checker
    flycheck-color-mode-line            ;; flycheck colors for highlighting errors
    flycheck-pos-tip                    ;; flycheck errors display in tooltip
    flycheck-tip                        ;; show flycheck/flymake errors by tooltip
    popup                               ;; show popup for flycheck

    flymake-easy                        ;; flymake on the fly syntax checker
    flymake-python-pyflakes             ;; flymake handler for syntax-checking Python source code using pyflakes or flake8
    flymake-hlint                       ;; linting for haskell
    flymake-cursor                      ;; show flymake errors in minibuffer
    ;;; org modes ;;;
    org                                 ;; org-mode setup
    org-bullets                         ;; org mode with bullets
    ;;; git integration ;;;
    magit                               ;; git status
    ;;; language and IDE setup ;;;
    virtualenvwrapper                   ;; virtualenv wrapper for python
    jedi                                ;; python jedi IDE
    elpy                                ;; python elpy IDE
    python-pylint                       ;; python linter
    py-yapf                             ;; python yapf
    pyvenv                              ;; python virtual environment interface for Emacs
    ;;; haskell programming modes ;;;
    haskell-mode                        ;; haskell language support
    company-ghc                         ;; haskell company autocompletion
    company-cabal                       ;; cabal company support
    shm                                 ;; structured haskell mode
    haskell-snippets                    ;; haskell language snippets
    hindent                             ;; haskell code indenting
    flycheck-haskell                    ;; haskell syntax checker
    hi2                                 ;; for haskell-indentation, 2nd try
    ghc                                 ;; haskell ghc
    ; intero                            ;; complete dev environment for haskell
    ;;; erlang laguage support ;;;
    erlang                              ;; erlang emacs plugin
    ; edts                              ;; erlang development ide
    ;;; scala development with ensime ;;;
    ensime                              ;; ENhanced Scala Interaction Mode for Emacs
    ;; Yasnippets package
    yasnippet                           ;; yasnippets for supporting languages
    ;;; important utilities ;;;
    helm                                ;; incremental completion and selection narrowing framework
    ;;; essential packs ;;;
    ecb                                 ;; emacs code browser
    buffer-move                         ;; move buffer
    ;;; utilities ;;;
    highlight-symbol                    ;; automatic and manual symbol highlighting for Emacs
    all-the-icons                       ;; package for showing various icons
    xah-math-input                      ;; show math input symbols
    ;;; keyboard mappings ;;;
    key-chord                           ;; map pairs of simultaneously pressed keys to commands
    diminish                            ;; Diminished modes are minor modes with no modeline display
    multiple-cursors                    ;; multiple cursors for emacs
  )
  "A list of packages that will be installed if not present when firing Emacs.")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
; Add the above packages to the load-path
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(unless (file-exists-p save-dir)
  (make-directory save-dir))
(add-to-list 'load-path module-dir)
(add-to-list 'load-path vendor-dir)



;;
; Requires packages in the modules/ directory
(mapc 'load (directory-files module-dir nil "^[^#].*el$"))
; Requires packages in the vendor/ directory
(mapc 'load (directory-files vendor-dir nil "^[^#].*el$"))



;;
; function to check if all listed packages are installed. return true when
; package is not installed. When Emacs boots, check to make sure all the
; packages defined in required-packages are installed. If not ELPA kicks in.
;;
(defun packages-installed-p ()
  "Load each package specified in the required-packages section."
  (loop for pkg in required-packages
        when (not (package-installed-p pkg)) do (return nil)
            finally (return t)))



;;
; if not all packages are installed, check one by one and install the missing ones.
;;
(unless (packages-installed-p)
  ; check for new packages (package versions)
  (message "%s" "Emacs is now refreshing its package database...")
  (package-refresh-contents)
  (message "%s" " done.")
  ; install the missing packages
  (dolist (p required-packages)
    (when (not (package-installed-p p))
      (package-install p))))

(provide 'required-packages)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
; package loading from custom el files
; currently support for the below
; haskell
; erlang
; python3
; flycheck
; paredit
; rainbow-delimiters
; hihlight-symbols
; fringe
;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar configs
    '(
      "haskell-config"
      "erlang-config"
      "python-config"
      "flycheck-colors-config"
      "rainbow-delims-config"
      "paredit-config"
      "highlight-symbol-config"
      "fringe-config"
      )
    "Configuration files which follow the modules/pkgname-config.el format."
    )

;;
; loop through and load the configured custom packages
;;
(loop for name in configs
      do (load (concat (file-name-directory load-file-name)
                       "modules/"
                       name ".el")))


;;
; load packages from custom path
;;
(defvar custom-load-paths
  '("erlang/elisp")
  "Custom load paths that do not follow the normal vendor/elisp/module-name.el format."
  )

;;
; loop through the custom lisp
;;
(loop for location in custom-load-paths
      do (add-to-list 'load-path
             (concat (file-name-directory (or load-file-name
                                              (buffer-file-name)))
                     "vendor/erlang/elisp"
                     location)))


;;; my-package-repos.el ends here
