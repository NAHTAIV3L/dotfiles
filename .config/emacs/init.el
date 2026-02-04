(require 'package)
(setq package-archives
      '(("org" . "https://orgmode.org/elpa/")
    	("gnu" . "https://elpa.gnu.org/packages/")
    	("melpa" . "https://melpa.org/packages/")
		("nongnu" . "https://elpa.nongnu.org/nongnu/")))
(setq package-archive-priorities
	  '(("gnu" . 10)))
(package-initialize)

(setq use-package-always-ensure t)

(add-to-list 'load-path (concat (getenv "HOME") "/dev/elisp/proj/"))

(setq custom-file (expand-file-name "customs.el" user-emacs-directory))
(load custom-file :no-error-if-file-is-missing)

(use-package no-littering
  :demand t)

(unless package-archive-contents
  (package-refresh-contents))

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

(require 'proj)

(scroll-bar-mode -1) ; Disable visible scrollbar
(tool-bar-mode -1) ; Disable the toolbar
(tooltip-mode -1) ; Disable tooltips
(menu-bar-mode -1) ; Disable the menu bar

;; fringes
(setq flymake-autoresize-margins nil)
(setq fringe-mode 0)
(set-fringe-mode 0)

(editorconfig-mode 1)
(add-hook 'prog-mode 'editorconfig-apply)

(setq scroll-up-aggressively nil
      scroll-down-aggressively nil
      scroll-conservatively 101
      display-line-numbers-type 'relative)

(setq scroll-step 1)
(setq scroll-margin 8)

(add-hook 'before-save-hook #'delete-trailing-whitespace)
(add-hook 'nroff-mode-hook
          (lambda () (add-hook 'after-save-hook
                               (lambda ()
                                 (let* ((input-file (buffer-file-name))
                                        (output-file (concat (file-name-sans-extension input-file) ".pdf"))
                                        (command (format "grog -U --run -dpaper=letter -Tpdf -- %s > %s"
                                                         (shell-quote-argument input-file)
                                                         (shell-quote-argument output-file))))
                                   (compile command)))
                               nil t)))

(column-number-mode +1)
(global-display-line-numbers-mode +1)
(setq-default fill-column 80)
(load-theme 'modus-vivendi t)
(set-face-attribute 'mode-line nil
                    :box nil
                    :foreground "#9fefff"
                    :background "black")
(set-face-attribute 'mode-line-inactive nil
                    :box nil
                    :foreground "#5e8891"
                    :background "black")

(dolist (mode '(org-mode-hook
                term-mode-hook
                shell-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(set-face-attribute 'default nil
                    :font "DejaVu Sans Mono"
                    :family "Monospace"
                    :height 100)
(set-face-attribute 'variable-pitch nil
                    :font "DejaVu Sans"
                    :family "Monospace"
                    :height 100)
(set-face-attribute 'fixed-pitch nil
                    :font "DejaVu Sans Mono"
                    :family "Monospace"
                    :height 100)

(defun erc-tls-oftc ()
  (interactive)
  (erc-tls :server "irc.oftc.net"
           :port "6697"))

(defun better-scroll-up (&optional arg)
  (interactive "^P")
  (call-interactively 'scroll-up-command arg)
  (recenter))
(defun better-scroll-down (&optional arg)
  (interactive "^P")
  (call-interactively 'scroll-down-command)
  (recenter))

(global-unset-key (kbd "C-z"))
(bind-key [remap scroll-down-command] 'better-scroll-down)
(bind-key [remap scroll-up-command] 'better-scroll-up)

(use-package evil
  :demand t
  :init
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 1)
  (bind-key "g c c"
            (lambda ()
              (interactive)
              (comment-line 1)
              (evil-previous-line))
            'evil-normal-state-map)
  (bind-key "g c" #'comment-dwim 'evil-visual-state-map)
  :custom
  (evil-want-C-u-scroll t)
  (evil-undo-system 'undo-redo)
  (evil-move-beyond-eol nil))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package dired
  :ensure nil
  :commands (dired)
  :hook
  ((dired-mode . hl-line-mode))
  :config
  (setq dired-recursive-copies 'always)
  (setq dired-recursive-deletes 'always)
  (setq dired-dwim-target t)
  (setq dired-kill-when-opening-new-dired-buffer t)
  (setq dired-listing-switches "-alh --group-directories-first"))

(use-package eglot
  :ensure nil
  :config
  (setq eglot-ignored-server-capabilities '(:inlayHintProvider :documentHighlightProvider))
  (add-hook 'eglot-mode-hook (lambda () (flymake-mode 1))))

(use-package yasnippet
  :ensure t
  :bind
  (:map yas-keymap
        ("M-n" . yas-next-field)
        ("M-p" . yas-prev-field)))

(use-package dumb-jump
  :ensure t
  :init
  (add-hook 'xref-backend-functions #'dumb-jump-xref-activate)
  (setq xref-show-definitions-function #'xref-show-definitions-completing-read))

(use-package vertico
  :init
  (vertico-mode))

(use-package marginalia
  :init
  (marginalia-mode))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (orderless-matching-styles '(orderless-initialism orderless-literal))
  (completion-category-defaults nil))

(use-package embark
  :ensure t
  :bind
  :init
  ;; Optionally replace the key help with a completing-read interface

  ;; Show the Embark target at point via Eldoc. You may adjust the
  ;; Eldoc strategy, if you want to see the documentation from
  ;; multiple providers. Beware that using this can be a little
  ;; jarring since the message shown in the minibuffer can be more
  ;; than one line, causing the modeline to move up and down:

  ;; (add-hook 'eldoc-documentation-functions #'embark-eldoc-first-target)
  ;; (setq eldoc-documentation-strategy #'eldoc-documentation-compose-eagerly)

  ;; Add Embark to the mouse context menu. Also enable `context-menu-mode'.
  ;; (context-menu-mode 1)
  ;; (add-hook 'context-menu-functions #'embark-context-menu 100)
  (global-set-key (kbd "C-'") 'embark-act) ;; pick some comfortable binding
  (global-set-key (kbd "M-'") 'embark-dwim))

;; Consult users will also want the embark-consult package.
(use-package embark-consult
  :ensure t ; only need to install it, embark loads it after consult if found
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(use-package helpful
  :bind
  ([remap describe-command] . helpful-command)
  ([remap describe-function] . helpful-callable)
  ([remap describe-variable] . helpful-variable)
  ([remap describe-key] . helpful-key))

(use-package avy
  :config
  (setq avy-dispatch-alist '((?x . avy-action-kill-move)
                             (?X . avy-action-kill-stay)
                             (?t . avy-action-teleport)
                             (?m . avy-action-mark)
                             (?c . avy-action-copy)
                             (?y . avy-action-yank)
                             (?Y . avy-action-yank-line)
                             (?i . avy-action-ispell)
                             (?z . avy-action-zap-to-char)))
  (setq avy-keys '(?s ?d ?f ?g ?h ?j ?k ?l ?p ?v ?b ?n ?q ?w ?e ?r ?u ?o ?a))
  (global-set-key (kbd "C-;") 'avy-goto-char-timer))

(use-package ace-window
  :config
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
  (set-face-attribute 'aw-leading-char-face nil
                      :height 1.0)
  (global-set-key (kbd "C-M-;") 'ace-window))

(use-package corfu
  ;; Optional customizations
  :custom
  ;; (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
  ;; (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
  ;; (corfu-quit-no-match nil)      ;; Never quit, even if there is no match
  (corfu-preview-current nil)    ;; Disable current candidate preview
  ;; (corfu-preselect 'prompt)      ;; Preselect the prompt
  ;; (corfu-on-exact-match 'insert) ;; Configure handling of exact matches
  (corfu-max-width 100)
  (corfu-bar-width 0)

  :init
  (global-corfu-mode)
  (bind-key "C-M-i" #'corfu-insert 'corfu-map))

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
  (global-set-key (kbd "C-c f") #'cape-file)
  (global-set-key (kbd "C-c d") #'cape-dabbrev)
  (global-set-key (kbd "C-c b") #'cape-elisp-block)
  (global-set-key (kbd "C-c s") #'cape-elisp-symbol)
  (global-set-key (kbd "C-c h") #'cape-history)
  (global-set-key (kbd "C-c w") #'cape-keyword)
  :config
  (advice-add 'eglot-completion-at-point :around #'cape-wrap-buster))

(use-package savehist
  :ensure nil
  :hook (after-init . savehist-mode))

(use-package consult
  :custom
  (consult-preview-key nil)
  :bind (("M-l"   . 'consult-git-grep)  ;; Search inside a project
		 ("M-s"   . 'consult-line)      ;; Search current buffer, like swiper
		 ("C-c i" . 'consult-imenu)     ;; Search the imenu
		 )
  :config
  (setq proj-grep-function 'consult-ripgrep))


(use-package haskell-ts-mode
  :vc (:url "https://codeberg.org/pranshu/haskell-ts-mode"
            :branch "main")
  :ensure t
  :custom
  (haskell-ts-font-lock-level 4))

(setq treesit-font-lock-level 4)
(setq treesit-language-source-alist
	  '((cpp "https://github.com/tree-sitter/tree-sitter-cpp")
		(c "https://github.com/tree-sitter/tree-sitter-c")
        (python "https://github.com/tree-sitter/tree-sitter-python")
        (haskell "https://github.com/tree-sitter/tree-sitter-haskell")))
(dolist (lang treesit-language-source-alist)
  (unless (treesit-language-available-p (car lang))
	(treesit-install-language-grammar (car lang))))
(setq treesit-load-name-override-list
      '((c++ "libtree-sitter-cpp")))
(setq major-mode-remap-alist '((c-mode . c-ts-mode)
                               (c++-mode . c++-ts-mode)
                               (python-mode . python-ts-mode)
                               (haskell-mode . haskell-ts-mode)))

(use-package ansi-color
  :hook (compilation-filter . ansi-color-compilation-filter))

(global-set-key (kbd "C-x b") #'proj-switch-to-buffer)
(global-set-key (kbd "C-c b") #'switch-to-buffer)

(global-set-key (kbd "C-x k") #'proj-kill-buffer)
(global-set-key (kbd "C-c k") #'kill-buffer)
