(use coops coops-primitive-objects (srfi 69))

(define rooms (make-hash-table))

(define objects (make-hash-table))

(define-class <object> ()
   (id initform: (next-object-id))
   (name initform: "")
   (description initform: "")
   (location initform: #f)])

(define-class <room> ()
  ([name initform: #f]
   [description initform: #f]
   [objects initform: (make-hash-table)]
   [exits initform: (make-hash-table)]))

(define-class <exit> ()
  ([name initform: ""]
   [description initform: ""]
   [room initform: #f]))

(define (make-room rname rdescription robjects rexits)
  (make <room> name rname
               description rdescription
               objects robjects
               exits rexits))

(define (get-room name)
  (if (hash-table-exists? rooms name)
    (hash-table-ref rooms name)
    #f))

(define (get-object name room)
  
(define (make-exit ename edescription)
  (make <exit> name ename description edescription))

(define-generic (teleport object location))

