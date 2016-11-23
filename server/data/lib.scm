(use coops coops-primitive-objects (srfi 69))

(define rooms (make-hash-table))

(define objects (make-hash-table))

(define-class <world> ()
  ([regions initform: (make-hash-table)]))

(define-class <region> ()
  ([rooms initform: (make-hash-table)]))

(define-class <world-object> ()
   ([name initform: ""]
    [description initform: ""]
    [location initform: #f]))

(define-class <room> ()
  ([name initform: #f]
   [description initform: #f]
   [objects initform: (make-hash-table)]
   [exits initform: (make-hash-table)]))

(define-class <room-exit> ()
  ([name initform: ""]
   [description initform: ""]
   [destination initform: #f]))

(define-class <region-exit> (<room-exit>)
   ([region initform: #f]))

(define-generic (region-add-room region room))

(define-method (region-add-room (region <region>) (room <room>))
  (hash-table-set! (slot-value region 'rooms) (slot-value room 'name) room))

(define (make-region #!optional (rooms '()))
  (let ([region (make <region>)])
    (for-each (lambda (room)
                (region-add-room region room))
              region)))

(define-generic (world-add-region! world region))

(define-method (world-add-region! (world <world>) (region <region>))
  (hash-table-set! (slot-value world 'regions) (slot-value region 'name) region))

(define (make-world #!optional (regions '()))
  (let ([world (make-world)])
    (for-each (lambda (region)
                (world-add-region! world region))
              regions)
    world))

(define-generic (room-add-exit! room room-exit))

(define-method (room-add-exit! (room <room>) (room-exit <room-exit>))
  (hash-table-set! (slot-value room 'exits) (slot-value room-exit 'name)))

(define-generic (teleport! object location))

(define-method (teleport! (object <world-object>) (location <room>))
  (let ([current-location (slot-value object 'location)])
    (when current-location
      (hash-table-delete! (slot-value current-location 'objects) object))
    (hash-table-set! (slot-value location 'objects) object)
    (set! (slot-value object 'location) location)
    #t))

(define-method (teleport! (object <world-object>) (location-name <string>))
  (let ([location (get-room location-name)])
    (teleport object location)))

(define room-add-object! teleport!)

(define-generic (move! object room-exit))

(define-method (move! (object <world-object>) (room-exit <room-exit>))
  (let ([new-location (slot-value exit 'room)])
    (teleport object new-location)))

(define (make-room rname rdescription #!optional (rexits '()) (robjects '()))
  (let ([room (make <room> 'name rname
                           'description rdescription)])
    (for-each (lambda (rexit)
                (room-add-exit! room rexit))
                rexits)
    (for-each (lambda (robjects)
                (room-add-object! room objects))
                robjects)
    room))
  
(define (make-world-object oname odescription olocation)
  (make <world-object> 'name oname
                       'description odescription
                       'location olocation))

(define-syntax area-exit (syntax-rules (to region)
  [(_ n to region reg room desc)
   (make <region-exit> 'name n
                       'region reg
                       'destination room
                       'description desc)]
  [(_ n to room desc)
   (make <room-exit> 'name n
                     'destination room
                     'description desc)]))


   

