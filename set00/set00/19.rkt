;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |19|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))


;; PURPOSE : To design a function rel-rec-sequence that takes as argument two
;;           numbers and returns a solid blue rectangle. The first argument
;;           is the width of the rectangle and the second argument is a
;;           proportion. The proportionis used to calculate the height of the
;;           rectangle using the formula,
;;           height = width * proportion.

;;***************************FUNCTION*******************************************

(require 2htdp/image)
;; rel-rec-sequence: Number Number -> Rectangle
;; GIVEN: two numbers width w and proportion p
;; RETURNS: a solid blue rectangle, where w is the width of the rectangle
;;          , and p is the proportion of width and height of the rectangle
;;          to be produced (i.e. height = width * proportion).
;; EXAMPLES: (rel-rec-sequence 10 2) => (rectangle 10 20 "solid" "blue")

(define (rel-rec-sequence w p)
  (rectangle w (* w p) "solid" "blue"))

;;****************************TEST**********************************************

(check-expect (rel-rec-sequence 10 2) (rectangle 10 20 "solid" "blue"))
