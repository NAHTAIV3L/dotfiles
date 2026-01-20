(defvar proj-locations
  '("~/dev" "~/latex" "~/rpi")
  "Value for where to look for projects")

(defvar proj-find-params
  '("-mindepth 2" "-maxdepth 2" "-path '*/.git'" "-prune -o" "-type d" "-print")
  "parameters to run find with")

(defvar proj-current nil
  "Current project root")

(defvar proj-grep-function #'grep
  "What function to run for proj-grep")

(defvar proj-compile-commands '()
  "Current project root")

(defmacro proj--clean-path (path) `(string-replace (getenv "HOME") "~" ,path))

(defun proj--get-buffer-path (buffer)
  (or (with-current-buffer buffer dired-directory) (buffer-file-name buffer)))

(defun proj--get-paths ()
  (delete proj-current
   (flatten-list (mapcar
     (lambda (p)
       (mapcar (lambda (str) (proj--clean-path (concat str "/")))
        (split-string (shell-command-to-string
          (concat "find " p " " (mapconcat (lambda (param) (concat param " ")) proj-find-params)))
         "\n" t)))
            proj-locations))))

(defun proj-goto-dir (dir)
  (interactive "D")
  (setq proj-current (file-truename (concat dir "/"))))

(defun proj-swap (&optional dir quiet)
  (interactive)
  (if dir
      (proj-goto-dir dir)
    (let* ((completion-extra-properties '(:category file))
           (choice
            (completing-read
             (concat "Switch to project"
                     (when proj-current
                       (concat " (" (proj--clean-path proj-current) ")"))
                     ": ")
             (append (proj--get-paths) '("Some other directory"))
             nil t nil nil proj-current)))
      (if (equal choice "Some other directory")
          (call-interactively 'proj-goto-dir)
        (proj-goto-dir choice))))
  (unless quiet (dired proj-current)))

(defun proj-find-file (&optional filename)
  (interactive)
  (unless proj-current (proj-swap nil t))
  (when filename (find-file filename))
  (let ((completion-extra-properties '(:category file))
        (default-directory proj-current))
    (find-file
     (completing-read
      (concat "Find file in " (proj--clean-path proj-current) ": ")
      (mapcar (lambda (str) (string-replace proj-current "" str))
              (split-string (shell-command-to-string
                             (concat "find " proj-current " -path '*/.git' -prune -o -type f -print"))
                            "\n" t))))))

(defun proj-switch-to-buffer (&optional buffer-or-name)
  (interactive)
  (switch-to-buffer
   (or buffer-or-name
       (let* ((other-buffer (other-buffer (current-buffer)))
              (other-name (buffer-name other-buffer))
              (pred (lambda (b)
                      (let ((path (proj--get-buffer-path (cdr b))))
                        (when path (file-in-directory-p (file-truename path) proj-current))))))
         (read-buffer
          (concat "Switch to buffer in " (proj--clean-path proj-current) ": ")
          (when (funcall pred (cons other-name other-buffer))
            other-name)
          nil pred)))))

(defun proj-dired ()
  (interactive)
  (if proj-current
      (dired proj-current)
    (proj-swap)))

(defun proj-grep ()
  (interactive)
  (unless proj-current (proj-swap))
  (let ((default-directory proj-current))
    (when proj-grep-function (call-interactively proj-grep-function))))

(defun proj-compile ()
  (interactive)
  (let* ((found (seq-find (lambda (f) (equal (car f) proj-current)) proj-compile-commands))
         (command (cdr (or found '("default" . "make -k"))))
         (compilation-buffer-name-function
          (lambda (f)
            (concat "*" (file-name-nondirectory (directory-file-name proj-current)) ": compilation*"))))
    (setq compile-command command)
    (call-interactively 'compile)
    (unless (equal compile-command command)
      (if found
          (setq proj-compile-commands
                (mapcar
                 (lambda (d) (if (equal (car d) proj-current) (cons proj-current compile-command) d))
                 proj-compile-commands))
        (add-to-list 'proj-compile-commands (cons proj-current compile-command))))))

(defvar proj-prefix-map
  (let ((map (make-sparse-keymap)))
    (define-key map "f" 'proj-find-file)
    (define-key map "b" 'proj-switch-to-buffer)
    (define-key map "p" 'proj-swap)
    (define-key map "d" 'proj-dired)
    (define-key map "c" 'proj-compile)
    (define-key map "g" 'proj-grep)
    map))

(define-key ctl-x-map "p" proj-prefix-map)

(provide 'proj)
