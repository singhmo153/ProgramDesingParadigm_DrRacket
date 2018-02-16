;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |21|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))

(require 2htdp/image)
(require "extras.rkt")
(provide person-image)
(provide person-firstname)
(provide person-lastname)
(provide make-person)

;; PURPOSE: To write down the data definition of the struct person, and 
;;          to write the function person-image that takes a person as 
;;          argument and returns an image in such a way that the height
;;          and weight of the image should be related to the height of 
;;          the person.

;;*******************************DATA DEFINITION************************

(define-struct person (firstname lastname age height weight))
;; A Person is a (make-person String String PosInteger PosReal PosReal)
;; It represents an identity and build of a person.
;; Interpretation:
;; first-name = the first-name/given-name of a person.
;; last-name = the last-name/surname of a person.
;; age = age of the person in years.
;; height = height of the person in centimeters.
;; weight = weight of the person in pounds.

;;********************************FUNCTION DEFINITION*******************


;; person-image: Person -> Image
;; GIVEN : A person with a first-name, last-name, age, height, and weight.
;; RETURNS : An image that corresponds to the height of the person.
;; Examples:
;; (person-image (make-person("Jane" "Doe" 30 160 120)) => Image

(define (person-image p)
  (above (beside (rect1-size 10 2 (person-height p)) 
               (beside (above (circle1 5 (person-height p)) 
                              (rect2-size 10 15 (person-height p)))
                       (rect1-size 10 2(person-height p)))) 
         (beside (rect3-size 2 15 (person-height p)) 
                 (beside (rect4-size 2 15 (person-height p)) 
                         (rect3-size 2 15 (person-height p))))))

;; proportion : PosReal -> PosReal
;; GIVEN : height of the image
;; RETURNS : propotionate value
;; Examples:
;; (proportion 160) => 8

(define (proportion h)
  (/ h 20))

;; rect1-size : PosReal PosReal PosReal -> Image
;; GIVEN : length and width of rectangle, and height of the person to
;;         draw proportionate size rectangle.
;; RETURNS : an image of solid blue rectangle.
;; Examples :
;; (rect1-size 10 2 160) => (rectangle 80 160 "solid" "blue")

(define (rect1-size l w h)
  (rectangle (* l (proportion h)) (* w (proportion h)) "solid" "blue"))

;; rect2-size : PosReal PosReal PosReal -> Image
;; GIVEN : length and width of rectangle, and height of the person to draw
;;         proportionate size rectangle.
;; RETURNS : an image of solid red rectangle.
;; Examples :
;; (rect2-size 10 2 160) => (rectangle 80 160 "solid" "red")
(define (rect2-size l w h)
  (rectangle (* l (proportion h)) (* w (proportion h)) "solid" "red"))

;; rect1-size : PosReal PosReal PosReal -> Image
;; GIVEN : length and width of rectangle, and height of the person to draw
;;         proportionate size rectangle.
;; RETURNS : an image of solid blue rectangle.
;; Examples :
;; (rect3-size 2 15 160) => (rectangle 16 120 "solid" "blue")

(define (rect3-size l w h)
  (rectangle (* l (proportion h)) (* w (proportion h)) "solid" "blue"))

;; rect4-size : PosReal PosReal PosReal -> Image
;; GIVEN : length and width of rectangle, and height of the person to draw 
;;         proportionate size rectangle.
;; RETURNS : an image of solid blue rectangle.
;; Examples :
;; (rect1-size 2 15 160) => (rectangle 16 120 "solid" "white")

(define (rect4-size l w h)
  (rectangle (* l (proportion h)) (* w (proportion h)) "solid" "white"))

;; circle1 : PosReal PosReal PosReal -> Image
;; GIVEN : radius of circle, and height of the person to draw proportionate size
;;         rectangle.
;; RETURNS : an image of solid blue circle.
;; Examples :
;; (circle1 5 160) => (circle 40 "solid" "blue")

(define (circle1 r h)
  (circle (* r (proportion h)) "solid" "blue"))

;;********************************************TEST******************************

(check-expect(image-height (person-image (make-person "Jane" "Doe" 30 160 120)))
(* 2 (image-height (person-image (make-person "Jane" "Doe" 30 80 100)))))
(check-expect(image-width (person-image (make-person "Jane" "Doe" 30 160 120)))
(* 2 (image-width (person-image (make-person "Jane" "Doe" 30 80 100)))))
(check-expect (person-image (make-person "Jane" "Doe" 30 160 120)) 
              (above (beside (rectangle 80 16 "solid" "blue") 
               (beside (above (circle 40 "solid" "blue") 
                              (rectangle 80 120 "solid" "red"))
                       (rectangle 80 16 "solid" "blue"))) 
         (beside (rectangle 16 120 "solid" "blue") 
                 (beside (rectangle 16 120 "solid" "white") 
                         (rectangle 16 120 "solid" "blue")))))

         





