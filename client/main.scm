(declare (uses window))

(window-init! "weird client" 640 480)

(let main-loop ()
  (when (not (window-quit-requested?))
    (window-draw-blank!)
    (window-update!)
    (main-loop)))

