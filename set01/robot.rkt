;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname robot) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
;; robot.rkt

; PURPOSE : To design a robot, that is a circle of radius 15, which moves 
;           around a 200 x 400 room surrounded by a wall. At every step,
;           the robot can move forward or rotate 90 degrees either right or 
;           left. The robot can also sense when it has run into a wall.

(require rackunit)
(require "extras.rkt")

(provide initial-robot
         robot-left
         robot-right
         robot-forward
         robot-north?
         robot-south? 
         robot-east? 
         robot-west?) 

;;****************************************************************************

;; A Direction is one of
;; -- "north"
;; -- "south"
;; -- "east"
;; -- "west"


;; direction-fn : Direction -> ??

;(define (direction-fn dir)
;  (cond
;    [(string=? dir "north") ...]
;    [(string=? dir "south") ...]
;    [(string=? s "east") ...]
;    [(string=? s "west") ...]))

(define-struct robot (x y dir))

;; A Robot is a (make-robot Real Real Direction)
;; It represents the position and direction of a robot.
;; Interpretation:
;; x = the x coordinate of the robot's position.
;; y = the y coordinate of the robot's position.
;; dir = the direction the robot is facing in.

;; TEMPLATE:
;(define (robot-fn r)
;  (...
;   (robot-x r)
;   (robot-y r)
;   (robot-dir r)))


(define RADIUS 15)
;;RADIUS is the radius of the circular robot.
(define LEFT 0)
;;LEFT is the left boundary of the room.
(define TOP 0)
;;TOP is the top boundary of the room.
(define RIGHT 200)
;;RIGHT is the right boundary of the room.
(define BOTTOM 400)
;;BOTTOM is the bottom boundary of the room.

;;****************************************************************************

;; initial-robot : Real Real-> Robot
;; GIVEN: a set of (x,y) coordinates
;; RETURNS: a robot with its center at those coordinates, facing north
; (up).
;; EXAMPLES:
;; (initial-robot 10 20) = (make-robot 10 20 "NORTH")
;; (initial-robot -20 -50) = (make-robot -20 -50 "NORTH")
;; STRATEGY: function composition.

(define (initial-robot x y)
  (make-robot x y "north"))

;;TEST

(begin-for-test
  (check-equal? 
   (initial-robot 10 20) 
   (make-robot 10 20 "north")             
   "the initial robot, should be (make-robot 10 20 north)")
  
  (check-equal? 
   (initial-robot -20 -50) 
   (make-robot -20 -50 "north")
   "the initial robot, should be (make-robot -20 -50 north)"))


;; robot-left : Robot -> Robot
;; GIVEN: a robot.
;; RETURNS: a robot like the original, but turned 90 degrees to left.
;; EXAMPLES:
;; (robot-left (make-robot 10 20 "north")) = (make-robot 10 20 "west")
;; (robot-left (make-robot -2.5 0 "south")) = (make-robot -2.5 0 "east")
;; STRATEGY: structural decomposition on r(robot).

(define (robot-left r)
  (make-robot 
   (robot-x r)
   (robot-y r)
   (direction-after-left 
    (robot-dir r))))

;;TEST

(begin-for-test
  (check-equal? 
   (robot-left (make-robot 10 20 "north"))
   (make-robot 10 20 "west")
   "the robot, should be (make-robot 10 20 west)")
  
  (check-equal? 
   (robot-left (make-robot 10 20 "south"))
   (make-robot 10 20 "east")
   "the robot, should be (make-robot 10 20 east)")
  
  (check-equal? 
   (robot-left (make-robot 10 20 "east"))
   (make-robot 10 20 "north")
   "the robot, should be (make-robot 10 20 north)")
  
  (check-equal? 
   (robot-left (make-robot 10 20 "west"))
   (make-robot 10 20 "south")
   "the robot, should be (make-robot 10 20 south)"))

;; direction-after-left : Direction -> Direction
;; GIVEN: a direction.
;; RETURNS: a direction after turning left.
;; EXAMPLES:
;; (direction-after-right "north") = "west"
;; STRATEGY: cases on Direction.

(define (direction-after-left dir)
  (cond
    [(string=? dir "north") "west"]
    [(string=? dir "south") "east"]
    [(string=? dir "east") "north"]
    [(string=? dir "west") "south"]))

;; TEST

(begin-for-test
  (check-equal? 
   (direction-after-left "north") 
   "west"
   "the direction should be west")
  (check-equal? 
   (direction-after-left "south") 
   "east"
   "the direction should be east")
  (check-equal? 
   (direction-after-left "east") 
   "north"
   "the direction should be north")
  (check-equal? 
   (direction-after-left "west") 
   "south"
   "the direction should be south"))


