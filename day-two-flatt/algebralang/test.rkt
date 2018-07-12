#lang algebralang
;; originally #lang s-exp "algebralang.rkt"
;; s-exp allow the parenthesis to be expanded to (syntax ***)
;; to get rid of quotes and .rkt, save .rkt file as main in a folder, and install that folder as a package.
;; then add a module reader so we don't need s-exp. s-exp has it's own reader.


0
"str"
#f
#true
(+ 3 2)
(* 4 10)
(if #t then 1 else 0)
(if #f then 1 else 2)
(define-function (my_double x) (+ x x))
(apply-function my_double 2)
(+ 0.1 (+ 0.1 (+ 0.1 (+ 0.1 (+ 0.1 (+ 0.1 (+ 0.1 (+ 0.1 (+ 0.1 0.1)))))))))


;; Negative test cases
#;then
#;(3)
#;(apply-function my_double 2 4)