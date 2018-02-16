;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname 27a) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))


;; PURPOSE : To design a function that takes alist of strings and draws 
;;           the combined text of those strings, separated by spaces. 

;;******************************FUNCTION************************************
(require 2htdp/image)

;; stringdisp : listOfStrings -> Image
    ;; GIVEN : a list of strings
    ;; RETURNS : a string that contains all strings in the list searated 
    ;;           spaces.
    ;; Examples: 
    ;; (stringdisp (list "Hi" "John")) = Hi John

(define (stringdisp lst)
   (cond 
      [(empty? lst) (text "" 12 "black")]
      [else (beside (beside (text (first lst) 12 "black") (text " " 12 "black"))
                    (stringdisp (rest lst)))]))

;;*****************************TEST****************************************

(check-expect (stringdisp (list "Hi" "John")) (text "Hi John " 12 "black"))
