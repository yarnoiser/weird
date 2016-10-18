; -----------------------------------------------------------------------------
; cooperative.import.scm
;
; Coroutines and Finite State Machines
; -----------------------------------------------------------------------------
(declare (unit coroutine))
  ; continuation stack
(define conts '())

; value returned by a yield
(define ret-val (void))

; flag used to determine if a continuation returned due to a yield
(define yield-occured #f)

(define (cont-push! c)
  (set! conts (cons c conts)))

(define (cont-pop!)
  (let ([c (car conts)])
    (set! conts (cdr conts))
    c))

(define (in-coroutine?)
  (not (null? conts)))

(define (make-coroutine proc . args)
  (let ([cont (lambda (return)
                (cont-push! return)
                (let ([res (apply proc args)])
                  ((cont-pop!) res)))]
        [finished #f])
    (lambda ()
      (if finished
        (error "coroutine has finished"))
      (set! cont (call/cc cont))
      (if yield-occured
        (begin (set! yield-occured #f)
               ret-val)
        (begin (set! finished #t)
               cont)))))

(define (yield! #!optional [val (void)])
  (if (not (in-coroutine?))
    (error "not within coroutine"))
  (set! ret-val val)
  (set! yield-occured #t)
  (cont-push! (call/cc (cont-pop!))))

