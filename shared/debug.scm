(declare (unit debug))

(define (dbg expr #!optional (port (current-output-port)))
  (display expr port)
  (newline port)
  expr)

(define (dbg-print expr #!optional (port (current-output-port)))
  (display expr port)
  (newline port))

