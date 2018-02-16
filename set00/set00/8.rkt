;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |8|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))


#| Purpose: To write the definition of a function called circle-area
            that computes the area included in a circle of radius r. |#


;*****************************FUNCTION****************************************

;circle-area : NonNegNumber -> NonNegNumber
;GIVEN: radius r of a circle
;RETURNS: area of the circle of radius r, using the formula pi * r^2.
;Examples:
;(circle-area 1) => 3.141592653589793
;(circle-area 5) => 78.53981633974483
;(circle-area 7) => 153.93804002589985

(define (circle-area r)
  (* pi (sqr r)))

;*******************************TEST******************************************

(check-within (circle-area 1) 3.141592653589793 0)
(check-within (circle-area 5) 78.53981633974483 0)
(check-within (circle-area 7) 153.93804002589985 0)