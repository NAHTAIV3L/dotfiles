(setq user-full-name    "Riley Beckett"
      user-mail-address "rbeckettvt@gmail.com"
      make-backup-files nil
      create-lockfiles  nil
      confirm-kill-processes nil)
(setq-default indent-tabs-mode nil)

(setq inhibit-startup-message t)
(setq backup-inhibited t)

(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 20)        ; Give some breathing room

(menu-bar-mode -1)            ; Disable the menu bar

(setq scroll-up-aggressively nil)
(setq scroll-down-aggressively nil)
(setq scroll-conservatively 101)
(setq display-line-numbers 'relative)

(column-number-mode)
(global-display-line-numbers-mode t)
(global-hl-line-mode t)

(dolist (mode '(org-mode-hook
        	term-mode-hook
        	vterm-mode-hook
        	shell-mode-hook
        	eshell-mode-hook
                mu4e-main-mode-hook
                mu4e-headers-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(setq scroll-up-aggressively nil)
(setq scroll-down-aggressively nil)
(setq scroll-conservatively 101)

(setq scroll-step 1)
(setq scroll-margin 8)

(setq gc-cons-threshold (* 50 1000 1000))

(defun display-startup-time ()
  (interactive)
  (message "Emacs loaded in %s with %d garbage collections."
           (format "%.2f seconds"
      	           (float-time
      	            (time-subtract after-init-time before-init-time)))
           gcs-done))

(add-hook 'emacs-startup-hook #'display-startup-time)

(defun browse-config ()
  (interactive)
  (let ((default-directory (file-truename (expand-file-name "~/.config/emacs/"))))
    (call-interactively #'find-file)))

(defun lookup-password (&rest keys)
  (let ((result (apply #'auth-source-search keys)))
    (if result
        (funcall (plist-get (car result) :secret))
      nil)))

(defun map! (key desc &optional fun)
  (if fun (define-key myemacs-leader-map (kbd key) fun))
  (which-key-add-keymap-based-replacements myemacs-leader-map key desc))

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)

(setq straight-use-package-by-default t)

(use-package diminish)
(diminish 'abbrev-mode)

(recentf-mode 1)
(use-package no-littering)
(add-to-list 'recentf-exclude
             (recentf-expand-file-name no-littering-var-directory))
(add-to-list 'recentf-exclude
             (recentf-expand-file-name no-littering-etc-directory))
(setq custom-file (no-littering-expand-etc-file-name "custom.el"))

(use-package gcmh
  :diminish gcmh-mode
  :init
  (gcmh-mode 1))

(use-package vertico
  :diminish vertico-mode
  :straight (:files (:defaults "extensions/*")) 
  :bind (:map vertico-map
              ("C-n" . vertico-next)
              ("C-p" . vertico-previous))
  :init
  (vertico-mode 1)
  (setq vertico-count 15))

;; Configure directory extension.
(use-package vertico-directory
  :after vertico
  :straight nil
  ;; More convenient directory navigation commands
  :bind (:map vertico-map
              ("RET" . vertico-directory-enter)
              ("DEL" . vertico-directory-delete-char)
              ("M-DEL" . vertico-directory-delete-word))
  ;; Tidy shadowed file names
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

(use-package savehist
  :diminish savehist-mode
  :init
  (savehist-mode 1))

(use-package marginalia
  :diminish marginalia-mode
  :after vertico
  :custom
  (marginalia-annotators '(marginalia-annotators-heavy marginalia-annotators-light nil))
  :init
  (marginalia-mode))

(use-package consult)
(setq completion-in-region-function
      (lambda (&rest args)
        (apply (if vertico-mode
                   #'consult-completion-in-region
                 #'completion--in-region)
               args)))
(consult-customize consult-buffer :preview-key "M-.")

(use-package orderless
  :config
  (setq completion-styles '(orderless)
        completion-category-defaults nil
        completion-category-overrides '((file (styles . (partial-completion))))))

(use-package flyspell
  :diminish flyspell-mode)

(use-package flyspell-correct
  :after flyspell)

(use-package consult-flyspell
  :straight (consult-flyspell :type git :host gitlab :repo "OlMon/consult-flyspell" :branch "master")
  :config
  ;; default settings
  (setq consult-flyspell-select-function (lambda () (flyspell-correct-at-point) (consult-flyspell))
        consult-flyspell-set-point-after-word t
        consult-flyspell-always-check-buffer nil))

(setq-default mode-line-buffer-identification
                '(:eval (format-mode-line (or (when-let* ((buffer-file-truename buffer-file-truename)
                                                          (prj (cdr-safe (project-current)))
                                                          (prj-parent (file-name-directory (directory-file-name (expand-file-name prj)))))
                                                (concat (file-relative-name (file-name-directory buffer-file-truename) prj-parent) (file-name-nondirectory buffer-file-truename)))
                                              "%b"))))
  (defun ml-fill-to-right (reserve)
    "Return empty space, leaving RESERVE space on the right."
    (when (and window-system (eq 'right (get-scroll-bar-mode)))
      (setq reserve (- reserve 2))) ; Powerline uses 3 here, but my scrollbars are narrower.
    (propertize " "
                'display `((space :align-to (- (+ right right-fringe right-margin)
                                               ,reserve)))))
  (defvar ml-selected-window nil)

  (defun ml-record-selected-window ()
    (setq ml-selected-window (selected-window)))

  (defun ml-update-all ()
    (force-mode-line-update t))

  (add-hook 'post-command-hook 'ml-record-selected-window)

  (add-hook 'buffer-list-update-hook 'ml-update-all)

  (defvar mode-line-left (list 
                          '(:eval mode-line-front-space)
                          '(:eval evil-mode-line-tag)
                          " %l:%c "
                          '(:eval mode-line-mule-info)
                          '(:eval mode-line-modified)
                          '(:eval mode-line-remote)
                          " "
                          mode-line-buffer-identification))

  (defvar mode-line-right (list 
                         '(:eval (if (eq ml-selected-window (selected-window))
                                     mode-line-misc-info
                                 '(:propertize mode-line-misc-info 'face 'mode-line-inactive)))
                           " "
                           '(:eval mode-name)))

  (defvar mode-line-spacing '(:eval (ml-fill-to-right (string-width (format-mode-line mode-line-right)))))

  ;; (setq-default mode-line-format
  ;;               (list
  ;;                "%e"
  ;;                '(:eval mode-line-left)
  ;;                '(:eval mode-line-spacing)
  ;;                '(:eval mode-line-right)))
(setq-default mode-line-format
      (list
       "%e"
       '(:eval mode-line-front-space)
       '(:eval evil-mode-line-tag)
       '(:eval mode-line-mule-info)
       '(:eval mode-line-modified)
       '(:eval mode-line-remote)
       " (%l:%c) "
       mode-line-buffer-identification
       " "
       '(:eval anzu--mode-line-format)
       " "
       mode-line-modes
       " "
      '(:eval (if (eq ml-selected-window (selected-window))
                  mode-line-misc-info
                '(:propertize mode-line-misc-info 'face 'mode-line-inactive)))
      ))

(setq mode-line-format
      (list
       "%e"
       '(:eval mode-line-front-space)
       '(:eval evil-mode-line-tag)
       '(:eval mode-line-mule-info)
       '(:eval mode-line-modified)
       '(:eval mode-line-remote)
       " (%l:%c) "
       mode-line-buffer-identification
       " "
       '(:eval anzu--mode-line-format)
       " "
       mode-line-modes
       " "
      '(:eval (if (eq ml-selected-window (selected-window))
                  mode-line-misc-info
                '(:propertize mode-line-misc-info 'face 'mode-line-inactive)))
      ))

;; (use-package doom-modeline
;;   :init
;;   (setq doom-modeline-display-default-persp-name t
;;         doom-modeline-buffer-file-name-style 'relative-from-project
;;         doom-modeline-mu4e t)
;;   (doom-modeline-mode 1)
;;   :custom ((doom-modeline-height 35)))

(use-package doom-themes
  :init (load-theme 'doom-one t))

(use-package rainbow-delimiters
  :diminish rainbow-delimiters-mode
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 1))

(use-package emojify
  ;; :diminish emojify-mode
  :hook (after-init . global-emojify-mode)
  :config
  (add-hook 'prog-mode-hook #'(lambda () (emojify-mode -1))))

(use-package helpful
  :bind
  ([remap describe-command] . helpful-command)
  ([remap describe-function] . helpful-callable)
  ([remap describe-variable] . helpful-variable)
  ([remap describe-key] . helpful-key))

(use-package statusbar
  :diminish statusbar-mode
  :straight '(:package "statusbar.el" :host github :type git :repo "NAHTAIV3L/statusbar.el")
  :config
  (setq display-wifi-essid-command "iw dev $(ip addr | awk '/state UP/ {gsub(\":\",\"\"); print $2}') link | awk '/SSID:/ {printf $2}'"
        display-wifi-connection-command "iw dev $(ip addr | awk '/state UP/ {gsub(\":\",\"\"); print $2}') link | awk '/signal:/ {gsub(\"-\",\"\"); printf $2}'"))

(use-package writeroom-mode
  :diminish)

(use-package fill-column-indicator
  :diminish fci-mode
  :config
  (setq fci-rule-column 80))

(use-package autorevert
  :ensure nil
  :straight nil
  :diminish auto-revert-mode)

(use-package eldoc
  :ensure nil
  :straight nil
  :diminish eldoc-mode)

(use-package isearch
  :ensure nil
  :straight nil
  :diminish isearch-mode)

(use-package undo-tree
  :diminish undo-tree-mode
  :init
  (global-undo-tree-mode))
(add-hook 'authinfo-mode-hook #'(lambda () (setq-local undo-tree-auto-save-history nil)))
(defvar --undo-history-directory (concat user-emacs-directory "undotreefiles/")
  "Directory to save undo history files.")
(unless (file-exists-p --undo-history-directory)
  (make-directory --undo-history-directory t))
;; stop littering with *.~undo-tree~ files everywhere
(setq undo-tree-history-directory-alist `(("." . ,--undo-history-directory)))

(use-package evil
  :diminish evil-mode
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  (setq evil-undo-system 'undo-tree)
  :config
  (evil-mode 1)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :diminish evil-collection-unimpaired-mode
  :after evil
  :config
  (evil-collection-init))

(use-package evil-nerd-commenter
  :after evil)

(use-package evil-anzu
  :diminish anzu-mode
  :after evil
  :config
  (setq anzu-cons-mode-line-p nil)
  (global-anzu-mode 1))

(use-package tex
  :straight auctex)

(use-package lsp-latex
  :straight '(:package "lsp-latex.el" :host github :type git :repo "ROCKTAKEY/lsp-latex"))

(setq markdown-command "pandoc")

(use-package org
  :diminish org-mode
  :config
  (setq org-ellipsis " ▾"))

(use-package org-superstar
  :diminish org-superstar-mode
  :after org)
(add-hook 'org-mode-hook (lambda () (org-superstar-mode 1)))
(setq org-hide-leading-stars t)
(require 'org-tempo)

(add-to-list 'org-structure-template-alist '("sh" . "src shell"))
(add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
(add-to-list 'org-structure-template-alist '("py" . "src python"))

(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (python . t)))

(defun org-babel-tangle-config ()
  (when (or
         (string-equal (buffer-file-name) (expand-file-name "~/.dotfiles/.config/emacs/Emacs.org"))
         (string-equal (buffer-file-name) (expand-file-name "~/.dotfiles/.config/emacs/Desktop.org")))
    ;; Dynamic scoping to the rescue
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle))))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'org-babel-tangle-config)))

(use-package dired
  :ensure nil
  :straight nil
  :commands (dired dired-jump)
  :bind (("C-x C-j" . dired-jump))
  :custom ((dired-listing-switches "-agho --group-directories-first"))
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "h" 'dired-single-up-directory
    "l" 'dired-single-buffer))

(use-package dired-single
  :commands (dired dired-jump))

(use-package all-the-icons)

(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode))

(use-package dired-hide-dotfiles
  :diminish dired-hide-dotfiles-mode
  :hook (dired-mode . dired-hide-dotfiles-mode)
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "H" 'dired-hide-dotfiles-mode))

(use-package hydra)
(defhydra hydra-text-scale (:timeout 4)
  "scale text"
  ("j" text-scale-increase "in")
  ("k" text-scale-decrease "out")
  ("f" nil "finished" :exit t))

(use-package perspective
  :config
  (add-hook 'persp-created-hook #'(lambda () (and (get-buffer "*mu4e-main*") (persp-add-buffer (get-buffer "*mu4e-main*")))))
  :init
  (setq persp-suppress-no-prefix-key-warning t
        persp-initial-frame-name "main"
        persp-sort 'name)
  (persp-mode)
  (consult-customize consult--source-buffer :hidden t :default nil)
  (add-to-list 'consult-buffer-sources persp-consult-source))

(use-package mu4e
  :ensure nil
  :straight nil
  :custom
  (mu4e-completing-read-function #'completing-read)
  :config

  (add-hook 'after-init-hook #'(lambda () (mu4e t)))
  ;; This is set to 't' to avoid mail syncing issues when using mbsync
  (setq mu4e-change-filenames-when-moving t)

  (add-hook 'mu4e-compose-mode-hook
            #'(lambda () (setq-local undo-tree-auto-save-history nil)))
  (add-hook 'mu4e-compose-mode-hook
            #'(lambda () (flyspell-mode)))
  ;; Refresh mail using isync every 10 minutes
  (setq mu4e-update-interval (* 10 60)
        mu4e-get-mail-command "mbsync -a"
        mu4e-maildir "~/Maildir"
        mu4e-read-option-use-builtin nil
        mu4e-headers-skip-duplicates nil

        mu4e-drafts-folder "/acc1-gmail/Drafts"
        mu4e-sent-folder   "/acc1-gmail/Sent Mail"
        mu4e-refile-folder "/acc1-gmail/All Mail"
        mu4e-trash-folder  "/acc1-gmail/Trash"
        smtpmail-smtp-server "smtp.gmail.com"
        smtpmail-smtp-service 465
        smtpmail-stream-type  'ssl
        message-send-mail-function 'smtpmail-send-it
        mu4e-compose-signature "Riley Beckett\nrbeckettvt@gmail.com"
        mu4e-compose-format-flowed t))

(use-package mu4e-alert
  :config
  (mu4e-alert-set-default-style 'libnotify)
  (add-hook 'after-init-hook #'mu4e-alert-enable-notifications))

(use-package pinentry)

(use-package origami
  :config
  (global-origami-mode 1))

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode))

(use-package smartparens
  :diminish smartparens-mode
  :config
  (setq sp-highlight-pair-overlay nil)
  (sp-local-pair 'emacs-lisp-mode "'" nil :actions nil)
  (smartparens-global-mode 1))

(use-package magit
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(use-package flycheck
  :diminish flycheck-mode
  :config
  (setq-default flycheck-emacs-lisp-load-path 'inherit)
  :init (global-flycheck-mode))

(use-package lsp-mode
  :init
  (setq lsp-keymap-prefix "C-c l")
  (setq lsp-headerline-breadcrumb-enable nil)
  (setq lsp-keep-workspace-alive nil)
  (setq lsp-lens-enable nil)
  :hook (;; replace XXX-mode with concrete major-mode(e. g. python-mode)
         (c-mode . lsp)
         (python-mode . lsp)
         ;; if you want which-key integration
         (lsp-mode . lsp-enable-which-key-integration))
  :commands lsp)

(use-package lsp-ui
  :after lsp
  :diminish lsp-lens-mode
  :config
  (setq lsp-ui-sideline-update-mode 'point)
  (setq lsp-ui-sideline-show-diagnostics t)
  (setq lsp-ui-sideline-ignore-duplicate t))

(use-package lsp-haskell
  :hook
  (haskell-mode . lsp))

(use-package lsp-treemacs
  :after lsp)

(use-package lsp-java
  :hook
  (java-mode . lsp))

(use-package consult-lsp
  :after lsp)

(defun lsp-bind ()
  (interactive)
  (define-key myemacs-leader-map (kbd "l") lsp-command-map)
  (map! "l" "lsp")
  (map! "l=" "formatting")
  (map! "lF" "folders")
  (map! "lG" "peek")
  (map! "lT" "toggle")
  (map! "la" "code actions")
  (map! "lg" "goto")
  (map! "lh" "help")
  (map! "lr" "refactor")
  (map! "lu" "ui")
  (map! "lw" "workspaces")
  (define-key myemacs-leader-map (kbd "lug") '("ui doc glance" . lsp-ui-doc-glance)))
(add-hook 'lsp-mode-hook 'lsp-bind)

(use-package company
  :diminish company-mode
  :hook (prog-mode . company-mode)
  :bind (:map company-active-map
              ("<tab>" . company-complete-selection))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

(use-package company-box
  :diminish company-box-mode
  :hook (company-mode . company-box-mode))

(use-package dap-mode
  :diminish
  :defer
  :custom
  (dap-auto-configure-mode t                           "Automatically configure dap.")
  (dap-auto-configure-features
   '(sessions locals breakpoints expressions tooltip)  "Remove the button panel in the top.")
  :config
      ;;; dap for c++
  (require 'dap-lldb)
  (require 'dap-gdb-lldb)
  (require 'dap-cpptools)
  (require 'dap-java)

      ;;; set the debugger executable (c++)
  (setq dap-lldb-debug-program '("/usr/bin/lldb-vscode"))

      ;;; ask user for executable to debug if not specified explicitly (c++)
  (setq dap-lldb-debugged-program-function (lambda () (read-file-name "Select file to debug: ")))

  (setq dap-default-terminal-kind "integrated") ;; Make sure that terminal programs open a term for I/O in an Emacs buffer
  (dap-auto-configure-mode +1)
      ;;; default debug template for (c++)
  (dap-register-debug-template
   "C++ LLDB dap"
   (list :type "lldb-vscode"
         :cwd nil
         :args nil
         :request "launch"
         :program nil))

  (dap-register-debug-template
   "Rust LLDB dap"
   (list :type "lldb-vscode"
         :request "launch"
         :program nil
         :cwd "${workspaceFolder}"
         :dap-compilation "cargo build"
         :dap-compilation-dir "${workspaceFolder}"))

  (defun dap-debug-create-or-edit-c-json-template ()
    "Edit the C++ debugging configuration or create + edit if none exists yet."
    (interactive)
    (let ((filename (concat (lsp-workspace-root) "/launch.json"))
          (default "~/.dotfiles/.config/emacs/default-c-launch.json"))
      (unless (file-exists-p filename)
        (copy-file default filename))
      (find-file-existing filename))))

(c-add-style "microsoft"
             '("stroustrup"
               (c-offsets-alist
                (innamespace . -)
                (inline-open . 0)
                (inher-cont . c-lineup-multi-inher)
                (arglist-cont-nonempty . +)
                (template-args-cont . +))))
(setq c-default-style "microsoft")
(use-package clang-format)
(use-package clang-format+)

(use-package tree-sitter
  :diminish tree-sitter-mode
  :config
  (global-tree-sitter-mode 1))
(use-package tree-sitter-langs)

(use-package highlight-quoted
  :diminish highlight-quoted-mode
  :hook (emacs-lisp-mode . highlight-quoted-mode))

(use-package hl-todo
  :hook
  (prog-mode . hl-todo-mode))

(use-package eros
  :diminish eros-mode
  :config
  (eros-mode 1))

(use-package harpoon
  :diminish harpoon-mode
  :straight '(:package "harpoon.el" :host github :type git :repo "NAHTAIV3L/harpoon.el"))

(use-package glsl-mode
  :diminish
  :straight '(:package "glsl-mode" :host github :type git :repo "jimhourihan/glsl-mode"))

(use-package rust-mode
  :diminish
  :hook (rust-mode . lsp))

(use-package cargo
  :diminish cargo-mode cargo-minor-mode
  :hook (rust-mode . cargo-minor-mode))

(use-package flycheck-rust
  :config (add-hook 'flycheck-mode-hook #'flycheck-rust-setup))

(use-package vterm
  :diminish vterm-mode
  :commands vterm
  :config
  (setq vterm-max-scrollback 10000)
  (setq vterm-kill-buffer-on-exit t))

(defun configure-eshell ()
  ;; Save command history when commands are entered
  (add-hook 'eshell-pre-command-hook 'eshell-save-some-history)

  ;; Truncate buffer for performance
  (add-to-list 'eshell-output-filter-functions 'eshell-truncate-buffer)

  ;; Bind some useful keys for evil-mode
  (evil-define-key '(normal insert visual) eshell-mode-map (kbd "C-r") 'counsel-esh-history)
  (evil-define-key '(normal insert visual) eshell-mode-map (kbd "<home>") 'eshell-bol)
  (evil-normalize-keymaps)

  (setq eshell-history-size         10000
        eshell-buffer-maximum-lines 10000
        eshell-hist-ignoredups t
        eshell-scroll-to-bottom-on-input t))

(use-package eshell-git-prompt)

(use-package all-the-icons)

(use-package eshell
  :diminish eshell-mode
  :hook (eshell-first-time-mode . configure-eshell)
  :config

  (with-eval-after-load 'esh-opt
    (setq eshell-destroy-buffer-when-process-dies t)
    (setq eshell-visual-commands '("htop" "zsh" "vim")))

  (eshell-git-prompt-use-theme 'multiline2))

(use-package general)

(global-set-key (kbd "<escape>") 'keyboard-quit)

(defvar myemacs-escape-hook nil
  "for killing things")

(defun myemacs/escape (&optional interactive)
  "Run `myemacs-escape-hook'."
  (interactive (list 'interactive))
  (cond ((minibuffer-window-active-p (minibuffer-window))
         ;; quit the minibuffer if open.
         (when interactive
           (setq this-command 'abort-recursive-edit))
         (abort-recursive-edit))
        ;; Run all escape hooks. If any returns non-nil, then stop there.
        ((run-hook-with-args-until-success 'myemacs-escape-hook))
        ;; don't abort macros
        ((or defining-kbd-macro executing-kbd-macro) nil)
        ;; Back to the default
        ((unwind-protect (keyboard-quit)
           (when interactive
             (setq this-command 'keyboard-quit))))))

(global-set-key [remap keyboard-quit] #'myemacs/escape)
(add-hook 'myemacs-escape-hook (lambda ()
      			         (when (evil-ex-hl-active-p 'evil-ex-search)
      			           (evil-ex-nohighlight)
      			           t)))

(defvar myemacs-leader-map (make-sparse-keymap)
  "map for leader")
(setq leader "SPC")
(setq alt-leader "M-SPC")

(define-prefix-command 'myemacs/leader 'myemacs-leader-map)
(define-key myemacs-leader-map [override-state] 'all)

(evil-define-key* '(normal visual motion) general-override-mode-map (kbd leader) 'myemacs/leader)
(global-set-key (kbd alt-leader) 'myemacs/leader)
(general-override-mode +1)

(global-unset-key (kbd "M-."))

;; (define-key myemacs-leader-map (kbd ".") '("find file" . find-file))
(map! "." "find file"  #'find-file)
(map! "," "open dired"  #'dired-jump)
(map! "<" "switch buffer" #'consult-buffer)
(map! "s" "search in file" #'consult-line)
(map! "`" "open file in config dir" #'browse-config)

(evil-global-set-key 'normal "gc" 'evilnc-comment-operator)
(evil-global-set-key 'visual "gc" 'evilnc-comment-operator)

(map! "t" "toggle")
(map! "ts" "text scaling" #'hydra-text-scale/body)

(map! "b" "buffer")
(map! "bk" "kill buffer" #'kill-current-buffer)
(map! "bi" "ibuffer" #'persp-ibuffer)
(map! "bn" "next buffer" #'evil-next-buffer)
(map! "bp" "previous buffer" #'evil-prev-buffer)

(map! "c" "consult")
(map! "cr" "ripgrep" #'consult-ripgrep)
(map! "cb" "switch buffer" #'consult-buffer)
(map! "cp" "project buffer" #'consult-project-buffer)
(map! "cw" "window buffer" #'consult-buffer-other-window)
(map! "cm" "imenu multi" #'consult-imenu-multi)
(map! "ci" "imenu" #'consult-imenu)
(map! "cf" "lsp file symbols" #'consult-lsp-file-symbols)
(map! "cv" "consult flyspell" #'consult-flyspell)
(map! "cs" "lsp symbols" #'consult-lsp-symbols)

(map! "g" "git")
(map! "gg" "Magit status" #'magit-status)

(map! "h" "help" #'help-command)
(map! "r" "cargo" #'cargo-minor-mode-command-map)
(map! "w" "window" #'evil-window-map)
(map! "p" "project" #'projectile-command-map)
(map! "t" "persp" #'perspective-map)
(unbind-key (kbd "ESC") projectile-command-map)

(define-key general-override-mode-map (kbd "M-1") '("switch to workspace 1" . (lambda () (interactive) (persp-switch-by-number 1))))
(define-key general-override-mode-map (kbd "M-2") '("switch to workspace 2" . (lambda () (interactive) (persp-switch-by-number 2))))
(define-key general-override-mode-map (kbd "M-3") '("switch to workspace 3" . (lambda () (interactive) (persp-switch-by-number 3))))
(define-key general-override-mode-map (kbd "M-4") '("switch to workspace 4" . (lambda () (interactive) (persp-switch-by-number 4))))
(define-key general-override-mode-map (kbd "M-5") '("switch to workspace 5" . (lambda () (interactive) (persp-switch-by-number 5))))
(define-key general-override-mode-map (kbd "M-6") '("switch to workspace 6" . (lambda () (interactive) (persp-switch-by-number 6))))
(define-key general-override-mode-map (kbd "M-7") '("switch to workspace 7" . (lambda () (interactive) (persp-switch-by-number 7))))
(define-key general-override-mode-map (kbd "M-8") '("switch to workspace 8" . (lambda () (interactive) (persp-switch-by-number 8))))
(define-key general-override-mode-map (kbd "M-9") '("switch to workspace 9" . (lambda () (interactive) (persp-switch-by-number 9))))

(map! "1" "harpoon go to 1" #'harpoon-go-to-1)
(map! "2" "harpoon go to 2" #'harpoon-go-to-2)
(map! "3" "harpoon go to 3" #'harpoon-go-to-3)
(map! "4" "harpoon go to 4" #'harpoon-go-to-4)
(map! "5" "harpoon go to 5" #'harpoon-go-to-5)
(map! "6" "harpoon go to 6" #'harpoon-go-to-6)
(map! "7" "harpoon go to 7" #'harpoon-go-to-7)
(map! "8" "harpoon go to 8" #'harpoon-go-to-8)
(map! "9" "harpoon go to 9" #'harpoon-go-to-9)

(map! "d" "delete")
(map! "d1" "harpoon delete 1" #'harpoon-delete-1)
(map! "d2" "harpoon delete 2" #'harpoon-delete-2)
(map! "d3" "harpoon delete 3" #'harpoon-delete-3)
(map! "d4" "harpoon delete 4" #'harpoon-delete-4)
(map! "d5" "harpoon delete 5" #'harpoon-delete-5)
(map! "d6" "harpoon delete 6" #'harpoon-delete-6)
(map! "d7" "harpoon delete 7" #'harpoon-delete-7)
(map! "d8" "harpoon delete 8" #'harpoon-delete-8)
(map! "d9" "harpoon delete 9" #'harpoon-delete-9)

(map! "j" "harpoon")
(map! "ja" "harpoon add file" #'harpoon-add-file)
(map! "jD" "harpoon delete item" #'harpoon-delete-item)
(map! "jc" "harpoon clear" #'harpoon-clear)
(map! "jf" "harpoon toggle file" #'harpoon-toggle-file)
(define-key general-override-mode-map (kbd "C-SPC") '("harpoon toggle quick menu" . harpoon-toggle-quick-menu))

(use-package exwm)

(if (or (string= (getenv "WINDOWMANAGER") "d") (string= (getenv "WINDOWMANAGER") ""))
    nil
  (load "~/.config/emacs/desktop.el"))
