#lang racket
;; Exercise 20
;; p is the rotated T, ie. "provable that" or "true in this type system"

;; Type rule for if
;;  
;; p e1: bool, p e2: type0, p e3: type0
;; ------------------------------------
;; p if e1 e2 e3: type0
;; ^ this is racket's "if" in the form if <cond> <then> <else>

;; Type rule for +
;;
;; p e1: number, p e2: number
;; ----------------------------
;; p + e1 e2: number


;; Exercise 21 (using bidirectional notation)

;; Type rule for function application
;;
;; p e1 => typein -> typeout, p e2 <= typein
;; ----------------------------
;; p e1 e2 <= typeout

;; Type rule for if
;;  
;; p e1 <= bool, p e2 => type0, p e3 => type0
;; ------------------------------------
;; p if e1 e2 e3 <= type0

;; Type rule for +
;;
;; p e1 <= number, p e2 <= number
;; ----------------------------
;; p + e1 e2 <= number

;; Type rule for lambdas
;;
;; , p e <= typeout 
;; ----------------------------
;; p lambda x:typein e <= (typein -> typeout)
;; no need p x <= typein because x:typein is specified.
