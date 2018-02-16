;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname 21a) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))




;; PURPOSE : To extend the function person-image in Ex 21 such that
;;           the full name of the person appears below the image.

;;*******************************DATA DEFINITION************************

;;(define-struct persondata(firstname lastname age height weight))
;; A Person is a (make-person String String PosInteger PosReal PosReal)
;; It represents an identity and build of a person.
;; Interpretation:
;; first-name = the first-name/given-name of a person.
;; last-name = the last-name/surname of a person.
;; age = age of the person in years.
;; height = height of the person in centimeters.
;; weight = weight of the person in pounds.


;;*********************************FUNCTION EXTENSION*******************

(require "21.rkt")
(require 2htdp/image)

;; person-image-name : Person -> Image
;; GIVEN : A person with a first-name, last-name, age, height, and weight.
;; RETURNS : An image with a full name.
;; Examples:
;; (person-image (make-person("Jane" "Doe" 30 160 120) => Image with full 
;;                                                        name.


(define (person-image-name p)
  (above (person-image p)
         (beside (text (person-firstname p)  24 "red") 
                 (text (person-lastname p) 24 "red"))))

;;**********************************TEST*********************************

(check-expect (person-image-name (make-person "Jane" "Doe" 30 160 120))
              (above (above (beside (rectangle 80 16 "solid" "blue") 
               (beside (above (circle 40 "solid" "blue") 
                              (rectangle 80 120 "solid" "red"))
                       (rectangle 80 16 "solid" "blue"))) 
         (beside (rectangle 16 120 "solid" "blue") 
                 (beside (rectangle 16 120 "solid" "white") 
                         (rectangle 16 120 "solid" "blue"))))
                     (beside (text "Jane" 24 "red")
                             (text "Doe" 24 "red"))))

