(declare (unit event) (uses debug))
(include "shared/macros.scm")

(define-record event pred thunk repeat)

(define events '())

(define (event-add! pred thunk repeat)
  (set! events (cons (make-event pred thunk repeat) events)))

(define (event-repeat? event)
  (or (eqv? (event-repeat event) #t)
      (> (event-repeat event) 0)))

(define (event-ready? event)
  ((event-pred event)))

(define (event-run! event)
  (if (number? (event-repeat event))
    (event-repeat-set! event (sub1 (event-repeat event)))
  ((event-thunk event))))

(define (events-process!)
  (let loop ([processed '()] [pending events])
    (cond
      [(null? pending)
       (set! events processed)]
      [(event-ready? (car pending))
       (event-run! (car pending))
         (if (event-repeat? (car pending))
           (loop (cons (car pending) processed) (cdr pending))
           (loop processed (cdr pending)))]
      [else
       (loop (cons (car pending) processed) (cdr pending))])))

(define (seconds->milliseconds time)
  (* time 1000))

(define (interval time)
  (let* ([last-reaction (current-milliseconds)]
        [next-reaction (+ last-reaction (seconds->milliseconds time))])
    (lambda ()
      (let ([new-time (current-milliseconds)])
        (if (>= new-time next-reaction)
          (begin (set! last-reaction next-reaction)
                 (set! next-reaction (+ next-reaction time))
                 #t)
          #f)))))




