;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |26|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))


;; PURPOSE : To design a function that takes a list of Points and draws a 
;;           solid blue circle with radius 10 at every Point in that list 
;;           into a 300x300 scene.

;;**************************FUNCTION**************************************

(require 2htdp/image)
(define-struct point (x y))

 ;; listOfPoints : ListOfPoints -> Image
 ;; GIVEN : a list of points (x y).
 ;; RETURNS : Image of a 300x300 scene with solid blue circles at
 ;;           every point on that list.
 ;; Examples: 
 ;; (listOfPoints (make-point 10 100) (make-point 50 200))
 ;; =>(place-images (list (circle 10 "solid" "blue") (circle 10 "solid" "blue"))
 ;;   (list (posn 10 100) (posn 50 200)) (empty-scene 300 300))

(define (listOfPoints lst)
  (place-images (make-list (length lst) (circle 10 "solid" "blue"))
                lst
                (empty-scene 300 300)))

;;*****************************TEST*********************************************
 

(check-expect (listOfPoints 
               (list (make-posn 10 100) (make-posn 50 200)))
              (place-images (list (circle 10 "solid" "blue") 
                                  (circle 10 "solid" "blue"))
                            (list (make-posn 10 100) (make-posn 50 200)) 
                            (empty-scene 300 300)))