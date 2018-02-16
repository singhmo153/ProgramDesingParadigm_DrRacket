;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname balls-in-box) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))

;; balls-in-box
;; the balls can move either right or left
;; and a ball moving in any direction
;; bounces smoothly off the edge of the canvas even when it is dragged to
;; the edges.
;; a user can drag the balls in box with the mouse.
;; button-down to select, drag to move, button-up to release.
;; key n to create new ball.
;; The balls are displayed as a circle with radius 20. 
;; An unselected ball is displayed as an outline; a selected ball 
;; is displayed solid.
;; In addition to the balls, the number of balls currently on the canvas
;; is also displayed.

;; run with (run speed frame-rate)
;; example:
;; (run 8 .25)

(require 2htdp/universe)
(require 2htdp/image)
(require rackunit)
(require "extras.rkt")

(provide run)
(provide initial-world)
(provide world-after-tick)
(provide world-after-key-event)
(provide world-after-mouse-event)
(provide world-balls)
(provide ball-x-pos)
(provide ball-y-pos)
(provide ball-selected?)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; RUN FUNCTION.

;; run : PosInt PosReal -> World
;; GIVEN: a ball speed and a frame rate, in secs/tick.
;; EFFECT: runs the world at the given frame rate.
;; RETURNS: the final state of the world.
;; EXAMPLE: (run 8 .25)  
;; = starts the simulation with the rectangle positioned at the centre
;;   of the canvas and returns final state of the world, similar to
;;   this, 
;;       (make-world (list (make-ball 200 150 0 0 false "right") 8 false))
;; STRATEGY: function composition

