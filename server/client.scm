(declare (unit client) (uses highlevel-io debug))
(use (srfi 1 69) tcp posix)
(include "shared/macros.scm")

(define select-timeout 1)

(define client-name-table (make-hash-table))
(define client-fd-table (make-hash-table))

(define current-client #f)

(define-record client username chat)

(define client-read-fds '())
(define client-selected-read-fds '())
(define client-write-fds '())
(define client-selected-write-fds '())
(define clients-in-eval-state '())

;(define (debug-lists)
;  (display "client-read-fds: ") (display client-read-fds) (newline)
;  (display "client-selected-read-fds: ") (display client-selected-read-fds) (newline)
;  (display "client-write-fds: ") (display client-write-fds) (newline)
;  (display "client-selected-write-fds: ") (display client-selected-write-fds) (newline)
;  (display "clients-in-eval-state: ") (display clients-in-eval-state) (newline)
;  (newline))

(define (fd-client fd)
  (hash-table-ref client-fd-table fd))

(define (client-find name)
  (hash-table-ref client-name-table name))

(define (client-read-fd client)
  (reader-fd (chatter-reader (client-chat client))))

(define (client-write-fd client)
  (writer-fd (chatter-writer (client-chat client))))

(define (client-err-fd client)
  (writer-fd (chatter-err-writer (client-chat client))))

(define (client-delete-fd fd)
  (if (hash-table-exists? client-fd-table fd)
    (hash-table-delete! client-fd-table fd)))

(define (client-delete-name name)
  (if (hash-table-exists? client-name-table name)
    (hash-table-delete! client-name-table name)))

(define (stdio-client? client)
  (= (client-read-fd client) fileno/stdin))

(define (client-add! client)
  (if (tcp-listener? client)
    (hash-table-set! client-fd-table (tcp-listener-fileno client) client)
    (begin (hash-table-set! client-fd-table (client-read-fd client) client)
           (hash-table-set! client-fd-table (client-write-fd client) client)
           (hash-table-set! client-fd-table (client-err-fd client) client)))
  (client-push! client))

(define (client-drop! client)
  (file-close (client-read-fd client))
  (if (not (= (client-read-fd client) (client-write-fd client)))
    (file-close (client-write-fd client)))
  (if (not (= (client-write-fd client) (client-err-fd client)))
    (file-close (client-err-fd client)))
  (client-delete-fd (client-read-fd client))
  (client-delete-fd (client-write-fd client))
  (client-delete-fd (client-err-fd client))
  (client-delete-name (client-username client)))

(define (client-push! client)
  (if (tcp-listener? client)
    (list-push! client-read-fds (tcp-listener-fileno client))
    (case (chatter-state (client-chat client))
      [(read)
       (list-push! client-read-fds (client-read-fd client))]
      [(print)
       (list-push! client-write-fds (client-write-fd client))]
      [(print-err)
       (list-push! client-write-fds (client-err-fd client))]
      [(eval)
       (list-push! clients-in-eval-state client)]
      [(stopped)
       (if (stdio-client? client)
         (begin (chatter-state-set! (client-chat client) 'read)
                (reader-eof-set! (chatter-reader (client-chat client)) #f)
                (client-push! client))
         (client-drop! client))]
      [else
       (error (string-append "invalid chatter state: " (symbol->string (chatter-state (client-chat current-client)))))])))

(define (client-select-next-pop?)
  (and (null? clients-in-eval-state)
       (null? client-selected-read-fds)
       (null? client-selected-write-fds)))

(define (client-pop!)
  ;(debug-lists)
  (cond
    [(not (null? clients-in-eval-state))
     (list-pop! clients-in-eval-state)]
    [(not (null? client-selected-read-fds))
     (fd-client (list-pop! client-selected-read-fds))]
    [(not (null? client-selected-write-fds))
     (fd-client (list-pop! client-selected-write-fds))]
    [else
     (receive (r w) (file-select client-read-fds client-write-fds select-timeout)
       (let ([rlist (if r r '())] [wlist (if w w '())])
         (set! client-selected-read-fds rlist)
         (set! client-selected-write-fds wlist)
         (set! client-read-fds (lset-difference = client-read-fds rlist))
         (set! client-write-fds (lset-difference = client-write-fds wlist))
         #f))]))

