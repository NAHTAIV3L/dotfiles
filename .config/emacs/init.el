(setq make-backup-files nil
      create-lockfiles  nil
      erc-join-buffer 'window
      confirm-kill-processes nil
      ring-bell-function 'ignore
      gc-cons-threshold (* 50 1000 1000))

(setq-default indent-tabs-mode nil
              c-basic-offset 4
              tab-width 4)

(setq inhibit-startup-message t
      backup-inhibited t)

(scroll-bar-mode -1) ; Disable visible scrollbar
(tool-bar-mode -1) ; Disable the toolbar
(tooltip-mode -1) ; Disable tooltips
(menu-bar-mode -1) ; Disable the menu bar

(setq scroll-up-aggressively nil
      scroll-down-aggressively nil
      scroll-conservatively 101
      display-line-numbers-type 'relative)

(setq scroll-step 1)
(setq scroll-margin 8)

(column-number-mode +1)
(global-display-line-numbers-mode +1)
(setq-default fill-column 80)

(electric-pair-mode +1)

(dolist (mode '(org-mode-hook
                term-mode-hook
                vterm-mode-hook
                shell-mode-hook
                eshell-mode-hook
                mu4e-main-mode-hook
                mu4e-headers-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(set-face-attribute 'default nil
                    :font "DejaVu Sans Mono"
                    :family "Monospace"
                    :height 97)
(set-face-attribute 'variable-pitch nil
                    :font "DejaVu Sans"
                    :height 97)
(set-face-attribute 'fixed-pitch nil
                    :font "DejaVu Sans Mono"
                    :family "Monospace"
                    :height 97)

(setq background-transparancy '(90 . 90))
(set-frame-parameter (selected-frame) 'alpha background-transparancy)
(add-to-list 'default-frame-alist `(alpha . ,background-transparancy))

(defun erc-tls-oftc ()
  (interactive)
  (erc-tls :server "irc.oftc.net"
           :port "6697"))

(defun astyle-buffer (&optional justify)
  (interactive)
  (let ((saved-line-number (line-number-at-pos)))
    (shell-command-on-region
     (point-min)
     (point-max)
     "astyle --style=kr"
     nil
     t)
    (goto-line saved-line-number)))

(defun better-scroll-up (&optional arg)
  (interactive "^P")
  (call-interactively 'scroll-up-command arg)
  (recenter))
(defun better-scroll-down (&optional arg)
  (interactive "^P")
  (call-interactively 'scroll-down-command)
  (recenter))

(defun open-mpv (&optional link)
  (interactive "sEnter Link:")
  (async-shell-command (format "mpv %s" link) nil))

(defun duplicate-line-better ()
  "Duplicate current line"
  (interactive)
  (let ((column (- (point) (point-at-bol)))
        (line (let ((s (thing-at-point 'line t)))
                (if s (string-remove-suffix "\n" s) ""))))
    (move-end-of-line 1)
    (newline)
    (insert line)
    (move-beginning-of-line 1)
    (forward-char column)))

(defvar elpaca-installer-version 0.7)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1
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
                 ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                 ,@(when-let ((depth (plist-get order :depth)))
                                                     (list (format "--depth=%d" depth) "--no-single-branch"))
                                                 ,(plist-get order :repo) ,repo))))
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
  (setq which-key-idle-delay 3))

(use-package vertico
   :ensure (vertico :files (:defaults "extensions/*"))
   :diminish vertico-mode
   :bind (:map vertico-map
               ("C-n" . vertico-next)
               ("C-p" . vertico-previous))
   :init
   (vertico-mode 1)
   ;; (vertico-flat-mode 1)
   (setq vertico-count 15))

 ;; Configure directory extension.
 (use-package vertico-directory
   :after vertico
   :ensure nil
   ;; More convenient directory navigation commands
   :bind (:map vertico-map
               ("RET" . vertico-directory-enter)
               ("DEL" . vertico-directory-delete-char)
               ("M-DEL" . vertico-directory-delete-word))
   ;; Tidy shadowed file names
   :hook (rfn-eshadow-update-overlay . vertico-directory-tidy))

 (use-package vertico-multiform
   :after vertico
   :ensure nil
   :config
   (setq vertico-multiform-commands
         '((switch-to-buffer flat)
           (find-file flat)
           (dired flat)
           (man flat)
           (cd flat)
           (kill-buffer flat)
           (execute-extended-command flat)))
   (vertico-multiform-mode 1))

(use-package savehist
  :ensure nil
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
  (setq completion-styles '(orderless basic)
        orderless-matching-styles '(orderless-literal orderless-regexp orderless-prefixes orderless-initialism)
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
  :ensure nil
  ;; :diminish flyspell-mode
  )

(use-package flyspell-correct
  :after flyspell)

(use-package consult-flyspell
  :ensure (consult-flyspell :host gitlab :repo "OlMon/consult-flyspell" :branch "master")
  :config
  ;; default settings
  (setq consult-flyspell-select-function (lambda () (flyspell-correct-at-point) (consult-flyspell))
        consult-flyspell-set-point-after-word t
        consult-flyspell-always-check-buffer nil))

(use-package nerd-icons)
(use-package all-the-icons)

(use-package doom-themes
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  ;; (load-theme 'doom-vibrant t)
  (doom-themes-org-config))

(use-package gruber-darker-theme)
  ;; :config
  ;; (load-theme 'gruber-darker t))

(use-package ef-themes
  :config
  (setq ef-bio-palette-overrides
        '((bg-region bg-green-subtle)))
  (load-theme 'ef-bio t))

(use-package rainbow-delimiters
  :diminish rainbow-delimiters-mode
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package emojify
  :hook (after-init . global-emojify-mode)
  :config
  (add-hook 'prog-mode-hook #'(lambda () (emojify-mode -1))))

(use-package helpful
  :bind
  ([remap describe-command] . helpful-command)
  ([remap describe-function] . helpful-callable)
  ([remap describe-variable] . helpful-variable)
  ([remap describe-key] . helpful-key))

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

(use-package pdf-tools
  :ensure nil
  :config
  (pdf-tools-install)
  (add-hook 'pdf-view-mode-hook #'pdf-view-fit-height-to-window))

(use-package whitespace
  :ensure nil
  :diminish whitespace-mode global-whitespace-mode
  :config
  (setq whitespace-style
        '(face tabs spaces trailing
               space-before-tab newline indentation
               space-after-tab space-mark tab-mark))
  (add-hook 'before-save-hook 'delete-trailing-whitespace)
  (add-hook 'prog-mode-hook (lambda () (whitespace-mode 1))))

(use-package evil
  :diminish evil-mode
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  (setq evil-undo-system 'undo-tree)
  :config
  ;; (evil-mode 1)
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

(use-package tex
  :ensure auctex)

(setq markdown-command "pandoc")

(use-package org
  :diminish org-mode
  :custom
  ((org-agenda-files (list "~/org/homework.org")))
  :config
  (setq org-ellipsis " ▾")
  (add-hook 'org-mode-hook '(lambda () (whitespace-mode -1)))

  (setq org-format-latex-options (plist-put org-format-latex-options :scale 1.5))
  (add-to-list 'org-structure-template-alist '("sh" . "src shell"))
  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
  (add-to-list 'org-structure-template-alist '("py" . "src python"))
  (add-to-list 'org-structure-template-alist '("cpp" . "src c++"))
  (setq org-capture-templates
        '(("h" "Homework" entry (file "~/org/homework.org")
           "* TODO %? \nDEADLINE: %^t" :refile-targets (("~/org/homework.org" :level 1)))))
  (setq org-agenda-prefix-format '((agenda . " %i %-12:c%?-12t% s%:T ")
                                  (todo . " %i %-12:c")
                                  (tags . " %i %-12:c%:T ")
                                  (search . " %i %-12:c%:T ")))
  (setq org-agenda-hide-tags-regexp ".*")

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
  :ensure t
  :init
  (setq org-roam-v2-ack t)
  :custom
  (org-roam-directory "~/org/RoamNotes")
  (org-roam-completion-everywhere t)
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert)
         :map org-mode-map
         ("C-M-i"    . completion-at-point))
  :config
  (org-roam-setup))

(defun org-babel-tangle-config ()
  (when (string-equal (buffer-file-name) (expand-file-name "~/.dotfiles/.config/emacs/Emacs.org"))
    ;; Dynamic scoping to the rescue
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle))))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'org-babel-tangle-config)))

(use-package dired
  :ensure nil
  :ensure nil
  :commands (dired dired-jump)
  :bind (:map dired-mode-map ("SPC" . dired-single-buffer))
  :config
  (setq dired-dwim-target t)
  (evil-collection-define-key 'normal 'dired-mode-map
    "h" 'dired-single-up-directory
    "l" 'dired-single-buffer))

(use-package dired-single
  :commands (dired dired-jump))

(use-package mu4e
  :ensure nil
  :custom
  (mu4e-completing-read-function #'completing-read)
  :config
  (add-hook 'after-init-hook #'(lambda () (mu4e t)))
  ;; This is set to 't' to avoid mail syncing issues when using mbsync
  (setq mu4e-change-filenames-when-moving t)

  (setq mu4e-last-update-buffer " *mu4e-last-update*")

  (add-hook 'mu4e-compose-mode-hook #'(lambda () (setq-local undo-tree-auto-save-history nil)))
  (add-hook 'mu4e-compose-mode-hook #'(lambda () (flyspell-mode)))
  ;; Refresh mail using isync every 10 minutes
  (setq mu4e-update-interval (* 10 60)
        mu4e-get-mail-command "mbsync -a"
        mu4e-maildir "~/Maildir"

        message-send-mail-function 'smtpmail-send-it
        mu4e-compose-format-flowed t
        mu4e-context-policy 'pick-first
        mu4e-compose-context-policy 'ask-if-none
        mu4e-contexts
        (list
         (make-mu4e-context
          :name "gmail"
          :match-func
          (lambda (msg) (when msg (string-prefix-p "/gmail" (mu4e-message-field msg :maildir))))
          :vars '((user-mail-address . "rbeckettvt@gmail.com")
                  (user-full-name    . "Riley Beckett")
                  (smtpmail-smtp-server  . "smtp.gmail.com")
                  (smtpmail-smtp-service . 465)
                  (smtpmail-stream-type  . ssl)
                  (mu4e-drafts-folder  . "/gmail/Drafts")
                  (mu4e-sent-folder  . "/gmail/Sent Mail")
                  ;; (mu4e-refile-folder  . "/gmail/All Mail")
                  (mu4e-trash-folder  . "/gmail/Trash")
                  (message-signature . "Riley Beckett\nrbeckettvt@gmail.com")
                  (mu4e-maildir-shortcuts . ((:maildir "/gmail/INBOX"     :key ?i)
                                             (:maildir "/gmail/Sent Mail" :key ?s)
                                             (:maildir "/gmail/Trash"     :key ?t)
                                             (:maildir "/gmail/Drafts"    :key ?d)))))
                                             ;; (:maildir "/gmail/All Mail"  :key ?a)))))
         (make-mu4e-context
          :name "rpi"
          :match-func
          (lambda (msg) (when msg (string-prefix-p "/rpi" (mu4e-message-field msg :maildir))))
          :vars '((user-mail-address . "becker3@rpi.edu")
                  (user-full-name    . "Riley Beckett")
                  (smtpmail-smtp-server  . "smtp.office365.com")
                  (smtpmail-smtp-service . 587)
                  (smtpmail-stream-type  . starttls)
                  (mu4e-drafts-folder  . "/rpi/Drafts")
                  (mu4e-sent-folder  .   "/rpi/Send Items")
                  (mu4e-refile-folder  . "/rpi/Archive")
                  (mu4e-trash-folder  .  "/rpi/Deleted Items")
                  (message-signature . "Riley Beckett\nbecker3@rpi.edu")
                  (mu4e-maildir-shortcuts . ((:maildir "/rpi/Inbox"         :key ?i)
                                             (:maildir "/rpi/Sent Items"    :key ?s)
                                             (:maildir "/rpi/Deleted Items" :key ?t)
                                             (:maildir "/rpi/Drafts"        :key ?d)
                                             (:maildir "/rpi/Archive"       :key ?a))))))))

(use-package mu4e-alert
  :config
  (mu4e-alert-set-default-style 'libnotify)
  (add-hook 'after-init-hook #'mu4e-alert-enable-notifications))
(elpaca-wait)

(use-package pinentry)

(defun elfeed-video (&optional use-generic-p)
  "watch video link"
  (interactive "P")
  (let ((entries (elfeed-search-selected)))
    (dolist (e entries)
      (and (elfeed-tagged-p 'video e) (elfeed-entry-link e)
       (progn (elfeed-untag e 'unread)
              (open-mpv (elfeed-entry-link e)))))
    (mapc #'elfeed-search-update-entry entries)
    (unless (use-region-p) (forward-line))))

(defun elfeed-podcast (&optional use-generic-p)
  "run podcast"
  (interactive "P")
  (let ((entries (elfeed-search-selected)))
    (dolist (e entries)
      (and (elfeed-tagged-p 'podcast e) (elfeed-entry-enclosures e)
       (progn (elfeed-untag e 'unread)
              (open-mpv (caar (elfeed-entry-enclosures e))))))
    (mapc #'elfeed-search-update-entry entries)
    (unless (use-region-p) (forward-line))))

(use-package elfeed
  :bind (:map elfeed-search-mode-map
              ("v" . #'elfeed-video)
              ("P" . #'elfeed-podcast))
  :config
  (setq elfeed-log-buffer-name " *elfeed-log*")
  (add-hook 'elfeed-new-entry-hook
            (elfeed-make-tagger :feed-url "youtube\\.com" :add '(video youtube)))
  (add-hook 'elfeed-new-entry-hook
            (lambda (entry) (when (elfeed-entry-enclosures entry) (elfeed-tag entry 'podcast))))
  (setq elfeed-feeds
        '(("https://www.youtube.com/feeds/videos.xml?channel_id=UCld68syR8Wi-GY_n4CaoJGA" linux)
          ("https://www.youtube.com/feeds/videos.xml?channel_id=UCUyeluBRhGPCW4rPe_UvBZQ" programming)
          ("https://www.reddit.com/r/emacs/.rss" reddit emacs)
          ("https://anchor.fm/s/149fd51c/podcast/rss" linux)
          ("https://www.reddit.com/r/unixporn/.rss" reddit))))

(use-package multiple-cursors
  :bind (:map global-map
              ("C->" . 'mc/mark-next-like-this)
              ("C-<" . 'mc/mark-previous-like-this)
              ("C-c C->" . 'mc/mark-all-like-this)
              :map mc/keymap
              ("<return>" . nil)))

(use-package change-inner)

(use-package move-text)

(use-package transient)
(use-package magit
  :bind (("C-x g" . magit-status))
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(use-package flycheck
  :config
  (setq flycheck-error-message-buffer " *Flycheck error messages*")
  (setq-default flycheck-emacs-lisp-load-path 'inherit)
  (global-flycheck-mode 1)
  (add-hook 'c-mode-hook '(lambda () (flycheck-mode -1))))

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
         ;; (c-mode . lsp)
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

(use-package lsp-java
  :hook
  (java-mode . lsp))

(use-package consult-lsp
  :after lsp)

(use-package corfu
  :custom
  (corfu-auto t)
  (corfu-auto-delay 1)
  (corfu-auto-prefix 1)
  (corfu-separator ?\s)
  (corfu-preview-current nil)
  :config
  (global-corfu-mode)
  (bind-key (kbd "s-SPC") 'corfu-insert-separator 'corfu-map))

(use-package corfu-terminal
  :diminish corfu-terminal-mode
  :ensure (corfu-terminal :repo "https://codeberg.org/akib/emacs-corfu-terminal.git")
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
  (add-to-list 'completion-at-point-functions #'cape-elisp-symbol)
  (add-to-list 'completion-at-point-functions #'cape-history)
  (add-to-list 'completion-at-point-functions #'cape-keyword)
  ;;(add-to-list 'completion-at-point-functions #'cape-tex)
  ;;(add-to-list 'completion-at-point-functions #'cape-sgml)
  ;;(add-to-list 'completion-at-point-functions #'cape-rfc1345)
  ;;(add-to-list 'completion-at-point-functions #'cape-abbrev)
  ;;(add-to-list 'completion-at-point-functions #'cape-dict)
  ;;(add-to-list 'completion-at-point-functions #'cape-line)
  )

(use-package lsp-latex
  :ensure (lsp-latex.el :host github :repo "ROCKTAKEY/lsp-latex"))

(use-package clang-format)
(use-package clang-format+)

(use-package tree-sitter
  :config
  (global-tree-sitter-mode 1)
  (add-hook 'prog-mode-hook #'tree-sitter-hl-mode))
(use-package tree-sitter-langs)

(use-package highlight-quoted
  :diminish highlight-quoted-mode
  :hook (emacs-lisp-mode . highlight-quoted-mode))

(use-package glsl-mode
  :diminish
  :ensure (glsl-mode :host github :repo "jimhourihan/glsl-mode"))

(use-package lsp-haskell
  :hook
  (haskell-mode . lsp))

(use-package kotlin-mode)

(use-package gradle-mode
  :diminish)

(use-package nasm-mode
  :hook
  (asm-mode . nasm-mode))

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

(use-package yaml-mode)

(use-package simpc-mode
  :ensure (simpc-mode.el :host github :repo "rexim/simpc-mode")
  :config
  (add-to-list 'tree-sitter-major-mode-language-alist '(simpc-mode . c))
  (add-hook 'simpc-mode-hook (lambda () (interactive) (setq-local fill-paragraph-function 'astyle-buffer)))
  (add-hook 'c-mode-hook 'simpc-mode))

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

  (setq eshell-prompt-function
        (lambda ()
          (let* ((start "[")
                 (center (concat
                          (getenv "USER")
                          "@"
                          (string-trim
                           (with-temp-buffer
                             (insert-file "/etc/hostname")
                             (buffer-string)))))
                 (dir (let* ((lst (split-string (eshell/pwd) "/" t))
                             (i (1- (length lst)))
                             (str (nth i lst)))
                        str))
                 (end (concat "]" (if (= (user-uid) 0) "# " "$ ")))
                 (full (concat start center " " dir end)))
            (add-face-text-property 0 (length start) 'default t full)
            (add-face-text-property (length start) (+ (length start) (length center)) 'nerd-icons-green t full)
            (add-face-text-property
             (length (concat start " " center)) (+ (length dir) (length (concat start center " ")))
             'nerd-icons-blue t full)
            (add-face-text-property
             (length (concat start center " " dir)) (+ (length end) (length (concat start center " " dir)))
             'default t full)
            full)))

  (setq eshell-history-size         10000
        eshell-buffer-maximum-lines 10000
        eshell-hist-ignoredups t
        eshell-scroll-to-bottom-on-input t))

(use-package eshell
  :ensure nil
  :diminish eshell-mode
  :hook (eshell-first-time-mode . configure-eshell)
  :config
  (with-eval-after-load 'esh-opt
    (setq eshell-destroy-buffer-when-process-dies t)
    (setq eshell-visual-commands '("htop"))
    (setq eshell-prompt-regexp "^.*\]$ ")))

(use-package calendar
  :ensure nil
  :config
  (defun calendar-insert-date ()
    "Capture the date at point, exit the Calendar, insert the date."
    (interactive)
    (seq-let (month day year) (save-match-data (calendar-cursor-to-date))
      (calendar-exit)
      (insert (format "%02d/%02d/%d" month day year))))

  (define-key calendar-mode-map (kbd "M-I") 'calendar-insert-date))

(elpaca-wait)

(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)

(global-unset-key (kbd "C-z"))
(bind-key [remap scroll-down-command] 'better-scroll-down)
(bind-key [remap scroll-up-command] 'better-scroll-up)
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)
(global-set-key (kbd "C-/") #'undo-tree-undo)
(global-set-key (kbd "M-/") #'undo-tree-redo)
(global-set-key (kbd "M-p") #'move-text-up)
(global-set-key (kbd "M-n") #'move-text-down)
(global-set-key (kbd "C-c v") #'avy-goto-char-timer)
(global-set-key (kbd "C-c s") #'consult-flyspell)
(global-set-key (kbd "C-c r") #'recompile)
(global-set-key (kbd "C-c m") #'mu4e)
(global-set-key (kbd "C-c f") #'elfeed)
(global-set-key (kbd "C-c a") #'ace-window)
(global-set-key (kbd "C-,") #'duplicate-line-better)
(global-set-key (kbd "C-c c d") #'cape-dabbrev)
(global-set-key (kbd "C-c c f") #'cape-file)
(global-set-key (kbd "C-c c b") #'cape-elisp-block)
(global-set-key (kbd "C-c c s") #'cape-elisp-symbol)
(global-set-key (kbd "C-c c h") #'cape-history)
(global-set-key (kbd "C-c c k") #'cape-keyword)
(global-set-key (kbd "C-c o a") #'org-agenda)
(global-set-key (kbd "C-c o d") #'org-deadline)
(global-set-key (kbd "C-c o s") #'org-schedule)
(global-set-key (kbd "C-c o c") #'org-capture)
(global-set-key (kbd "M-i") #'change-inner)
