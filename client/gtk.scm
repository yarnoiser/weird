(declare (unit gtk))

; gtk header
(foreign-declare "#include <gtk/gtk.h>")

; gtk types
(define-foreign-type g-pointer c-pointer)
(define-foreign-type gtk-widget c-pointer)
(define-foreign-type gtk-application c-pointer)
(define-foreign-type g-application c-pointer)
(define-foreign-type g-string c-string)
(define-foreign-type g-callbcak c-pointer)

; gtk constants
(define null-pointer (foreign-value "NULL"))
(define g-application-flags-none (foreign-value "G_APPLICATION_FLAGS_NONE" unsigned-int))

; gtk procedures
(define gtk-application-new (foreign-lambda gtk-application gtk_application_new c-string unsigned-int))
(define g-object-unref (foreign-lambda void g_object_unref g-pointer))
(define g-application-run (foreign-lambda int g_application_run g-application int c-pointer))

; gtk macro wrappers
(define g-signal-connect
  (foreign-lambda* void ([gtk-application instance] [g-string detailed-signal] [g-callback c-handler] [g-pointer data])
    "g_signal_connect(instance, detailed_signal, c_handler, data);"))

(define g-callback
  (foreign-lambda* g-callback ([g-pointer f])
    "C_return(G_CALLBACK(f));"))

(define g-application
  (foreign-lambda* g-application ([g-pointer a])
    "C_return(G_APPLICATION(a));"))

