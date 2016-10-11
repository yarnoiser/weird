(declare (unit init) (uses debug))
(use posix)
(include "shared/macros.scm")

(define config-path "server/data/config.scm")
(define port 2000)
(define select-timeout #f)
(define crypt-warning
"WARNING: This software does not have any built in encryption. It should always
be used with a properly configured ssl/tls proxy for non testing purposes.")

(define (init-args!)
  (if (regular-file? config-path)
    (load config-path))

  (let loop ([args (command-line-arguments)])
    (cond
      [(null? args)
       (void)]
      [(or (string=? (car args) "-c") (string=? (car args) "--config-file"))
       (if (null? (cdr args))
         (error "missing config file in arg string"))
       (if (not (regular-file? config-path))
         (error "no config file at specified location"))
       (set! config-path (cadr args))
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
    (display "Enter admin password: ")
    (let ([password (read-line)])
      (user-add! "admin" password))
    (print "admin account created")
    (print "starting server...")
  (init-args!)))