;; robot-right : Robot -> Robot
;; GIVEN: a robot.
;; RETURNS: a robot like the original, but turned 90 degrees rigt.
;; EXAMPLES:
;; (robot-right (make-robot 10 20 "NORTH")) = (make-robot 10 20 "EAST")
;; (robot-right (make-robot -2.5 0 "SOUTH")) = (make-robot -2.5 0 "WEST")
;; STRATEGY: structural decomposition on r(robot).

(define (robot-right r)
  (make-robot 
   (robot-x r)
   (robot-y r)
   (direction-after-right 
    (robot-dir r))))

;;TEST 

(begin-for-test
  (check-equal? 
   (robot-right (make-robot 10 20 "north"))
   (make-robot 10 20 "east")
   "the robot, should be (make-robot 10 20 east)")
  
  (check-equal? 
   (robot-right (make-robot 10 20 "south"))
   (make-robot 10 20 "west")
   "the robot, should be (make-robot 10 20 west)")
  
  (check-equal? 
   (robot-right (make-robot 10 20 "east"))
   (make-robot 10 20 "south")
   "the robot, should be (make-robot 10 20 south)")
  
  (check-equal? 
   (robot-right (make-robot 10 20 "west"))
   (make-robot 10 20 "north")
   "the robot, should be (make-robot 10 20 north)"))

;; direction-after-right : Direction -> Direction
;; GIVEN: a direction.
;; RETURNS: a direction after turning right.
;; EXAMPLES:
;; (direction-after-right "east") = "south"
;; STRATEGY: cases on Direction.


(define (direction-after-right dir)
  (cond
    [(string=? dir "north") "east"]
    [(string=? dir "south") "west"]
    [(string=? dir "east") "south"]
    [(string=? dir "west") "north"]))

;; TEST

(begin-for-test
  (check-equal? 
   (direction-after-right "north") 
   "east"
   "the direction should be east")
  (check-equal? 
   (direction-after-right "south") 
   "west"
   "the direction should be west")
  (check-equal? 
   (direction-after-right "east") 
   "south"
   "the direction should be south")
  (check-equal? 
   (direction-after-right "west") 
   "north"
   "the direction should be north"))


;; robot-forward : Robot PosInt -> Robot
;; GIVEN: a robot and a distance.
;; RETURNS: a robot like the given one, but moved forward by the
;  specified distance.  If moving forward the specified distance
;  would cause the robot to move from being entirely inside the 
;  room to being even partially outside the room, then the robot
;  should stop at the wall.
;; EXAMPLES:
; (robot-forward (make-robot 60 20 "NORTH") 20) 
; = (make-robot 60 5 "NORTH")
; (robot-forward (make-robot -20 450 "SOUTH") 20) 
; = (make-robot -20 470 "SOUTH")
;; STRATEGY: function-composition.

(define (robot-forward r d)
  (if (will-robot-collide-wall? r d) 
      (robot-after-stop r d) 
      (robot-after-forward r d)))

;; TEST

