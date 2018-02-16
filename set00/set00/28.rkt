;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |28|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))


;; PURPOSE : To design a function that takes a list of lists of strings as an 
;;           argument that treats each of the lists of strings as a line in a
;;           text and renders the whole text as an image. 

;;******************************FUNCTION****************************************
(require 2htdp/image)

;; stringlist : ListOfListOfStrings -> Image
    ;; GIVEN : a list of list of strings
    ;; RETURNS : a string that contains each of the lists of strings as a line
    ;;           in a text and renders the whole text as an image. 
    ;; Examples: 
    ;; (stringlist (list "Hi" "John") (list "Welcome" "back")
    ;; => Hi John
    ;;    Welcome back

(define (stringlist lst)
   (cond 
      [(empty? lst) empty-image]
      [else (above (stringdisp (first lst))
                    (stringlist (rest lst)))]))

;; stringdisp : listOfStrings -> Image
    ;; GIVEN : a list of strings
    ;; RETURNS : a string that contains all strings in the list searated 
    ;;           spaces.
    ;; Examples: 
    ;; (stringdisp (list "Hi" "John")) = Hi John

(define (stringdisp lst)
   (cond 
      [(empty? lst) empty-image]
      [else (beside/align "bottom" 
             (text (first lst) 12 "black") (text " " 12 "white") 
             (stringdisp (rest lst)))]))

;;*****************************TEST****************************************

(check-expect (stringlist (list (list "Hi" "John") (list "Hi" "Jane")))
                         (above (beside/align "bottom" (text "Hi" 12 "black")
                                              (text " " 12 "white")
                                              (text "John" 12 "black")
                                              (text " " 12 "white") empty-image)
                                (beside/align "bottom" (text "Hi" 12 "black")
                                              (text " " 12 "white")
                                              (text "Jane" 12 "black") 
                                              (text " " 12 "white") empty-image)))
