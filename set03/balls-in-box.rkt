;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname balls-in-box) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))

;; balls-in-box
;; a user can drag the balls in box with the mouse.
;; button-down to select, drag to move, button-up to release.
;; key n to create new ball.
;; The balls are displayed as a circle with radius 20. 
;; An unselected ball is displayed as an outline; a selected ball 
;; is displayed solid.
;; In addition to the balls, the number of balls currently on the canvas
;; is also displayed.

;; run with (run 0)

(require 2htdp/universe)
(require 2htdp/image)
(require rackunit)
(require "extras.rkt")

(provide run)
(provide initial-world)
(provide world-after-key-event)
(provide world-after-mouse-event)
(provide world-balls)
(provide ball-x-pos)
(provide ball-y-pos)
(provide ball-selected?)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; RUN FUNCTION.

;; run : Any -> World
;; GIVEN: An argument, which is ignored.
;; EFFECT: runs the world.
;; RETURNS: the final state of the world.
;; EXAMPLE: 
;; (run 0) = starts the simulation with the rectangle positioned at the centre
;;           of the canvas and returns final state of the world, similar to
;;           this, (make-world (list (make-ball 200 150 0 0 false)))
;; STRATEGY: function composition

(define (run any-value)
  (big-bang (initial-world any-value)
            (on-draw world-to-scene)
            (on-key world-after-key-event)
            (on-mouse world-after-mouse-event)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;CONSTANTS

;;dimensions of the canvas
(define SCENE-WIDTH 400)
(define SCENE-HEIGHT 300)

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
(define other-key " ")


;;;;;;;;;;;;;;;;;;;;; DATA DEFINITIONS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ListofBalls

;; A ListOfBalls (LOB) is either
;; -- empty           Interpretation:empty represents an empty list
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


(define-struct world (balls))
;; A World is a (make-world LOB)
;; Interpretation: 
;; balls is the list of balls in the canvas

;; template:
;; world-fn : World -> ??
;;(define (world-fn w)
;; (... (world-balls w)))

;; EXAMPLES: example follow examples of struct ball

(define-struct ball (x-pos y-pos mx my selected?))
;; A Ball is a (make-ball Integer Integer Integer Integer Boolean)
;; Interpretation:
;; x-pos, y-pos are the coordinate's of the ball's centre
;; mx my are the position of mouse pointer.
;; selected? represents whether the ball is selected or not

;; template:
;; ball-fn : Ball -> ??
;;(define (ball-fn b)
;;  (... (ball-x-pos b)
;;       (ball-y-pos b)
;;       (ball-mx b)
;;       (ball-my b)
;;       (ball-selected? b)))

;; EXAMPLES:
;; a selected ball at the centre
(define ball1 
  (make-ball 
   CENTER-X-COORD CENTER-Y-COORD CENTER-X-COORD CENTER-Y-COORD true))
;; an unselected ball at the centre
(define ball2 
  (make-ball CENTER-X-COORD CENTER-Y-COORD MOUSE-X MOUSE-Y false))

;; an unselected ball at the centre
(define ball3 
  (make-ball 
   CENTER-X-COORD CENTER-Y-COORD CENTER-X-COORD CENTER-Y-COORD false))

;; EXAMPLES: examples of world
;; a world with no balls
(define world1 (make-world empty))
;; a world with an unselected ball at the centre
(define world2 
  (make-world
   (list 
    (make-ball CENTER-X-COORD CENTER-Y-COORD MOUSE-X MOUSE-Y false))))
;; a world with a selected ball at the centre
(define world3 
  (make-world
   (list 
    (make-ball 
     CENTER-X-COORD CENTER-Y-COORD CENTER-X-COORD CENTER-Y-COORD true))))

;; EXAMPLE: example of LOB
;; a list of balls with three unselected balls at the centre
(define lob1
  (list
   (make-ball CENTER-X-COORD CENTER-Y-COORD MOUSE-X MOUSE-Y false)
   (make-ball CENTER-X-COORD CENTER-Y-COORD MOUSE-X MOUSE-Y false)
   (make-ball CENTER-X-COORD CENTER-Y-COORD MOUSE-X MOUSE-Y false)))

;; a list of balls with three selected balls at the centre
(define lob2
  (list
   (make-ball 
    CENTER-X-COORD CENTER-Y-COORD CENTER-X-COORD CENTER-Y-COORD true)
   (make-ball 
    CENTER-X-COORD CENTER-Y-COORD CENTER-X-COORD CENTER-Y-COORD true)
   (make-ball 
    CENTER-X-COORD CENTER-Y-COORD CENTER-X-COORD CENTER-Y-COORD true)))

;; a list of balls with three unselected balls at the centre, 
;; and the mouse pointer
;; position is also at the centre of canvas.

(define lob3
  (list
   (make-ball 
    CENTER-X-COORD CENTER-Y-COORD CENTER-X-COORD CENTER-Y-COORD false)
   (make-ball 
    CENTER-X-COORD CENTER-Y-COORD CENTER-X-COORD CENTER-Y-COORD false)
   (make-ball 
    CENTER-X-COORD CENTER-Y-COORD CENTER-X-COORD CENTER-Y-COORD false)))


;;;;;;;;;;;;;;;;;;;;; END DATA DEFINITIONS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; initial-world : Any -> World
;; GIVEN: An argument, which is ignored.
;; RETURNS: a world with no balls.
;; EXAMPLE:
;; (initial-world 0)= (make-world empty)
;; STRATEGY: function composition

(define (initial-world any-value)
  (make-world empty))

;; TEST:

(begin-for-test
  (check-equal?
   (initial-world 0)
   ;; world1 is a world with no balls
   world1
   "the initial world is a world with no balls,
    so the list of balls should be empty"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; world-to-scene : World -> Scene
;; GIVEN: a world
;; RETURNS: a Scene that portrays the given world.
;; EXAMPLE: (world-to-scene (make-world empty))
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
;; RETURNS: a Scene with the images of balls on the list.
;; EXAMPLE: 
;; (draw-list-of-balls (list ball1))= 
;; (place-image 
;;  (ball-image ball1) (image-x ball1) (image-y ball1) EMPTY-CANVAS)
;; ball1 is a selected ball at the centre of canvas
;; STRATEGY: structural decomposition on lob : LOB

(define (draw-list-of-balls lob)
  (cond
    [(empty? lob) EMPTY-CANVAS]
    [else (place-image (ball-image (first lob)) 
                       (image-x (first lob)) 
                       (image-y (first lob))
                       (draw-list-of-balls (rest lob)))]))

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
   (world-to-scene world2)
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
  (make-world (balls-after-button-down (world-balls w) mx my)))

;; TEST: test follow help functions

;; balls-after-button-down : LOB Integer Integer -> LOB
;; GIVEN: a list of balls, x and y coordinates of the mouse pointer
;; RETURNS: a list of balls. If the button down is inside a ball on the list 
;; then that ball becomes selected.
;; EXAMPLE: (balls-after-button-down lob1 CENTRE-X-COORD CENTRE-Y-COORD) 
;; = lob2
;; lob1 is a list of unselected balls at the centre, and lob2 is a list of 
;; selected balls at the centre.
;; STRATEGY: structural decomposition on lob : LOB

(define (balls-after-button-down lob mx my)
  (cond
    [(empty? lob) empty]
    [else (cons (if (in-circle? (first lob) mx my)
                    (select-ball (first lob) mx my)
                    (first lob))
                (balls-after-button-down (rest lob) mx my))]))

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
  (make-ball (ball-x-pos b) (ball-y-pos b) mx my true))
  
;; TESTS: 

;; examples of world, for testing
(define world4 (make-world lob1))
(define world5 (make-world lob2))
(define world6 (make-world (list (make-ball 70 80 0 0 false))))

(begin-for-test
  (check-equal?
   ;; the balls in world4 are unselected before the button down
   ;; 200 150 is a point inside the balls
   (world-after-mouse-event world4 200 150 button-down)
   world5
   "the balls in world should be selected after button down mouse event")
  (check-equal?
   ;; the ball in world6 is unselected
   ;; 200 150 is a point outside the ball in the world
   (world-after-mouse-event world6 200 150 button-down)
   world6
   "the ball in the world should remain unselected"))   

;; world-after-drag : World Integer Integer -> World
;; GIVEN: a world and x,y coordinate of mouse pointer
;; RETURNS: the world following a drag at the given location.
;; EXAMPLE: refer tests below
;; STRATEGY: structural decomposition on w: World

(define (world-after-drag w mx my)
  (make-world (balls-after-drag (world-balls w) mx my))) 

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
;; STRATEGY: structural decomposition on lob : LOB

(define (balls-after-drag lob mx my)
  (cond
    [(empty? lob) empty]
    [else (cons (if (is-ball-selected? (first lob))
                    (ball-after-drag (first lob) mx my)
                    (first lob))
                (balls-after-drag (rest lob) mx my))]))

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
   (ball-x-pos b) (ball-y-pos b) (ball-mx b) (ball-my b) true mx my))

