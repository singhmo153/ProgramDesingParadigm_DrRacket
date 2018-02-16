;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |18|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
(require 2htdp/image)
;; PURPOSE : To design a function rel-rec-sequence that takes a number n as 
;;           input and returns the nth element in the sequence.

;; RUN     : (rel-rec-square 4)

;***************************************************************************

;; 32x64
;; 64x128

; Formula for nth element = (rectangle (exp 2 n) (exp 2 (+ n 1)) "solid" "blue")

;**********************************FUNCTION*********************************

; rec-sequence : PosInteger -> Image
; GIVEN : the sequence number n
; RESULT : Image of the nth element of the sequence
; EXAMPLES :
; (rec-sequence 2) => (rectangle 4 8 "solid" "blue")
; (rec-sequence 3) => (rectangle 8 16 "solid" "blue")

(define (rec-sequence n)
  (rectangle (expt 2 n) (expt 2 (+ n 1)) "solid" "blue"))

;**********************************TEST*************************************

(check-expect (rec-sequence 2) (rectangle 4 8 "solid" "blue"))
(check-expect (rec-sequence 3) (rectangle 8 16 "solid" "blue"))

