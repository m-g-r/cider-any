;;; cider-any.el --- Evaluate any buffer in cider.

;; Copyright (C) 2016 by Artem Malyshev

;; Author: Artem Malyshev <proofit404@gmail.com>
;; URL: https://github.com/xquery-mode/cider-any
;; Version: 0.0.1
;; Package-Requires: ((cider "0.13.0"))

;;; Commentary:

;;; Code:

(require 'cider)

(defgroup cider-any nil
  "Evaluate any buffer in cider."
  :group 'cider)

(defcustom cider-any-backends nil
  "The list of active backends.

Only one backend is used at a time.  Each backend is a function
that takes a variable number of arguments.  The first argument is
the command requested from the backend.  It is one of the
following:

`check': The backend should return t in the case it can eval in
current context.  Returning nil from this command passe control
to the next backend.

`eval' Request to perform evaluation of current context.  The
second argument is the context type passed as a symbol.
`buffer', `function', `line' and `region' are default context
types."
  :type '(repeat :tag "User defined" (function)))

(defvar cider-any-initiated-backends nil)

(defvar cider-any-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c C-c") 'cider-any-buffer)
    (define-key map (kbd "C-M-x") 'cider-any-function)
    (define-key map (kbd "C-c C-l") 'cider-any-line)
    (define-key map (kbd "C-c C-r") 'cider-any-region)
    map)
  "Keymap for `cider-any-mode'.")

(defun cider-any-buffer ()
  "Eval current buffer in cider."
  (interactive)
  (cider-any-eval 'buffer))

(defun cider-any-function ()
  "Eval current function in cider."
  (interactive)
  (cider-any-eval 'function))

(defun cider-any-line ()
  "Eval current line in cider."
  (interactive)
  (cider-any-eval 'line))

(defun cider-any-region ()
  "Eval current region in cider."
  (interactive)
  (cider-any-eval 'region))

(defun cider-any-eval (context)
  "Try to evaluate current CONTEXT."
  (let ((backends cider-any-backends)
        backend found)
    (while (and (not found) backends)
      (setq backend (car-safe backends)
            backends (cdr-safe backends))
      (when (apply backend '(check))
        (setq found t)))
    (if (not backend)
        (error "Can not evaluate current %s" context)
      (unless (memq backend cider-any-initiated-backends)
	(let ((expr (apply backend '(init))))
	  (push backend cider-any-initiated-backends)))
      (apply backend '(eval context)))))

;;;###autoload
(define-minor-mode cider-any-mode
  "Evaluate any buffer in the cider.

\\{cider-any-mode-map}"
  :lighter " Cider-Any"
  :keymap cider-any-mode-map)

(provide 'cider-any)

;;; cider-any.el ends here