;; ball-after-drag-helper : 
;; Integer Integer Integer Integer Boolean Integer Integer -> Ball
;; GIVEN: x and y coordinates of ball's centre 
;; and old mouse pointer x,y position, 
;; a value for selected?
;; and x,y coordinate of new mouse pointer position.
;; RETURNS: the ball following a drag at the given location.
;; EXAMPLE: (ball-after-drag-helper 200 150 195 145 true 300 170) = 
;; (make-ball 305 225 300 170 true)
;; STRATEGY: function composition

(define (ball-after-drag-helper x y old-mx old-my selected? new-mx new-my) 
  (make-ball (+ x (- new-mx old-mx)) 
             (- y (- old-my new-my)) 
             new-mx
             new-my
             selected?))

;; TESTS:

;; examples of lob for testing

;; a list of balls before drag
(define lob5
  (list
   (make-ball 200 150 195 145 true)
   (make-ball 80 200 MOUSE-X MOUSE-Y false)
   (make-ball 80 50 MOUSE-X MOUSE-Y false)))

;;  a list of balls after drag
(define lob4
  (list
   (make-ball 305 175 300 170 true)
   (make-ball 80 200 MOUSE-X MOUSE-Y false)
   (make-ball 80 50 MOUSE-X MOUSE-Y false)))

