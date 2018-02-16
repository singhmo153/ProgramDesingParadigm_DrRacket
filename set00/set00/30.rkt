;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |30|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))




;; PURPOSE : To design a function that, given a list of booleans,
;;           returns a list with each boolean reversed


;;******************************FUNCTION************************************

;; neg-list : listOfBooleans -> listOfBooleans
    ;; GIVEN : a list of booleans
    ;; RETURNS : a list of booleans with each booleans reversed
    ;; Examples: 
    ;;(neg-list (list true false true)) => 
    ;;(cons false (cons true (cons false empty)))

(define (neg-list lst)
   (cond 
      [(empty? lst) empty]
      [else (append (cons (not (first lst)) empty) (neg-list (rest lst)))])) 
            


;;*****************************TEST****************************************

(check-expect (neg-list (list true false true)) 
              (cons false (cons true (cons false empty))))



