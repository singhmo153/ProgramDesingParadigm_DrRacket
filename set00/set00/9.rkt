;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |9|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))



#| Purpose: To define a predicate even-num? that takes a number as an argument
            and returns true if this number is divisible by 2, and false 
            otherwise. |#

;**************************************PREDICATE******************************
; is-even?: Number -> Boolean
; GIVEN: a number
; RESULT: true if the number is divisible by 2, and false otherwise
; Examples:
;(is-even? 4) => true
;(is-even? 5) => false
; remainder operator is used to find out whether the number is divisible by 2
; or not. If remainder is 0 then the number is divisible by 2.

(define (is-even? n)
  (= (remainder n 2) 0))

;**********************************TEST***************************************

(check-expect (is-even? 4) true)
(check-expect (is-even? 5) false)