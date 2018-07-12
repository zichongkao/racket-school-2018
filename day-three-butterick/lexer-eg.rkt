#lang br
(require brag/support)
(define lex (lexer
             ["fo" lexeme]
             [(:: "f" (:+ "o")) 42]
             [any-char (lex input-port)]))
(for/list ([tok (in-port lex
                         (open-input-string "foobar"))])
  tok) ;;42
(for/list ([tok (in-port lex
                         (open-input-string "fobar"))])
  tok) ;;fo because although the second condition matches, the first is, well, first and they both match 2 chars.