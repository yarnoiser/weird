(declare (unit highlevel-io) (uses lowlevel-io coroutine debug))
(use (srfi 1 69) posix)
(include "shared/macros.scm")

(define-record chatter state reader writer err-writer evaluator proc)

(define (make-chatter-proc chat)
  (make-coroutine (lambda ()
                   (let loop ()
                      (case (chatter-state chat)
                        [(read)
                         (cond
                           [(reader-eof (chatter-reader chat))
                            (chatter-state-set! chat 'stopped)]
                           [(reader-has-token? (chatter-reader chat))
                            (chatter-state-set! chat 'eval)]
                           [(reader-ready? (chatter-reader chat))
                            (reader-read! (chatter-reader chat))
                            (cond
                              [(reader-has-token? (chatter-reader chat))
                               (chatter-state-set! chat 'eval)]
                              [(reader-eof (chatter-reader chat))
                               (chatter-state-set! chat 'stopped)])]
                           [else
                            (void)])]
                        [(eval)
                         (receive (out err) ((chatter-evaluator chat) (reader-get-token! (chatter-reader chat)))
                             (writer-enqueue! (chatter-err-writer chat) err)
                             (writer-enqueue! (chatter-writer chat) out)
                           (cond
                             [(eqv? (chatter-state chat) 'stopped)
                              (void)]
                             [(not (writer-finished? (chatter-err-writer chat)))
                              (chatter-state-set! chat 'print-err)]
                             [(not (writer-finished? (chatter-writer chat)))
                              (chatter-state-set! chat 'print)]
                             [else
                              (chatter-state-set! chat 'read)]))]
                        [(print-err)
                          (cond
                            [(writer-finished? (chatter-err-writer chat))
                             (cond
                               [(not (writer-finished? (chatter-writer chat)))
                                (chatter-state-set! chat 'print)]
                               [(reader-has-token? (chatter-reader chat))
                                (chatter-state-set! chat 'eval)]
                               [else 
                                (chatter-state-set! chat 'read)])]
                            [(writer-ready? (chatter-err-writer chat))
                             (writer-write! (chatter-err-writer chat))]
                            [else
                             (void)])]
                        [(print)
                         (cond
                            [(writer-finished? (chatter-writer chat))
                             (if (and (reader-has-token? (chatter-reader chat))
                                      (not (reader-eof (chatter-reader chat))))
                               (chatter-state-set! chat 'eval)
                               (chatter-state-set! chat 'read))]
                            [(writer-ready? (chatter-writer chat))
                             (writer-write! (chatter-writer chat))]
                            [else
                             (void)])]
                        [(stopped)
                         (void)]
                        [else
                          (error "invalid chatter state")])
                      (yield!)
                      (loop)))))

(define new-chatter make-chatter)

(define (init-chatter-record in-fd out-fd err-fd sep-proc evaluator)
  (new-chatter 'read (make-reader in-fd sep-proc) (make-writer out-fd) (make-writer err-fd) evaluator #f))

(define (make-chatter in-fd out-fd err-fd sep-proc evaluator)
  (let ([chat (init-chatter-record in-fd out-fd err-fd sep-proc evaluator)])
    (chatter-proc-set! chat (make-chatter-proc chat))
    chat))

(define (chatter-chat! chat)
  ((chatter-proc chat)))

(define (chatter-select! chats #!optional (timeout #f))
  (let ([hash (make-hash-table)]
        [read-fds '()]
        [write-fds '()]
        [eval-chats '()])
    (for-each
      (lambda (chat)
        (case (chatter-state chat)
          [(eval) (set! eval-chats (cons chat eval-chats))]
          [(read) (begin (hash-table-set! hash (reader-fd (chatter-reader chat)) chat)
                         (set! read-fds (cons (reader-fd (chatter-reader chat)) read-fds)))]
          [(print) (begin (hash-table-set! hash (writer-fd (chatter-writer chat)) chat)
                          (set! write-fds (cons (writer-fd (chatter-writer chat)) write-fds)))]
          [(print-err) (begin (hash-table-set! hash (writer-fd (chatter-err-writer chat)) chat)
                              (set! write-fds (cons (writer-fd (chatter-err-writer chat)) write-fds)))]))
       chats)
    (if (null? eval-chats)
      (receive (readable writable) (file-select read-fds write-fds timeout)
        (map (lambda (fd)
               (hash-table-ref hash fd))
             (append readable writable)))
      eval-chats)))

(define (chatter-stop! chat)
  (chatter-state-set! chat 'stopped)
  (file-close (reader-fd (chatter-reader chat)))
  (file-close (writer-fd (chatter-err-writer chat)))
  (file-close (writer-fd (chatter-writer chat))))

(define (chatter-force! chat command)
  (reader-tokens-set! (chatter-reader chat) (append (reader-tokens (chatter-reader chat)) (list command)))
  (chatter-state-set! chat 'eval))

(define (chatter-message! chat message)
  (chatter-force! chat (string-append "\"Message: " message "\"")))

(define (reader-read-next-token! reader)
  (let loop ()
    (cond
      [(reader-has-token? reader)
       (reader-get-token! reader)]
      [(reader-ready? reader)
       (begin (reader-read! reader)
              (if (in-coroutine?) (yield! #f))
              (loop))]
      [else
       (begin (if yield (yield! #f))
              (loop))])))

(define (writer-complete-write! writer)
  (let loop ()
    (cond
      [(writer-finished? writer)
       #t]
      [(writer-ready? writer)
       (begin (writer-write! writer)
              (if (in-coroutine?) (yield! #f))
              (loop))])))

