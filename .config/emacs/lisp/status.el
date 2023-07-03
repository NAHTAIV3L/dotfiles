;;; package --- status.el
;;; Commentary:
;;; modes to display statuses in mode line.  requires pulseaudio and NetworkManager

;;; Code:

;; --------------------------------------------------------
;;                diplay brightness mode
;; --------------------------------------------------------

(defvar display-brightness-string nil
  "Volume displayed string.")

(defvar brightness-update-timer nil
  "Blah dont change.")

(defun brightness-update ()
  "Brightness update string."
  (setq display-brightness-string
	(concat "|  " (car (split-string (shell-command-to-string "getbright") "\n" t)) "%% |")))

(defun brightness-update-handler ()
  "Handler for brightness update."
  (brightness-update)
  (sit-for 0))

(define-minor-mode display-brightness-mode
  "Displays the volume and whether or not its muted."
  :global t :group 'display-brightness
  (if display-brightness-mode
      (progn
        (or (memq 'display-brightness-string global-mode-string)
            (add-to-list 'global-mode-string 'display-brightness-string t))
        (setq brightness-update-timer (run-at-time nil 1 #'brightness-update-handler))
        (brightness-update))
    (setq global-mode-string (delq 'display-brightness-string global-mode-string))
    (setq brightness-update-timer nil)))

;; --------------------------------------------------------
;;                   diplay volume mode
;; --------------------------------------------------------

(defvar display-volume-string nil
  "Volume displayed string.")

(defvar volume-update-timer nil
  "Blah dont change.")

(defun volume-update ()
  "Update volume string."
  (setq display-volume-string
	(concat
	 (if (string= " muted" (car (split-string(shell-command-to-string "getmuted") "\n" t)))
	   "|  "
	   "|  ")
	 (car (split-string (shell-command-to-string "getvolume") "\n" t))
	 "%%"
	 "  |")))

(defun volume-update-handler ()
  "Handler for volume update."
  (volume-update)
  (sit-for 0))

(define-minor-mode display-volume-mode
  "Displays the volume and whether or not its muted."
  :global t :group 'display-volume
  (if display-volume-mode
      (progn
        (or (memq 'display-volume-string global-mode-string)
            (add-to-list 'global-mode-string 'display-volume-string t))
        (setq volume-update-timer (run-at-time nil 1 #'volume-update-handler))
        (volume-update))
    (setq global-mode-string (delq 'display-volume-string global-mode-string))
    (setq volume-update-timer nil)))

;; --------------------------------------------------------
;;                   diplay wifi mode
;; --------------------------------------------------------

(defvar display-wifi-string nil
  "Volume displayed string.")

(defvar wifi-update-timer nil
  "Blah dont change.")

(defun wifi-update ()
  "Update wifi string."
  (let ((essid
	 (car
	  (split-string
	   (or
	    (car
	    (split-string
	     (shell-command-to-string "nmcli -t -f name,device connection show --active | grep -v lo:lo")
	     "\n" t))
	    "")
	   ":" t)))
        (connection
	 (car
	  (split-string
	   (shell-command-to-string "awk 'NR==3 {print $3}' /proc/net/wireless | cut -d. -f1")
	   "\n" t))))
    (if (equal essid nil)
      (setq display-wifi-string "|  NO SIGNAL |")
      (setq display-wifi-string (concat (format "|  %s %s" essid connection) "%% |")))))

(defun wifi-update-handler ()
  "Handler for wifi update."
  (wifi-update)
  (sit-for 0))

(define-minor-mode display-wifi-mode
  "Displays the volume and whether or not its muted."
  :global t :group 'display-wifi
  (if display-wifi-mode
      (progn
        (or (memq 'display-wifi-string global-mode-string)
            (add-to-list 'global-mode-string 'display-wifi-string t))
        (setq wifi-update-timer (run-at-time nil 1 #'wifi-update-handler))
        (wifi-update))
    (setq global-mode-string (delq 'display-wifi-string global-mode-string))
    (setq wifi-update-timer nil)))

(provide 'status)
;;; status.el ends here
