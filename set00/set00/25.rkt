;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |25|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))



;; PURPOSE : To write the function that returns true if all booleans in the
;;           list are true.

;;******************************FUNCTION************************************


;; booleanfn : ListOfBoolean -> Boolean
    ;; GIVEN : a list of booleans
    ;; RETURNS : true iff all booleans in the list are true, and false 
    ;;           otherwise
    ;; Examples: 
    ;; (booleanfn empty) = false
    ;; (booleanfn (list false)) = false
    ;; (booleanfn (list true true true) = true

(define (booleanfn lst)
      (cond
        [(empty? lst) false]
        [else (subbooleanfn lst)]))

;; subbooleanfn : ListOfBoolean -> Boolean
    ;; GIVEN : a list of booleans
    ;; RETURNS : true iff all booleans in the list are true, and false 
    ;;           otherwise
    ;; Examples: 
    ;; (subbooleanfn empty) = false
    ;; (subbooleanfn (list false)) = false
    ;; (subbooleanfn (list true true true) = true

(define (subbooleanfn lst)
      (cond
        [(empty? lst) true]
        [else (and (first lst) (subbooleanfn (rest lst)))]))

;;******************************TEST*****************************************

(check-expect (booleanfn empty) false)
(check-expect (booleanfn (list true true true)) true)
(check-expect (booleanfn (list false true true)) false)

    