#lang racket
(module reader syntax/module-reader
  racket)
;; This says use the syntax/module-reader as the reader and then pass to racket as the expander.
;; We could have also used 'passthrough' as the expander, and then added
  ;(provide (all-from-out racket)) here so that when passthrough is called and directed to main.rkt,
;; we have available the original racket module to be used as an expander.