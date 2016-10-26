(declare (unit window) (uses debug))
(use (prefix sdl2 sdl2:))
(include "shared/macros.scm")

(define dirty-rects '())

(define black (sdl2:make-color 0 0 0))

(define window #f)

(define (window-needs-update?)
  (not (null? dirty-rects)))

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

(define (window-mark-dirty!)
  (list-push! dirty-rects (rect 0 0 (sld2:surface-w (sdl2:window-surface))
                                    (sdl2:surface-h (sdl2:window-surface)))))

(define (window-fill! color)
  (sdl2:fill-rect! (sdl2:window-surface window) #f color)
  (window-mark-dirty!))

(define (window-update!)
  (apply sdl2:update-window-surface-rects (list window dirty-rects))
  (set! dirty-rects '()))

(define image-load sdl2:load-bmp)

(define rect sdl2:make-rect)

(define point sdl2:make-point)

(define (image-crop-draw! image source-rect  dest-rect)
  (sdl2:blit-surface! image source-rect (sdl2:window-surface window) dest-rect)
  (list-push! dirty-rects dest-rect))

(define (image-draw! image x y)
  (image-crop-draw! image (rect 0 0 (sdl2:surface-w image) (sdl2:surface h image))
                          (rect x y (sdl2:surface-w image) (sdl2:surface h image))))

