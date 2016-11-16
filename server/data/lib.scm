(use coops coops-primitive-objects (srfi 69))

(define rooms (make-hash-table))

(define objects (make-hash-table))

(define-class <world-object> ()
   ([name initform: ""]
    [description initform: ""]
    [location initform: #f]))

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
  (make <room> 'name rname
               'description rdescription
               'objects robjects
               'exits rexits))

(define (make-world-object oname odescription olocation)
  (make <world-object> 'name oname
                       'description odescription
                       'location olocation))

(define (get-room name)
  (if (hash-table-exists? rooms name)
    (hash-table-ref rooms name)
    #f))

(define (make-exit ename edescription eroom)
  (make <exit> 'name ename 'description edescription 'room eroom))

(define-generic (teleport object location))

(define-method (teleport (object <world-object>) (location <room>))
  (let ([current-location (slot-value object 'location)])
    (when current-location
      (hash-table-delete! (slot-value current-location 'objects) object))
    (hash-table-set! (slot-value location 'objects) object)
    (set! (slot-value object 'location) location)
    #t))

(define-method (teleport (object <world-object>) (location-name <string>))
  (let ([location (get-room location-name)])
    (teleport object location)))


