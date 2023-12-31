(defun bkmrkadd ()
  (interactive)
  (let ((clip (shell-command-to-string "xclip -o"))
        (desc (read-string "Enter description: ")))
    (with-current-buffer (find-file (expand-file-name "~/.dotfiles/bookmark"))
      (goto-char (point-min))
      (flush-lines "^$")
      (goto-char (point-min))
      (if (search-forward clip nil t)
          (shell-command (format "notify-send \"Already Added\" \"%s\"" clip))
        (goto-char (point-max))
        (insert (format "\n%s #%s" clip desc))
        (shell-command (format "notify-send \"Bookmark Added\" \"%s\"" clip)))
      (save-buffer)
      (kill-buffer))))

(defun bkmrkdel ()
  (interactive)
  (let ((del (with-temp-buffer 
               (insert-file-contents (expand-file-name "~/.dotfiles/bookmark"))
               (goto-char (point-min))
               (while (re-search-forward "^#" nil t)
                 (delete-region (line-beginning-position) (line-beginning-position 2)))
               (completing-read "bookmark to remove: " (split-string (buffer-string) "\n" t) nil t))))
    (with-current-buffer (find-file-noselect (expand-file-name "~/.dotfiles/bookmark"))
      (if (string= "No" (completing-read "Are you sure: " '("Yes" "No") nil t))
          (shell-command "notify-send \"Deletion Canceled\"")
        (search-forward del)
        (delete-region (line-beginning-position) (line-beginning-position 2))
        (save-buffer)
        (kill-buffer)
        (shell-command (format "notify-send \"Bookmark Deleted\" \"%s\"" del))))))

(defun getitem (list item)
  (if (eq list '())
      '()
    (if (string= (car (cdar list)) item) ;matches,
        (caar list)  ;take the matching element
      (getitem (cdr list) item))))

(defun bkmrkput ()
  (interactive)
  (let* ((lists (mapcar (lambda (x) (mapcar #'string-trim (split-string x "#" t)))
                        (split-string (with-temp-buffer 
                                        (insert-file-contents (expand-file-name "~/.dotfiles/bookmark"))
                                        (goto-char (point-min))
                                        (while (re-search-forward "^#" nil t)
                                          (delete-region
                                           (line-beginning-position)
                                           (line-beginning-position 2)))
                                        (buffer-string)) "\n" t)))
         (items (mapcar (lambda (x) (car (last x))) lists))
         (item (completing-read "Which bookmark: " items))
         (link (getitem lists item)))
    (start-process-shell-command "xdotool" nil
                                 (format "sleep 0.1 ; xdotool type --delay 1 --clearmodifiers \"%s\"" link))))

(defun emacs-dmenu ()
  (interactive)
  (let* ((programs (split-string (shell-command-to-string "IFS=: ; stest -flx $PATH | sort -u") "\n" t ))
         (choice (completing-read "$ " programs)))
    (start-process-shell-command (car (split-string choice " " t)) nil choice)))

(defun firefoxchoice ()
  (interactive)
  (let* ((files (directory-files (expand-file-name "~/.mozilla/firefox/") nil "^\\([^.]\\|\\.[^.]\\|\\.\\..\\)"))
         (ffprofs (cl-delete-if (lambda (x) (string-match-p "\.ini" x)) files))
         (strings (mapcar (lambda (x) (car (last (split-string x "\\." t)))) ffprofs))
         (choice (completing-read "$ " strings)))
    (start-process-shell-command "firefox" nil (format "firefox -p %s" choice))))

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
         (filep (file-exists-p (format "/proc/%s/cmdline" pid)))
         (str (if filep (file-to-string (format "/proc/%s/cmdline" pid)) nil)))
    (if str (car (last (split-string (s-replace "\x00" " " (substring str 0 (- (length str) 1))) "/" t))) nil)))

(defun exwm-update-class ()
  (exwm-workspace-rename-buffer (or (cmdline) (or exwm-class-name "EXWM"))))

(defun exwm-update-title ()
  (exwm-workspace-rename-buffer (format "%s: %s" (or (cmdline) exwm-class-name "EXWM") exwm-title)))

(defun exwm-special-keys ()
  (global-set-key [\S-XF86MonBrightnessDown]      #'(lambda () (interactive)
                                                      (start-process-shell-command "backlightctrl" nil "backlightctrl -dec 5 -time 0")
                                                      (brightness-update)))
  (global-set-key [XF86MonBrightnessDown]         #'(lambda () (interactive)
                                                      (start-process-shell-command "backlightctrl" nil "backlightctrl -dec 1 -time 0")
                                                      (brightness-update)))
  (global-set-key [\S-XF86MonBrightnessUp]        #'(lambda () (interactive)
                                                      (start-process-shell-command "backlightctrl" nil "backlightctrl -inc 5 -time 0")
                                                      (brightness-update)))
  (global-set-key [XF86MonBrightnessUp]           #'(lambda () (interactive)
                                                      (start-process-shell-command "backlightctrl" nil "backlightctrl -inc 1 -time 0")
                                                      (brightness-update)))
  (global-set-key [\S-XF86Display]                #'(lambda () (interactive)
                                                      (start-process-shell-command "mounter" nil "mounter")))
  (global-set-key [\S-XF86WLAN]                   #'(lambda () (interactive)
                                                      (start-process-shell-command "unmounter" nil "unmounter")))
  (global-set-key [XF86AudioLowerVolume]          #'(lambda () (interactive)
                                                      (start-process-shell-command "pactl" nil "pactl set-sink-volume @DEFAULT_SINK@ -1%")
                                                      (volume-update)))
  (global-set-key [\S-XF86AudioLowerVolume]       #'(lambda () (interactive)
                                                      (start-process-shell-command "pactl" nil "pactl set-sink-volume @DEFAULT_SINK@ -5%")
                                                      (volume-update)))
  (global-set-key [XF86AudioRaiseVolume]          #'(lambda () (interactive)
                                                      (start-process-shell-command "pactl" nil "pactl set-sink-volume @DEFAULT_SINK@ +1%")
                                                      (volume-update)))
  (global-set-key [\S-XF86AudioRaiseVolume]       #'(lambda () (interactive)
                                                      (start-process-shell-command "pactl" nil "pactl set-sink-volume @DEFAULT_SINK@ +5%")
                                                      (volume-update)))
  (global-set-key [XF86AudioMute]                 #'(lambda () (interactive)
                                                      (start-process-shell-command "pactl" nil "pactl set-sink-mute @DEFAULT_SINK@ toggle")
                                                      (volume-update)))
  (map! "e" :desc "emacs")
  (map! "ex" :desc "sleep" #'(lambda () (interactive) (start-process-shell-command "loginctl" nil "loginctl suspend")))
  (map! "ez" :desc "hibernate" #'(lambda () (interactive) (start-process-shell-command "loginctl" nil "loginctl hibernate")))
  (map! "epoweroff" :desc "poweroff" #'(lambda () (interactive) (start-process-shell-command "loginctl" nil "loginctl poweroff"))))

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
(setq epa-pinentry-mode 'loopback)
(setq epg-pinentry-mode 'loopback)

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

        ([?\s-s] . bkmrkput)
        ([?\C-\s-s] . bkmrkadd)
        ([?\M-\s-s] . bkmrkdel)

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
