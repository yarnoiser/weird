(declare (uses client lowlevel-io highlevel-io remote user event debug init terminal))
(use (srfi 1) posix tcp)
(include "shared/macros.scm")

(define (login!)
  (let ([reader (make-reader fileno/stdin sep-line)]
        [writer (make-writer fileno/stdout)])
    (writer-enqueue! writer "Enter username: ")
    (writer-complete-write! writer)
    (let ([username (reader-read-next-token! reader)])
      (writer-enqueue! writer "Enter password: ")
      (writer-complete-write! writer)
      (echo-off! fileno/stdin)
      (let ([password (reader-read-next-token! reader)])
        (echo-on! fileno/stdin)
        (writer-enqueue! writer "\n")
        (writer-complete-write! writer)
        (remote-login! username password)))))

(define (remote-login! username password)
  (user-load! username)
  (if (user-password-match? username password)
    (begin (client-username-set! current-client username)
           (hash-table-set! client-name-table username current-client)
           #t)
    (begin (user-unload! username)
           (error "invalid password"))))

(init!)

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

(define listener (tcp-listen port))
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

