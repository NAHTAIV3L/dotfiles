(defun lookup-password (&rest keys)
  (let ((result (apply #'auth-source-search keys)))
    (if result
        (funcall (plist-get (car result) :secret))
      nil)))

(defun emacs-dmenu ()
  (interactive)
  (let* ((programs (split-string (shell-command-to-string "IFS=: ; stest -flx $PATH | sort -u") "\n" t ))
         (choice (completing-read "$ " programs)))
    (start-process-shell-command (car (split-string choice " " t)) nil choice)))

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

(defun exwm-update-class ()
  (exwm-workspace-rename-buffer (cmdline)))

(defun exwm-update-title ()
  ;; (pcase exwm-class-name
  ;;   ("Firefox" (exwm-workspace-rename-buffer (format "Firefox: %s" exwm-title)))
  ;;   ("qutebrowser" (exwm-workspace-rename-buffer (format "qutebrowser: %s" exwm-title))))
  (exwm-workspace-rename-buffer (format "%s: %s" (cmdline) exwm-title)))

(defun exwm-special-keys ()
  (global-set-key [\S-XF86MonBrightnessDown]      #'(lambda () (interactive)
                                                      (start-process-shell-command "xbacklight" nil "xbacklight -dec 5")))
  (global-set-key [XF86MonBrightnessDown]         #'(lambda () (interactive)
                                                      (start-process-shell-command "xbacklight" nil "xbacklight -dec 1")))
  (global-set-key [\S-XF86MonBrightnessUp]        #'(lambda () (interactive)
                                                      (start-process-shell-command "xbacklight" nil "xbacklight -inc 5")))
  (global-set-key [XF86MonBrightnessUp]           #'(lambda () (interactive)
                                                      (start-process-shell-command "xbacklight" nil "xbacklight -inc 1")))
  (global-set-key [\S-XF86Display]                #'(lambda () (interactive)
                                                      (start-process-shell-command "mounter" nil "mounter")))
  (global-set-key [\S-XF86WLAN]                   #'(lambda () (interactive)
                                                      (start-process-shell-command "unmounter" nil "unmounter")))
  (global-set-key [XF86AudioLowerVolume]          #'(lambda () (interactive)
                                                      (start-process-shell-command "pactl" nil "pactl set-sink-volume @DEFAULT_SINK@ -1%")))
  (global-set-key [\S-XF86AudioLowerVolume]       #'(lambda () (interactive)
                                                      (start-process-shell-command "pactl" nil "pactl set-sink-volume @DEFAULT_SINK@ -5%")))
  (global-set-key [XF86AudioRaiseVolume]          #'(lambda () (interactive)
                                                      (start-process-shell-command "pactl" nil "pactl set-sink-volume @DEFAULT_SINK@ +1%")))
  (global-set-key [\S-XF86AudioRaiseVolume]       #'(lambda () (interactive)
                                                      (start-process-shell-command "pactl" nil "pactl set-sink-volume @DEFAULT_SINK@ +5%")))
  (global-set-key [XF86AudioMute]                 #'(lambda () (interactive)
                                                      (start-process-shell-command "pactl" nil "pactl set-sink-mute @DEFAULT_SINK@ toggle")))
  (which-key-add-keymap-based-replacements myemacs-leader-map "e" "emacs")
  (define-key myemacs-leader-map (kbd "ex") '("sleep" . (lambda () (interactive (start-process-shell-command "loginctl" nil "loginctl suspend")))))
  (define-key myemacs-leader-map (kbd "ez") '("hybernate" . (lambda () (interactive (start-process-shell-command "loginctl" nil "loginctl hybernate"))))))

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
(server-start)

(setq exwm-input-global-keys
      `(
        ;; Reset to line-mode (C-c C-k switches to char-mode via exwm-input-release-keyboard)
        ([?\s-r] . exwm-reset)

        ([?\M-\ ] . myemacs/leader)
        ;; Launch applications via shell command
        ([?\M-p] . emacs-dmenu)
        ([?\s-1] . +workspace/switch-to-1)
        ([?\s-2] . +workspace/switch-to-2)
        ([?\s-3] . +workspace/switch-to-3)
        ([?\s-4] . +workspace/switch-to-4)
        ([?\s-5] . +workspace/switch-to-5)
        ([?\s-6] . +workspace/switch-to-6)
        ([?\s-7] . +workspace/switch-to-7)
        ([?\s-8] . +workspace/switch-to-8)
        ([?\s-9] . +workspace/switch-to-9)))
(exwm-enable)
(define-key exwm-mode-map [?\C-q] 'exwm-input-send-next-key)
