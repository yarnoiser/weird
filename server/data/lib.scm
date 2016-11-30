(use coops coops-primitive-objects (srfi 1 69))

(define-class <world> ()
  ([name initform: ""]
   [description initform: ""]
   [regions initform: (make-hash-table)]))

(define-class <region> ()
  ([name initform: ""]
   [description initform: ""]
   [rooms initform: (make-hash-table)]))

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

(define-class <world-exit> (<region-exit>)
  ([world initform: #f]))

(define worlds (make-hash-table))

(define-generic (add-world! world))

(define-method (add-world! (world <world>))
  (hash-table-set! worlds (slot-value world 'name) world))

(define-generic (region-add-room! region room))

(define-method (region-add-room! (region <region>) (room <room>))
  (hash-table-set! (slot-value region 'rooms) (slot-value room 'name) room))

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
    (teleport! object location)))

(define room-add-object! teleport!)

(define-generic (move! object room-exit))

(define-method (move! (object <world-object>) (room-exit <room-exit>))
  (let ([new-location (slot-value exit 'room)])
    (teleport object new-location)))

(define (make-world-object oname odescription olocation)
  (make <world-object> 'name oname
                       'description odescription
                       'location olocation))

(define (room-exit name description destination)
  (make <room-exit> 'name name
                    'description description
                    'destination destination))

(define (region-exit name description region destination)
  (make <region-exit> 'name name
                      'description description
                      'region region
                      'destination destination)) 

(define (world-exit name description world region destination)
  (make <world-exit> 'name name
                     'description description
                     'world world
                     'region region
                     'destination destination))
                     

(define (room name description . exits-and-objects)
  (let ([r (make <room> 'name name
                        'description description)])
    (for-each (lambda (exit-or-object)
                (cond
                  [(subclass? (class-of exit-or-object) <room-exit>)
                   (room-add-exit! r exit-or-object)]
                  [(subclass? (class-of exit-or-object) <world-object>)
                   (room-add-object! r exit-or-object)]))
              exits-and-objects)
    r))

(define (region name description . rooms)
  (let ([r (make <region> 'name name
                          'description description)])
    (for-each (lambda (room)
                (region-add-room! r room))
              rooms)
   r))

(define (world name description . regions)
  (let ([w (make <world> 'name name
                         'description description)])
    (for-each (lambda (region)
                (world-add-region! w region))
              regions)
    w))                         