;; examples of world for testing
(define world7 (make-world lob5))
(define world8 (make-world lob4))

;; test

(begin-for-test
  (check-equal?
   ;; 300 170 is the new mouse pointer position
   (world-after-mouse-event world7 300 170 drag)
   world8
   "the location of the ball in the world should change 
    relative to the given mouse pointer position"))

;; world-after-button-up : World Integer Integer -> World
;; GIVEN: a world and x,y coordinate of mouse pointer
;; RETURNS: the world following a button-up at the given location.
;; EXAMPLE: refer tests for example
;; STRATEGY: structural decomposition on w: World

(define (world-after-button-up w mx my)
  (make-world (balls-after-button-up (world-balls w) mx my)))

;; TEST: test follow help functions

;; balls-after-button-up : LOB Integer Integer -> LOB
;; GIVEN: a list of balls and x,y coordinate of mouse pointer
;; RETURNS: the list of balls following a button-up at the given location.
;; EXAMPLE: (balls-after-button-up lob2 MOUSE-X MOUSE-Y) = lob1
;; lob2 is a selected world, lob1 is an unselected world.
;; STRATEGY: structural decomposition on lob : LOB

(define (balls-after-button-up lob mx my)
  (cond
    [(empty? lob) empty]
    [else (cons (if (is-ball-selected? (first lob))
                     (ball-after-button-up (first lob) mx my)
                     (first lob))
              (balls-after-button-up (rest lob) mx my))]))

;; TEST: test follow help functions

;; ball-after-button-up : Ball Integer Integer -> Ball
;; GIVEN: a ball and x,y coordinate of mouse pointer
;; RETURNS: a ball following a button-up at the given location.
;; EXAMPLE: (ball-after-button-up ball1 CENTRE-X-COORD CENTRE-Y-COORD) = ball2
;; ball1 is a selected ball, ball2 is an unselected ball
;; STRATEGY: structural decomposition on b : Ball

(define (ball-after-button-up b mx my)
  (make-ball (ball-x-pos b) (ball-y-pos b) mx my false))

;; TESTS:

;; examples of world, for testing
(define world9 (make-world lob2))
(define world10 (make-world lob3))
(define world11 (make-world (list (make-ball 70 80 0 0 false))))

(begin-for-test
  (check-equal?
   ;; the balls in world9 are selected before the button up
   ;; 200 150 is a point inside the balls
   (world-after-mouse-event world9 200 150 button-up)
   world10
   "the balls in world should get unselected after button up mouse event")
  (check-equal?
   ;; the ball in world6 is unselected
   ;; 200 150 is a point outside the ball in the world
   (world-after-mouse-event world6 200 150 button-up)
   world11
   "the ball in the world should remain unselected")
  (check-equal?
   ;; 200 150 is any location
   (world-after-mouse-event world11 200 150 other-mouse-event)
   world11
   "the world should not respond to any other mouse event"))
   
;; world-after-key-event : World KeyEvent -> World
;; GIVEN: a world, and a key event 
;; RETURNS: the world that should follow the given key event
;; EXAMPLE: refer tests for example.
;; STRATEGY: Cases on KeyEvent

(define (world-after-key-event w kev)
  (cond
    [(key=? kev "n")
     (world-after-key-event-helper w)]
    [else w]))

;; TESTS : tests follow helper functions

;; world-after-key-event-helper : World -> World
;; GIVEN: a world
;; RETURNS: the world that should follow the key event n
;; EXAMPLE: (world-after-key-event-helper world1) = world2
;; world1 is a world with no balls and world2 is a world 
;; with one unselected ball at the centre
;; STRATEGY: structural decomposition on w : World

(define (world-after-key-event-helper w)
  (make-world (world-after-new-balls (world-balls w))))

;; TESTS: tests follow helper functions

;; world-after-new-balls : LOB -> LOB
;; GIVEN: a list of balls
;; RETURNS: the list of balls with a new unselected ball at the
;; centre of canvas appended to the list 
;; EXAMPLE: (world-after-new-balls empty) = 
;; (list (make-ball CENTRE-X-COORD CENTRE-Y-COORD MOUSE-X MOUSE-Y false))
;; STRATEGY: function composition

(define (world-after-new-balls lob)
  (cons (make-ball CENTER-X-COORD CENTER-Y-COORD MOUSE-X MOUSE-Y false) lob))

;; TESTS

(begin-for-test
  (check-equal?
   (world-after-key-event world1 n-key)
   world2
   "a new ball should be added to the world at the centre of canvas")
  (check-equal?
   (world-after-key-event world1 other-key)
   world1
   "the world should remain unchanged"))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



