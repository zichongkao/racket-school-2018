#lang brag
taco-program: /"\n"* taco-leaf* /"\n"*
taco-leaf: /"#" (taco | not-a-taco){7} /"$"
taco: /"%"
not-a-taco: /"#" /"$"
; the cuts are necessary to ensure we don't add these as leaves. Basically makes them non-capturing
; test using (parse-to-datum "\n##$%#$%#$#$#$$\n") after this file has run