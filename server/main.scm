(declare (uses client highlevel-io remote user event debug))
(use (srfi 1) posix tcp)
(include "shared/macros.scm")

(define port-number 2000)

(define (login! username password)
  (user-load! username)
  (if (user-password-match? username password)
    (begin (client-username-set! current-client username)
           (hash-table-set! client-name-table username current-client)
           #t)
    (begin (user-unload! username)
           (error "invalid password"))))

(expose! '+ 'anon)
(expose! '- "robert")
(expose! '*)
(expose! '/)
(expose! 'user-add! 'anon)
(expose! 'user-save!)
(expose! 'user-load!)
(expose! 'login! 'anon)
(expose! 'client-find 'anon)

(user-clean-directory!)

(define listener (tcp-listen port-number))
(client-add! listener)

(client-add! (make-client #f (make-chatter fileno/stdin
                                           fileno/stdout
                                           fileno/stderr
                                           sep-scheme-expr
                                           remote-command)))

(let main-loop ()
  (set! current-client (client-pop!))
  (cond
    [(eqv? current-client #f)
     (events-process!)]
    [(tcp-listener? current-client)
     (if (tcp-accept-ready? current-client)
      (receive (from to) (tcp-accept current-client)
        (client-add! (make-client #f (make-chatter (port->fileno from)
                                                   (port->fileno to)
                                                   (port->fileno to)
                                                   sep-scheme-expr
                                                   remote-command)))))]
    [else
     (chatter-chat! (client-chat current-client))])
  (if (not (eqv? current-client #f))
    (client-push! current-client))
  (set! current-client #f)
  (main-loop))

