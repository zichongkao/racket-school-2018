#lang br/quicklang
(require brag/support) ; imports `lexer`

(module+ reader
  (provide read-syntax))

(define lex (lexer
             ["#$" null]
             ["%" 'taco]
             [any-char (lex input-port)]))

;; Test lexer
#;(for/list ([tok (in-port lex
                         (open-input-string "##$%%%#$%#$$"))])
  tok)

(define (tokenize ip)
  (define flat-tokens (for/list ([tok (in-port lex ip)])
                        tok))
  (split-into-tokens flat-tokens))

(define (split-into-tokens lst)
  (cond
    [(eq? lst '()) '()]
    [else
     (cons (take lst 7) (split-into-tokens (drop lst 7)))]))

;; Test tokenizer
#;(tokenize (open-input-string "##$%%%#$%#%%%%%%%%$$"))

(define (parse toks)
  (displayln toks)
  (for/list ([tok (in-list toks)])
    (integer->char
     (for/sum ([val (in-list tok)]
               [power (in-naturals)]
               #:when (eq? val 'taco))
       (expt 2 power)))))

;; Test parser
#;(parse (tokenize (open-input-string "##$%%%#$%#%%%%%%%%$$")))

(define (read-syntax src ip)
  (define toks (tokenize ip))
  (define parse-tree (parse toks))
  (strip-context
   (with-syntax ([PT parse-tree])
     #'(module untaco racket
         (display (list->string 'PT))))))