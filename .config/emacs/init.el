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

(recentf-mode 1)
(use-package no-littering)
(add-to-list 'recentf-exclude
             (recentf-expand-file-name no-littering-var-directory))
(add-to-list 'recentf-exclude
             (recentf-expand-file-name no-littering-etc-directory))
(setq custom-file (no-littering-expand-etc-file-name "custom.el"))

(use-package gcmh
  :init
  (gcmh-mode 1))

(defun minibuffer-backward-kill (arg)
  "When minibuffer is completing a file name delete up to parent
folder, otherwise delete a word"
  (interactive "p")
  (if minibuffer-completing-file-name
      ;; Borrowed from https://github.com/raxod502/selectrum/issues/498#issuecomment-803283608
      (if (string-match-p "/." (minibuffer-contents))
          (zap-up-to-char (- arg) ?/)
        (delete-minibuffer-contents))
    (delete-word (- arg))))

(use-package vertico
  :bind (:map vertico-map
              ("C-n" . vertico-next)
              ("C-p" . vertico-previous)
              ("M-h" . minibuffer-backward-kill))
  :init
  (vertico-mode 1)
  (setq vertico-count 15))

(use-package savehist
  :init
  (savehist-mode 1))

(use-package marginalia
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

(use-package flyspell)

(use-package flyspell-correct
  :after flyspell)

(use-package consult-flyspell
  :straight (consult-flyspell :type git :host gitlab :repo "OlMon/consult-flyspell" :branch "master")
  :config
  ;; default settings
  (setq consult-flyspell-select-function (lambda () (flyspell-correct-at-point) (consult-flyspell))
        consult-flyspell-set-point-after-word t
        consult-flyspell-always-check-buffer nil))

(use-package doom-modeline
  :init
  (setq doom-modeline-display-default-persp-name t
        doom-modeline-buffer-file-name-style 'relative-from-project
        doom-modeline-mu4e t)
  (doom-modeline-mode 1)
  :custom ((doom-modeline-height 35)))

(use-package doom-themes
  :init (load-theme 'doom-one t))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 1))

(use-package emojify
  :hook (after-init . global-emojify-mode))

(use-package helpful
  :bind
  ([remap describe-command] . helpful-command)
  ([remap describe-function] . helpful-callable)
  ([remap describe-variable] . helpful-variable)
  ([remap describe-key] . helpful-key))

(use-package statusbar
  :straight '(:package "statusbar.el" :host github :type git :repo "NAHTAIV3L/statusbar.el"))

(use-package undo-tree
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
  :after evil
  :config
  (evil-collection-init))

(use-package evil-nerd-commenter
  :after evil)

(use-package evil-anzu
  :after evil
  :config
  (global-anzu-mode 1))

(use-package tex
  :straight auctex)

(use-package lsp-latex
  :straight '(:package "lsp-latex.el" :host github :type git :repo "ROCKTAKEY/lsp-latex"))

(setq markdown-command "pandoc")

(use-package org
  :config
  (setq org-ellipsis " ▾"))

(use-package org-superstar
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
  :init
  (setq persp-suppress-no-prefix-key-warning t)
  (persp-mode)
  (consult-customize consult--source-buffer :hidden t :default nil)
  (add-to-list 'consult-buffer-sources persp-consult-source))

(use-package mu4e
  :ensure nil
  :straight nil
  :custom
  (mu4e-completing-read-function #'completing-read)
  :config

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

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode))

(use-package smartparens
  :config
  (setq sp-highlight-pair-overlay nil)
  (sp-local-pair 'emacs-lisp-mode "'" nil :actions nil)
  (smartparens-global-mode 1))

(use-package magit
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(use-package flycheck
  :init (global-flycheck-mode))

(use-package lsp-mode
  :init
  (setq lsp-keymap-prefix "C-c l")
  (setq lsp-headerline-breadcrumb-enable nil)
  :hook (;; replace XXX-mode with concrete major-mode(e. g. python-mode)
         (c-mode . lsp)
         (python-mode . lsp)
         ;; if you want which-key integration
         (lsp-mode . lsp-enable-which-key-integration))
  :commands lsp)

(use-package lsp-ui
  :after lsp
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
  :hook (prog-mode . company-mode)
  :bind (:map company-active-map
              ("<tab>" . company-complete-selection))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

(use-package company-box
  :hook (company-mode . company-box-mode))

(use-package clang-format)
(use-package clang-format+)

(use-package tree-sitter
  :config
  (global-tree-sitter-mode 1))
(use-package tree-sitter-langs)

(use-package highlight-quoted
  :hook (emacs-lisp-mode . highlight-quoted-mode))

(use-package hl-todo
  :hook
  (prog-mode . hl-todo-mode))

(use-package eros
  :config
  (eros-mode 1))

(use-package harpoon
  :straight '(:package "harpoon.el" :host github :type git :repo "NAHTAIV3L/harpoon.el"))

(use-package glsl-mode
  :straight '(:package "glsl-mode" :host github :type git :repo "jimhourihan/glsl-mode"))

(use-package vterm
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
