;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |16|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))

(require 2htdp/image)
(define my-image (bitmap "1.jpg"))
(above my-image my-image my-image)
(beside my-image my-image)
(rectangle 20 30 "outline" "black")
(rectangle 20 30 "solid" "black")
(circle 4 "solid" "blue")
(text "Monisha" 12 "black")
(empty-scene 20 20)
(place-image my-image  50 50 (empty-scene 100 100))