(begin-for-test
  (check-equal? 
   (robot-forward (make-robot 60 20 "north") 20) (make-robot 60 15 "north")
   "the robot, should be (make-robot 60 15 north)")
  
  (check-equal? 
   (robot-forward (make-robot 60 380 "south") 20) (make-robot 60 385 "south")
   "the robot, should be (make-robot 60 385 south)")
  
  (check-equal? 
   (robot-forward (make-robot 180 50 "east") 50) (make-robot 185 50 "east")
   "the robot, should be (make-robot 185 50 east)")
  
  (check-equal? 
   (robot-forward (make-robot 30 380 "west") 20) (make-robot 15 380 "west")
   "the robot, should be (make-robot 15 380 west)")
  
  (check-equal? 
   (robot-forward (make-robot 50 -20 "north") 50) (make-robot 50 -70 "north")
   "the robot, should be (make-robot 50 -70 north)")
  
  (check-equal? 
   (robot-forward (make-robot -20 450 "south") 20) (make-robot -20 470 "south") 
   "the robot, should be (make-robot -20 470 south)")
  
  (check-equal? 
   (robot-forward (make-robot -60 20 "west") 20) (make-robot -80 20 "west")
   "the robot, should be (make-robot -80 20 west)")    
  
  (check-equal? 
   (robot-forward (make-robot 350 20 "east") 50) (make-robot 400 20 "east")
   "the robot, should be (make-robot 400 20 east)")
  
  (check-equal? 
   (robot-forward (make-robot 0 0 "north") 50) (make-robot 0 -50 "north")
   "the robot, should be (make-robot 0 -50 north)")
  
  (check-equal? 
   (robot-forward (make-robot 0 0 "east") 50) (make-robot 50 0 "east")
   "the robot, should be (make-robot 50 0 east)")
  
  (check-equal? 
   (robot-forward (make-robot 0 0 "south") 50) (make-robot 0 50 "south")
   "the robot, should be (make-robot 50 0 south)")
  
  (check-equal? 
   (robot-forward (make-robot 0 0 "west") 50) (make-robot -50 0 "west")
   "the robot, should be (make-robot -50 0 west)")
  
  (check-equal? 
   (robot-forward (make-robot 200 0 "north") 50) (make-robot 200 -50 "north")
   "the robot, should be (make-robot 200 -50 north)")
  
  (check-equal? 
   (robot-forward (make-robot 200 0 "east") 50) (make-robot 250 0 "east")
   "the robot, should be (make-robot 250 0 east)")
  
  (check-equal? 
   (robot-forward (make-robot 200 0 "south") 50) (make-robot 200 50 "south")
   "the robot, should be (make-robot 200 50 south)")
  
  (check-equal? 
   (robot-forward (make-robot 200 0 "west") 50) (make-robot 150 0 "west")
   "the robot, should be (make-robot 150 0 west)")
  
  (check-equal? 
   (robot-forward (make-robot 200 400 "north") 50) (make-robot 200 350 "north")
   "the robot, should be (make-robot 200 350 north)")
  
  (check-equal? 
   (robot-forward (make-robot 200 400 "east") 50) (make-robot 250 400 "east")
   "the robot, should be (make-robot 250 400 east)")
  
  (check-equal? 
   (robot-forward (make-robot 200 400 "south") 50) (make-robot 200 450 "south")
   "the robot, should be (make-robot 200 450 south)")
  
  (check-equal? 
   (robot-forward (make-robot 200 400 "west") 50) (make-robot 150 400 "west")
   "the robot, should be (make-robot 150 400 west)")
  
  (check-equal? 
   (robot-forward (make-robot 0 200 "north") 50) (make-robot 0 150 "north")
   "the robot, should be (make-robot 0 150 north)")
  
  (check-equal? 
   (robot-forward (make-robot 0 200 "east") 50) (make-robot 50 200 "east")
   "the robot, should be (make-robot 50 200 east)")
  
  (check-equal? 
   (robot-forward (make-robot 0 200 "south") 50) (make-robot 0 250 "south")
   "the robot, should be (make-robot 0 250 south)")
  
  (check-equal? 
   (robot-forward (make-robot 0 200 "west") 50) (make-robot -50 200 "west")
   "the robot, should be (make-robot -50 200 west)"))


;; will-robot-collide-wall? : Robot PosInt -> Boolean
;; GIVEN: a robot and a distance
;; RETURNS: true if the robot collides a wall, false otherwise.
;; EXAMPLES:
; (will-robot-collide-wall? (make-robot 60 20 "NORTH") 20) = true
; (will-robot-collide-wall? (make-robot -20 450 "SOUTH") 20) = false
;; STRATEGY: structural decomposition

(define (will-robot-collide-wall? r d)
  (is-robot-close-to-wall? d
                           (robot-x r)
                           (robot-y r)
                           (robot-dir r)))
;; TEST

(begin-for-test
  (check-equal?
   (will-robot-collide-wall? (make-robot 60 20 "north") 20) true)
  (check-equal?
   (will-robot-collide-wall? (make-robot 800 600 "south") 20) false))

;; robot-close-to-wall? : PosInt Real Real String -> Boolean
;; GIVEN: a distance, x and y coordinate of robot, and direction of robot.
;; RETURNS: true if the robot is close to the wall, false otherwise.
;; EXAMPLES:
; (robot-close-to-wall? 20 60 20 "NORTH") = true
; (robot-close-to-wall? 20 -20 450 "SOUTH") = false
;; STRATEGY: cases on dir(direction).


(define (is-robot-close-to-wall? d x y dir)
  (cond
    [(string=? dir "north") (robots-north-and-west-in-range? 
                             x (- y RADIUS d) LEFT RIGHT TOP y)]
    [(string=? dir "south") (robots-south-and-east-in-range?
                             x (+ y RADIUS d) LEFT RIGHT BOTTOM y)]
    [(string=? dir "east") (robots-south-and-east-in-range? 
                            y (+ x RADIUS d) TOP BOTTOM RIGHT x)]
    [(string=? dir "west") (robots-north-and-west-in-range? 
                            y (- x RADIUS d) TOP BOTTOM LEFT x)]))

