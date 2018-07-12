#lang racket

(require (for-syntax syntax/parse))
(require rackunit)

; Exercise 6
(define-syntax (where stx)
  (syntax-parse stx
    [(_ e0:expr [variable:id e1:expr] ...)
     #'(let ([variable e1] ...)
         e0)]))

;;test cases
(check-equal? (where (+ my-favorite-number 2)
                     [my-favorite-number 8])
              (let ([my-favorite-number 8])
                (+ my-favorite-number 2)))

(check-equal? (where (op 10 (+ my-favorite-number an-ok-number))
                     [my-favorite-number 8]
                     [an-ok-number 2]
                     [op *])
              (let ([op *]
                    [an-ok-number 2]
                    [my-favorite-number 8])
                (op 10 (+ my-favorite-number an-ok-number))))

;; Part 2
(define-syntax (where* stx)
  (syntax-parse stx
    [(_ body:expr
        [name:id rhs:expr]
        ...)
     #`(let* #,(reverse (syntax->list #'([name rhs] ...))) ;#, converts back to syntax automatically
         body)]))

(define-syntax (where-recurse* stx)
  (syntax-parse stx
    [(_ body) ;terminal layer
     #'body]
    [(_ body [variable1:id e1:expr] [variable0:id e0:expr] ...) ;intermediate layers
     #'(where-recurse*
        (let ([variable1 e1]) body)
        [variable0 e0] ...)
     ]))

(define-syntax (where-recurse2* stx)
  (syntax-parse stx
    [(_ body) ;terminal layer
     #'body]
    [(_ body [variable0:id e0:expr] ... [variable1:id e1:expr]) ;intermediate layers
     #'(let ([variable1 e1])
         (where-recurse2* body [variable0 e0] ...))
     ]))

;; Test Case
(check-equal? (where* (list x y z)
                      [x (+ y 4)]
                      [y (+ z 2)]
                      [z 1])
              (let* ([z 1]
                    [y (+ z 2)]
                    [x (+ y 4)])
                (list x y z)))

(check-equal? (where-recurse* (list x y z)
                              [x (+ y 4)]
                              [y (+ z 2)]
                              [z 1])
              (let* ([z 1]
                    [y (+ z 2)]
                    [x (+ y 4)])
                (list x y z)))

(check-equal? (where-recurse2* (list x y z)
                               [x (+ y 4)]
                               [y (+ z 2)]
                               [z 1])
              (let* ([z 1]
                    [y (+ z 2)]
                    [x (+ y 4)])
                (list x y z)))

;; Exercise 7
(define-syntax (and/v stx)
  (syntax-parse stx
    #:literals (=>)
    [(_ e0:expr => var:id e1:expr)
     #'(let ([var e0]) (and var e1))]
    [(_ e0:expr e1:expr)
     #'(and e0 e1)]
    ))


(check-equal? (and/v 1 => x (+ x 1))
              2)

(check-equal? (and/v #f => x (+ x 1))
              #f)

(check-equal? (and/v #t (+ 2 1))
              3)