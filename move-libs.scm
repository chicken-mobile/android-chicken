;;; Helper util to move all eggs and unit libraries to an Android
;;; project's libs folder.

;; usage: ./move-libs <source-dir> <destination-dir>
;; e.g. ./move-libs jni/chicken/target/$(PACKAGE_NAME)/lib libs/armeabi/
(use files posix)

(define source-dir      (car  (command-line-arguments)))
(define destination-dir (cadr (command-line-arguments)))

(assert (directory? destination-dir))
(assert (directory? source-dir))

(for-each
 (lambda (fn)
   (let* ((source fn)
          (prefix (if (string=? "lib" (substring fn 0 3)) "" "lib"))
          (dest (make-pathname destination-dir
                               (string-append prefix (pathname-file fn))
                               (pathname-extension fn))))
     (if (file-exists? dest)
         (print "skipping existing file " dest)
         (begin (print "copying " dest)
                (file-copy source dest)))))
 (append (glob (make-pathname source-dir "/lib/*.so"))
         (let ((eggdir (make-pathname source-dir "/lib/chicken/7/")))
           (if (directory? eggdir)
               (glob (make-pathname eggdir "*.so"))
               '()))))
