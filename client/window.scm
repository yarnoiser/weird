(declare (unit window))
(use (prefix sdl2 sdl2:))

(define black (sdl2:make-color 0 0 0))

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

  (set! window (sdl2:create-window! title 0 0 width height '(resizable))))

(define window-quit-requested? sdl2:quit-requested?)

(define (window-draw-blank!)
  (sdl2:fill-rect! (sdl2:window-surface window) #f black))

(define (window-update!)
  (sdl2:update-window-surface! window))

(define image-load sdl2:load-bmp)


