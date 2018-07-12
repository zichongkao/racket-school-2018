#lang racket

(require (for-syntax syntax/parse))
;; Exercise 9

; SYNTAX
; (define-function (f x ...) e)
; binds f to a syntax tranformer of shape (cons n s)
; where n is the arity |x ...| of f
; and   s is syntax for (λ (x ...) e)
(define-syntax (define-function stx)
  (syntax-parse stx
    [(_ (f:id parameter:id ...) body:expr)
     (define arity (length (syntax->list #'(parameter ...))))
     #`(define-syntax f (cons #,arity #'(lambda (parameter ...) body)))]))

; SYNTAX
; (function-app f e1 ... eN)
; applies f to the values of e1 ... IF f is defined and f's arity is N  
(define-syntax (function-app stx)
  (syntax-parse stx
    [(_ f:id arg:expr ...)
     (define n-args (length (syntax->list #'(arg ...))))
     (define-values (arity the-function) (lookup #'f stx))
     (cond
       [(= arity n-args) #`(#,the-function arg ...)]
       [else
        (define msg (format "wrong number of arguments for ~a" (syntax-e #'f)))
        (raise-syntax-error #f msg stx)])]))

; Identifier Syntax -> (values N Id)
; EFFECT raises an exception if id is not available
(define-for-syntax (lookup id stx)
  ; -> Empty
  ; EFFECT abort process with syntax error 
  (define (failure)
    (define msg (format "undefined function: ~a" (syntax-e id)))
    (raise-syntax-error #f msg stx))
  (define result (syntax-local-value id failure))
  (values (car result) (cdr result)))

; Exercise 12 - 15
(provide #%module-begin
         (rename-out [literal #%datum]
                     [primitive-op +]
                     [primitive-op *]
                     [complain-app #%app]
                     [complain-top #%top]
                     [unwrap #%top-interaction]
                     [my_if if]
                     [function-app apply-function]) ;; Exercise 14
         define-function
         then
         else)

(define-syntax (literal stx)
  (syntax-parse stx
    [(_ . v:number) #'(#%datum . v)]
    [(_ . s:string) #'(#%datum . s)]
    [(_ . b:boolean) #'(#%datum . b)]  ;; Exercise 12
    [(_ . other) (raise-syntax-error #f "unknown literal" #'other)]))

(define-syntax (primitive-op stx) ;; Exercise 15
  (syntax-parse stx
    [(op n1:expr n2:expr)
    ; Want to ensure that op gets converted into native racket op
     ; and no further attempts are made to re-expand to avoid an infinite loop
     (define literal-op (syntax->datum #'op))
     #`(#,literal-op n1 n2)]))

(define-syntax (complain-app stx)
  (define (complain msg src-stx)
    (raise-syntax-error 'parentheses msg src-stx))
  (define without-app-stx
    (syntax-parse stx [(_ e ...) (syntax/loc stx (e ...))]))
  (syntax-parse stx
    [(_)
     (complain "empty parentheses are not allowed" without-app-stx)]
    [(_ n:number)
     (complain "extra parentheses are not allowed around numbers" #'n)]
    [(_ x:id _ ...)
     (complain "unknown operator" #'x)]
    [_
     (complain "something is wrong here" without-app-stx)]))

(define-syntax (complain-top stx)
  (syntax-parse stx
    [(_ . x:id)
     (raise-syntax-error 'variable "unknown" #'x)]))

(define-syntax (unwrap stx)
  (syntax-parse stx
    [(_ . e) #'e]))

;; Exercise 13
(define-syntax (my_if stx)
  (syntax-parse stx
    #:literals (then else)
    [(_ e0:expr then e1:expr else e2:expr)
     #'(if e0 e1 e2)]))

(define-syntax (then stx)
  ; Ensures that "then" gets an outside-of-if error rather than unbound identifier error
  (raise-syntax-error 'then "then is only allowed within an if function" stx))

(define-syntax (else stx)
  ; Ensures that "else" gets an outside-of-if error rather than unbound identifier error
  (raise-syntax-error 'else "else is only allowed within an if function" stx))

;; Exercise 17
(module reader syntax/module-reader
  ;; defines module named "reader", which Racket will look for when someone specifies "#lang algebralang"
  ;; this module is expanded with syntax/module-reader which knows how to parse #:wrapper1 like stuff to
  ;; provide a customized read-syntax. algebralang is required by syntax/module-reader so it can be specified
  ;; as the expander for the incoming file.
  algebralang
  #:wrapper1 (lambda (t)
               (parameterize ([read-decimal-as-inexact #f]) ;;Exercise 18
                 (t))))

#;
(module reader racket
  ;; manually overload the read-syntax function, modifying it in plain racket
  (provide (rename-out [read-module-syntax read-syntax]))
  
  (define (read-syntax-all src in)
    (parameterize ([read-decimal-as-inexact #f]) ;; Exercise 18
      (define e (read-syntax src in))
      (if (eof-object? e)
          '()
          (cons e (read-syntax-all src in)))))
  
  (define (read-module-syntax src in)
    (define lang (datum->syntax #f algebralang)) ;; when you do it manually, you specify the expander here.
    #`(module whatever #,lang
        #,@(read-syntax-all src in))))