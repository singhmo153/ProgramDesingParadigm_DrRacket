;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname rectangle) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))

;; draggable rectangle.
;; a user can drag the rectangle with the mouse.
;; button-down to select, drag to move, button-up to release.
;; A solid circle is used to indicate the position of mouse
;; pointer on rectangle, when the rectangle is selected.

;; run with (run 0)

(require 2htdp/universe)
(require 2htdp/image)
(require rackunit)
(require "extras.rkt")

(provide run)
(provide initial-world)
(provide world-x)
(provide world-y)
(provide world-selected?)
(provide world-after-mouse-event)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; RUN FUNCTION.

;; run : Any -> World
;; GIVEN: any value
;; EFFECT: ignores its argument and starts the interactive program.
;; RETURNS: the final state of the world.
;; EXAMPLE: 
;; (run 0) = starts the simulation with the rectangle positioned at the centre
;;           of the canvas and returns final state of the world, similar to
;;           this, (make-world 171 167 191 179 false)
;; STRATEGY: function composition

(define (run any-value)
  (big-bang (make-world 
             RECTANGLE-X-COORD RECTANGLE-Y-COORD any-value any-value false)
            (on-draw world-to-scene)
            (on-mouse world-after-mouse-event)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;CONSTANTS

;;dimensions of the canvas
(define SCENE-WIDTH 400)
(define SCENE-HEIGHT 300)

;;color constants
(define RECTANGLE-COLOR "green")
(define CIRCLE-COLOR "red")

;;image constants
(define SOLID-RECTANGLE-IMAGE (rectangle 100 60 "solid" RECTANGLE-COLOR))
(define OUTLINE-RECTANGLE-IMAGE (rectangle 100 60 "outline" RECTANGLE-COLOR))
(define POINTER-CIRCLE-IMAGE (circle 5 "solid" CIRCLE-COLOR))
(define EMPTY-CANVAS (empty-scene SCENE-WIDTH SCENE-HEIGHT))

;;initial position of rectangle's center on the canvas
(define RECTANGLE-X-COORD (/ SCENE-WIDTH 2))
(define RECTANGLE-Y-COORD (/ SCENE-HEIGHT 2))

;;initial mouse pointer position
(define MOUSE-X 0)
(define MOUSE-Y 0)

;;dimensions of the rectangle
(define HALF-RECTANGLE-WIDTH  (/ (image-width  SOLID-RECTANGLE-IMAGE) 2))
(define HALF-RECTANGLE-HEIGHT (/ (image-height SOLID-RECTANGLE-IMAGE) 2))

;;other mouse event
(define button-up "button-up")
(define button-down "button-down")
(define drag "drag")
(define other-mouse-event "enter")

;;;;;;;;;;;;;;;;;;;;; DATA DEFINITIONS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define-struct world (x y mx my selected?))
;; A World is a (make-world Integer Integer Integer Integer Boolean)
;; Interpretation: 
;; x, y give the position of the rectangle's centre.
;; mx, my give the position of the mouse pointer
;; selected? describes whether or not the rectangle is selected.

;; template:
;; world-fn : World -> ??
;;(define (world-fn w)
;; (... (world-x w) 
;;      (world-y w)
;;      (world-mx w) 
;;      (world-my w) 
;;      (world-selected? w)))

;; EXAMPLES:
;; examples for testing

;;rectangle is unselected in this example
(define unselected-world 
  (make-world RECTANGLE-X-COORD RECTANGLE-Y-COORD MOUSE-X MOUSE-Y false))


;;rectangle is selected in this example
(define selected-world 
  (make-world RECTANGLE-X-COORD RECTANGLE-Y-COORD MOUSE-X MOUSE-Y true))



;;;;;;;;;;;;;;;;;;;;; END DATA DEFINITIONS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; initial-world : Any -> World
;; GIVEN: any value
;; RETURNS: the initial world.
;; Ignores its argument.
;; EXAMPLE:
;; (initial-world 0)= (make-world RECTANGLE-X-COORD RECTANGLE-Y-COORD false)
;; STRATEGY: function composition

(define (initial-world any-value)
  (make-world RECTANGLE-X-COORD RECTANGLE-Y-COORD MOUSE-X MOUSE-Y false))

;; TEST:

(begin-for-test
  (check-equal?
   (initial-world 0)
   unselected-world
   "unselected world with the rectangle positioned 
    at the centre was expected"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; world-to-scene : World -> Scene
;; GIVEN: a world
;; RETURNS: a Scene that portrays the given world.
;; EXAMPLE: (world-to-scene (make-world 200 150 true))
;;          = (place-image (rectangle 200 150 "sollid" "green") EMPTY-CANVAS)
;; STRATEGY: structural decomposition on w: World

(define (world-to-scene w)
  (draw-rectangle  
   (world-x w)
   (world-y w)               
   (world-mx w) 
   (world-my w)
   (world-selected? w)))

;; TESTS: tests follow help function

;; draw-rectangle: Integer Integer Integer Integer Boolean Image -> Scene
;; GIVEN: the x-xoordinates and y-coordinates of rectangle's centre and mouse
;; pointer, a boolean value, and an empty canvas image.
;; RETURNS: draws the rectangle on the canvas, in solid mode if slected, 
;; outlined otherwise. if selected then the location of mouse pointer is also
;; drawn.
;; EXAMPLE: refer tests
;; STRATEGY: function composition

(define (draw-rectangle x y mx my selected?)
  (if selected? 
      (place-image POINTER-CIRCLE-IMAGE mx my 
                   (place-image OUTLINE-RECTANGLE-IMAGE x y EMPTY-CANVAS))
      (place-image SOLID-RECTANGLE-IMAGE x y EMPTY-CANVAS)))

;; TESTS:

;;examples for test

(define initial-world-image 
  (place-image 
   SOLID-RECTANGLE-IMAGE RECTANGLE-X-COORD RECTANGLE-Y-COORD EMPTY-CANVAS))

(define pointer-at-center-image 
  (place-image 
   POINTER-CIRCLE-IMAGE 
   RECTANGLE-X-COORD 
   RECTANGLE-Y-COORD
   (place-image 
    OUTLINE-RECTANGLE-IMAGE RECTANGLE-X-COORD RECTANGLE-Y-COORD EMPTY-CANVAS)))


(begin-for-test
  (check-equal?
   (world-to-scene (initial-world 0))
   initial-world-image)
  (check-equal?
   (world-to-scene 
    (make-world 
     RECTANGLE-X-COORD 
     RECTANGLE-Y-COORD 
     RECTANGLE-X-COORD 
     RECTANGLE-Y-COORD 
     true))
   pointer-at-center-image
   "the world-to-scene (initial-world 0) returned an unexpected image"))

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
;; if the button-down is inside the rectangle, return a world just like the
;; given one, except that the rectangle is selected.
;; EXAMPLES: refer tests for example
;; STRATEGY: struct decomposition on w: World

(define (world-after-button-down w mx my)
  (if (in-rectangle? w mx my)
      (make-world (world-x w) 
                  (world-y w)
                  mx 
                  my 
                  true)
      w))

;; TESTS: tests follow help functions

;; in-rectangle? : World Integer Integer -> World
;; GIVEN: a world, x and y coordinates of the mouse pointer.
;; RETURNS: true iff the given coordinate is inside the rectangle.
;; EXAMPLE: (in-rectangle? unselected-world-mouse-pointer-outside 230 155)
;; = true
;; strategy: structural decomposition on w : World

(define (in-rectangle? w x y)
  (and
   (<= 
    (- (world-x w) HALF-RECTANGLE-WIDTH)
    x
    (+ (world-x w) HALF-RECTANGLE-WIDTH))
   (<= 
    (- (world-y w) HALF-RECTANGLE-HEIGHT)
    y
    (+ (world-y w) HALF-RECTANGLE-HEIGHT))))

;; TESTS

;; examples of world, for testing
(define unselected-world-mouse-pointer-outside 
  (make-world RECTANGLE-X-COORD RECTANGLE-Y-COORD 300 250 false))

(define selected-world-mouse-after-pointer-inside 
  (make-world RECTANGLE-X-COORD RECTANGLE-Y-COORD 230 155 true))

(begin-for-test
  (check-equal?
   ;;mouse pointer inside the rectangle
   (world-after-mouse-event  
    unselected-world-mouse-pointer-outside 230 155 button-down)
   selected-world-mouse-after-pointer-inside
   "the world should get selected")
  (check-equal?
   ;;mouse pointer outside the rectangle
   (world-after-mouse-event 
    unselected-world-mouse-pointer-outside 380 290 button-down)
   unselected-world-mouse-pointer-outside)
  "the world should not change")


;; world-after-drag : World Integer Integer -> World
;; GIVEN: a world and x,y coordinate of mouse pointer
;; RETURNS: the world following a drag at the given location.
;; if the world is selected, then return a world just like the given
;; one, with the centre of the rectangle relative to mouse pointer's position.
;; EXAMPLE: refer tests below
;; STRATEGY: structural decomposition on w: World


(define (world-after-drag w mx my)
  (if (world-selected? w)
      (rectangle-after-drag mx my 
                            (world-x w)
                            (world-y w)
                            (world-mx w)
                            (world-my w)
                            true)
      w)) 

;; TESTS: tests follow help functions

;; rectangle-after-drag : 
;; Integer Integer Integer Integer Integer Integer Boolean -> World
;; GIVEN: x and y coordinates of rectabgle's centre and mouse pointer in world,
;; and x,y coordinate of new mouse pointer position, and selected.
;; RETURNS: the world following a drag at the given location.
;; if the world is selected, then return a world just like the given
;; one, with the centre of the rectangle relative to mouse pointer's position.
;; EXAMPLE: refer tests below
;; STRATEGY: function composition

(define (rectangle-after-drag new-mx new-my x y old-mx old-my selected?) 
  (make-world (+ x (- new-mx old-mx)) 
              (- y (- old-my new-my)) 
              new-mx
              new-my
              selected?)) 

;; TESTS:

;; examples of world, for testing

(define world-pointer-inside-before-drag 
  (make-world 100 100 70 70 true))
(define world-pointer-inside-after-drag-mouse-event 
  (make-world 130 130 100 100 true))
(define world-pointer-outside-before-drag 
  (make-world 100 100 300 250 false))


(begin-for-test
  (check-equal?
   ;; the mouse pointer is inside the rectangle
   (world-after-mouse-event world-pointer-inside-before-drag 100 100 drag)
   world-pointer-inside-after-drag-mouse-event
   "the rectangle should be dragged to the new location")
  (check-equal?
   ;; the mouse pointer is outside the rectangle
   (world-after-mouse-event world-pointer-outside-before-drag 100 100 drag)
   world-pointer-outside-before-drag
   "the rectangle should remain at its original position"))


;; world-after-button-up : World Integer Integer -> World
;; GIVEN: a world and x,y coordinate of mouse pointer
;; RETURNS: the world following a button-up at the given location.
;; if the world is selected, return a world just like the given one,
;; except that it is no longer selected.
;; EXAMPLE: refer tests
;; STRATEGY: structural decomposition on w: World


(define (world-after-button-up w mx my)
  (if (world-selected? w)
      (make-world (world-x w) 
                  (world-y w)
                  mx 
                  my
                  false)
      w))



;; TESTS:

;; examples of world, for testing
(define world-pointer-inside-before-button-up 
  (make-world 100 100 70 70 true))
(define world-pointer-inside-after-button-up 
  (make-world 100 100 70 70 false))
(define world-pointer-outside-before-button-up 
  (make-world 100 100 300 250 false))


(begin-for-test
  (check-equal?
   ;; mouse pointer inside rectangle
   (world-after-mouse-event 
    world-pointer-inside-before-button-up 70 70 button-up)
   world-pointer-inside-after-button-up
   "the rectangle should get unselected")
  (check-equal?
   ;; mouse pointer outside rectangle
   (world-after-mouse-event 
    world-pointer-outside-before-button-up 300 250 button-up)
   world-pointer-outside-before-button-up
   "the rectangle should remain in its original state"))

(begin-for-test
  (check-equal?
   ;; other mouse event
   (world-after-mouse-event 
    world-pointer-inside-before-button-up 70 70 other-mouse-event)
   world-pointer-inside-before-button-up
   "the rectangle should remain in its original state"))




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



