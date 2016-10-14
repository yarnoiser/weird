(declare (unit init) (uses debug terminal))
(use posix)
(include "shared/macros.scm")

(define crypt-warning
"WARNING: This software does not have any built in encryption. It should always
be used with a properly configured ssl/tls proxy for non testing purposes.")

(define config-path "server/data/config.scm")
(define port 2000)
(define select-timeout #f)

(define (init-args!)
  (if (regular-file? config-path)
    (load config-path))

  (let loop ([args (command-line-arguments)])
    (cond
      [(null? args)
       (void)]
      [(or (string=? (car args) "-c") (string=? (car args) "--config-file"))
       (if (null? (cdr args))
         (error "missing config file in program arguments"))
       (set! config-path (cadr args))
       (if (not (regular-file? config-path))
         (error "no config file at specified location"))
       (load config-path)]
      [(or (string=? (car args) "-p") (string=? (car args) "--port"))
       (if (null? (cdr args))
         (error "missing port number in arg string"))
       (set! port (string->number (cadr args)))]
      [(or (string=? (car args) "-s") (string=? (car args) "--select-timeout"))
       (if (null? (cdr args))
         (error "missing select timeout in arg string"))
       (set! select-timeout (string->number (cadr args)))])

    (if (not (null? args))
      (loop (cdr args)))))

(define (init!)
  ; if this is the first startup...
  (when (not (regular-file? "server/data/users/admin.scm"))
    (print crypt-warning)
    (newline)
    (let loop ()
      (display "Enter admin password: ")
      (echo-off! fileno/stdin)
      (let ([password1 (read-line)])
        (newline)
        (display "Re-enter password: ")
        (let ([password2 (read-line)])
          (echo-on! fileno/stdin)
          (newline)
          (if (string=? password1 password2)
            (user-add! "admin" password1)
            (begin (print "Passwords do not match...")
                   (loop))))))
    (print "admin account created")
    (print "starting server..."))
  (init-args!))

