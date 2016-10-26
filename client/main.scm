(declare (uses window))

(window-init! "weird client" 640 480)

(let main-loop ()
  (when (not (window-quit-requested?))
    (main-loop)))

