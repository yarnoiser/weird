(declare (unit event) (uses debug))
;(use (srfi 19))
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

(define-record event-date nanosecond second minute hour day month year zone-offset)

;(define (event-date->date event-date)
;  (let ([date (current-date)])
;    (make-date (if (event-date-nanosecond event-date)
;                 (event-date-nanosecond event-date)
;                 (date-nanosecond date))
;               (if (event-date-second event-date)
;                 (event-date-second event-date)
;                 (date-second date))
;               (if (event-date-minute event-date)
;                 (event-date-minute event-date)
;                 (date-minute date))
;               (if (event-date-hour event-date)
;                 (event-date-hour event-date)
;                 (date-hour date))
;               (if (event-date-day event-date)
;                 (event-date-day event-date)
;                 (date-day date))
;               (if (event-date-month event-date)
;                 (event-date-month event-date)
;                 (date-month date))
;               (if (event-date-year event-date)
;                 (event-date-year event-date)
;                 (date-year date))
;               (if (event-date-zone-offset event-date)
;                 (event-date-zone-offset event-date)
;                 (date-zone-offset date)))))

;(define (date->event-date)
;  (make-event-date (date-nanosecond date)
;                   (date-second date)
;                   (date-minute date)
;                   (date-hour date)
;                   (date-day date)
;                   (date-month date)
;                   (date-year date)
;                   (date-zone-offset date)))


