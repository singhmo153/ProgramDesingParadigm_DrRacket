;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |14|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))


;; PURPOSE : To list the functions that Racket will create when we execute 
;;           this: (define-struct student (id name major))?

;******************************FUNCTIONS***********************************

;; make-student  : Integer String String -> Student
;; student?      : Any -> Boolean
;; student-id    : Student -> Integer
;; student-name  : Student -> String
;; student-major : Student -> String