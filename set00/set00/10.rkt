;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |10|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))


#| Purpose: To define a function that takes three numbers as arguments and 
            returns the sum of the two larger numbers.|#

;***************************FUNCTION******************************************

; larger-sum : Number Number Number -> Number
; GIVEN: three numbers a,b, and c
; RESULT: sum of the two larger numbers among the three numbers a,b, and c
; Examples:
; (larger-sum 1 2 3) => 5
; (larger-sum -2 -5 -3) => -5

; Sum of two larger numbers = sum of all three numbers - minimum of the
;                             three numbers
(define (larger-sum a b c)
  (- (+ a b c) (min a b c)))

;****************************TEST*********************************************

(check-expect (larger-sum 1 2 3) 5)
(check-expect (larger-sum -2 -5 -3) -5)