;;; Quick helper that tries to detect an android project's platform.
;;; project.properties file should be located at the project root,
;;; containing eg. "target=android-10". Using simple regex for search.
(use irregex)

(print (irregex-match-substring
        (irregex-search "\ntarget=([^\n]*)\n"
                        (with-input-from-file (car (command-line-arguments))
                          read-string))
        1))
