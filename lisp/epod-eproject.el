(add-hook
 'perl-project-file-visit-hook
 (lambda ()
   (if (eproject-attribute :local-lib-exists-p)
       ; set local libs for this file
       (progn
         (make-local-variable 'epod-local-lib-dirs)
         (if (not (boundp 'epod-local-lib-dirs)) (setq epod-local-lib-dirs nil))
         (pushnew
          (format "%sperl5/" (eproject-root))
          epod-local-lib-dirs)
         ))))


