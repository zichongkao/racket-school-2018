#lang racket
;;Exercise 22

(require (for-syntax syntax/parse syntax/stx syntax/id-table))
(provide
 if lambda +
 (rename-out
  [typechecking-mb #%module-begin]))
  ;; hijack #%module-begin to do type-checking beforehand 

(begin-for-syntax

  ;; Exercise 23
  (define (mk-empty-env)
    (make-immutable-free-id-table))
  ;; we want an immutable table so that for cases like (+ ((lambda ([x : Int]) x) 5) x)
  ;; the type of the first x doesn't get used for the second x. This should rightly not check out.
  
  (define (add-to-env env x t)
    (free-id-table-set env x t))

  (define (lookup-env env x)
    (free-id-table-ref env x #f))
  
  ;; compute : StxExpr -> StxTy
  (define (compute e ctx)  ; Exercise 24
    ; ctx is this free-id-table that is passed around and keeps track
    ; of the types of the already defined variables.
    (syntax-parse e
      [_:integer #'Int]
      [_:string #'String]
      [_:boolean #'Bool]
      [((~literal if) e1 e2 e3)
       #:when (check #'e1 #'Bool ctx)
       #:with t (compute #'e2 ctx)
       #:when (check #'e3 #'t ctx)
       #'t]
      [((~literal +) e1 e2 ...)
       #:with t (compute #'e1 ctx)
       #:when (andmap
               (lambda (e) (check e #'t ctx))
               (syntax->list #'(e2 ...)))
       #'t]
      [((~literal lambda) ([x : t_in] ...) e1)
       #:with t_out (compute #'e1 (foldr
                                  (lambda (y t_y env)
                                    ; rmb that accumulator passed in last. From the docs:
                                    ; "If foldl is called with n lists, then proc must take n+1 arguments.
                                    ; "The extra argument is the combined return values so far.
                                    (add-to-env env y t_y))
                                  ctx
                                  (syntax->list #'(x ...))
                                  (syntax->list #'(t_in ...))))
       ; foldr here saves each variable with its associated type in the env
       ; foldr so that the env gets updated and passed along
       #'(-> t_in ... t_out)]
      [x:id   ; handles the terminal "compute e1" step in the lambda pattern
       #:do[(define t-or-false (lookup-env ctx #'x))]
       #:when t-or-false
       t-or-false]
      [(e1 e2 ...)   ; (lambda) function application
      #:with ((~literal ->) t1 ... t_out) (compute #'e1 ctx)
      #:fail-unless (= (length (syntax->list #'(e2 ...)))
                       (length (syntax->list #'(t1 ...))))
      "arity error"
      #:when (andmap
              (lambda (e t) (check e t ctx))
              (syntax->list #'(e2 ...))
              (syntax->list #'(t1 ...)))
      #'t_out]
      [e (raise-syntax-error
          'compute
          (format
           "could not compute type of ~a"
           (syntax->datum #'e))
          #'e)]
      ))

  ; check : ExprStx TyStx -> Bool
  ; checks that the given term has the given type
  (define (check e t-expected ctx)
    (define t (compute e ctx))
    (or (type=? t t-expected)
        (raise-syntax-error
         'check
         (format "error while checking term ~a: expected ~a; got ~a"
                 (syntax->datum e)
                 (syntax->datum t-expected)
                 (syntax->datum t)))))
 
  ; type=? : TyStx TyStx -> Bool
  ; type equality here is is stx equality
  (define (type=? t1 t2)
    (or (and (identifier? t1) (identifier? t2) (free-identifier=? t1 t2))
        (and (stx-pair? t1) (stx-pair? t2)
             (= (length (syntax->list t1))
                (length (syntax->list t2)))
             (andmap type=? (syntax->list t1) (syntax->list t2))))))

(define-syntax typechecking-mb
  (syntax-parser
    [(_ e ...)
     ; prints out each term e and its type, it if has one;
     ; otherwise raises type error
     #:do[(stx-map
           (λ (e)
               (printf "~a : ~a\n"
                       (syntax->datum e)
                       (syntax->datum (compute e (mk-empty-env)))))
           #'(e ...))]
     ; this language only checks types,
     ; it doesn't run anything
     #'(#%module-begin (void))]))