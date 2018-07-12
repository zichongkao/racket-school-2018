#lang br/quicklang

(module+ reader
  (provide read-syntax))

(define (tokenize ip)
  ;;use read-char here to get a list of chars
  (for/list ([tok (in-port read-char ip)])
    tok))

(define (parse toks)
  (map taco-parser toks)
  )

(define (taco-parser tok)
  (define padded-binary (reverse (cdr (reverse (integer->binary (+ 128 (char->integer tok)))))))
  (map tacofy padded-binary))

(define (tacofy b)
  (cond
    [(equal? b 0) '()]
    [(equal? b 1) 'taco]))

(define (integer->binary n)
 (cond
   [(< n 2)
    (list n)]
   [else
     (cons (remainder n 2) (integer->binary (quotient n 2)))]))

;; Intermediate test
;;(parse (tokenize (open-input-string "42 (+ 1 2)")))

(define (read-syntax src ip)
  (define toks (tokenize ip))
  (define parse-tree (parse toks))
  (strip-context
   (with-syntax ([(PT ...) parse-tree])
     #`(module tacofied racket
         (displayln 'PT)...
         ))))