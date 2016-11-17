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

(define (make-exit ename edescription eroom)
  (make <exit> 'name ename 'description edescription 'room eroom))

(define exit make-exit)

(define (make-room rname rdescription rexits #!optional robjects)
  (make <room> 'name rname
               'description rdescription
               'objects robjects
               'exits rexits))

(define (room rname rdescription rexits #!optional robjects)
  (let ([r (make-room rname rdescription (make-hash-table) robjects)])
    (for-each (lambda (exit-args)
                (hash-table-set! (slot-value r 'exits) (car exit-args) (apply make-exit exit-args)))
              rexits)
    r))

(define (world . rooms)
  (let ([world-table (make-hash-table)])
    (for-each (lambda (room-args)
                (hash-table-set! world-table (car room) (apply room room-args)))
              rooms))
  world-table)

(define (make-world-object oname odescription olocation)
  (make <world-object> 'name oname
                       'description odescription
                       'location olocation))

(define (get-room name)
  (if (hash-table-exists? rooms name)
    (hash-table-ref rooms name)
    #f))

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

(define-generic (move object exit))

(define-method (move (object <world-object>) (exit <exit>))
  (let ([new-location (slot-value exit 'room)])
    (teleport object new-location)))

