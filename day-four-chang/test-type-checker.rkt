#lang s-exp "type-checker.rkt"

5
#f
"five"
; 1.1 ;; err
; (if 1 2 3) ;; err
(if #f 2 3)
(if (if #t #f #t) 2 3)

(+ 1 2)
(+ 1 2 3)
; (+ #f 1) ;; err

;+
(lambda ([x : Int]) x)
((lambda ([x : Int]) x) 5)
; ((lambda ([x : Int]) x) "4") ;; err
; (+ ((lambda ([x : Int]) x) 5) x) ;;err
