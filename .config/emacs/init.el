(setq user-full-name    "Riley Beckett"
      user-mail-address "rbeckettvt@gmail.com"
      make-backup-files nil
      create-lockfiles  nil
      confirm-kill-processes nil)
(setq-default indent-tabs-mode nil
              tab-width 4)

(setq inhibit-startup-message t)
(setq backup-inhibited t)


(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(add-hook 'prog-mode-hook (lambda () (toggle-truncate-lines +1)))

(menu-bar-mode -1)          ; Disable the menu bar

(setq scroll-up-aggressively nil)
(setq scroll-down-aggressively nil)
(setq scroll-conservatively 101)
(setq display-line-numbers-type 'relative)

(column-number-mode)
(global-display-line-numbers-mode t)
(global-hl-line-mode t)
(set-fill-column 80)

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
      	            (time-subtract elpaca-after-init-time before-init-time)))
           gcs-done))

(add-hook 'after-init-hook #'display-startup-time)
(add-hook 'server-after-make-frame-hook #'display-startup-time)

(setq background-transparancy '(90 . 90))

(set-frame-parameter (selected-frame) 'alpha background-transparancy)
(add-to-list 'default-frame-alist `(alpha . ,background-transparancy))

(defun browse-config ()
  "open find file in emacs config folder."
  (interactive)
  (let ((default-directory (file-truename (expand-file-name "~/.config/emacs/"))))
    (call-interactively #'find-file)))

(defun close-window-and-buffer ()
  "Kills current buffer and closes window."
  (interactive)
  (kill-buffer)
  (delete-window))

(defun lookup-password (&rest keys)
  "search authinfo.gpg file for passwords"
  (let ((result (apply #'auth-source-search keys)))
    (if result
        (funcall (plist-get (car result) :secret))
      nil)))

(defun map! (&rest mylist)
  "Map key to myemacs-leader-map.
keybinds should be a string
the description of the keybind if wanted should be prefixed with :desc
function can be any interactive function"
  (let (desc
        function
        keys
        (keymap myemacs-leader-map))
    (while mylist
      (let ((key (pop mylist)))
        (cond
         ((keywordp key)
          (pcase key
            (:desc
             (setq desc (pop mylist)))
            (:map
             (setq keymap (pop mylist)))))
         ((functionp key)
          (setq function key))
         ((keymapp key)
          (setq function key))
         ((stringp key)
          (setq keys key)))))
    (and function
         (define-key keymap (kbd keys) function))
    (and desc
         (which-key-add-keymap-based-replacements keymap keys desc))))

(defun bind! (key desc &optional func)
  (and func (define-key myemacs-leader-map (kbd key) func))
  (which-key-add-keymap-based-replacements myemacs-leader-map key desc))

(defun sudo-find-file (file)
  "Open FILE as root."
  (interactive "FOpen file as root: ")
  (when (file-writable-p file)
    (user-error "File is user writeable, aborting sudo"))
  (find-file (if (file-remote-p file)
                 (concat "/" (file-remote-p file 'method) ":"
                         (file-remote-p file 'user) "@" (file-remote-p file 'host)
                         "|sudo:root@"
                         (file-remote-p file 'host) ":" (file-remote-p file 'localname))
               (concat "/sudo:root@localhost:" file))))

(defvar elpaca-installer-version 0.6)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (< emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                 ((zerop (call-process "git" nil buffer t "clone"
                                       (plist-get order :repo) repo)))
                 ((zerop (call-process "git" nil buffer t "checkout"
                                       (or (plist-get order :ref) "--"))))
                 (emacs (concat invocation-directory invocation-name))
                 ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                       "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                 ((require 'elpaca))
                 ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (load "./elpaca-autoloads")))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

(elpaca elpaca-use-package
  ;; Enable :elpaca use-package keyword.
  (elpaca-use-package-mode)
  ;; Assume :elpaca t unless otherwise specified.
  (setq elpaca-use-package-by-default t))

;; Block until current queue processed.
(elpaca-wait)

(use-package diminish)
(elpaca-wait)

(diminish 'abbrev-mode)
(auto-revert-mode 1)
(diminish 'auto-revert-mode)
(diminish 'eldoc-mode)
(diminish 'isearch-mode)
(diminish 'abbrev-mode)

(recentf-mode 1)

(use-package no-littering
  :config
  (add-to-list 'recentf-exclude
               (recentf-expand-file-name no-littering-var-directory))
  (add-to-list 'recentf-exclude
               (recentf-expand-file-name no-littering-etc-directory))
  (setq custom-file (no-littering-expand-etc-file-name "custom.el")))

(use-package gcmh
  :diminish gcmh-mode
  :init
  (gcmh-mode 1))

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 1))

(use-package vertico
  :elpaca (vertico :files (:defaults "extensions/*"))
  :diminish vertico-mode
  :bind (:map vertico-map
              ("C-n" . vertico-next)
              ("C-p" . vertico-previous))
  :init
  (vertico-mode 1)
  (setq vertico-count 15))

;; Configure directory extension.
(use-package vertico-directory
  :after vertico
  :elpaca nil
  ;; More convenient directory navigation commands
  :bind (:map vertico-map
              ("RET" . vertico-directory-enter)
              ("DEL" . vertico-directory-delete-char)
              ("M-DEL" . vertico-directory-delete-word))
  ;; Tidy shadowed file names
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

(use-package savehist
  :elpaca nil
  :diminish savehist-mode
  :init
  (savehist-mode 1))

(use-package marginalia
  :diminish marginalia-mode
  :after vertico
  :custom
  (marginalia-annotators '(marginalia-annotators-heavy marginalia-annotators-light nil))
  :config
  (marginalia-mode))

(use-package consult
  :config
  (setq completion-in-region-function
        (lambda (&rest args)
          (apply (if vertico-mode
                     #'consult-completion-in-region
                   #'completion--in-region)
                 args)))
  (consult-customize consult-buffer :preview-key "M-."))

(use-package orderless
  :config
  (setq completion-styles '(orderless)
        completion-category-defaults nil
        completion-category-overrides '((file (styles . (partial-completion))))))

(use-package embark
  :bind
  (("C-." . embark-act)
   ("C-;" . embark-dwim))
  :init
  (setq prefix-help-command #'embark-prefix-help-command)
  :config
  (setq embark--minimal-indicator-overlay nil)
  (setq embark-indicators (delq 'embark-mixed-indicator embark-indicators))
  (add-to-list 'embark-indicators #'embark-minimal-indicator))

(use-package embark-consult
  :config
  (define-key embark-file-map (kbd "S") 'sudo-find-file))

(use-package flyspell
  :elpaca nil
  ;; :diminish flyspell-mode
  )

(use-package flyspell-correct
  :after flyspell)

(use-package consult-flyspell
  :elpaca (consult-flyspell :host gitlab :repo "OlMon/consult-flyspell" :branch "master")
  :config
  ;; default settings
  (setq consult-flyspell-select-function (lambda () (flyspell-correct-at-point) (consult-flyspell))
        consult-flyspell-set-point-after-word t
        consult-flyspell-always-check-buffer nil))

(defface modeline-project-face
  '((t :foreground "#00F00C"
       :weight bold))
  "Test face."
  :group 'modeline-face)

(defface modeline-path-face
  '((t :foreground "#00C0FF"
       :weight bold))
  "Test2 face."
  :group 'modeline-face)

(setq-default mode-line-buffer-identification
              '(:eval (format-mode-line (if buffer-file-truename (or (when-let* ((prj (cdr-safe (project-current)))
                                                                                 (parent (file-name-directory (directory-file-name (cdr-safe (project-current)))))
                                                                                 (folder (file-relative-name prj parent))
                                                                                 (path (file-relative-name buffer-file-truename parent)))
                                                                       (put-text-property 0 (-(length folder) 1) 'face 'modeline-project-face path)
                                                                       (put-text-property (-(length folder) 1) (length path) 'face 'modeline-path-face path)
                                                                       path)
                                                                     "%b")
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
  (or (eq (selected-window) (minibuffer-window))
      (setq ml-selected-window (selected-window))))

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

(defmacro ml-inactive-color-fix (var)
  `(if (eq ,ml-selected-window (selected-window))
       ,var
     '(:eval (let ((a (format-mode-line ,var)))
               (set-text-properties 0 (length a) '(face mode-line-inactive) a)
               a))))
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
               ;; '(:eval (ml-inactive-color-fix mode-line-buffer-identification))
               '(:eval (ml-inactive-color-fix mode-line-buffer-identification))
               '(:eval (and anzu--state " "))
               '(:eval anzu--mode-line-format)
               " "
               '(:eval (ml-inactive-color-fix mode-line-modes))
               '(:eval (ml-inactive-color-fix mode-line-misc-info))))

;; (use-package doom-modeline
;;   :init
;;   (setq doom-modeline-display-default-persp-name t
;;         doom-modeline-buffer-file-name-style 'relative-from-project
;;         doom-modeline-mu4e t)
;;   (doom-modeline-mode 1)
;;   :custom ((doom-modeline-height 35)))

(use-package doom-themes
  :config
  (setq doom-themes-enable-bold t    
        doom-themes-enable-italic t) 
  (load-theme 'doom-vibrant t)

  ;; Enable flashing mode-line on errors
  ;; (doom-themes-visual-bell-config)
  ;; Enable custom neotree theme (all-the-icons must be installed!)
  ;; or for treemacs users
  (doom-themes-treemacs-config)
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

(use-package rainbow-delimiters
  :diminish rainbow-delimiters-mode
  :hook (prog-mode . rainbow-delimiters-mode))

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

(use-package posframe)

(use-package statusbar
  :diminish statusbar-mode
  :elpaca (statusbar.el :host github :repo "NAHTAIV3L/statusbar.el")
  :config
  (setq display-wifi-essid-command "iw dev $(ip addr | awk '/state UP/ {gsub(\":\",\"\"); print $2}') link | awk '/SSID:/ {printf $2}'"
        display-wifi-connection-command "iw dev $(ip addr | awk '/state UP/ {gsub(\":\",\"\"); print $2}') link | awk '/signal:/ {gsub(\"-\",\"\"); printf $2}'"
        externalcmd-shellcommand "slstatus -s -1"))

(use-package writeroom-mode
  :diminish)

(use-package undo-tree
  :diminish undo-tree-mode
  :config
  (global-undo-tree-mode)
  (add-hook 'authinfo-mode-hook #'(lambda () (setq-local undo-tree-auto-save-history nil)))
  (defvar --undo-history-directory (concat user-emacs-directory "undotreefiles/")
    "Directory to save undo history files.")
  (unless (file-exists-p --undo-history-directory)
    (make-directory --undo-history-directory t))
  ;; stop littering with *.~undo-tree~ files everywhere
  (setq undo-tree-history-directory-alist `(("." . ,--undo-history-directory))))

(use-package avy)

(use-package ace-window
  :config
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)
        aw-scope 'frame))

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
  (define-key evil-normal-state-map (kbd "j") 'evil-next-visual-line)
  (define-key evil-normal-state-map (kbd "k") 'evil-previous-visual-line)
  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal)
  (define-key evil-window-map (kbd "d") '("close buffer & window" . close-window-and-buffer)))

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

(elpaca-wait)

(use-package tex
  :elpaca (auctex :pre-build
                  (("cd" "~/.emacs.d/elpaca/repos/auctex/")
                   ("./autogen.sh")
                   ("./configure")
                   ("make"))
                  :host github :repo "emacs-straight/auctex" :files ("*" (:exclude ".git"))))

(setq markdown-command "pandoc")

(use-package org
  :diminish org-mode
  :custom
  ((org-agenda-files (list "~/org/homework.org")))
  :config
  (setq org-ellipsis " ▾")


  (setq org-format-latex-options (plist-put org-format-latex-options :scale 1.5))
  (add-to-list 'org-structure-template-alist '("sh" . "src shell"))
  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
  (add-to-list 'org-structure-template-alist '("py" . "src python"))

  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (python . t))))

(use-package org-superstar
  :diminish org-superstar-mode
  :after org
  :config
  (add-hook 'org-mode-hook (lambda () (org-superstar-mode 1)))
  (setq org-hide-leading-stars t)
  (require 'org-tempo))

(elpaca-wait)

(use-package org-roam
  :elpaca t
  :init
  (setq org-roam-v2-ack t)
  :custom
  (org-roam-directory "~/RoamNotes")
  (org-roam-completion-everywhere t)
  :config
  (org-roam-setup))

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
  :elpaca nil
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

(use-package hydra
  :config
  (defhydra hydra-text-scale (:timeout 4)
    "scale text"
    ("j" text-scale-increase "in")
    ("k" text-scale-decrease "out")
    ("f" nil "finished" :exit t)))

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
  :elpaca nil
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

        mu4e-drafts-folder "/Drafts"
        mu4e-sent-folder   "/Sent Mail"
        mu4e-refile-folder "/All Mail"
        mu4e-trash-folder  "/Trash"
        smtpmail-smtp-server "smtp.gmail.com"
        smtpmail-smtp-service 465
        smtpmail-stream-type  'ssl
        message-send-mail-function 'smtpmail-send-it
        mu4e-compose-signature "Riley Beckett\nrbeckettvt@gmail.com"
        mu4e-compose-format-flowed t
        mu4e-maildir-shortcuts
        '((:maildir "/INBOX"    :key ?i)
          (:maildir "/Sent Mail" :key ?s)
          (:maildir "/Trash"     :key ?t)
          (:maildir "/Drafts"    :key ?d)
          (:maildir "/All Mail"  :key ?a))))

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
  :config (projectile-mode +1))

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
  (global-flycheck-mode 1))

(use-package lsp-mode
  :init
  (setq lsp-keymap-prefix "C-c l"
        lsp-headerline-breadcrumb-enable nil
        lsp-headerline-breadcrumb-icons-enable nil
        lsp-keep-workspace-alive nil
        lsp-completion-provider :none
        lsp-enable-snippet nil
        lsp-lens-enable nil)
  :hook (;; replace XXX-mode with concrete major-mode(e. g. python-mode)
         (c-mode . lsp)
         (python-mode . lsp-deferred)
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
  :after lsp
  :custom
  (lsp-treemacs-error-list-current-project-only t))

(use-package lsp-java
  :hook
  (java-mode . lsp))

(use-package consult-lsp
  :after lsp)

(defun lsp-bind ()
  (interactive)
  (define-key myemacs-leader-map (kbd "l") lsp-command-map)
  (map! "l" :desc "lsp")
  (map! "l=" :desc "formatting")
  (map! "lF" :desc "folders")
  (map! "lG" :desc "peek")
  (map! "lT" :desc "toggle")
  (map! "la" :desc "code actions")
  (map! "lg" :desc "goto")
  (map! "lh" :desc "help")
  (map! "lr" :desc "refactor")
  (map! "lu" :desc "ui")
  (map! "lw" :desc "workspaces")
  (define-key myemacs-leader-map (kbd "lug") '("ui doc glance" . lsp-ui-doc-glance)))
(add-hook 'lsp-mode-hook 'lsp-bind)

(use-package corfu
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0)
  (corfu-auto-prefix 1)
  (corfu-separator ?\s)
  (corfu-preview-current nil)
  :config
  (global-corfu-mode)
  (defun corfu-enable-in-minibuffer ()
    "Enable Corfu in the minibuffer if `completion-at-point' is bound."
    (when (where-is-internal #'completion-at-point (list (current-local-map)))
      ;; (setq-local corfu-auto nil) ;; Enable/disable auto completion
      (setq-local corfu-echo-delay nil ;; Disable automatic echo and popup
                  corfu-popupinfo-delay nil)
      (corfu-mode 1)))
  (add-hook 'minibuffer-setup-hook #'corfu-enable-in-minibuffer)
  (bind-key (kbd "s-SPC") 'corfu-insert-separator 'corfu-map))

(use-package corfu-terminal
  :diminish corfu-terminal-mode
  :elpaca (corfu-terminal :repo "https://codeberg.org/akib/emacs-corfu-terminal.git")
  :config
  (unless (display-graphic-p)
    (corfu-terminal-mode +1)))

(use-package cape
  ;; Bind dedicated completion commands
  ;; Alternative prefix keys: C-c p, M-p, M-+, ...
  :init
  ;; Add to the global default value of `completion-at-point-functions' which is
  ;; used by `completion-at-point'.  The order of the functions matters, the
  ;; first function returning a result wins.  Note that the list of buffer-local
  ;; completion functions takes precedence over the global list.
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-elisp-block)
  ;;(add-to-list 'completion-at-point-functions #'cape-history)
  ;;(add-to-list 'completion-at-point-functions #'cape-keyword)
  (add-to-list 'completion-at-point-functions #'cape-tex)
  ;;(add-to-list 'completion-at-point-functions #'cape-sgml)
  ;;(add-to-list 'completion-at-point-functions #'cape-rfc1345)
  ;;(add-to-list 'completion-at-point-functions #'cape-abbrev)
  ;;(add-to-list 'completion-at-point-functions #'cape-dict)
  ;;(add-to-list 'completion-at-point-functions #'cape-elisp-symbol)
  ;;(add-to-list 'completion-at-point-functions #'cape-line)
  )

(use-package yasnippet
  :diminish yas-minor-mode
  :config
  (yas-global-mode))
(use-package yasnippet-snippets)
(use-package company
  :config
  (add-to-list 'completion-at-point-functions
                  (cape-company-to-capf #'company-yasnippet)))

(use-package lsp-latex
  :elpaca (lsp-latex.el :host github :repo "ROCKTAKEY/lsp-latex"))

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
  :elpaca (harpoon.el :host github :repo "NAHTAIV3L/harpoon.el"))

(use-package glsl-mode
  :diminish
  :elpaca (glsl-mode :host github :repo "jimhourihan/glsl-mode"))

(use-package gradle-mode
  :diminish)

(use-package rust-mode
  :diminish
  :hook (rust-mode . lsp))

(use-package cargo
  :diminish cargo-mode cargo-minor-mode
  :hook (rust-mode . cargo-minor-mode))

(use-package flycheck-rust
  :config (add-hook 'flycheck-mode-hook #'flycheck-rust-setup))

(defun my-asm-mode-hook ()
  (defun asm-calculate-indentation ()
    (or
     ;; Flush labels to the left margin.
                                        ;   (and (looking-at "\\(\\.\\|\\sw\\|\\s_\\)+:") 0)
     (and (looking-at "[.@_[:word:]]+:") 0)
     ;; Same thing for `;;;' comments.
     (and (looking-at "\\s<\\s<\\s<") 0)
     ;; %if nasm macro stuff goes to the left margin
     (and (looking-at "%") 0)
     (and (looking-at "c?global\\|section\\|default\\|align\\|INIT_..X") 0)
     ;; Simple `;' comments go to the comment-column
                                        ;(and (looking-at "\\s<\\(\\S<\\|\\'\\)") comment-column)
     ;; The rest goes at column 4
     (or 4))))

(add-hook 'asm-mode-hook #'my-asm-mode-hook)

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

(use-package eshell
  :elpaca nil
  :diminish eshell-mode
  :hook (eshell-first-time-mode . configure-eshell)
  :config

  (with-eval-after-load 'esh-opt
    (setq eshell-destroy-buffer-when-process-dies t)
    (setq eshell-visual-commands '("htop" "zsh" "vim")))

  (eshell-git-prompt-use-theme 'multiline2))

(use-package calendar
  :elpaca nil
  :config
  (defun calendar-insert-date ()
    "Capture the date at point, exit the Calendar, insert the date."
    (interactive)
    (seq-let (month day year) (save-match-data (calendar-cursor-to-date))
      (calendar-exit)
      (insert (format "%02d/%02d/%d" month day year))))

  (define-key calendar-mode-map (kbd "M-I") 'calendar-insert-date))

(elpaca-wait)

(defvar keyboard-override-mode-map (make-sparse-keymap)
  "override other keybinds")

(define-minor-mode keyboard-override-mode
  "override keybinds mode"
  :lighter ""
  :global t
  :keymap keyboard-override-mode-map)

(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; (defvar myemacs-escape-hook nil
;;   "for killing things")

;; (defun myemacs/escape (&optional interactive)
;;   "Run `myemacs-escape-hook'."
;;   (interactive (list 'interactive))
;;   (cond ((minibuffer-window-active-p (minibuffer-window))
;;          ;; quit the minibuffer if open.
;;          (when interactive
;;            (setq this-command 'abort-recursive-edit))
;;          (abort-recursive-edit))
;;         ;; Run all escape hooks. If any returns non-nil, then stop there.
;;         ((run-hook-with-args-until-success 'myemacs-escape-hook))
;;         ;; don't abort macros
;;         ((or defining-kbd-macro executing-kbd-macro) nil)
;;         ;; Back to the default
;;         ((unwind-protect (keyboard-quit)
;;            (when interactive
;;              (setq this-command 'keyboard-quit))))))

;; (global-set-key [remap keyboard-quit] #'myemacs/escape)
;; (add-hook 'myemacs-escape-hook (lambda ()
;;       			         (when (evil-ex-hl-active-p 'evil-ex-search)
;;       			           (evil-ex-nohighlight)
;;       			           t)))

(defvar myemacs-leader-map (make-sparse-keymap)
  "map for leader")
(setq leader "SPC")
(setq alt-leader "M-SPC")

(define-prefix-command 'myemacs/leader 'myemacs-leader-map)

(evil-define-key* '(normal visual motion) keyboard-override-mode-map (kbd leader) 'myemacs/leader)
(global-set-key (kbd alt-leader) 'myemacs/leader)
(keyboard-override-mode +1)

(global-unset-key (kbd "M-."))

;; (define-key myemacs-leader-map (kbd ".") '("find file" . find-file))
(map! "." :desc "find file"  #'find-file)
(map! "," :desc "open dired"  #'dired-jump)
(map! "<" :desc "switch buffer" #'consult-buffer)
(map! "s" :desc "search in file" #'consult-line)
(map! "`" :desc "open file in config dir" #'browse-config)

(map! "v" :desc "ace window" #'ace-window)

(map! "a" :desc "avy")
(map! "ac" :desc "avy go to char" #'avy-goto-char)
(map! "al" :desc "avy go to char 2" #'avy-goto-char-2)
(map! "at" :desc "avy go to char timer" #'avy-goto-char-timer)

(evil-global-set-key 'normal "gc" 'evilnc-comment-operator)
(evil-global-set-key 'visual "gc" 'evilnc-comment-operator)

(map! "o" :desc "org")
(map! "oa" :desc "org agenda" #'org-agenda)
(map! "o[" :desc "org agenda add front" #'org-agenda-file-to-front)
(map! "os" :desc "org schedule" #'org-schedule)
(map! "od" :desc "org deadline" #'org-deadline)

(map! "n" :desc "org roam")
(map! "nl" :desc "org roam buffer toggle" #'org-roam-buffer-toggle)
(map! "nf" :desc "org roam node find" #'org-roam-node-find)
(map! "ni" :desc "org roam node insert" #'org-roam-node-insert)

(map! "t" :desc "toggle")
(map! "ts" :desc "text scaling" #'hydra-text-scale/body)

(map! "b" :desc "buffer")
(map! "bk" :desc "kill buffer" #'kill-current-buffer)
(map! "bi" :desc "ibuffer" #'persp-ibuffer)
(map! "bn" :desc "next buffer" #'evil-next-buffer)
(map! "bp" :desc "previous buffer" #'evil-prev-buffer)

(map! "c" :desc "consult")
(map! "cr" :desc "ripgrep" #'consult-ripgrep)
(map! "cb" :desc "switch buffer" #'consult-buffer)
(map! "cp" :desc "project buffer" #'consult-project-buffer)
(map! "cw" :desc "window buffer" #'consult-buffer-other-window)
(map! "cm" :desc "imenu multi" #'consult-imenu-multi)
(map! "ci" :desc "imenu" #'consult-imenu)
(map! "cf" :desc "lsp file symbols" #'consult-lsp-file-symbols)
(map! "cv" :desc "consult flyspell" #'consult-flyspell)
(map! "cs" :desc "lsp symbols" #'consult-lsp-symbols)

(map! "g" :desc "git")
(map! "gg" :desc "Magit status" #'magit-status)

;; (bind! "h" "help" #'help-command)
;; (bind! "r" "cargo" #'cargo-minor-mode-command-map)
;; (bind! "w" "window" #'evil-window-map)
;; (bind! "t" "persp" #'perspective-map)
(map! "h" :desc "help" #'help-command)
(map! "r" :desc "cargo" #'cargo-minor-mode-command-map)
(map! "w" :desc "window" #'evil-window-map)
(map! "t" :desc "persp" #'perspective-map)
(with-eval-after-load "projectile"
  (map! "p" :desc "project" #'projectile-command-map)
  (unbind-key (kbd "ESC") #'projectile-command-map))

(map! :map keyboard-override-mode-map "M-1" :desc "switch to workspace 1" #'(lambda () (interactive) (persp-switch-by-number 1)))
(map! :map keyboard-override-mode-map "M-2" :desc "switch to workspace 2" #'(lambda () (interactive) (persp-switch-by-number 2)))
(map! :map keyboard-override-mode-map "M-3" :desc "switch to workspace 3" #'(lambda () (interactive) (persp-switch-by-number 3)))
(map! :map keyboard-override-mode-map "M-4" :desc "switch to workspace 4" #'(lambda () (interactive) (persp-switch-by-number 4)))
(map! :map keyboard-override-mode-map "M-5" :desc "switch to workspace 5" #'(lambda () (interactive) (persp-switch-by-number 5)))
(map! :map keyboard-override-mode-map "M-6" :desc "switch to workspace 6" #'(lambda () (interactive) (persp-switch-by-number 6)))
(map! :map keyboard-override-mode-map "M-7" :desc "switch to workspace 7" #'(lambda () (interactive) (persp-switch-by-number 7)))
(map! :map keyboard-override-mode-map "M-8" :desc "switch to workspace 8" #'(lambda () (interactive) (persp-switch-by-number 8)))
(map! :map keyboard-override-mode-map "M-9" :desc "switch to workspace 9" #'(lambda () (interactive) (persp-switch-by-number 9)))

(map! "1" :desc "harpoon go to 1" #'harpoon-go-to-1)
(map! "2" :desc "harpoon go to 2" #'harpoon-go-to-2)
(map! "3" :desc "harpoon go to 3" #'harpoon-go-to-3)
(map! "4" :desc "harpoon go to 4" #'harpoon-go-to-4)
(map! "5" :desc "harpoon go to 5" #'harpoon-go-to-5)
(map! "6" :desc "harpoon go to 6" #'harpoon-go-to-6)
(map! "7" :desc "harpoon go to 7" #'harpoon-go-to-7)
(map! "8" :desc "harpoon go to 8" #'harpoon-go-to-8)
(map! "9" :desc "harpoon go to 9" #'harpoon-go-to-9)

(map! "d" :desc "delete")
(map! "d1" :desc "harpoon delete 1" #'harpoon-delete-1)
(map! "d2" :desc "harpoon delete 2" #'harpoon-delete-2)
(map! "d3" :desc "harpoon delete 3" #'harpoon-delete-3)
(map! "d4" :desc "harpoon delete 4" #'harpoon-delete-4)
(map! "d5" :desc "harpoon delete 5" #'harpoon-delete-5)
(map! "d6" :desc "harpoon delete 6" #'harpoon-delete-6)
(map! "d7" :desc "harpoon delete 7" #'harpoon-delete-7)
(map! "d8" :desc "harpoon delete 8" #'harpoon-delete-8)
(map! "d9" :desc "harpoon delete 9" #'harpoon-delete-9)

(map! "j" :desc "harpoon")
(map! "ja" :desc "harpoon add file" #'harpoon-add-file)
(map! "jD" :desc "harpoon delete item" #'harpoon-delete-item)
(map! "jc" :desc "harpoon clear" #'harpoon-clear)
(map! "jf" :desc "harpoon toggle file" #'harpoon-toggle-file)
(map! "C-SPC" :desc "harpoon toggle quick menu" #'harpoon-toggle-quick-menu)

(use-package exwm)

(elpaca-wait)

(if (or (string= (getenv "WINDOWMANAGER") "d") (string= (getenv "WINDOWMANAGER") ""))
    nil
  (load "~/.config/emacs/desktop.el"))
