(define-syntax debug (syntax-rules ()
  [(debug expr port)
   (cond-expand
     [debug
      (dbg expr port)]
     [else
      expr] ) ]
  [(debug expr)
   (cond-expand
     [debug
      (dbg expr)]
     [else expr
      expr] ) ] ) )

(define-syntax debug-print (syntax-rules ()
  [(debug-print expr port)
   (cond-expand
    [debug
     (dbg-print expr port)]
    [else
    ])]
  [(debug-print expr)
   (cond-expand
  [debug
     (dbg-print expr)]
   [else
   ])] ))

(define-syntax list-push! (syntax-rules ()
  [(_ lst elem)
   (set! lst (cons elem lst))]))

(define-syntax list-push-back! (syntax-rules ()
  [(_ lst elem)
   (set! lst (append lst (list elem)))]))

(define-syntax list-pop! (syntax-rules ()
  [(_ lst)
   (let ([elem (car lst)])
    (set! lst (cdr lst))
    elem)]))
