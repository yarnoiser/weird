(declare (unit user) (uses lowlevel-io highlevel-io))
(use (srfi 69) posix crypt)
(include "shared/macros.scm")

(define user-data-path "server/data/users/")

(define password-salt "$6$uDpnXOEWj3bQofeTVXB0I.")

(define file-perms (bitwise-ior perm/irusr perm/iwusr))

(define users (make-hash-table))

(define-record user password data)

(define (user-password-crypt password)
  (crypt password password-salt))

(foreign-declare "#include <unistd.h>")
(define unlink (foreign-lambda int "unlink" c-string))

(define (user-exists? name)
  (regular-file? (string-append user-data-path name ".scm")))

(define (user-save! name)
  (let* ([temp-path (string-append user-data-path name "tmp.scm")]
         [final-path (string-append user-data-path name ".scm")]
         [user (hash-table-ref users name)]
         [fd (file-open temp-path (+ open/creat open/rdwr) file-perms)]
         [writer (make-writer fd)])
    (writer-enqueue! writer (expr->string `(make-user ,(user-password user) ,(user-data user))))
    (writer-complete-write! writer)
    (file-close fd)
    (unlink final-path)
    (file-link temp-path final-path)
    (unlink temp-path)
    (void)))

(define (user-load! name)
  (let* ([fd (file-open (string-append user-data-path name ".scm") (+ open/rdonly))]
         [reader (make-reader fd sep-scheme-expr)])
    (hash-table-set! users name (eval (string->expr (reader-read-next-token! reader))))))

(define (user-password-match? user password)
  (string=? (user-password (hash-table-ref users user)) (user-password-crypt password)))

(define (user-get name)
  (hash-table-ref users name))

(define (user-unload! name)
  (hash-table-delete! users name))

(define (user-add! name password #!optional (data-init #f))
  (if (user-exists? name)
    (error "user exists")
    (begin (hash-table-set! users name (make-user (user-password-crypt password) data-init))
           (user-save! name)
           (user-unload! name))))

(define (user-delete! name)
  (if (not (user-exists? name))
    (error "user does not exist")
    (begin (if (hash-table-exists? users name)
             (hash-table-delete! users name))
           (unlink (string-append user-data-path name ".scm"))
           (void))))

(define (user-clean-directory!)
  (for-each unlink (glob (string-append user-data-path "*.tmp.scm"))))

