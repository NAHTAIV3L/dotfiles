;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

;; (exwm-enable)

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Riley Beckett"
      user-mail-address "rbeckettvt@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/.dotfiles/org/")
(setq +zen-text-scale nil)


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(require 'bon-app-launcher)

(defun getpid ()
  (interactive)
  (car (split-string (car (last (split-string (shell-command-to-string (format "xprop -id 0x%X _NET_WM_PID" (exwm--buffer->id (current-buffer)))) " " t))) "\n" t)))

(defun file-to-string (file)
  (with-temp-buffer
      (insert-file-contents file)
      (buffer-string)))

(defun cmdline ()
  (let* ((pid (getpid))
              (str (file-to-string (format "/proc/%s/cmdline" pid))))
    (s-replace "\x00" " " (substring str 0 (- (length str) 1)))))

;; -------------------------------------------------
;;      for displaying wifi in the mode line
;; -------------------------------------------------

(defun wifi-update ()
  (let ((essid (car(split-string (shell-command-to-string "nmcli -t -f name,device connection show --active | grep -v lo:lo") "\n" t)))
        (connection (car(split-string (shell-command-to-string "awk 'NR==3 {print $3}' /proc/net/wireless | cut -d. -f1") "\n" t))))
  (setq display-wifi-string (concat (format "%s %s" essid connection) "%%  "))))

(defun wifi-update-handler ()
  (wifi-update)
  (sit-for 0))

(defvar display-wifi-string nil
  "volume displayed string")

(define-minor-mode display-wifi-mode
  "displays the volume and whether or not its muted"
  :global t :group 'display-wifi
  (if display-wifi-mode
      (progn
        (or (memq 'display-wifi-string global-mode-string)
            (add-to-list 'global-mode-string 'display-wifi-string t))
        (setq wifi-update-timer (run-at-time nil 1 #'wifi-update-handler))
        (wifi-update))
    (setq global-mode-string (delq 'display-wifi-string global-mode-string))
    (setq wifi-update-timer nil)))

;; -------------------------------------------------
;;      for displaying volume in the mode line
;; -------------------------------------------------

(defun volume-update ()
  (setq display-volume-string (concat (car (split-string (shell-command-to-string "getvolume") "\n" t)) "%"
                                      (car (split-string(shell-command-to-string "getmuted") "\n" t)) "  ")))

(defun volume-update-handler ()
  (volume-update)
  (sit-for 0))

(defvar display-volume-string nil
  "volume displayed string")

(define-minor-mode display-volume-mode
  "displays the volume and whether or not its muted"
  :global t :group 'display-volume
  (if display-volume-mode
      (progn
        (or (memq 'display-volume-string global-mode-string)
            (add-to-list 'global-mode-string 'display-volume-string t))
        (setq volume-update-timer (run-at-time nil 1 #'volume-update-handler))
        (volume-update))
    (setq global-mode-string (delq 'display-volume-string global-mode-string))
    (setq volume-update-timer nil)))

;; -------------------------------------------------
;;    for displaying brightness in the mode line
;; -------------------------------------------------

(defun brightness-update ()
  (setq display-brightness-string (concat (car (split-string (shell-command-to-string "getbright") "\n" t)) "%%  ")))

(defun brightness-update-handler ()
  (brightness-update)
  (sit-for 0))

(defvar display-brightness-string nil
  "volume displayed string")

(define-minor-mode display-brightness-mode
  "displays the volume and whether or not its muted"
  :global t :group 'display-brightness
  (if display-brightness-mode
      (progn
        (or (memq 'display-brightness-string global-mode-string)
            (add-to-list 'global-mode-string 'display-brightness-string t))
        (setq brightness-update-timer (run-at-time nil 1 #'brightness-update-handler))
        (brightness-update))
    (setq global-mode-string (delq 'display-brightness-string global-mode-string))
    (setq brightness-update-timer nil)))

;; -----------------------------------------------------------
;; -----------------------------------------------------------

(defun exwm-update-class ()
  (exwm-workspace-rename-buffer (cmdline)))

(defun exwm-update-title ()
  ;; (pcase exwm-class-name
  ;;   ("Firefox" (exwm-workspace-rename-buffer (format "Firefox: %s" exwm-title)))
  ;;   ("qutebrowser" (exwm-workspace-rename-buffer (format "qutebrowser: %s" exwm-title))))
  (exwm-workspace-rename-buffer (format "%s: %s" (cmdline) exwm-title)))

(defun exwm-special-keys ()
  (map! [\S-XF86MonBrightnessDown]      #'(lambda () (interactive)
                                            (start-process-shell-command "xbacklight" nil "xbacklight -dec 5")))
  (map! [XF86MonBrightnessDown]         #'(lambda () (interactive)
                                            (start-process-shell-command "xbacklight" nil "xbacklight -dec 1")))
  (map! [\S-XF86MonBrightnessUp]        #'(lambda () (interactive)
                                            (start-process-shell-command "xbacklight" nil "xbacklight -inc 5")))
  (map! [XF86MonBrightnessUp]           #'(lambda () (interactive)
                                            (start-process-shell-command "xbacklight" nil "xbacklight -inc 1")))
  (map! [\S-XF86Display]                #'(lambda () (interactive)
                                            (start-process-shell-command "mounter" nil "mounter")))
  (map! [\S-XF86WLAN]                   #'(lambda () (interactive)
                                            (start-process-shell-command "unmounter" nil "unmounter")))
  (map! [XF86AudioLowerVolume]          #'(lambda () (interactive)
                                            (start-process-shell-command "pactl" nil "pactl set-sink-volume @DEFAULT_SINK@ -1%")))
  (map! [\S-XF86AudioLowerVolume]       #'(lambda () (interactive)
                                            (start-process-shell-command "pactl" nil "pactl set-sink-volume @DEFAULT_SINK@ -5%")))
  (map! [XF86AudioRaiseVolume]          #'(lambda () (interactive)
                                            (start-process-shell-command "pactl" nil "pactl set-sink-volume @DEFAULT_SINK@ +1%")))
  (map! [\S-XF86AudioRaiseVolume]       #'(lambda () (interactive)
                                            (start-process-shell-command "pactl" nil "pactl set-sink-volume @DEFAULT_SINK@ +5%")))
  (map! [XF86AudioMute]                 #'(lambda () (interactive)
                                            (start-process-shell-command "pactl" nil "pactl set-sink-mute @DEFAULT_SINK@ toggle")))
  (map! :leader
        :prefix ("e" . "emacs")
        :desc "sleep"           "x" #'(lambda () (interactive) (start-process-shell-command "loginctl" nil "loginctl suspend"))
        :desc "hybernate"       "z" #'(lambda () (interactive) (start-process-shell-command "loginctl" nil "loginctl hybernate")))
  )

(if (or (string= (getenv "WINDOWMANAGER") "d") (string= (getenv "WINDOWMANAGER") ""))
    nil
  (progn
    (add-hook 'exwm-update-class-hook #'exwm-update-class)
    (add-hook 'exwm-update-title-hook #'exwm-update-title)
    (setq exwm-input-prefix-keys
          '(?\C-x
            ?\C-u
            ?\C-h
            ?\M-x
            ?\M-`
            ?\M-&
            ?\M-:
            ?\C-\M-j  ;; Buffer list
            ?\C-\ ;; Ctrl+Space
            ?\M-\ ;; Alt+Space
            \S-XF86Display
            \S-XF86WLAN
            XF86MonBrightnessUp
            XF86MonBrightnessDown
            \S-XF86MonBrightnessUp
            \S-XF86MonBrightnessDown
            XF86AudioLowerVolume
            XF86AudioRaiseVolume
            \S-XF86AudioLowerVolume
            \S-XF86AudioRaiseVolume
            XF86AudioMute))

    (exwm-special-keys)
    (setq display-time-format "%I:%M:%S %p")
    (setq display-time-interval 1)
    (setq display-time-load-average-threshold 10)
    (display-time-mode)
    (display-battery-mode)
    (display-wifi-mode)
    (display-volume-mode)
    (display-brightness-mode)

    (setq exwm-input-global-keys
          `(
            ;; Reset to line-mode (C-c C-k switches to char-mode via exwm-input-release-keyboard)
            ([?\s-r] . exwm-reset)

            ([?\M-\ ] . doom/leader)
            ;; Launch applications via shell command
            ([?\M-p] . (lambda (command)
                         (interactive (list (read-shell-command "$ ")))
                         (start-process-shell-command command nil command)))
            ([?\s-1] . +workspace/switch-to-0)
            ([?\s-2] . +workspace/switch-to-1)
            ([?\s-3] . +workspace/switch-to-2)
            ([?\s-4] . +workspace/switch-to-3)
            ([?\s-5] . +workspace/switch-to-4)
            ([?\s-6] . +workspace/switch-to-5)
            ([?\s-7] . +workspace/switch-to-6)
            ([?\s-8] . +workspace/switch-to-7)
            ([?\s-9] . +workspace/switch-to-8)))
    (exwm-enable)
    (define-key exwm-mode-map [?\C-q] 'exwm-input-send-next-key))
  )

(setq-default tab-width 4)
(map! :n "C-SPC" 'harpoon-toggle-quick-menu)
(map! :leader
      :prefix ("j" . "harpoon")
        :desc "harpoon add file"          "a" #'harpoon-add-file
        :desc "harpoon delete items"      "D" #'harpoon-delete-item
        :desc "harpoon clear"             "c" #'harpoon-clear
        :desc "harpoon toggle file"       "f" #'harpoon-toggle-file)

(map! :leader "1" 'harpoon-go-to-1)
(map! :leader "2" 'harpoon-go-to-2)
(map! :leader "3" 'harpoon-go-to-3)
(map! :leader "4" 'harpoon-go-to-4)
(map! :leader "5" 'harpoon-go-to-5)
(map! :leader "6" 'harpoon-go-to-6)
(map! :leader "7" 'harpoon-go-to-7)
(map! :leader "8" 'harpoon-go-to-8)
(map! :leader "9" 'harpoon-go-to-9)
(map! :leader
      :prefix ("d" . "delete")
        :desc "harpoon delete 1"        "1" #'harpoon-delete-1
        :desc "harpoon delete 2"        "2" #'harpoon-delete-2
        :desc "harpoon delete 3"        "3" #'harpoon-delete-3
        :desc "harpoon delete 4"        "4" #'harpoon-delete-4
        :desc "harpoon delete 5"        "5" #'harpoon-delete-5
        :desc "harpoon delete 6"        "6" #'harpoon-delete-6
        :desc "harpoon delete 7"        "7" #'harpoon-delete-7
        :desc "harpoon delete 8"        "8" #'harpoon-delete-8
        :desc "harpoon delete 9"        "9" #'harpoon-delete-9)

(map! :leader
      :prefix ("l" . "lsp")
        :desc "lsp format buffer"       "f" #'lsp-format-buffer
        :desc "lsp ui doc show"         "d" #'lsp-ui-doc-show)

(after! undo-tree (map! :leader "u" 'undo-tree-visualize))

(add-hook 'haskell-mode-hook #'lsp)
(add-hook 'haskell-literate-mode-hook #'lsp)
(add-hook '*-mode-hook #'tree-sitter-hl-mode)

(setq scroll-margin 8)

(map! "M-j" 'drag-stuff-down)
(map! "M-k" 'drag-stuff-up)

(defun 2pong ()
  "Play pong with better keybinds for 2 people"
  (interactive)
  (keymap-set pong-mode-map "w" #'pong-move-left)
  (keymap-set pong-mode-map "s" #'pong-move-right)
  (pong))

