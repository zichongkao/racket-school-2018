#lang racket

(require (for-syntax syntax/parse))

; Exercise 1 (compile time)
(define-syntax (define-world* stx)
  
  (syntax-parse stx
    [(_ x:id ...)
     #`(begin
         (define counter 0)
         (begin
           (define x counter)
           (set! counter (+ counter 1)))...)]
    ))

#;
(define-world* x y z)
x
y
z

; Exercise 1 (compile recursive time)
(define-syntax (define-world-level stx)
  (syntax-parse stx
    [(_ level x:id) ; 1 arg
     #`(define x level)]
    [(_ level x:id y:id ...) ; 1+ arg
     #`(begin
         (define x level)
         (define-world-level (+ level 1) y ...))]
    ))

(define-syntax (define-world-recurse* stx)
  (syntax-parse stx
    [(_ x ...)
     #'(define-world-level 0 x ...)]))

#;
(define-world-recurse* x y z)
x
y
z

; Exercise 1 (runtime time)
(require racket/list)
(define-syntax (define-world-runtime* stx)
  (syntax-parse stx
    [(_ x:id ...)
     (define args (syntax->list #'(x ...)))
     (define len (length args))
     #`(define-values #,args (apply values (range #,len)))]
    ))

#;
(define-world-runtime* x y z)
x
y
z