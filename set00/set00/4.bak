;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |4|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
#| Purpose: To define a function called tip that takes two arguments, a number
            representing the amount of a bill in dollars, and a decimal number
            between 0.0 and 1.0, representing the percentage of a tip one wants
            to give. tip should return the amount of tip in dollars.|#

;*****************************FUNCTION*****************************************

;tip : NonNegNumber Number[0.0,1.0] -> Number
;GIVEN: the amount of the bill in dollars and the
;percentage of tip
;RETURNS: the amount of the tip in dollars.
;Examples:
;(tip 10 0.15) => 1.5
;(tip 20 0.17) => 3.4

(define (tip a p)
  (* a p))

;****************************TEST*********************************************

(check-expect (tip 10 0.15) 1.5)
(check-expect (tip 20 0.17) 3.4)