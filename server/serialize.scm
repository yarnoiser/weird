(declare (unit serializer))
(use (srfi 69))

(define-record serializer pred proc)

(define serializers '())

(define (string->expr str)
  (read (open-input-string str)))

(define (expr->string expr)
  (let ([port (open-output-string)])
    (write expr port)
    (get-output-string port)))

(define (serializer-add! pred proc)
  (set! serializers (cons (make-serializer pred proc) serializers)))

(define (serialize expr)
  (let loop ([sers serializers])
    (cond
      [(null? sers)
       (expr->string (list 'quote expr))]
      [((serializer-pred (car sers)) expr)
       (expr->string ((serializer-proc (car sers)) expr))]
      [else
       (loop (cdr sers))])))

(serializer-add! hash-table? (lambda (table)
                               `(alist->hash-table ,(hash-table->alist table))))


