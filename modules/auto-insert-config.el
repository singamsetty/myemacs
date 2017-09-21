;;; package --- customize auto-insert configuration for Emacs
;;; auto-insert-config.el ---
;;; -*- coding: utf-8 -*-
;;;
;;; Commentary:
;;;              automatically insert headers based on file type
;;;
;;; Filename   : auto-insert-config.el
;;; Description: auto-insert configuration for Emacs
;;;===========================================================================

;;; Code:

(require 'autoinsert)

(auto-insert-mode 1)
(auto-insert)

(setq auto-insert-alist
      '(((erlang-mode . "Erlang program") nil
         "%%%-----------------------------------------------------------------------------\n"
         "%%% File: " (file-name-nondirectory buffer-file-name) "\n"
         "%%% @author " (user-full-name) " <" (progn user-mail-address) ">\n"
         "%%% @copyright (C) " (format-time-string "%Y")  " " (user-full-name) "\n"
         "%%% @doc\n"
         "%%%\n"
         "%%% @end\n"
         "%%% Created " (format-time-string "%d %b %Y") "\n"
         "%%%-----------------------------------------------------------------------------\n\n"
         "-module(" (file-name-base buffer-file-name) ").\n\n")
         ;;"-module(." (file-name-sans-extension buffer-file-name) ").\n")
        ((python-mode . "Python program") nil
         "#!/usr/bin/env python\n"
         "# -*- encoding:utf-8 -*-\n"
         "# @Copyright (C) " (substring (current-time-string) -4) " " (user-full-name) "\n\n"
         "# @File        : " (file-name-nondirectory buffer-file-name) "\n"
         "# @Author      : " (user-full-name) " <" (progn user-mail-address) ">\n"
         "# @Time-stamp  : " (format-time-string "%a %b %d %H:%M:%S %Z %Y") "\n"
         "# @Description : " _ "\n"
         "#\n"
         "################################################################################\n\n")
        ((c-mode . "C program") nil
         "/*\n"
         " * File: " (file-name-nondirectory buffer-file-name) "\n"
         " * Time-stamp: <>\n"
         " * Copyright (C) " (substring (current-time-string) -4) " " (user-full-name) "\n"
         " * Description: " _ "\n"
         " */\n\n")
        ((c++-mode . "CPP program") nil
         "/*\n"
         " *================================================================================\n\n"
         " * Filename      : " (file-name-nondirectory buffer-file-name) "\n"
         " * Description   : " _ "\n"
         " * Version       : 1.0\n"
         " * Created       : " (format-time-string "%a %b %d %H:%M:%S %Z %Y") "\n"
         " * Revision      : none\n"
         " * Compiler      : gcc\n"
         " * Author        : " (progn user-full-name) " <" (progn user-mail-address) ">\n"
         " * Organization  : "
         " * Copyright (C) " (substring (current-time-string) -4) " " (user-full-name) "\n"
         " *================================================================================\n"
         " */\n\n")
        ((sh-mode . "Shell script") nil
         "#!/usr/bin/env bash\n"
         "# -*- mode: sh; -*-\n\n"
         "# File: " (file-name-nondirectory buffer-file-name) "\n"
         "# Time-stamp: <>\n"
         "# Copyright (C) " (substring (current-time-string) -4) " " (user-full-name) "\n"
         "# Description: " _ "\n\n"
         "set -o errexit\n\n"
         "[ -z $BASH ] && (echo \"Not in a BASH sub process\"; exit 1)\n"
         "BASE_DIR=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)\n\n")
        ((restclient-mode . "REST client") nil
         "# -*- restclient -*-\n\n")
        ((org-mode . "Org mode") nil
         "#+AUTHOR: " (user-full-name) "\n"
         "#+DATE: " (current-time-string) "\n"
         "#+STARTUP: showall\n\n")))

(provide 'auto-insert-config)

;;; auto-insert-config.el ends here