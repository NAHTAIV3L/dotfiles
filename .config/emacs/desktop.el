(defun emacs-dmenu ()
  (interactive)
  (let* ((programs (split-string (shell-command-to-string "IFS=: ; stest -flx $PATH | sort -u") "\n" t ))
         (choice (completing-read "$ " programs)))
    (start-process-shell-command (car (split-string choice " " t)) nil choice)))

(defun getpid ()
  (interactive)
  (let ((output (shell-command-to-string (format "xprop -id 0x%X _NET_WM_PID" (exwm--buffer->id (current-buffer))))))
    (string-trim (car (last (split-string output " " t))))))

(defun file-to-string (file)
  (with-temp-buffer
    (insert-file-contents file)
    (buffer-string)))

(defun cmdline ()
  (let* ((pid (getpid))
         (str (file-to-string (format "/proc/%s/cmdline" pid))))
    (car (last (split-string (s-replace "\x00" " " (substring str 0 (- (length str) 1))) "/" t)))))

(defun exwm-update-class ()
  (exwm-workspace-rename-buffer (cmdline)))

(defun exwm-update-title ()
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
  (define-key myemacs-leader-map (kbd "ez") '("hybernate" . (lambda () (interactive (start-process-shell-command "loginctl" nil "loginctl hybernate")))))
  (define-key myemacs-leader-map (kbd "epoweroff") '("poweroff" . (lambda () (interactive (start-process-shell-command "loginctl" nil "loginctl poweroff"))))))

(defun turn-on-statusbar ()
  (statusbar-mode 1)
  (display-wifi-mode 1)
  (display-volume-mode 1)
  (display-brightness-mode 1)
  (setq display-time-format "%I:%M:%S %p")
  (setq display-time-interval 1)
  (setq display-time-load-average-threshold 10)
  (statusbar-time-mode 1)
  (statusbar-battery-mode 1))

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

(setq exwm-input-global-keys
      `(
        ;; Reset to line-mode (C-c C-k switches to char-mode via exwm-input-release-keyboard)
        ([?\s-r] . exwm-reset)

        ([?\s-s] . (lambda () (interactive) (start-process-shell-command "bkmrkcli" nil "bkmrkcli -p")))
        ([?\C-\s-s] . (lambda () (interactive) (start-process-shell-command "bkmrkcli" nil "bkmrkcli -a")))
        ([?\M-\s-s] . (lambda () (interactive) (start-process-shell-command "bkmrkcli" nil "bkmrkcli -d")))

        ([?\M-\ ] . myemacs/leader)
        ;; Launch applications via shell command
        ([?\M-p] . emacs-dmenu)

        ,@(mapcar (lambda (i)
                    `(,(kbd (format "s-%d" i)) .
                      (lambda ()
                        (interactive)
                        (exwm-workspace-switch-create ,i))))
                  (number-sequence 0 9))))
(exwm-enable)
(exwm-workspace-switch-create 1)
(define-key exwm-mode-map [?\C-q] 'exwm-input-send-next-key)

(run-at-time 4 nil #'turn-on-statusbar)
(server-start)
