(declare (unit remote) (uses user serializer debug))
(use (srfi 1 69) data-structures simple-exceptions)
(include "shared/macros.scm")

(define exposed (make-hash-table))

(define aliases (make-hash-table))

(define (to-string x)
  (let ([port (open-output-string)])
    (display x port)
    (get-output-string port)))

(define (expose! symbol #!optional (users 'all))
  (let ([new-users (if (list? users) users (list users))])
    (if (hash-table-exists? exposed symbol)
      (let ([current-users (hash-table-ref exposed symbol)])
        (hash-table-set! exposed symbol (delete-duplicates (append current-users new-users))))
      (hash-table-set! exposed symbol (delete-duplicates new-users)))))

(define (unexpose! symbol #!optional (users #f))
  (if (not (hash-table-exists? exposed symbol))
    (error "symbol does not exist"))
  (let* ([removed-users (if (list? users) users (list users))]
         [current-users (hash-table-ref exposed symbol)]
         [new-users (remove (lambda (u)
                              (member u removed-users))
                            current-users)])
    (if (null? new-users)
      (hash-table-delete! exposed symbol)
      (hash-table-set! exposed symbol new-users))))

(define (alias! al com)
  (hash-table-set! aliases al com))

(define (unalias! al)
  (hash-table-delete! aliases al))

(define (edit-output str)
  (if (string=? str "#<unspecified>")
    ""
    (string-append str "\n")))

(define (handler e)
  (values ""
          (string-append "error: "
                         (message e)
                         (if (not (null? (arguments e)))
                           (string-append ": "
                                          (string-intersperse (map to-string (arguments e))))
                           "")
                         (if (location e)
                            (string-append " in "
                                         (to-string (location e)))
                           "")
                          "\n")))


(define (command-access? name command)
  (if (not (hash-table-exists? exposed command))
    #f
    (let ([command-access (hash-table-ref exposed command)])
      (cond
        [(memv 'anon command-access)
         #t]
        [(and (not (eqv? name #f)) (memv 'all command-access))
         #t]
        [(member name command-access)
         #t]
        [else
         #f]))))


; Adapted from Dan D's answer at
; http://stackoverflow.com/questions/33338078/flattening-a-list-in-scheme
(define (flatten-input expr)
  (let loop ([ex (list expr)] [acc '()] [stack '()])
    (cond
      [(null? ex)
       (if (null? stack)
         (reverse acc)
         (loop (car stack) acc (cdr stack)))]
      [(and (pair? (car ex)) (not (list? (car ex))))
       (loop (cdr ex) (cons (cdar ex) (cons (caar ex) acc)) stack)]
      [(and (list? (car ex)) (eqv? (caar ex) 'quote))
       (loop (cdr ex) (cons (car ex) acc) stack)]
      [(list? (car ex))
       (loop (car ex) acc (if (null? (cdr ex))
                            stack
                            (cons (cdr ex) stack)))]
      [else
        (loop (cdr ex) (cons (car ex) acc) stack)])))

(define (remote-command str)
  (let* ([expr (with-exn-handler handler (lambda () (string->expr str)))])
    (with-exn-handler handler (lambda ()
      (for-each (lambda (elem)
                  (if (symbol? elem)
                    (if (not (command-access? (client-username current-client) elem))
                      (error (string-append "could not access symbol: " (symbol->string elem))))))
                (flatten-input expr))
      (values (edit-output (expr->string (eval expr)))
              "")))))