(define (run speed rate)
  (big-bang (initial-world speed)
            (on-tick world-after-tick rate)
            (on-draw world-to-scene)
            (on-key world-after-key-event)
            (on-mouse world-after-mouse-event)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;CONSTANTS

;;dimensions of the canvas
(define SCENE-WIDTH 400)
(define SCENE-HEIGHT 300)
(define RIGHT 400)
(define LEFT 0)

;;color constants
(define BALL-COLOR "green")

;;image constants
(define SOLID-BALL-IMAGE (circle 20 "solid" BALL-COLOR))
(define OUTLINE-BALL-IMAGE (circle 20 "outline" BALL-COLOR))
(define EMPTY-CANVAS (empty-scene SCENE-WIDTH SCENE-HEIGHT))

;; dimension of circle

(define RADIUS 20)

;;center of the canvas
(define CENTER-X-COORD (/ SCENE-WIDTH 2))
(define CENTER-Y-COORD (/ SCENE-HEIGHT 2))

;;initial mouse pointer position
(define MOUSE-X 0)
(define MOUSE-Y 0)

;; mouse event
(define button-up "button-up")
(define button-down "button-down")
(define drag "drag")
(define other-mouse-event "enter")

;; number display
(define NUMBER-X 200)
(define NUMBER-Y 280)
(define FONT-SIZE 24)
(define FONT-COLOR "black")

;; key event
(define n-key "n")
(define other-key "a")
(define space-key " ")


;;;;;;;;;;;;;;;;;;;;; DATA DEFINITIONS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; A Direction is one of

;; -- "right"  Interpretation: right represents the direction towards the right
;;                             boundary of the canvas
;; -- "left"  Interpretation:  left represents the direction towards the left
;;                             boundary of the canvas


;; direction-fn : Direction -> ??

;;(define (direction-fn dir)
;;  (cond    
;;    [(string=? dir "right") ...]
;;    [(string=? dir "left") ...]))


;; ListofBalls

;; A ListOfBalls (LOB) is either
;; -- empty           Interpretation:empty represents an empty list of balls
;; -- (cons Ball LOB) Interpretation:(cons Ball LOB) represents a list of balls

;; template:
;; lob-fn : LOB -> ??
;; (define (lob-fn lob)
;;   (cond
;;     [(empty? lob) ...]
;;     [else (...
;;             (ball-fn (first lob))
;;             (lob-fn (rest lob)))]))

;; EXAMPLE: example follows examples of struct world


(define-struct world (balls speed paused?))
;; A World is a (make-world LOB PosInt Boolean)
;; Interpretation: 
;; balls is the list of balls in the canvas
;; speed is the speed at which any ball created in this world will travel.
;; paused? describes whether or not the world is paused.

;; template:
;; world-fn : World -> ??
;;(define (world-fn w)
;;  (... (world-balls w)
;;       (world-speed w)
;;       (world-paused? w)))

;;; EXAMPLE: 
;;; an unpaused world with no balls and speed of 8
;(define world1 (make-world empty 8 false))

(define-struct ball (x-pos y-pos mx my selected? dir))
;; A Ball is a (make-ball Real Real Integer Integer Boolean Direction)
;; Interpretation:
;; x-pos, y-pos are the coordinate's of the ball's centre
;; mx my are the position of mouse pointer.
;; selected? represents whether the ball is selected or not
;; dir represents the direction in which the ball will travel

;; template:
;; ball-fn : Ball -> ??
;;(define (ball-fn b)
;;  (... (ball-x-pos b)
;;       (ball-y-pos b)
;;       (ball-mx b)
;;       (ball-my b)
;;       (ball-selected? b)
;;       (ball-dir b)))

;; EXAMPLE:
;; a selected ball at the centre
;(define ball1 
;  (make-ball 
;   CENTER-X-COORD CENTER-Y-COORD CENTER-X-COORD CENTER-Y-COORD true))


;;; EXAMPLE: example of LOB, for testing
;;; a list of balls with three unselected balls at the centre moving right
(define lob1
  (list
   (make-ball CENTER-X-COORD CENTER-Y-COORD MOUSE-X MOUSE-Y false "right")
   (make-ball CENTER-X-COORD CENTER-Y-COORD MOUSE-X MOUSE-Y false "right")
   (make-ball CENTER-X-COORD CENTER-Y-COORD MOUSE-X MOUSE-Y false "right")))

;; a list of balls with three selected balls at the centre moving right
(define lob2
  (list
   (make-ball 
    CENTER-X-COORD CENTER-Y-COORD CENTER-X-COORD CENTER-Y-COORD true "right")
   (make-ball 
    CENTER-X-COORD CENTER-Y-COORD CENTER-X-COORD CENTER-Y-COORD true "right")
   (make-ball 
    CENTER-X-COORD CENTER-Y-COORD CENTER-X-COORD CENTER-Y-COORD true "right")))

;;; a list of balls with three unselected balls at the centre moving right,
;;; and the mouse pointer
;;; position is also at the centre of canvas.
;
(define lob3
  (list
   (make-ball 
    CENTER-X-COORD 
    CENTER-Y-COORD CENTER-X-COORD CENTER-Y-COORD false "right")
   (make-ball 
    CENTER-X-COORD 
    CENTER-Y-COORD CENTER-X-COORD CENTER-Y-COORD false "right")
   (make-ball 
    CENTER-X-COORD 
    CENTER-Y-COORD CENTER-X-COORD CENTER-Y-COORD false "right")))


;;;;;;;;;;;;;;;;;;;;; END DATA DEFINITIONS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; initial-world : PosInt -> World
;; GIVEN: a ball speed
;; RETURNS: an unpaused world with no balls,but with the
;; property that any balls created in that world
;; will travel at the given speed.
;; EXAMPLE:
;; (initial-world 8) = (make-world empty 8 false)
;; STRATEGY: function composition

(define (initial-world speed)
  (make-world empty speed false))

;; TEST:

;;; a world with no balls, for testing
(define world1 (make-world empty 8 false))

(begin-for-test
  (check-equal?
   (initial-world 8)
   ;; world1 is an unpaused world with no balls, and speed 8
   world1
   "the initial world is an unpaused world with no balls,
    but has a speed for balls that will be created
    so the list of balls should be empty, unpaused and speed should be 8"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;world-after-tick : World -> World
;;GIVEN: a world
;;RETURNS: the world that should follow the given world after a tick.
;;EXAMPLE: refer tests for example
;;STRATEGY: structural decomposition on w : World

(define (world-after-tick w)
  (if (world-paused? w)
      w
      (make-world 
       (balls-after-tick (world-balls w) (world-speed w))
       (world-speed w)
       false)))

;;TEST: test follow help functions

;;balls-after-tick : LOB PosInt -> LOB
;;GIVEN: a list of balls and ball speed
;;RETURNS: the list of balls after a tick
;;EXAMPLE: (balls-after-tick (list ball1)) = (list ball3)
;;STRATEGY: HOFC 

(define (balls-after-tick lob s)
  (foldr
   ; Ball LOB -> LOB
   ; GIVEN: a ball and a list of balls
   ; RETURNS: a list of balls that should follow after a tick
   (lambda (b rest) (cons (ball-after-tick b s) rest))
   empty
   lob))

;;TEST : test follow help functions

;;ball-after-tick : Ball PosInt -> Ball
;;GIVEN: a ball and ball speed
;;RETURNS: the ball that should follow after a tick
;;EXAMPLE: (ball-after-tick ball1) = ball3
;;STRATEGY: structural decomposition on b:Ball

(define (ball-after-tick b s)
  (ball-after-tick-new-location 
   (ball-x-pos b) 
   (ball-y-pos b) 
   (ball-mx b) 
   (ball-my b) 
   (ball-selected? b) 
   (ball-dir b) s))

;; TEST : test follow help functions

;;ball-after-tick-new-location: 
;;Real Real Integer Integer Boolean Direction PosInt -> Ball
;;GIVEN: x,y coordinate of ball's centre,
;;coordinates of mouse position in ball
;;a value for selected?, direction in which the ball is moving,
;;and ball's speed.
;;RETURNS: a ball that should follow the given ball after tick
;;EXAMPLE: (ball-after-tick-new-location 110 150 0 0 false "right" 8)
;;(make-ball 118 150 0 0 false "right")
;;STRATEGY: function composition

(define (ball-after-tick-new-location x y mx my selected? dir s)
  (if (ball-within-x-boundaries? x)
      (if selected?
          (make-ball x y mx my selected? dir)
          (ball-not-selected-after-tick x y mx my dir s))
      (ball-at-boundary x y mx my selected? dir)))

;;TEST: test follow help functions

;; ball-within-x-boundaries? : Real -> Boolean
;; GIVEN: x coordinate of the ball's centre
;; RETURNS: true iff the ball's centre lies within the right 
;; and left boundaries of the canvas.
;; EXAMPLES:
;; (ball-within-x-boundaries? 200 200) = true
;; (ball-within-x-boundaries? 800 800) = false
;; STRATEGY: function composition

(define (ball-within-x-boundaries? x) 
  (and (>= (- x RADIUS) LEFT) (<= (+ x RADIUS) RIGHT)))

;;TEST : test follow help functions

;;ball-at-boundary: 
;;Real Real Integer Integer Boolean Direction -> Ball
;;GIVEN: x,y coordinate of ball's centre,
;;coordinates of mouse position in ball
;;a value for selected?, direction in which the ball is moving
;;RETURNS: a ball that is bounced from the left or right boundary
;;EXAMPLE: (ball-at-boundary 400 150 0 0 false "right")
;;(make-ball 380 150 0 0 false "left")
;;STRATEGY: function composition

(define (ball-at-boundary x y mx my selected? dir)
  (if (> (+ x RADIUS) RIGHT) 
      (make-ball (- RIGHT RADIUS) y mx my selected? "left")
      (make-ball (+ LEFT RADIUS) y mx my selected? "right")))

;;TEST : test follow help functions

;;ball-not-selected-after-tick: 
;;Real Real Integer Integer Direction PosInt-> Ball
;;GIVEN: x,y coordinate of ball's centre,
;;coordinates of mouse position in ball
;;, direction in which the ball is moving
;;and ball's speed
;;RETURNS: an unselected ball after tick
;;EXAMPLE: (ball-not-selected-after-tick 110 150 0 0 "right" 8)
;;(make-ball 118 150 0 0 false "right")
;;STRATEGY: structural decomposition on dir : Direction

(define (ball-not-selected-after-tick x y mx my dir s)
  (cond
    [(string=? dir "right") 
     (ball-after-tick-moving-right x y mx my dir s)]
    [(string=? dir "left") 
     (ball-after-tick-moving-left x y mx my dir s)]))

;;TEST : test follow help functions

;;ball-after-tick-moving-right: 
;;Real Real Integer Integer Direction PosInt-> Ball
;;GIVEN: x,y coordinate of ball's centre,
;;coordinates of mouse position in ball
;;, direction in which the ball is moving
;;and ball's speed
;;RETURNS: an unselected ball after tick
;;EXAMPLE: (ball-after-tick-moving-right 110 150 0 0 "right" 8)
;;(make-ball 118 150 0 0 false "right")
;;STRATEGY: function composition

(define (ball-after-tick-moving-right x y mx my dir s)
  (if (> (+ x RADIUS s) RIGHT)
      (make-ball (- RIGHT RADIUS) y  mx my false "left")
      (make-ball (+ x s) y mx my false dir)))

;;TEST : test follow help functions

;;ball-after-tick-moving-left: 
;;Real Real Integer Integer Direction PosInt-> Ball
;;GIVEN: x,y coordinate of ball's centre,
;;coordinates of mouse position in ball
;;, direction in which the ball is moving
;;and ball's speed
;;RETURNS: an unselected ball after tick
;;EXAMPLE: (ball-after-tick-moving-left 110 150 0 0 "left" 8)
;;(make-ball 102 150 0 0 false "left")
;;STRATEGY: function composition

(define (ball-after-tick-moving-left x y mx my dir s)
  (if (< (- x RADIUS s)  LEFT)
      (make-ball (+ LEFT RADIUS) y  mx my false "right")
      (make-ball (- x s) y mx my false dir)))

;;TEST :

;;examples of ball for testing

;; a selected ball at the centre
(define ball1 
  (make-ball 
   CENTER-X-COORD CENTER-Y-COORD CENTER-X-COORD CENTER-Y-COORD true "right"))

;; an unselected ball at the centre, moving right
(define ball2 
  (make-ball CENTER-X-COORD CENTER-Y-COORD MOUSE-X MOUSE-Y false "right"))

;; an unselected ball at the centre, moving right
(define ball3 
  (make-ball 
   CENTER-X-COORD CENTER-Y-COORD CENTER-X-COORD CENTER-Y-COORD false "right"))

;; an unselected ball at the centre, moving right
(define ball4 
  (make-ball 
   (+ CENTER-X-COORD 8) 
   CENTER-Y-COORD CENTER-X-COORD CENTER-Y-COORD false "right"))

;; an unselected ball at the centre, moving left
(define ball14 
  (make-ball 
   CENTER-X-COORD CENTER-Y-COORD CENTER-X-COORD CENTER-Y-COORD false "left"))

;; an unselected ball at the centre, moving left
(define ball15 
  (make-ball 
   (- CENTER-X-COORD 8) 
   CENTER-Y-COORD CENTER-X-COORD CENTER-Y-COORD false "left"))


;; ball not selected at right boundary
(define ball5 
  (make-ball 
    RIGHT CENTER-Y-COORD CENTER-X-COORD CENTER-Y-COORD false "right"))

;; ball not selected after bouncing from right boundary
(define ball6 
  (make-ball 
   (- RIGHT RADIUS) 
   CENTER-Y-COORD CENTER-X-COORD CENTER-Y-COORD false "left"))

;; selected ball at right boundary
(define ball7 
  (make-ball 
    RIGHT CENTER-Y-COORD CENTER-X-COORD CENTER-Y-COORD true "right"))

;; selected ball after  bouncing from right boundary
(define ball8 
  (make-ball 
   (- RIGHT RADIUS) CENTER-Y-COORD CENTER-X-COORD CENTER-Y-COORD true "left"))

;; ball not selected at left boundary
(define ball9 
  (make-ball 
    LEFT CENTER-Y-COORD CENTER-X-COORD CENTER-Y-COORD false "left"))

;; ball not selected after bouncing from left boundary
(define ball10 
  (make-ball 
   (+ LEFT RADIUS) CENTER-Y-COORD CENTER-X-COORD CENTER-Y-COORD false "right"))

;; selected ball at left boundary
(define ball11 
  (make-ball 
    LEFT CENTER-Y-COORD CENTER-X-COORD CENTER-Y-COORD true "left"))

;; selected ball after  bouncing from left boundary
(define ball12
  (make-ball 
   (+ LEFT RADIUS) CENTER-Y-COORD CENTER-X-COORD CENTER-Y-COORD true "right"))

;; unselected ball moving right
(define ball16
  (make-ball 
   370 CENTER-Y-COORD CENTER-X-COORD CENTER-Y-COORD false "right"))

;; unselected ball after  bouncing from right boundary
(define ball17
  (make-ball 
   (- RIGHT RADIUS) CENTER-Y-COORD CENTER-X-COORD CENTER-Y-COORD false "left"))

;; unselected ball moving left
(define ball18
  (make-ball 
   25 CENTER-Y-COORD CENTER-X-COORD CENTER-Y-COORD false "left"))

;; unselected ball after  bouncing from left boundary
(define ball19
  (make-ball 
   (+ LEFT RADIUS) CENTER-Y-COORD CENTER-X-COORD CENTER-Y-COORD false "right"))


;; exmples of world, for testing

(define world2 (make-world empty 8 true))
(define world3 (make-world (list ball1) 8 false))
(define world4 (make-world (list ball3) 8 false))
(define world5 (make-world (list ball4) 8 false))
(define world6 (make-world (list ball5) 8 false))
(define world7 (make-world (list ball6) 8 false))
(define world8 (make-world (list ball7) 8 false))
(define world9 (make-world (list ball8) 8 false))
(define world10 (make-world (list ball9) 8 false))
(define world11 (make-world (list ball10) 8 false))
(define world12 (make-world (list ball11) 8 false))
(define world13 (make-world (list ball12) 8 false))
(define world14 (make-world (list ball14) 8 false))
(define world15 (make-world (list ball15) 8 false))
(define world16 (make-world (list ball16) 25 false))
(define world17 (make-world (list ball17) 25 false))
(define world18 (make-world (list ball18) 25 false))
(define world19 (make-world (list ball19) 25 false))
(define world20 (make-world (list ball2) 8 true))


(begin-for-test
  (check-equal?
   (world-after-tick world2)
   world2
   "the paused world should remain same")
  (check-equal?
   (world-after-tick world3)
   world3
   "the ball is selected so the world will remain same")
  (check-equal?
   (world-after-tick world4)
   world5
   "the ball in the world should move in the right direction with catspeed")
  (check-equal?
   (world-after-tick world6)
   world7
   "the unselected ball will bounce from right wall and start moving left")
  (check-equal?
   (world-after-tick world8)
   world9
   "the selected ball will bounce from right wall and start moving left 
    when unselected")
  (check-equal?
   (world-after-tick world10)
   world11
   "the unselected ball will bounce from left wall and  start moving righ")
  (check-equal?
   (world-after-tick world12)
   world13
   "the selected ball will bounce from left wall and  start moving right
    when unselected")
  (check-equal?
   (world-after-tick world14)
   world15
   "the unselected ball will move with catspeed in left direction")
  (check-equal?
   (world-after-tick world16)
   world17
   "the unselected ball moving right will bounce from right wall 
    and start moving left")
  (check-equal?
   (world-after-tick world18)
   world19
   "the unselected ball moving left will bounce from left wall 
    and start moving right"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; world-to-scene : World -> Scene
;; GIVEN: a world
;; RETURNS: a Scene that portrays the given world.
;; EXAMPLE: (world-to-scene (make-world empty 8 false))
;;          = (place-image 
;;             (text (number->string 0) 24 "black") 200 280 EMPTY-CANVAS)
;; STRATEGY: structural decomposition on w: World

(define (world-to-scene w)
  (place-image 
   (text  (number-of-balls w) FONT-SIZE FONT-COLOR) 
   NUMBER-X 
   NUMBER-Y 
   (draw-list-of-balls (world-balls w))))              
  
;; TESTS: tests follow help function

;; number-of-balls: World -> NonNegInt
;; GIVEN: a world
;; RETURNS: the number of balls present in the world
;; EXAMPLE: 
;; (number-of-balls world1) = 0
;; world1 is a world with no balls.
;; STRATEGY: structural decomposition on w : world

(define (number-of-balls w)
  (number->string (length (world-balls w))))

;; TESTS: tests follow help functions

;; draw-list-of-balls: LOB -> Scene
;; GIVEN: a list of balls
;; RETURNS: a scene with the images of balls on the list.
;; EXAMPLE: 
;; (draw-list-of-balls (list ball1))= 
;; (place-image 
;;  (ball-image ball1) (image-x ball1) (image-y ball1) EMPTY-CANVAS)
;; ball1 is a selected ball at the centre of canvas
;; STRATEGY: HOFC

(define (draw-list-of-balls lob)
  (foldr
   ; Ball Scene -> Scene
   ; GIVEN: a ball and a scene 
   ; RETURNS: a scene with image of ball drawn to it
   (lambda (b rest-scene) (place-image (ball-image b) (image-x b) 
                                       (image-y b) rest-scene))
   EMPTY-CANVAS
   lob))

;; TESTS: tests follow help functions

;; ball-image: Ball -> Image
;; GIVEN: a ball
;; RETURNS: a solid image of ball if the ball is selected else returns
;; an outline image of ball.
;; EXAMPLE: (ball-image ball1) = SOLID-BALL-IMAGE
;; ball1 is a selected ball at the centre of canvas
;; STRATEGY: structural decomposition on b : Ball

(define (ball-image b)
  (if (ball-selected? b)
      SOLID-BALL-IMAGE
      OUTLINE-BALL-IMAGE))

;; TEST: tests follow help functions

;; image-x: Ball -> Integer
;; GIVEN: a ball
;; RETURNS: x coordinate of the centre of ball
;; EXAMPLE: (image-x ball1) = 200
;; ball1 is located at the centre of canvas
;; STRATEGY: structural decomposition on b : Ball

(define (image-x b)
  (ball-x-pos b))

;; TEST: tests follow help functions

;; image-y: Ball -> Integer
;; GIVEN: a ball
;; RETURNS: y coordinate of the centre of ball
;; EXAMPLE: (image-y ball1) = 150
;; ball1 is located at the centre of canvas
;; STRATEGY: structural decomposition on b : Ball

(define (image-y b)
  (ball-y-pos b))

;; TESTS:

;;examples for test

(define initial-world-image 
  (place-image 
   (text "0" FONT-SIZE FONT-COLOR) 
   NUMBER-X 
   NUMBER-Y 
   EMPTY-CANVAS))

(define world2-image 
  (place-image 
   (text "1" FONT-SIZE FONT-COLOR) 
   NUMBER-X 
   NUMBER-Y 
   (place-image 
    OUTLINE-BALL-IMAGE CENTER-X-COORD CENTER-Y-COORD EMPTY-CANVAS)))

(define world3-image 
  (place-image 
   (text "1" FONT-SIZE FONT-COLOR) 
   NUMBER-X 
   NUMBER-Y 
   (place-image 
    SOLID-BALL-IMAGE CENTER-X-COORD CENTER-Y-COORD EMPTY-CANVAS)))

;; test

(begin-for-test
  (check-equal?
   (world-to-scene world1)
   initial-world-image
   "an empty canvas with the image of 0 on it should be returned")
  (check-equal?
   (world-to-scene world20)
   world2-image
   "image of an outline ball and image of 1 should be displayed on the canvas")
  (check-equal?
   (world-to-scene world3)
   world3-image
   "image of a solid ball and image of 1 should be displayed on the canvas"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; world-after-mouse-event : World Integer Integer MouseEvent -> World
;; GIVEN: a world, x and y coordinates of the mouse pointer, and a mouse event 
;; RETURNS: the world that should follow the given mouse event
;; EXAMPLE: refer tests for example.
;; STRATEGY: Cases on MouseEvent

(define (world-after-mouse-event w mx my mev)
  (cond
    [(mouse=? mev "button-down") (world-after-button-down w mx my)]
    [(mouse=? mev "drag") (world-after-drag w mx my)]
    [(mouse=? mev "button-up")(world-after-button-up w mx my)]
    [else w]))

;; TESTS: tests follow help functions

;; world-after-button-down : World Integer Integer -> World
;; GIVEN: a world, x and y coordinates of the mouse pointer
;; RETURNS: the world following a button-down at the given location.
;; EXAMPLE: (world-after-button-down world2 CENTRE-X-COORD CENTRE-Y-COORD) 
;; = world3
;; world2 is a world with an unselected ball at the centre of canvas
;; world3 is a world with a selected ball at the centre of canvas
;; STRATEGY: structural decomposition on w: World

(define (world-after-button-down w mx my)
  (make-world (balls-after-button-down 
               (world-balls w) mx my) (world-speed w) (world-paused? w)))

;; TEST: test follow help functions

;; balls-after-button-down : LOB Integer Integer -> LOB
;; GIVEN: a list of balls, x and y coordinates of the mouse pointer
;; RETURNS: a list of balls. If the button down is inside a ball on the list 
;; then that ball becomes selected.
;; EXAMPLE: (balls-after-button-down lob1 CENTRE-X-COORD CENTRE-Y-COORD) 
;; = lob2
;; lob1 is a list of unselected balls at the centre, and lob2 is a list of 
;; selected balls at the centre.
;; STRATEGY: HOFC

(define (balls-after-button-down lob mx my)
  (foldr
   ; BALL LOB -> LOB
   ; GIVEN: a ball and a list of balls
   ; RETURNS: a list of balls with the ball appended to it. if button down is
   ; inside the ball then the ball becomes selected.
   (lambda (b rest-balls) (cons (if (in-circle? b mx my) 
                              (select-ball b mx my) 
                              b) 
                          rest-balls))
   empty
   lob))

;; TEST: test follow help functions

;; in-circle? : Ball Integer Integer -> Boolean
;; GIVEN: a ball, x and y coordinates of the mouse pointer.
;; RETURNS: true iff the given coordinate is inside the ball.
;; EXAMPLE: (in-circle? ball1 CENTRE-X-COORD CENTRE-Y-COORD) = true
;; ball1 is located at the centre of the canvas.
;; STRATEGY: structural decomposition on b : Ball

(define (in-circle? b x y)
  (< (+ (sqr (- x (ball-x-pos b))) (sqr (- y (ball-y-pos b)))) (sqr RADIUS)))

;; TESTS: tests follow help functions

;; select-ball : Ball Integer Integer -> Ball
;; GIVEN: a ball, x and y coordinates of the mouse pointer.
;; RETURNS: a ball similar to the given one, but selected.
;; EXAMPLE: (select-ball ball2 CENTRE-X-COORD CENTRE-Y-COORD) = ball1
;; ball2 is an unselected ball at the centre, ball1 is a selected ball 
;; at the centre.
;; STRATEGY: structural decomposition on b : Ball

(define (select-ball b mx my)
  (make-ball (ball-x-pos b) (ball-y-pos b) mx my true (ball-dir b)))
  
;; TESTS: 

; examples of world, for testing
(define world21 (make-world lob1 8 false))
(define world22 (make-world lob2 8 false))
(define world23 (make-world 
                 (list (make-ball 70 80 0 0 false "right")) 8 false)) 

(begin-for-test
  (check-equal?
   ;; the balls in world21 are unselected before the button down
   ;; 200 150 is a point inside the balls
   (world-after-mouse-event world21 200 150 button-down)
   world22
   "the balls in world should be selected after button down mouse event")
  (check-equal?
   ;; the ball in world23 is unselected
   ;; 200 150 is a point outside the ball in the world
   (world-after-mouse-event world23 200 150 button-down)
   world23
   "the ball in the world should remain unselected"))   

;; world-after-drag : World Integer Integer -> World
;; GIVEN: a world and x,y coordinate of mouse pointer
;; RETURNS: the world following a drag at the given location.
;; EXAMPLE: refer tests below
;; STRATEGY: structural decomposition on w: World

(define (world-after-drag w mx my)
  (make-world (balls-after-drag 
               (world-balls w) mx my) (world-speed w) (world-paused? w))) 

;; TESTS : tests follow help functions

;; balls-after-drag : LOB Integer Integer -> LOB
;; GIVEN: a list of balls, and x,y coordinate of mouse pointer
;; RETURNS: a list of balls after the drag mouse event. if a ball
;; on the list is dragged then the coordinates of ball's centre
;; changes relative to the new mouse pointer location.
;; EXAMPLE: (balls-after-drag lob3 300 170) = lob4
;; lob3 is the list of balls before drag and lob4 is the list of 
;; balls after drag.
;; refer test for further explanation.
;; STRATEGY: HOFC

(define (balls-after-drag lob mx my)
  (foldr
   ; Ball LOB -> LOB
   ; GIVEN: a ball and a list of balls
   ; RETURNS: a list of ball with the given ball appended to it. 
   ; If the ball is dragged then the ball with the modified 
   ; location is appended to list.
   (lambda (b rest) (cons (if (is-ball-selected? b) 
                              (ball-after-drag b mx my) 
                              b) 
                          rest))
   empty
   lob))

;; TEST: tests follow help functions

;; is-ball-selected? : Ball -> Boolean
;; GIVEN: a Ball
;; RETURNS: true if the ball is selected, false otherwise.
;; EXAMPLE: (is-ball-selected? ball1) =true
;; ball1 is a selected ball
;; STRATEGY: structural decomposition on b : Ball

(define (is-ball-selected? b)
  (ball-selected? b))

;; TEST: test follow help functions

;; ball-after-drag : Ball Integer Integer -> Ball
;; GIVEN: a ball, and x,y coordinates of mouse pointer.
;; RETURNS: a ball after drag mouse event.
;; EXAMPLE: (ball-after-drag (make-ball 200 150 19 145 true)) =
;; (make-ball 305 225 300 170 true)
;; STRATEGY: structural decomposition on b : Ball

(define (ball-after-drag b mx my)
  (ball-after-drag-helper 
   (ball-x-pos b) (ball-y-pos b) (ball-mx b) 
   (ball-my b) true mx my (ball-dir b)))

;; ball-after-drag-helper : 
;; Real Real Integer Integer Boolean Integer Integer Direction -> Ball
;; GIVEN: x and y coordinates of ball's centre 
;; and old mouse pointer x,y position, 
;; a value for selected?
;; x,y coordinate of new mouse pointer position.
;; and direction of the ball
;; RETURNS: the ball following a drag at the given location.
;; EXAMPLE: (ball-after-drag-helper 200 150 195 145 true 300 170 "right") = 
;; (make-ball 305 225 300 170 true "right")
;; STRATEGY: function composition

(define (ball-after-drag-helper x y old-mx old-my selected? new-mx new-my dir) 
  (make-ball (+ x (- new-mx old-mx)) 
             (- y (- old-my new-my)) 
             new-mx
             new-my
             selected?
             dir))

;; TESTS:

;; examples of lob for testing

;; a list of balls before drag
(define lob5
  (list
   (make-ball 200 150 195 145 true "right")
   (make-ball 80 200 MOUSE-X MOUSE-Y false "right")
   (make-ball 80 50 MOUSE-X MOUSE-Y false "right")))

;;  a list of balls after drag
(define lob4
  (list
   (make-ball 305 175 300 170 true "right")
   (make-ball 80 200 MOUSE-X MOUSE-Y false "right")
   (make-ball 80 50 MOUSE-X MOUSE-Y false "right")))

;; examples of world for testing
(define world24 (make-world lob5 8 false))
(define world25 (make-world lob4 8 false))

;; test

(begin-for-test
  (check-equal?
   ;; 300 170 is the new mouse pointer position
   (world-after-mouse-event world24 300 170 drag)
   world25
   "the location of the ball in the world should change 
    relative to the given mouse pointer position"))

;; world-after-button-up : World Integer Integer -> World
;; GIVEN: a world and x,y coordinate of mouse pointer
;; RETURNS: the world following a button-up at the given location.
;; EXAMPLE: refer tests for example
;; STRATEGY: structural decomposition on w: World

(define (world-after-button-up w mx my)
  (make-world (balls-after-button-up 
               (world-balls w) mx my) (world-speed w) (world-paused? w)))

;; TEST: test follow help functions

;; balls-after-button-up : LOB Integer Integer -> LOB
;; GIVEN: a list of balls and x,y coordinate of mouse pointer
;; RETURNS: the list of balls following a button-up at the given location.
;; EXAMPLE: (balls-after-button-up lob2 MOUSE-X MOUSE-Y) = lob1
;; lob2 is a selected world, lob1 is an unselected world.
;; STRATEGY: HOFC

(define (balls-after-button-up lob mx my)
  (foldr
   ; Ball LOB -> LOB
   ; GIVEN: a ball and a list of balls
   ; RETURNS: a list of balls with the given ball appended to it following 
   ; a button up, if the ball is selected then it becomes unselected
   (lambda (b rest) (cons (if (is-ball-selected? b) 
                              (ball-after-button-up b mx my) 
                              b) 
                          rest))
   empty
   lob))

;; TEST: test follow help functions

;; ball-after-button-up : Ball Integer Integer -> Ball
;; GIVEN: a ball and x,y coordinate of mouse pointer
;; RETURNS: a ball following a button-up at the given location.
;; EXAMPLE: (ball-after-button-up ball1 CENTRE-X-COORD CENTRE-Y-COORD) = ball2
;; ball1 is a selected ball, ball2 is an unselected ball
;; STRATEGY: structural decomposition on b : Ball

(define (ball-after-button-up b mx my)
  (make-ball (ball-x-pos b) (ball-y-pos b) mx my false (ball-dir b)))

;; TESTS:

; examples of world, for testing
(define world26 (make-world lob2 8 false))
(define world27 (make-world lob3 8 false))
(define world28 (make-world 
                 (list (make-ball 70 80 0 0 false "right")) 8 false)) 

(begin-for-test
  (check-equal?
   ;; the balls in world26 are selected before the button up
   ;; 200 150 is a point inside the balls
   (world-after-mouse-event world26 200 150 button-up)
   world27
   "the balls in world should get unselected after button up mouse event")
  (check-equal?
   ;; the ball in world23 is unselected
   ;; 200 150 is a point outside the ball in the world
   (world-after-mouse-event world23 200 150 button-up)
   world28
   "the ball in the world should remain unselected")
  (check-equal?
   ;; 200 150 is any location
   (world-after-mouse-event world28 200 150 other-mouse-event)
   world28
   "the world should not respond to any other mouse event"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   
; world-after-key-event : World KeyEvent -> World
;; GIVEN: a world, and a key event 
;; RETURNS: the world that should follow the given key event
;; EXAMPLE: refer tests for example.
;; STRATEGY: Cases on KeyEvent

(define (world-after-key-event w kev)
  (cond
    [(key=? kev "n")
     (world-after-n-key-event w)]
    [(key=? kev " ") (world-with-paused-toggled w)]
    [else w]))
  
;; world-with-paused-toggled : World -> World
;; GIVEN: a world w
;; RETURNS: a world just like the given one, but with paused? toggled
;; EXAMPLES: refer tests below.
;; STRATEGY: structural decomposition on w : World

(define (world-with-paused-toggled w)
  (make-world
   (world-balls w)
   (world-speed w)
   (not (world-paused? w))))


;; TESTS : tests follow helper functions

;; world-after-n-key-event : World -> World
;; GIVEN: a world
;; RETURNS: the world that should follow the key event n
;; EXAMPLE: (world-after-key-event-helper world1) = world2
;; world1 is a world with no balls and world2 is a world 
;; with one unselected ball at the centre
;; STRATEGY: structural decomposition on w : World

(define (world-after-n-key-event w)
  (make-world (world-after-new-balls 
               (world-balls w)) (world-speed w) (world-paused? w)))

;; TESTS: tests follow helper functions

;; world-after-new-balls : LOB -> LOB
;; GIVEN: a list of balls
;; RETURNS: the list of balls with a new unselected ball at the
;; centre of canvas appended to the list 
;; EXAMPLE: (world-after-new-balls empty) = 
;; (list (make-ball CENTRE-X-COORD CENTRE-Y-COORD MOUSE-X MOUSE-Y false))
;; STRATEGY: function composition

(define (world-after-new-balls lob)
  (cons (make-ball 
         CENTER-X-COORD CENTER-Y-COORD MOUSE-X MOUSE-Y false "right") lob))

;; TESTS
;;examples of world for testing
(define world29 
  (make-world 
   (list 
    (make-ball 
     CENTER-X-COORD CENTER-Y-COORD MOUSE-X MOUSE-Y false "right")) 8 false))
(define world30 
  (make-world 
   (list 
    (make-ball 
     CENTER-X-COORD CENTER-Y-COORD MOUSE-X MOUSE-Y false "right")) 8 true))

;;test
(begin-for-test
  (check-equal?
   (world-after-key-event world1 n-key)
   world29
   "a new ball should be added to the world at the centre of canvas")
  (check-equal?
   (world-after-key-event world1 other-key)
   world1
   "the world should remain unchanged")
  (check-equal?
   (world-after-key-event world29 space-key)
   world30
   "the world will be paused"))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



