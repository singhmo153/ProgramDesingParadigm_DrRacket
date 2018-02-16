;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |23|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))



;; PURPOSE: To write down an expression whose value is the list of booleans
;;          alternating between true and false, and starting with true.

;;********************************EXPRESSION*******************************

(list true false true false true)

;;********************************TEST*************************************

(check-expect (list true false true false true) 
              (cons true (cons false 
                               (cons true (cons false (cons true empty))))))