;; TEST

(begin-for-test
  (check-equal?
   (is-robot-close-to-wall? 20 60 20 "north") true)
  (check-equal?
   (is-robot-close-to-wall? 20 800 600 "south") false))


;; robot-nort-west-in-range? : Real Real PosInt PosInt PosInt Real-> Boolean
;; GIVEN: x and y of robot and a value, and boundaries of the room.
;  RETURNS: true if the robot is going to collide to the top or left wall,
;  false otherwise
;; EXAMPLES: (robot-in range1? 60 -15 LEFT RIGHT TOP 20) = true
;  20 60 are coordinates of robot and -15 = (20 - RADIUS - distance to travel)
;  STRATEGY: function composition

(define (robots-north-and-west-in-range? x z first-b second-b third-b y)
  (and
   (in-range? x first-b second-b)
   (if (> y 0)
       (is-smaller? z third-b)
       false)))

;; TEST

(begin-for-test
  (check-equal?
   (robots-north-and-west-in-range? 20 -15 0 200 0 20) true))

;; robot-in-range2? : Real Real PosInt PosInt PosInt Real -> Boolean
;; GIVEN:x and y of robot and a value, and boundaries of the room.
;  RETURNS: true if the robot is going to collide the bottom or right wall,
;  false otherwise
;; EXAMPLES: (robot-in range1? 60 -15 LEFT RIGHT TOP 20) = true
;  20 60 are coordinates of robot and -15 = (20 - RADIUS - distance to travel)
;  STRATEGY: function composition

(define (robots-south-and-east-in-range? x z first-b second-b third-b y)
  (and
   (in-range? x first-b second-b)
   (if (< y third-b)
       (is-larger? z third-b)
       false)))

;; TEST

(begin-for-test
  (check-equal?
   (robots-south-and-east-in-range? 20 850 0 200 800 20) true))


;; in-range? : Real PosInt PosInt -> Boolean
;; GIVEN: x or y coordinate of robot.
;; RETURNS: true if the robot is within the boundaries.
;; EXAMPLES:
; (in-range? 10 0 200) = true
; (in-range? 800 0 400) = false
;; STRATEGY: function Composition

(define (in-range? x y z)
  (and (>= x y) (<= x z)))

;; TEST

(begin-for-test
  (check-equal?
   (in-range? 20 0 800) true))

;; is-smaller? : Real PosInt -> Boolean
;; GIVEN: two numbers.
;; RETURNS: true if the first is smaller than the second, false otherwise.
;; EXAMPLES:
; (is-smaller? 10 50) = true
; (is-smaller? 50 40) = false
;  STRATEGY: function composition

(define (is-smaller? a b)
  (<= a b))

;; TEST

(begin-for-test
  (check-equal?
   (is-smaller? 20 800) true))


;; is-larger? : Real PosInt -> Boolean
;; GIVEN: two numbers.
;; RETURNS: true if the first is larger than the second, false otherwise.
;; EXAMPLES:
; (is-smaller? 10 50) = false
; (is-smaller? 50 40) = true
;  STRATEGY: function composition

(define (is-larger? a b)
  (>= a b))

;; TEST

(begin-for-test
  (check-equal?
   (is-smaller? 2 8) true))



;; robot-after-stop : Robot PosInt -> Robot
;; GIVEN: a robot and a distance.
;; RETURNS: a robot like the given one, but after stopping just
;  before a wall.
;; EXAMPLES:
;  Instead of ravelling 20 steps in north, the robot stops after 5 steps because
;  it encountered the wall.
; (robot-stop-position (make-robot 60 20 "NORTH") 20) 
; = (make-robot 60 15 "NORTH")
;; STRATEGY: Cases on dir(direction).

(define (robot-after-stop r d)
  (cond
    [(string=? (robot-dir r) "north") (make-robot (robot-x r) 
                                                  (+ TOP RADIUS) (robot-dir r))]
    [(string=? (robot-dir r) "south") (make-robot (robot-x r)
                                                  (- BOTTOM RADIUS) 
                                                  (robot-dir r))]
    [(string=? (robot-dir r) "east") (make-robot (- RIGHT RADIUS)
                                                 (robot-y r) 
                                                 (robot-dir r))]
    [(string=? (robot-dir r) "west") (make-robot (+ LEFT RADIUS)
                                                 (robot-y r)
                                                 (robot-dir r))]))

;; TEST

