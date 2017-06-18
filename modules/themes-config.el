;;; package --- themes-config.el configuration settings for color theme
;; -*- mode: emacs-lisp -*-
;;;
;;; Commentary:
;;;
;;; Filename   : themes-config.el
;;; Description: Emacs Color themes set or unset values
;;;
;;; elisp code for customizing the color theme
;;===============================================================================
;;;
;;; Code:
;;;
;;-------------------------------------------------------------------------------
;; fancy modeline(s) - powerline, airline and sml
;;-------------------------------------------------------------------------------
(require 'powerline)
(powerline-default-theme)


;;-------------------------------------------------------------------------------
;; define constants for holding the themes
;;-------------------------------------------------------------------------------
(defcustom aqua-airline-theme nil
  "Select an appropriate Airline Theme."
  :type 'symbol)

(defcustom aqua-sml-theme nil
  "Theme for smart-mode-line."
  :type 'symbol)

;; change the airline themes as required from the below
(setq aqua-airline-theme 'airline-cool)
;; Alternatives
;; (setq aqua-airline-theme 'airline-light)
;; (setq aqua-airline-theme 'airline-kalisi)


;; set smart-mode-line theme
(setq aqua-sml-theme 'powerline)
;; Alternatives:
;; (sml/apply-theme 'powerline)
;; (sml/apply-theme 'dark)
;; (sml/apply-theme 'light)
;; (sml/apply-theme 'respectful)
;; (sml/apply-theme 'automatic)


;;-------------------------------------------------------------------------------
;; vim airline theme for emacs modeline customized display
;;-------------------------------------------------------------------------------
(defun load-airline-settings ()
  "Load required Airline theme settings."
  (interactive)
  (require 'airline-themes)
  ;; setting powerline fonts for font glyphs
  (setq powerline-utf-8-separator-left        #xe0b0
        powerline-utf-8-separator-right       #xe0b2
        airline-utf-glyph-separator-left      #xe0b0
        airline-utf-glyph-separator-right     #xe0b2
        airline-utf-glyph-subseparator-left   #xe0b1
        airline-utf-glyph-subseparator-right  #xe0b3
        airline-utf-glyph-branch              #xe0a0
        airline-utf-glyph-readonly            #xe0a2
        airline-utf-glyph-linenumber          #xe0a1))

(defun apply-airline ()
  "Apply the Airline Themes as needed."
  (interactive)
  ;; load airline settings
  (load-airline-settings)
  ;; load the airline theme
  (load-theme aqua-airline-theme t))


;;-------------------------------------------------------------------------------
;; smart-mode-line enable/disable
;;-------------------------------------------------------------------------------
(defun apply-sml ()
  "Apply Smart Mode Line if needed."
  (interactive)
  (require 'smart-mode-line)
  (if (require 'smart-mode-line nil 'noerror)
      (progn
        (setq sml/name-width 20)
        (setq sml/mode-width 'full)
        (setq sml/shorten-directory t)
        (setq sml/shorten-modes t)
        (setq sml/no-confirm-load-theme t)
        (rich-minority-mode 1)
        ;; for hiding minor modes
        (setq rm-blacklist '(" GitGutter" " Helm" " es" " Guide"))
        (if after-init-time
            (sml/setup)
          (add-hook 'after-init-hook #'sml/setup))
        (if (not (null aqua-sml-theme))
            (setq sml/theme aqua-sml-theme)
          ;; delegate theme to the current active one
          (setq sml/theme nil))
        (setq sml/replacer-regexp-list
              '(("^~/org/" ":O:")
                ("^~/code/" ":CODE:")
                ("^~/\\.emacs\\.d/" ":ED:")))))
  ;; (setq sml/no-confirm-load-theme t)
  ;; (if (not (null aqua-sml-theme))
  ;;     (setq sml/theme aqua-sml-theme)
  ;;   ;; delegate theme to current active one
  ;;   (setq sml/theme nil))
  )


;;-------------------------------------------------------------------------------
;; setting default color theme to required (from Steve Purcell .emacs)
;;-------------------------------------------------------------------------------
(setq-default custom-enabled-themes '(
                                      sanityinc-solarized-light
                                      ;sanityinc-tomorrow-day
                                      ;majapahit-dark
                                      ;majapahit-light
                                      ))

;; Ensure that themes will be applied even if they have not been customized
(defun reapply-themes ()
  "Forcibly load the themes listed in `custom-enabled-themes'."
  (interactive)
  (dolist (theme custom-enabled-themes)
    (unless (custom-theme-p theme)
      (message "loading the theme %s" theme)
      (load-theme theme t)))
  (custom-set-variables `(custom-enabled-themes (quote ,custom-enabled-themes))))

;; disabling the current themes
(defun disable-all-themes ()
  "Disable each currently enabled theme."
  (interactive)
  (mapc #'disable-theme custom-enabled-themes))

;;-------------------------------------------------------------------------------
;; load the required airline settings
;;-------------------------------------------------------------------------------
; (add-hook 'after-init-hook 'load-airline-settings)

;;-------------------------------------------------------------------------------
;; uncomment if airline themes are required
;;-------------------------------------------------------------------------------
; (add-hook 'after-init-hook 'apply-airline)

;;-------------------------------------------------------------------------------
;; uncomment if sml is required
;;-------------------------------------------------------------------------------
(add-hook 'after-init-hook 'apply-sml)

;;-------------------------------------------------------------------------------
;; apply the themes after emacs initializes
;;-------------------------------------------------------------------------------
(add-hook 'after-init-hook 'reapply-themes)


;;------------------------------------------------------------------------------
;; Toggle between light and dark solarized themes
;;------------------------------------------------------------------------------
(defun light ()
  "Activate a solarized light color theme."
  (interactive)
  (require 'color-theme-sanityinc-solarized)
  (color-theme-sanityinc-solarized-light))

(defun dark ()
  "Activate a solarized dark color theme."
  (interactive)
  (require 'color-theme-sanityinc-tomorrow)
  (color-theme-sanityinc-solarized-dark))

;;------------------------------------------------------------------------------
;; Toggle between prelude's light and dark solarized themes
;;------------------------------------------------------------------------------
(defun prelude-solarized-settings ()
  "Settings for the prelude solarized themes."
  (interactive)
  ;; make the fringe stand out from the background
  (setq solarized-distinct-fringe-background t)
  ;; Don't change the font for some headings and titles
  (setq solarized-use-variable-pitch nil)
  ;; make the modeline high contrast
  (setq solarized-high-contrast-mode-line t)
  ;; Use less bold font
  (setq solarized-use-less-bold t)
  ;; Use more italics
  (setq solarized-use-more-italic t)
  ;; Use less colors for indicators such as git:gutter, flycheck and similar
  (setq solarized-emphasize-indicators nil)
  ;; Don't change size of org-mode headlines (but keep other size-changes)
  (setq solarized-scale-org-headlines nil)
  ;; Avoid all font-size changes
  (setq solarized-height-minus-1 1.0)
  (setq solarized-height-plus-1 1.0)
  (setq solarized-height-plus-2 1.0)
  (setq solarized-height-plus-3 1.0)
  (setq solarized-height-plus-4 1.0)
  (message "loading the custom settings for solarized..."))

(defun slight ()
  "Activate prelude solarized light theme."
  (interactive)
  (require 'solarized-theme)
  (prelude-solarized-settings)
  (load-theme 'solarized-light t))

(defun sdark ()
  "Activate prelude solarized light theme."
  (interactive)
  (require 'solarized-theme)
  (prelude-solarized-settings)
  (load-theme 'solarized-dark t))

;;------------------------------------------------------------------------------
;; Toggle between spacemacs's light and dark themes
;;------------------------------------------------------------------------------
(defun space-light ()
  "Activate spacemacs light theme"
  (interactive)
  (load-theme 'spacemacs-light t))


(defun space-dark ()
  "Activate spacemacs light theme"
  (interactive)
  (load-theme 'spacemacs-dark t))


;;-------------------------------------------------------------------------------
;; automatically switch colors between dark and light based on the system time
;;-------------------------------------------------------------------------------
;; (require 'moe-theme-switcher)
(defun moe ()
  "Activate moe light theme."
  (interactive)
  (require 'moe-theme)
  (powerline-moe-theme)
  (setq moe-theme-highlight-buffer-id t
        moe-theme-resize-markdown-title '(1.5 1.4 1.3 1.2 1.0 1.0)
        moe-theme-resize-org-title '(1.5 1.4 1.3 1.2 1.1 1.0 1.0 1.0 1.0)
        moe-theme-resize-rst-title '(1.5 1.4 1.3 1.2 1.1 1.0))
  (moe-theme-set-color 'cyan)
  (powerline-moe-theme)
  (moe-light))

;;-------------------------------------------------------------------------------

(provide 'themes-config)

;;; themes-config.el ends here
