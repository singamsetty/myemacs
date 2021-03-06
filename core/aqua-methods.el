;;; package --- aqua-methods.el
;;;
;;; Commentary:
;;; Filename   : aqua-methods.el
;;; Description: any custom methods can all be defined here.
;;;
;;; Code:
;;; Updated    : 06 Apr 2018


;;------------------------------------------------------------------------------
;;** identify unnecessary whitespace in all the programming modes
;;** whitespace-cleanup command for clearing trailing white spaces
;;------------------------------------------------------------------------------
(require 'whitespace)                           ;; this is an internal package
(setq-default show-trailing-whitespace t)
(set-default 'indent-tabs-mode nil)


;;------------------------------------------------------------------------------
(setq my-command-buffer-hooks (make-hash-table))
(defun aqua/command-on-save-buffer (c)
  "C Run a command <c> every time the buffer is saved."
  (interactive "sShell command: ")
  (puthash (buffer-file-name) c my-command-buffer-hooks))

;;------------------------------------------------------------------------------
(defun aqua/command-buffer-kill-hook ()
  "Remove a key from <command-buffer-hooks> if it exists."
  (remhash (buffer-file-name) my-command-buffer-hooks))


;;------------------------------------------------------------------------------
(defun aqua/command-buffer-run-hook ()
  "Run a command if it exists in the hook."
  (let ((hook (gethash (buffer-file-name) my-command-buffer-hooks)))
    (when hook
      (shell-command hook))))


;;------------------------------------------------------------------------------
;;** add a function for inserting the current date time.
;;------------------------------------------------------------------------------
(defun aqua/insert-date (prefix)
  "Insert the current date with PREFIX, use ISO format.
With two prefix arguments, write out the day and month name."
  (interactive "P")
  (let ((format (cond
                 ((not prefix) "%Y-%m-%d %H:%M")
                 ((equal prefix '(4)) "%Y-%m-%d")
                 ((equal prefix '(16)) "%A, %d. %B %Y"))))
    (insert (format-time-string format))))

;;------------------------------------------------------------------------------
;;** function to get the current system's name and defining system types
;;------------------------------------------------------------------------------
(defun aqua/insert-system-name()
  (interactive)
  "Get current system's name"
  (insert (format "%s" (system-name))))

(defun aqua/is-mac()
  "Get and see if the System type is MAC."
  (interactive)
  (string-equal system-type "darwin"))

(defun aqua/is-linux()
  "Get and see if the System type is Linux."
  (interactive)
  (string-equal system-type "gnu/linux"))

;;------------------------------------------------------------------------------
;;** function to get current system type
;;------------------------------------------------------------------------------
(defun aqua/insert-system-type()
  (interactive)
  "Get current system type."
  (insert (format "%s" system-type)))

;;------------------------------------------------------------------------------
;;** function to get face information at a position
;;------------------------------------------------------------------------------
(defun aqua/get-faces (pos)
  "Get the font faces at POS."
  (remq nil
        (list
         (get-char-property pos 'read-face-name)
         (get-char-property pos 'face)
         (plist-get (text-properties-at pos) 'face))))

;;** function to check if the named font is available
(defun aqua/font-existsp (font)
  "Check if the specified FONT is available."
  (interactive)
  (if (null (x-list-fonts font))
      nil t))


;;------------------------------------------------------------------------------
;;** print the face found at the current point (M-x what-face)
;;------------------------------------------------------------------------------
(defun aqua/what-face (pos)
  "Print font face at the POS."
  (interactive "d")
  (let ((face (or (get-char-property (point) 'read-face-name)
                  (get-char-property (point) 'face))))
    (if face (message "Face: %s" face) (message "No face at %d" pos))))

;;------------------------------------------------------------------------------
;;** function to reduce the cruft in modeline (rename major mode)
;;------------------------------------------------------------------------------
(defmacro aqua/rename-modeline (package-name mode new-name)
  "Rename the PACKAGE-NAME in the MODE on mode line to NEW-NAME."
  `(eval-after-load ,package-name
     '(defadvice ,mode (after rename-modeline activate)
        (setq mode-name ,new-name))))

;;------------------------------------------------------------------------------
;;** reloading the .emacs configuration file
;;------------------------------------------------------------------------------
(defun aqua/reload-dot-emacs ()
  "Save the .emacs buffer if required and reload .emacs."
  (interactive)
  (let ((dot-emacs (concat (getenv "HOME") "/.emacs")))
    (and (get-file-buffer dot-emacs)
         (save-buffer (get-file-buffer dot-emacs)))
    (load-file dot-emacs))
  (message "--> Emacs re-initialized."))


;;------------------------------------------------------------------------------
;;** get the major version as Aquamacs has none
;;------------------------------------------------------------------------------
(defconst aq-major-version
  (progn (string-match "^[0-9]+" emacs-version)
         (string-to-number (match-string 0 emacs-version)))
  "Major version number of this version of Emacs.
This variable first existed in version 19.23.")


;;------------------------------------------------------------------------------
;;** functions for un-setting key maps and checking key maps
;;------------------------------------------------------------------------------
(defun aqua/get-key-combo (key)
  "Just return the KEY combo entered by the user."
  (interactive "kKey combo: ")
  key)

(defun aqua/keymap-unset-key (key keymap)
  "Remove binding of KEY in a KEYMAP where KEY is a string or vector representing a sequence of keystrokes."
  (interactive
   (list (call-interactively #'get-key-combo)
         (completing-read "Which map: " minor-mode-map-alist nil t)))
  (let ((map (rest (assoc (intern keymap) minor-mode-map-alist))))
    (when map
      (define-key map key nil)
      (message  "%s unbound for %s" key keymap))))
;;
;; Then use it interativly
;; Or like this: (keymap-unset-key  '[C-M-left]   "paredit-mode")
;;


;;------------------------------------------------------------------------------
;;** function for setting default fonts
;;------------------------------------------------------------------------------
(defun aqua/default-fonts ()
  "Set up the fonts that I like for my work."
  (interactive)
  (set-face-font 'menu "-*-Monaco for Powerline-normal-normal-normal-*-12-*-*-*-p-0-iso10646-1")
  (set-face-font 'default "-*-Monaco for Powerline-normal-normal-normal-*-12-*-*-*-p-0-iso10646-1"))


;;------------------------------------------------------------------------------
;;** [ESC] - exit the evils insert state and also close the company popup
;;------------------------------------------------------------------------------
(defun aqua/company-abort ()
  "Pressing ESC should close POPUP."
  (interactive)
  (company-abort)
  (when (and (bound-and-true-p evil-mode)
             (eq evil-state 'insert))
    (evil-force-normal-state)))

;;------------------------------------------------------------------------------
;;** utility function to (brokenly :< ) handle versioned dirs
;;------------------------------------------------------------------------------
(defun aqua/wild (dir stem)
  "Return the last (alphabetically) file name that match DIR/STEM*."
  (car
   (reverse
    (sort
     (let (value)
       (dolist (element (file-name-all-completions stem dir) value)
         (setq value (cons (concat dir element) value)))) 'string-lessp))))

;;------------------------------------------------------------------------------
;;** kill all other buffers
;;------------------------------------------------------------------------------
(defun aqua/kill-other-buffers ()
  "Kill all buffers but the current one, doesn't mess with special buffers."
  (interactive)
  (dolist (buffer (buffer-list))
    (unless (or (eql buffer (current-buffer)) (not (buffer-file-name buffer)))
      (kill-buffer buffer))))


;;------------------------------------------------------------------------------
(defvar aqua--diminished-minor-modes nil
  "List of diminished modes to unicode or ascii values.")

(defmacro aqua|diminish (mode &optional unicode ascii)
  "Diminish MODE name in mode line to UNICODE or ASCII depending on the value `dotspacemacs-mode-line-unicode-symbols'. If ASCII is not provided then UNICODE
is used instead. If neither are provided, the mode will not show in the mode line."
  `(let ((cell (assq ',mode aqua--diminished-minor-modes)))
     (if cell
         (setcdr cell '(,unicode ,ascii))
       (push '(,mode ,unicode ,ascii) aqua--diminished-minor-modes))))

(defmacro aqua|hide-lighter (mode)
  "Diminish MODE name in mode line to LIGHTER."
  `(eval-after-load 'diminish '(diminish ',mode)))


;;------------------------------------------------------------------------------
;; list of current active modes
;;------------------------------------------------------------------------------
(defun aqua/list-active-modes()
  "List all the active modes in current buffer."
  (interactive)
  (let ((active-modes))
    (mapc (lambda (mode) (condition-case nil
                        (if (and (symbolp mode) (symbol-value mode))
                            (add-to-list 'active-modes mode))
                      (error nil)))
          minor-mode-list)
    (message "Current active modes list %s" active-modes)))

;;------------------------------------------------------------------------------
;;** https://github.com/cofi/dotfiles/blob/master/emacs.d/config/cofi-util.el
;;------------------------------------------------------------------------------
(defun aqua/add-to-hooks (fun hooks)
  "Add function FUN to hooks HOOKS."
  (dolist (hook hooks)
    (add-hook hook fun)))


(defun aqua/add-to-hook (hook funs)
  "Add to HOOK, list of functions FUNS."
  (dolist (fun funs)
    (add-hook hook fun)))


(defun aqua/add-all-to-hook (hook &rest funs)
  "Add to HOOK FUNS."
  (aqua/add-to-hook hook funs))


;;------------------------------------------------------------------------------
;;** add hooks | fill n unfill
;;------------------------------------------------------------------------------
(add-hook 'kill-buffer-hook 'aqua/command-buffer-kill-hook)
(add-hook 'after-save-hook 'aqua/command-buffer-run-hook)

;; http://endlessparentheses.com/fill-and-unfill-paragraphs-with-a-single-key.html
; (defun aqua/fill-or-unfill ()
;   "Like `fill-paragraph', but unfill if used twice."
;   (interactive)
;   (let ((fill-column
;          (if (eq last-command 'endless/fill-or-unfill)
;              (progn (setq this-command nil)
;                     (point-max))
;            fill-column)))
;     (call-interactively #'fill-paragraph)))

; (bind-key [remap fill-paragraph] #'endless/fill-or-unfill)

;;------------------------------------------------------------------------------
;;** indentation function
;;------------------------------------------------------------------------------
(defun aqua/indent-reformat-buffer-on-save ()
  "Indent an entire buffer with the default indentation scheme."
  (interactive)
  (save-excursion
    (delete-trailing-whitespace)
    (indent-region (point-min) (point-max) nil)
    (untabify (point-min) (point-max))))

;;** functions for custom display
(defvar aqua-display-system-init-list '()
  "Function list to be run after display system initialization.")

;;----------------------------------------------------------------------------
;;** toggle menu-bar, scroll-bar and tool-bar
;;----------------------------------------------------------------------------
(defun aqua/toggle-bars ()
 "Toggles the menu, tool and scroll bars."
 (interactive)
 (if menu-bar-mode
     (progn
       (menu-bar-mode -1)
       (tool-bar-mode -1)
       (scroll-bar-mode -1))
   (progn
     (menu-bar-mode 1)
     (scroll-bar-mode 1)
     (tool-bar-mode 1))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(provide 'aqua-methods)

;; Local Variables:
;; coding: utf-8
;; mode: emacs-lisp
;; End:

;;; aqua-methods.el ends here
