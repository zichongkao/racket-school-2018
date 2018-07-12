#lang s-exp "typed-lang.rkt"
(require turnstile/rackunit-typechecking)
 
(check-type 5 : Int)
(check-type "five" : String)
(check-type #f : Bool)
 
;(typecheck-fail #f #:with-msg "Unsupported literal") ;; We have now implemented Bools
(typecheck-fail 1.1 #:with-msg "Unsupported literal")
 
(check-type (if #t 2 3) : Int -> 2)

(check-type + : (-> Int Int Int))

(check-type (+ 1 2) : Int -> 3)

(typecheck-fail (+ 1)) ;; Only enable this if we're using the arity checking version of %app