;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |24|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))


;; PURPOSE : To write the function that returns product of all the numbers
;;           in a list.

;;******************************FUNCTION************************************


;; product : List -> Number
    ;; GIVEN : a list of numbers
    ;; RETURNS : product of all the numbers in the given list.
    ;; Examples: 
    ;; (product empty) = 0
    ;; (product (list 1)) = 1
    ;; (product (list 1 2 3) = 6
    
(define (product lst)     
        (cond 
             [(empty? lst) 0]
             [else (prod lst)]))

 ;; prod : List -> PosReal
    ;; GIVEN : a list of positive real numbers
    ;; RETURNS : product of all the numbers in the given list.
    ;; Examples: 
    ;; (product empty) = 0
    ;; (product (list 1)) = 1
    ;; (product (list 1 2 3) = 6

(define (prod lst)
   (cond 
             [(empty? lst) 1]
             [else (* (first lst) (prod (rest lst)))]))

;;************************************TEST*********************************


(check-expect (product (list 1 2 3)) 6)
(check-expect (product empty) 0)
