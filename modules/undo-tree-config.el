;;; package --- undo-tree-config.el configuration settings for undo visualisation
;;;
;;; Commentary:
;;;
;;; Filename   : unto-tree-config.el
;;; Description: Emacs Undo Tree Visualisation
;;;
;;; elisp code for customizing the undo-tree
;;; undo-tree: undo (C-/) behaves just like normal editor.  To redo, C-_
;;; To open the undo tree, C-x u
;;;
;;; Code:
;;;
;;;

(lazy-init
 (require 'undo-tree)

 ;; auto save the undo-tree history
 (after "undo-tree-autoloads"
   (setq undo-tree-auto-save-history t)
   (setq undo-tree-history-directory-alist
         `(("." . ,(expand-file-name "undo" cache-dir))))
   (setq undo-tree-visualizer-timestamps t)
   (setq undo-tree-visualizer-diff t)
   (global-undo-tree-mode))
 ;; volatile highlights
 (after "volatile-highlights"
   (vhl/define-extension 'undo-tree 'undo-tree-yank 'undo-tree-move)
   (vhl/install-extension 'undo-tree)))

(provide 'undo-tree-config)

;; Local Variables:
;; coding: utf-8
;; mode: emacs-lisp
;; End:

;;; undo-tree-config.el ends here
