;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |3|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
#| Purpose: To write the definition of a function that converts a temperature
            from degrees Fahrenheit to degrees Celsius.|#

;*************************FUNCTION********************************************

;f->c : Number -> Number
;GIVEN: a temperature in degrees Fahrenheit as an argument
;RETURNS: the equivalent temperature in degrees Celsius.
;Examples:
;(f->c 32)  => 0
;(f->c 100) => 37.77777777777778

(define (f->c tf)
  (/ (* 5 (- tf 32))
     9))

;************************TEST*************************************************

(check-expect (f->c 32) 0)
(check-within (f->c 100) 37.77777777777778 0.00000000000001)
(check-expect (f->c  -13) -25)