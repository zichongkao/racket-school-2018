#lang racket
(require (for-syntax syntax/parse))

(module reader syntax/module-reader
  atomic-taco)

(provide #%module-begin
         #%top-interaction
         (rename-out [taco-datum #%datum]
                     [taco-app #%app]
                     [taco-datum #%top]
                     ))

(define-syntax (taco-datum stx)
  (syntax-parse stx
    [(_ . n) #'(#%datum . taco)]))
    ;note that #%datum has the syntactical pattern (#%datum . X) so we need to match that pattern

(define-syntax (taco-app stx)
  ;;(displayln stx)
  (syntax-parse stx
    [(_ op args ...) #'`(taco ,args ...)]))
   ; can't return "(#%app taco args ...)" otherwise we look to apply the taco function, but taco is not bound
   ; need to return taco as a literal 