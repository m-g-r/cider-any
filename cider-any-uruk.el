;;; init.el --- Evaluate XQuery with uruk in the cider  -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

(require 'cl-lib)
(require 'cider-any)

(defgroup cider-any-uruk nil
  "Evaluate XQuery documents in the cider repl."
  :group 'cider-any)

(defcustom cider-any-uruk-uri nil
  "Uri uruk/create-session argument."
  :type 'string
  :group 'cider-any-uruk)

(defcustom cider-any-uruk-user nil
  "User uruk/create-session argument."
  :type 'string
  :group 'cider-any-uruk)

(defcustom cider-any-uruk-password nil
  "Password uruk/create-session argument."
  :type 'string
  :group 'cider-any-uruk)

(defcustom cider-any-uruk-content-base nil
  "Content base uruk/create-session argument."
  :type 'string
  :group 'cider-any-uruk)

(defun cider-any-uruk-plist-to-map (&rest plist)
  "Convert Elisp PLIST into Clojure map."
  (concat "{"
          (mapconcat #'(lambda (element)
                         (cl-case (type-of element)
                           (string (concat "\"" element "\""))
                           (symbol (symbol-name element)))) 
                     plist
                     " ")
          "}"))

(defun cider-any-uruk (command &rest args)
  "Eval XQuery in Cider."
  (cl-case command
    (check (eq major-mode 'xquery-mode))
    (init "(require '[uruk.core :as uruk])")
    (eval (format "(let [db %s]
                     (with-open [session (uruk/create-session db)]
                       (uruk/execute-xquery session \"%%s\")))"
                  (cider-any-uruk-plist-to-map
                   :uri cider-any-uruk-uri
                   :user cider-any-uruk-user
                   :password cider-any-uruk-password
                   :content-base cider-any-uruk-content-base)))
    (handle (message ">>> %s <<<" args))
    (handle-init (message ">>> %s <<<" args))))

(add-to-list 'cider-any-backends 'cider-any-uruk)

(provide 'cider-any-uruk)

;;; cider-any-uruk.el ends here
