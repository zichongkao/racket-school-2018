#lang br/quicklang
(require brag/support "grammar.rkt")
(provide (all-from-out br/quicklang) (all-defined-out))

(module+ reader
  (provide read-syntax))

(define-lex-abbrev regex-chars (char-set "()*+?.^$|<!=[]"))

(define tokenize
  (lexer
   [(:+ "\n") (token 'NEWLINE lexeme)]
   [(from/stop-before ";" "\n") (token 'COMMENT #:skip? #t)]
   [(:+ whitespace) (token 'SP lexeme #:skip? #t)]
   [regex-chars lexeme]
   [alphabetic (token 'LITERAL lexeme)]))

(define (read-syntax src ip)
  (define parse-tree (parse (λ () (tokenize ip))))
  (strip-context
   (with-syntax ([PT parse-tree])
     (displayln parse-tree)
     #'(module regexcellent-mod regexcellent
         (for ([line (in-list PT)])
           (displayln line))))))

(define (top . pieces)
  pieces)

(define (line . pieces)
  (define line-val (string-append* pieces))
  (format "This pattern matches~a." line-val))

(define (sequence . pieces)
  (cond
    [(eq? (length pieces) 1)
     (car pieces)]
    [else
     (define sequence-val (string-join pieces ", followed by"))
     (format "~a" sequence-val)]))
  
(define-cases quantified
  [(_ arg) arg]
  [(_ arg quantifier)
   (format "~a~a" arg quantifier)])

(define (quantifier arg)
  arg)

(define (group . pieces)
  (cond
    [(eq? (length pieces) 1)
     (car pieces)]
    [else
     (format " a group consisting~a" (string-join pieces ", "))]))
  
;; these pieces have trivial logic
(define (literals . pieces)
  (cond
    [(eq? (length pieces) 1)
     (format " the character ~s" (car pieces))]
    [else
     (format " the literal string ~s" (string-append* pieces))]))

(define (or)
  "; or")

(define (anything)
  " any character")

(define (input-start)
  " the start of input")

(define (input-end)
  " the end of input")

(define (zero-or-more)
  " zero or more times")

(define (once-or-more)
  " one or more times")

(define (zero-or-once)
  " zero or once")

(define (literal arg)
  (format " the character ~s" arg))