(begin-for-test
  (check-equal? 
   (robot-after-stop (make-robot 60 20 "north") 20) 
   (make-robot 60 15 "north")
   "the robot, should be (make-robot 60 15 north)")
  
  (check-equal? 
   (robot-after-stop (make-robot -20 380 "south") 50) 
   (make-robot -20 385 "south") 
   "the robot, should be (make-robot -20 470 south)")
  
  (check-equal? 
   (robot-after-stop (make-robot 180 50 "east") 50) 
   (make-robot 185 50 "east")
   "the robot, should be (make-robot 15 50 east)")
  
  (check-equal? 
   (robot-after-stop (make-robot 60 20 "west") 50) 
   (make-robot 15 20 "west")
   "the robot, should be (make-robot 15 20 west)"))


;; robot-after-forward: Robot PosInt -> Robot
;; GIVEN: a robot and a distance.
;; RETURNS: a robot like the given one, but after moving 
;  specified distance in a given direction.
;; EXAMPLES:
; (robot-stop-position (make-robot 60 700 "NORTH") 20) 
; = (make-robot 60 680 "NORTH")
;; STRATEGY: Cases on dir(direction).

(define (robot-after-forward r d)
  (cond
    [(string=? (robot-dir r) "north") (make-robot (robot-x r) 
                                                  (- (robot-y r)  d) 
                                                  (robot-dir r))]
    [(string=? (robot-dir r) "south") (make-robot (robot-x r) 
                                                  (+ (robot-y r) d) 
                                                  (robot-dir r))]
    [(string=? (robot-dir r) "east") (make-robot (+ (robot-x r) d) 
                                                 (robot-y r) 
                                                 (robot-dir r))]
    [(string=? (robot-dir r) "west") (make-robot (- (robot-x r) d)
                                                 (robot-y r) 
                                                 (robot-dir r))]))  

;; TEST

(begin-for-test
  (check-equal? 
   (robot-after-forward (make-robot 400 500 "north") 20) 
   (make-robot 400 480 "north")
   "the robot, should be (make-robot 400 480 north)")
  
  (check-equal? 
   (robot-after-forward (make-robot -20 450 "south") 20)
   (make-robot -20 470 "south") 
   "the robot, should be (make-robot -20 470 south)")
  
  (check-equal? 
   (robot-after-forward (make-robot 380 50 "east") 50)
   (make-robot 430 50 "east")
   "the robot, should be (make-robot 430 50 east)")
  
  (check-equal? 
   (robot-after-forward (make-robot -40 20 "west") 50)
   (make-robot -90 20 "west")
   "the robot, should be (make-robot -90 20 west)"))




;; robot-north? : Robot -> Boolean
;; robot-south? : Robot -> Boolean
;; robot-east? : Robot -> Boolean
;; robot-west? : Robot -> Boolean
;; GIVEN: a robot
;; ANSWERS: whether the robot is facing in the specified direction.
;; EXAMPLES:
;; (robot-north? (make-robot 10 20 "NORTH")) = true
;; (robot-north? (make-robot 10 20 "SOUTH")) = false
;; (robot-south? (make-robot 10 20 "SOUTH")) = true
;; (robot-south? (make-robot 10 20 "NORTH")) = false
;; (robot-east? (make-robot 10 20 "EAST")) = true
;; (robot-east? (make-robot 10 20 "WEST")) = false
;; (robot-west? (make-robot 10 20 "WEST")) = true
;; (robot-west? (make-robot 10 20 "NORTH")) = false
;  STRATEGY: function composition.

(define (robot-north? r)
  (string=? (robot-dir r) "north"))
(define (robot-south? r)
  (string=? (robot-dir r) "south"))
(define (robot-east? r)
  (string=? (robot-dir r) "east"))
(define (robot-west? r)
  (string=? (robot-dir r) "west"))

;; TEST
(begin-for-test
  (check-equal? (robot-north? (make-robot 10 20 "north")) true
                "the value, should be true")
  (check-equal? (robot-north? (make-robot 10 20 "south")) false
                "the value, should be false")
  (check-equal? (robot-south? (make-robot 10 20 "south")) true
                "the value, should be true")
  (check-equal? (robot-south? (make-robot 10 20 "north")) false
                "the value, should be false")
  (check-equal? (robot-east? (make-robot 10 20 "east")) true
                "the value, should be false")
  (check-equal? (robot-east? (make-robot 10 20 "north")) false
                "the value, should be false")
  (check-equal? (robot-west? (make-robot 10 20 "west")) true
                "the value, should be false")
  (check-equal? (robot-west? (make-robot 10 20 "north")) false
                "the value, should be false"))


