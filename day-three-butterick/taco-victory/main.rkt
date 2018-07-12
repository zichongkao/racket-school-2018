#lang br/quicklang
(require brag/support "grammar.rkt")
(provide (all-from-out br/quicklang) (all-defined-out))

(module+ reader
  (provide read-syntax))

(define (tokenize ip)
  (define lex (lexer
             ["#$" lexeme]
             ["%" lexeme]
             [any-char (lex input-port)]))
  (lex ip))

;;Test
;(apply-lexer tokenize "\n#$#$#$%#$%%\n")

(define (taco-program . pieces)
  pieces
  )

(define (taco-leaf . pieces)
  (integer->char
     (for/sum ([val (in-list pieces)]
               [power (in-naturals)]
               #:when (equal? val 1))
       (expt 2 power))))

(define (taco)
  1
  )

(define (not-a-taco)
  0
  )

(define (read-syntax src ip)
  (define token-thunk (λ () (tokenize ip)))
  (define parse-tree (parse token-thunk))
  (strip-context
   (with-syntax ([PT parse-tree])
     #'(module winner taco-victory  ;now we are using our own expander
         (display (apply string PT))))))