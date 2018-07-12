#lang turnstile/quicklang
(provide Int String Bool ->
         (rename-out [typed-app #%app]
                     [typed-+ +]
                     [typed-datum #%datum]
                     [typed-if if]))

;; alt + \ or cmd + \ expands the following:
;; \vdash => ⊢
;; \gg => ≫
;; \Rightarrow => ⇐
;; \Leftarrow <= ⇐

(define-base-types Int String Bool)
(define-type-constructor -> #:arity > 0)
 
(define-primop typed-+ + : (-> Int Int Int))

(define-typerule typed-app
  #;[(_ f e ...) ≫          ; Original
               [⊢ f ≫ f- ⇒ (~-> τin ... τout)]
               ; The tilde is important to because it tells racket to use it as a template rather than a pattern.
               [⊢ e ≫ e- ⇐ τin] ...
                --------------------
               [⊢ (#%app f- e- ...) ⇒ tout]]
  #;[(_ f e ...) ⇐ τout ≫   ; Exercise 28. Do this first, it's easier.
               [⊢ e ≫ e- ⇒ τin] ...               
               [⊢ f ≫ f- ⇐ (-> τin ... τout)]
               ; this will cause (+ 1) to fail with:
               ; "#%app: type mismatch: expected (-> Int Int), given (-> Int Int Int)"
               ; because we're saying "check that the type of f, in this case +, which is (-> Int Int Int) is what we're inferring from the args (-> Int Int)"
               ; But we want it to say "You're passing in the wrong number of args!" rather than "You're using the wrong function."
               --------------------
               [⊢ (#%app f- e- ...)]]
  [(_ f e ...) ≫           ; Exercise 27
               [⊢ f ≫ f- ⇒ (~-> τin ... τout)]
               ; ^The change from ⇐ to ⇒ is crucial because we want to compute here to be able to check in the next lines.
               #:fail-unless (= (stx-length #'(τin ...))
                                (stx-length #'(e ...)))
               "Wrong arity"
               [⊢ e ≫ e- ⇐ τin] ...               
               --------------------
               [⊢ (#%app f- e- ...) ⇒ τout]]

  )

(define-typerule typed-if  ; Exercise 29
  [(_ e1 e2 e3) ≫
              [⊢ e1 ≫ e1- ⇐ Bool]
              [⊢ e2 ≫ e2- ⇒ τ]
              [⊢ e3 ≫ e3- ⇐ τ]
              --------------------
              [⊢ (if e1- e2- e3-) ⇒ τ]])

(define-typerule typed-datum
  [(_ . n:integer) ≫
   -------------
   [⊢ (#%datum . n) ⇒ Int]]
  
  [(_ . s:str) ≫
   -------------
   [⊢ (#%datum . s) ⇒ String]]

  [(_ . b:boolean) ≫
   -------------
   [⊢ (#%datum . b) ⇒ Bool]] 
  
  [(_ . x) ≫
   --------
   [#:error (type-error #:src #'x #:msg "Unsupported literal: ~v" #'x)]])
