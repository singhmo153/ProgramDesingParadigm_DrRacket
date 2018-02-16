;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |32|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))





;; PURPOSE : To design a function that takes a list of Points and returns 
;;           the sum of all distances of those Points from (0,0).

;;******************************FUNCTION************************************

;; sum-of-distances : listOfPosns -> PosReal
    ;; GIVEN : a list of positions (x y)
    ;; RETURNS : the sum of all distances of those positions from (0,0) using
    ;;           the Manhattan distance measure (distance = x + y).
    ;; Examples: 
    ;;(sum-of-distances (list (make-posn 1 2) (make-posn 3 4))) => 
    ;; 10


(define (sum-of-distances lst)
   (cond 
      [(empty? lst) 0]
      [else (+ (Manhattan-distance (first lst)) 
                    (sum-of-distances (rest lst)))]))

;; Manhattan-distance : Posn -> PosReal
    ;; GIVEN : a position (x y)
    ;; RETURNS : returns the distance where, distance = x + y.
    ;; Examples: 
    ;;(Manhattan-distance (make-posn 1 2)) => 3

(define (Manhattan-distance p) 
  (+ (posn-x p) (posn-y p)))

            


;;*****************************TEST****************************************

(check-expect (sum-of-distances (list (make-posn 1 2) (make-posn 3 4))) 
              10)


