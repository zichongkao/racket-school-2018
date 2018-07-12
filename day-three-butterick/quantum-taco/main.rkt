#lang br/quicklang
;; This does the same thing as atomic-taco, but operating at the reader instead of expander-level 
(require racket/stream)
(module+ reader
  (provide read-syntax))

(define (tokenize ip)
  ;; takes input port and return list of datums
  (define next-datum (read ip))
  (cond [(eof-object? next-datum) '()]
        [else
         (cons next-datum (tokenize ip))])
  )

#;(define (tokenize ip) ;;fancy way to do it
    (for/list ([tok (in-port read ip)])
      tok))

(define (parse toks)
  (cond
    [(empty? toks)
     ('())]
    [(list? toks)
     (map parse toks)]
    [(pair? toks)
     (cons (parse (car toks)) (parse (cdr toks)))]
    [else
      'taco]))

;; Intermediate test
#;(parse (tokenize (open-input-string "42 (+ 1 2)")))

(define (read-syntax src ip)
  (define toks (tokenize ip))
  (define parse-tree (parse toks))
  (with-syntax ([(PT ...) parse-tree])
    #'(module tacofied racket
        'PT ...)))