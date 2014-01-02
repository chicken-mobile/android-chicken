;;; Helper program that tries to detect an android project's
;;; package-name.
;;; TODO: exit with error-code if something goes wrong?
(use ssax sxpath)

(print (cadar
        ((sxpath "//manifest/@package")
         (ssax:xml->sxml (open-input-file (car (command-line-arguments)))
                         '()))))

