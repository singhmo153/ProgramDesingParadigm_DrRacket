;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |31|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))




;; PURPOSE : To design a function that, given a list of Numbers, returns a 
;;           list of Images, where each image is a circle that has a radius
;;           based on a number of the input list.

;;******************************FUNCTION************************************

;; circle-list : listOfNumbers -> listOfImages
    ;; GIVEN : a list of numbers
    ;; RETURNS : a list of images where each image is a circle that has a radius
    ;;           based on a number of the input list.
    ;; Examples: 
    ;;(circle-list (list 1 2)) => 
    ;;(cons ((circle 1 "solid" "blue") (cons (circle 2 "solid" "blue") empty)))

(require 2htdp/image)
(define (circle-list lst)
   (cond 
      [(empty? lst) empty]
      [else (append (cons (circle (first lst) "solid" "blue") empty) 
                    (circle-list (rest lst)))])) 
            


;;*****************************TEST****************************************

(check-expect (circle-list (list 1 2)) 
              (cons (circle 1 "solid" "blue") 
                    (cons (circle 2 "solid" "blue") empty)))



