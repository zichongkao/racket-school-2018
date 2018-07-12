#lang brag
taco-program : taco-leaf*
taco-leaf : (taco | not-a-taco){7} 
taco : /"%"
not-a-taco : /"#$"
; different from before where we expected tokens of one characters
; because now we are giving tokens of two characters each