(declare (unit window))
(use (prefix sdl2 sdl2:))

(define window #f)

(define (window-init! title width height)
  (sdl2:set-main-ready!)
  (sdl2:init! '(video))

  (on-exit sdl2:quit!)
  (current-exception-handler
    (let ([original-handler (current-exception-handler)])
      (lambda (exception)
        (sdl2:quit!)
        (original-handler exception))))

  (set! window (sdl2:creat-window! title 0 0 width height)))

(define window-quit-requested? sdl2:quit-requested?)

