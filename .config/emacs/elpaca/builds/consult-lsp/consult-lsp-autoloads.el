;;; consult-lsp-autoloads.el --- automatically extracted autoloads (do not edit)   -*- lexical-binding: t -*-
;; Generated by the `loaddefs-generate' function.

;; This file is part of GNU Emacs.

;;; Code:



;;; Generated autoloads from consult-lsp.el

(autoload 'consult-lsp-diagnostics "consult-lsp" "\
Query LSP-mode diagnostics.

When ARG is set through prefix, query all workspaces.

(fn ARG)" t)
(autoload 'consult-lsp-symbols "consult-lsp" "\
Query workspace symbols. When ARG is set through prefix, query all workspaces.

(fn ARG)" t)
(autoload 'consult-lsp-file-symbols "consult-lsp" "\
Search symbols defined in current file in a manner similar to `consult-line'.

If the prefix argument GROUP-RESULTS is specified, symbols are grouped by their
kind; otherwise they are returned in the order that they appear in the file.

(fn GROUP-RESULTS)" t)
(register-definition-prefixes "consult-lsp" '("consult-lsp-"))

;;; End of scraped data

(provide 'consult-lsp-autoloads)

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; no-native-compile: t
;; coding: utf-8-emacs-unix
;; End:

;;; consult-lsp-autoloads.el ends here
