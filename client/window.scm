(declare (unit window) (uses debug))
(use (prefix sdl2 sdl2:))
(include "shared/macros.scm")

(define dirty-rects '())

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

(define (window-fill! color)
  (sdl2:fill-rect! (sdl2:window-surface window) #f color))

(define window-update! sdl2:update-window-surface!)

(define image-load sdl2:load-bmp)

(define rect sdl2:make-rect)

(define point sdl2:make-point)

(define (image-crop-draw! image source-rect  dest-rect)
  (sdl2:blit-surface! image source-rect (sdl2:window-surface window) dest-rect))

(define (image-draw! image x y)
  (image-crop-draw! image (rect 0 0 (surface-w image) (surface h image))
                          (rect x y (surface-w image) (surface h image))))

