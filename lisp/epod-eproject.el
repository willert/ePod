(defun epod/add-eproject-local-lib ()
  (if (eproject-attribute :local-lib-exists-p)
                                        ; set local libs for this file
      (progn
        (make-local-variable 'epod-local-lib-dirs)
        (if (not (boundp 'epod-local-lib-dirs)) (setq epod-local-lib-dirs nil))
        (pushnew
         (format "%sperl5/perl-5.14.2/" (eproject-root))
         epod-local-lib-dirs)
        ))
  )

(add-hook
 'perl-project-file-visit-hook
 'epod/add-eproject-local-lib)


