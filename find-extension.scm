
;; hack of the year!
;;
;; you can have shared libraries in your android projects (under
;; ./libs). but only the ones that start with "lib" get included
;; during packaging. that's great.
;;
;; so we have a "make libs" target which adds the "lib" prefix to all
;; shared libraries. this hack then changes the chicken runtime to
;; look for files with the "lib" prefix if the one without it doesn't
;; work.
;;
;; include this file in your main-scheme file before any
;; (require-library) or (use) forms!
;;
;; you can (use tcp) and other units, but without this patch, (use
;; eggs) won't find the extensions.

(define ##sys#find-extension
  (let ((old-##sys#find-extension ##sys#find-extension))
    (lambda (p inc?)
      (or (old-##sys#find-extension p inc?)
          (old-##sys#find-extension (string-append "lib" p) inc?)))))
