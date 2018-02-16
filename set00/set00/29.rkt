;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |29|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))




;; PURPOSE : To design a function that takes a list of people and uses the 
;;           function from Ex21 to draw these people, placing them beside 
;;           each other to form some kind of a group photo.

;;******************************FUNCTION************************************

;; person-list : listOfStructure -> listOfImages
    ;; GIVEN : a list of structure person
    ;; RETURNS : a list of Images
    ;; Examples: 
    ;; (person-list (list (make-person "Jane" "Doe" 30 160 120)
    ;; (make-person "John" "Doe" 30 200 150))) => 
    ;; Images


(require "21.rkt")
(require 2htdp/image)

(define (person-list lst)
   (cond 
      [(empty? lst) empty-image]
      [else (beside/align "bottom" (person-image (first lst)) 
                          (person-list (rest lst)))]))

            


;;*****************************TEST****************************************

(check-expect (person-list (list (make-person "Jane" "Doe" 30 160 120)
             (make-person "John" "Doe" 30 200 150))) 
              (beside/align "bottom"
                            (above (beside (rectangle 80 16 "solid" "blue") 
               (beside (above (circle 40 "solid" "blue") 
                              (rectangle 80 120 "solid" "red"))
                       (rectangle 80 16 "solid" "blue"))) 
         (beside (rectangle 16 120 "solid" "blue") 
                 (beside (rectangle 16 120 "solid" "white") 
                         (rectangle 16 120 "solid" "blue"))))
                            (above (beside (rectangle 100 20 "solid" "blue") 
               (beside (above (circle 50 "solid" "blue") 
                              (rectangle 100 150 "solid" "red"))
                       (rectangle 100 20 "solid" "blue"))) 
         (beside (rectangle 20 150 "solid" "blue") 
                 (beside (rectangle 20 150 "solid" "white") 
                         (rectangle 20 150 "solid" "blue"))))))
                            



