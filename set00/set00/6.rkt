;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |6|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))


#| Purpose: To define a function quadratic-root that takes as arguments
            a,b, and c, and computes one of the roots of the corresponding
            quadratic equation. |#

;***************************FUNCTION******************************************

; quadratic-root : NonZeroNumber Number Number -> Number
; GIVEN: the coefficients a,b, and c of a quadratic equation
; RETURNS: One of the solutions of the quadratic equation
; Examples:
; (quadratic-root 1 -2 1) => 1
; (quadratic-root 1 -1 1) => #i0.5+0.8660254037844386i

(define (quadratic-root a b c)
  (/ (+ (- b) (sqrt (- (* b b) (* 4 (* a c)))))
     (* 2 a)))
;*************************************TEST************************************

(check-expect (quadratic-root 1 -2 1) 1)
(check-within (quadratic-root 1 -1 1) #i0.5+0.8660254037844386i 0)