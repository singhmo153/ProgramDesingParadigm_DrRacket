;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |11|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
;; PURPOSE    : To write contracts for the point functions

;*******************CONTRACTS OF POINT FUNCTIONS************

;; make-point : Number Number -> Point
;; point?     : Any   -> Boolean
;; point-x    : Point -> Number
;; point-y    : Point -> Number