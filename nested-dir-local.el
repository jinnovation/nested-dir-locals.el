(defun nested-dir-local--all-parent-dirs (&optional dir)
  (require 'esh-util)
  (let* ((base (or dir default-directory))
         (parent-dir-cmps (eshell-split-path base)))
    (mapcar (lambda (depth)
              (apply 'concat (subseq parent-dir-cmps 0 depth)))
            (number-sequence 1 (length parent-dir-cmps)))))

(defun nested-dir-local--parent-dir-locals (&optional dir)
  (let* ((base (or default-directory default-directory))
         (parent-dirs (nested-dir-local--all-parent-dirs base))
         (parent-dir-locals (seq-filter 'file-exists-p (mapcar
                             (lambda (d) (concat d ".dir-locals.el")) parent-dirs))))
    parent-dir-locals))

(advice-add 'hack-dir-local-variables
            :around
            (lambda (fn &rest args)
              (dolist (file (nested-dir-local--parent-dir-locals))
                (let ((dir-locals-file (expand-file-name file)))
                  (apply fn args))))
            '((name . nested-dir-locals)))

(provide 'nested-dir-local)
