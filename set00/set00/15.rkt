;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |15|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))


;; PURPOSE : To write reasonable comments for the definition of the tye Student
;;           from Ex14 that defines the types of the fields and their
;;           interpretation

;;***********************DATA DEFINITION****************************
(define-struct student(id name major))
;; A Student is a (make-student Integer String String).
;; It represents a student's id, name, and major.
;; Interpretation:
;;   id    = the identification number of the student.
;;   name  = the name of the student.
;;   major = the major of the student.