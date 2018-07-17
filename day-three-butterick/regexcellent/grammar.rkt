#lang brag
;; this doesn't really conform to typical regex standards, but will do for now.
; composite elements
top : (/NEWLINE+ [line])* /NEWLINE*
line :  sequence (or sequence)*
sequence : input-start? (literals | anything | group | quantified )+ input-end?
quantified : (literal | anything | group) quantifier

; atomic elements
once-or-more: /"+"
zero-or-once: /"?"
zero-or-more: /"*"
input-start : /"^"
input-end : /"$"
or : /"|"
anything : /"."
literals : @literal+
literal : LITERAL
group : /"(" ( literals | anything )+ /")" ; give parenthesized things high precedence
quantifier : ( once-or-more | zero-or-more | zero-or-once )
