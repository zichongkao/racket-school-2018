#lang br/quicklang

(module+ reader
  (provide read-syntax))

(define (tokenize ip)
  (for/list ([tok (in-port read ip)])
    tok))

(define (parse toks)
  (map parse-char toks)
  )

(define (parse-char tacolist)
  (define reversed-binary-rep (map detacofy tacolist))
  (integer->char (binary-rep->integer reversed-binary-rep)))

(define (binary-rep->integer bin-rep)
  (for/sum ([val (in-list bin-rep)]
            [power (in-naturals)]
            #:when (eq? val 1))
    (expt 2 power)))

(define (detacofy elem)
  (cond
    [(equal? elem 'taco) 1]
    [(equal? elem '()) 0]))

;; Intermediate test
;(parse (tokenize (open-input-string "(() taco () taco () () ()) (())")))

(define (read-syntax src ip)
  (define toks (tokenize ip))
  (define parse-tree (parse toks))
  (strip-context
   (with-syntax ([(PT ...) parse-tree])
     #'(module untaco racket
         (display 'PT)...
         ))))