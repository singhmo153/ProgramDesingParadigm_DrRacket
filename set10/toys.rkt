#lang racket

;;toys.rkt
(require rackunit)
(require "extras.rkt")
(require 2htdp/universe)   
(require 2htdp/image)  


(provide World%)
(provide SquareToy%)
(provide CircleToy%)
(provide make-world)
(provide run)
(provide make-square-toy)
(provide make-circle-toy)
(provide StatefulWorld<%>)
(provide StatefulToy<%>)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; toy consists of a canvas, initially a circle called the target.
;; the target appears at the centre of the canvas
;; the target is smoothly draggable

;; Press s for new square-shaped toy to pop up. 
;; When a square-shaped toy appears, it begins travelling rightward at a 
;; constant rate. When its edge reaches the edge of the canvas, it starts
;; again in the opposite direction

;; Press c for new circle-shaped toy to pop up.
;; These circular toys do not move, but they alternate between solid red and
;; solid green every 5 ticks. The circle is initially green.

;; start with (run framerate square-speed).  Typically: (run 0.25 8)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; CONSTANTS

(define CANVAS-WIDTH 400)
(define CANVAS-HEIGHT 500)

(define EMPTY-CANVAS (empty-scene 400 500))

;; arbitrary choice
(define TARGET-INITIAL-X (/ CANVAS-WIDTH 2))
(define TARGET-INITIAL-Y (/ CANVAS-HEIGHT 2))
(define CIRCLE-INIT-COLOR "green")
(define ZERO 0)
(define ONE 1)
(define FOUR 4)
(define TWO 2)
(define FOURTY 40)
(define FIVE 5)
(define TEN 10)

;;;;;;;;;;;;;;;;;;;;;;DATA DEFINITION;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ListOfStatefulToy<%>

;; A ListOfStatefulToy<%> (LOST) is either
;; -- empty                       Interpretation:empty represents an empty 
;;                                list of toys
;; -- (cons StatefulToy<%> LOST)  Interpretation:(cons StatefulToy<%> LOST) 
;;                                represents a non empty list of toys

;; template:
;; lost-fn : LOST -> ??
;; (define (lost-fn lost)
;;   (cond
;;     [(empty? lost) ...]
;;     [else (...
;;             (... (first lost))
;;             (lost-fn (rest lost)))]))

;; example
;;empty
;;(list StatefulToy<%> StatefulToy<%>)

;; Velocity

;; A Velocity is one of 

;; --PosInt         Interpretation: velocity is a positive integer, velocity 
;;                  is positive when moving towards the right boundary of the
;;                  canvas.
;; --NegInt         Interpretation: velocity is a negative integer, velocity
;;                  is negative when moving towards the left boundary of the
;;                  canvas.

;; template:
;; velocity-fn : Velocity -> ??

;;(define (velocity-fn v)
;;  (cond    
;;    [(positive? v) ...]
;;    [(negative? v) ...]))

;; example
;8
;-8

;; A ColorString is one of 

;; --"red"         Interpretation: red represents red color
;; --"green"       Interpretation: green represents green color

;; template:
;; color-fn :  ColorString-> ??

;;(define (color-fn c)
;;  (cond    
;;    [(string=? c "red") ...]
;;    [(string=? c "green") ...]))

;; example
;"red"
;"green"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;INTERFACES:

(define StatefulWorld<%>
  (interface ()

    ;; -> Void
    ;; GIVEN: no arguments
    ;; EFFECT: updates this StatefulWorld<%> to the state that it should be 
    ;; in after a tick.
    on-tick                             

    ;; Integer Integer MouseEvent -> Void
    ;; GIVEN: x y coordinate of the mouse pointer and a mouse event
    ;; EFFECT: updates this StatefulWorld<%> to the state that it should be in
    ;; after the given MouseEvent
    on-mouse

    ;; KeyEvent -> Void
    ;; GIVEN: a key event
    ;; EFFECT: updates this StatefulWorld<%> to the state that it should be in
    ;; after the given KeyEvent
    on-key

    ;; -> Scene
    ;; GIVEN: no arguments
    ;; RETURNS: a Scene depicting this StatefulWorld<%>
    ;; on it.
    on-draw 
    
    ;; -> PosInt
    ;; GIVEN: no arguments
    ;; RETURNS: the x coordinate of the centre of the target
    target-x
    
    ;; -> PosInt
    ;; GIVEN: no arguments
    ;; RETURNS: the y coordinate of the centre of the target
    target-y

    ;; -> Boolean
    ;; GIVEN: no arguments
    ;; RETURNS: true if the target is selected, false otherwise
    target-selected?

    ;; -> ListOfStatefulToy<%>
    ;; GIVEN: no arguments
    ;; RETURNS: the list of StatefulToy<%> on the canvas
    get-toys
    
    ;; -> StatefulTarget<%>
    ;; GIVEN: no arguments
    ;; RETURNS: the StatefulTarget<%> on the canvas
    for-test:get-tgt

))

(define StatefulToy<%> 
  (interface ()

    ;; -> Void
    ;; GIVEN: no arguments
    ;; EFFECT: updates this StatefulToy<%> to the state it should be in after a
    ;; tick. 
    on-tick                             

    ;; Scene -> Scene
    ;; GIVEN: a scene
    ;; RETURNS: a Scene like the given one, but with this StatefulToy<%> drawn
    ;; on it.
    add-to-scene

    ;; -> PosInt
    ;; GIVEN: no arguments
    ;; RETURNS: x coordinate of the centre of this StatefulToy<%>
    toy-x
    
    ;; -> PosInt
    ;; GIVEN: no arguments
    ;; RETURNS: y coordinate of the centre of this StatefulToy<%>
    toy-y

    ;; -> ColorString
    ;; GIVEN: no arguments
    ;; RETURNS: the current color of this StatefulToy<%>
    toy-color

    ))

(define StatefulTarget<%>
  (interface ()
    
    ;; -> PosInt
    ;; GIVEN: no arguments
    ;; RETURNS: the x coordinate of the centre of this StatefulTarget<%>
    tgt-x
    
    ;; -> PosInt
    ;; GIVEN: no arguments
    ;; RETURNS: the y coordinate of the centre of this StatefulTarget<%>
    tgt-y
    
    ;; -> Boolean
    ;; GIVEN: no arguments
    ;; RETURNS: true if thisStatefulTarget<%> is selected, false otherwise
    tgt-selected?
    
    ;; Integer Integer MouseEvent -> Void
    ;; GIVEN: x y coordinate of the mouse pointer and a mouse event
    ;; EFFECT: updates this StatefulTarget<%> to the state that it should be 
    ;; in after the given MouseEvent 
    tgt-on-mouse
    
    
    ;; Scene -> Scene
    ;; GIVEN: a scene
    ;; RETURNS: a Scene like the given one, but with this StatefulTarget<%> 
    ;; drawn on it.
    add-to-scene    
    ))


;;;;;;;;;;;;;;;;;;;;;;;;;;;CLASS DEFINITIONS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

;; A World is a (new World% [tgt Target][toys ListOfStatefulToy<%>]
;;                          [speed PosInt])
;; Interpretation: represents a world, containing a target, list of toy, and
;; speed which represents the rate at which the square toy will move when
;; created

(define World%            
  (class* object% (StatefulWorld<%>)         
    (init-field tgt)        ; a StatefulTarget<%>-- the StatefulTarget<%> in  
                            ; the marvelous toy
    (init-field toys)       ; a ListOfStatefulToy<%> -- the list of 
                            ; StatefulToy<%>on the canvas. 
    (init-field speed)      ; PosInt -- the constant speed at which the
                            ; rectangle will move   
    (super-new)
    
    ;; on-tick : -> Void
    ;; GIVEN: no arguments
    ;; EFFECT: updates this StatefulWorld<%> to the state that it should be 
    ;; in after a tick.
    ;; EXAMPLE: refer test
    
    (define/public (on-tick)
      (for-each
       ;StatefulToy<%> -> Void
       ;GIVEN: a toy
       ;EFFECT: updates this StatefulToy<%> to the state it should be in
       ;after a tick. 
       (lambda (toy) (send toy on-tick))
       toys))    
    
    ;; on-mouse : Integer Integer MouseEvent -> Void
    ;; GIVEN: x y coordinate of the mouse pointer and a mouse event
    ;; EFFECT: updates this StatefulWorld<%> to the state that it should be in
    ;; after the given MouseEvent
    ;; EXAMPLE: refer test
    
    (define/public (on-mouse x y me)
      (send tgt tgt-on-mouse x y me))
    
    ;; on-key : KeyEvent -> Void
    ;; GIVEN: a key event
    ;; EFFECT: updates this StatefulWorld<%> to the state that it should be in
    ;; after the given KeyEvent
    ;; EXAMPLE: refer test
    ;; STRATEGY: Cases on kev : KeyEvent 
    
    (define/public (on-key kev)
      (cond
        [(key=? kev "s")
         (set! toys 
               (cons (make-square-toy (target-x) (target-y) speed) toys))]
        [(key=? kev "c")
         (set! toys
               (cons (make-circle-toy (target-x) (target-y)) toys))]
        [else this]))    
    
    ;; on-draw : -> Scene
    ;; GIVEN: no argument
    ;; RETURNS: a scene with this world painted on it.
    ;; EXAMPLE: refer test
    
    (define/public (on-draw)
      (local
        ;; first add the target to the scene
        ((define scene-with-target (send tgt add-to-scene EMPTY-CANVAS)))
        ;; then tell each toy to add itself to the scene
        (foldr
         ; StatefulToy<%> Scene -> Scene
         ; GIVEN: a toy and a scene constructed so far
         ; RETURNS: the given toy painted on the given scene
         (lambda (toy scene) (send toy add-to-scene scene))
         scene-with-target
         toys)))
    
    ;; target-x: -> PosInt
    ;; GIVEN: no arguments
    ;; RETURNS: the x coordinate of the centre of the target
    ;; EXAMPLE: 
    ;; (define w1 (new World% [tgt (new Target% [x 10][y 20][selected? false]
    ;;                               [x-off 10][y-off 10])]
    ;;             [toys empty]
    ;;             [speed 8]))
    ;;(send w1 target-x) => 10
    
    (define/public (target-x)
      (send tgt tgt-x))
    
    ;; target-y: -> PosInt
    ;; GIVEN: no arguments
    ;; RETURNS: the y coordinate of the centre of the target
    ;; EXAMPLE: 
    ;; (define w1 (new World% [tgt (new Target% [x 10][y 20][selected? false]
    ;;                               [x-off 10][y-off 10])]
    ;;             [toys empty]
    ;;             [speed 8]))
    ;;(send w1 target-y) => 20
    
    (define/public (target-y)
      (send tgt tgt-y))
    
    ;; target-selected?: -> Boolean
    ;; GIVEN: no arguments
    ;; RETURNS: true if the target is selected, false otherwise 
    ;; EXAMPLE: Consider the target object of this world
    ;; (define w1 (new World% [tgt (new Target% [x 10][y 20][selected? false]
    ;;                               [x-off 10][y-off 10])]
    ;;             [toys empty]
    ;;             [speed 8]))
    ;; (send w1 target-selected?) => false
    ;; Consider another target object of this world
    ;; (define w2 (new World% [tgt (new Target% [x 10][y 20][selected? true]
    ;;                               [x-off 10][y-off 10])]
    ;;             [toys empty]
    ;;             [speed 8]))
    ;; (send w2 target-selected?) => true
    
    (define/public (target-selected?)
      (send tgt tgt-selected?))
    
    ;; get-toys: -> ListOfStatefulToy<%>
    ;; GIVEN: no arguments
    ;; RETURNS: the list of toys on the canvas
    ;; EXAMPLE:
    ;; (define sq (new SquareToy% [x 10][y 10][speed 10]))
    ;; (define cir (new CircleToy% [x 10][y 10][count 0]))
    ;; (define w (new World% [tgt (new Target% [x 10][y 20][selected? true]
    ;; [x-off 10][y-off 10])][toys sq cir][speed 10]))
    ;; (send w get-toys) -> (list (new SquareToy% [x 10][y 10][speed 10])
    ;;                     (new CircleToy% [x 10][y 10][count 0]))
    
    (define/public (get-toys)
      toys)
    
    ;; for-test:get-tgt : -> StatefulTarget<%>
    ;; GIVEN: no arguments
    ;; RETURNS: the target of this world
    ;; EXAMPLE: Consider this world with this target,
    ;; (define w (new World% [tgt (new Target% [x 10][y 20][selected? true]
    ;;                               [x-off 10][y-off 10])]
    ;;             [toys empty]
    ;;             [speed 8]))
    ;; (send w for-test:get-tgt) -> 
    ;; (new Target% [x 10][y 20][selected? true][x-off 10][y-off 10])
    (define/public (for-test:get-tgt)
      tgt)    
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; A Target is a (new Target% [x PosInt][y PosInt][selected? Boolean]
;;                            [x-off PosInt][y-off PosInt])
;; Interpretation: represents a target, containing x,y coordinates of centre 
;; of the target, selected? which describes whether or not the target is 
;; selected and x-off, y-off which describes the relative x and y positions 
;; from target's x and y original position to the mouse's current x & y 
;; position for smooth dragging.

(define Target%            
  (class* object% (StatefulTarget<%>)         
    (init-field x)         ;PosInt --The x position of centre of the target 
                           ;relative to the upper left corner of the screen
    (init-field y)         ;PosInt --The y position of centre of the target 
                           ;relative to the upper left corner of the screen
    (init-field selected?) ;Boolean --true if target is selected
    (init-field
     x-off                 ;PosInt --the relative x position from target's x 
                           ;original position to the mouse's current x   
                           ;position for smooth dragging
     y-off)                ;PosInt --the relative y position from target's y 
                           ;original position to the mouse's current y   
                           ;position for smooth dragging
    (field [r TEN])        ;PosInt --the radius of the target. 
    (field [IMG (circle r "outline" "red")]) ;image --the target image
    
    (super-new)
    
    ;; tgt-on-mouse: Integer Integer MouseEvent -> Void
    ;; GIVEN: x y coordinate of the mouse pointer and a mouse event
    ;; EFFECT: updates this StatefulTarget<%> to the state that it should be 
    ;; in after the given MouseEvent
    ;; EXAMPLE: refer test
    ;; STRATEGY: Cases on evt: MouseEvent
    
    (define/public (tgt-on-mouse x y evt)
      (cond
        [(mouse=? evt "button-down")
         (target-after-button-down x y)]
        [(mouse=? evt "drag") 
         (target-after-drag x y)]
        [(mouse=? evt "button-up")
         (target-after-button-up)]
        [else this]))
    
    ;; target-after-button-down : Integer Integer -> Void
    ;; GIVEN: x and y coordinates of the mouse pointer
    ;; EFFECT: updates this StatefulTarget<%> to the state that it should be 
    ;; in after the button down mouse event
    ;; If the event is inside the target, then updates the state of target to 
    ;; selected, otherwise returns the target unchanged.
    ;; EXAMPLE: refer test 
    
    (define (target-after-button-down mouse-x mouse-y)
      (if (in-target? mouse-x mouse-y)
          (begin
            (set! selected? true)
            (set! x-off mouse-x)
            (set! y-off mouse-y))
          this)) 
    
    ;; target-after-drag : Integer Integer -> Void
    ;; GIVEN: x and y coordinates of the mouse pointer
    ;; EFFECT: updates this StatefulTarget<%> to the state that it should be 
    ;; in after the drag mouse event
    ;; if target is selected, move the target relative to the mouse 
    ;; location, otherwise ignore.
    ;; EXAMPLE: refer test
    
    (define (target-after-drag mouse-x mouse-y)
      (if selected?
          (begin
            (set! x (+ x (- mouse-x x-off)))
            (set! y (+ y (- mouse-y y-off)))
            (set! x-off mouse-x)
            (set! y-off mouse-y))
          this))   
    
    ;; target-after-button-up : -> Void
    ;; GIVEN: no arguments
    ;; EFFECT: updates this StatefulTarget<%> to the state that it should be 
    ;; in after the drag mouse event
    ;; EXAMPLE: refer test
    
    (define (target-after-button-up)
      (set! selected? false))
    
    ;; in-target? : Integer Integer -> Boolean
    ;; GIVEN: x,y coordinates of a location on the canvas
    ;; RETURNS: true iff the location is inside this target.
    ;; EXAMPLE: Consider this target
    ;; (define tgt (new Target% [x 10][y 20][selected? true]
    ;;                          [x-off 10][y-off 10]))
    ;; (in-target? 10 10) -> true 
    ;; (10,10) is a point inside the target 
    ;; (in-target? 100 100)-> false
    ;; (100,100) is point outside the target
    
    (define (in-target? other-x other-y)
      (<= (+ (sqr (- x other-x)) (sqr (- y other-y)))
          (sqr r)))
    
    ;; add-to-scene : Scene -> Scene
    ;; GIVEN: a scene
    ;; RETURNS: a scene like the given one, but with this target painted
    ;; on it.
    ;; EXAMPLE: Consider this target
    ;; (define tgt (new Target% [x 10][y 20][selected? true]
    ;;                          [x-off 10][y-off 10]))
    ;; (send tgt add-to-scene EMPTY-CANVAS) ->
    ;; a scene with a red outline circle of radius 10 centred at 10, 20
    ;; painted on the empty canvas
    
    (define/public (add-to-scene scene)
      (place-image IMG x y scene))
    
    ;; tgt-x : -> PosInt
    ;; GIVEN: no arguments
    ;; RETURNS: the x position of the target
    ;; EXAMPLE: Consider this target
    ;; (define tgt (new Target% [x 10][y 20][selected? true]
    ;;                          [x-off 10][y-off 10]))
    ;; (send tgt tgt-x) -> 10
    ;; returns 10 i.e the x coordinate of the example
    
    (define/public (tgt-x)
      x)
    
    ;; tgt-y : -> PosInt
    ;; GIVEN: no arguments
    ;; RETURNS: the y-position of the target
    ;; EXAMPLE: Consider this target
    ;; (define tgt (new Target% [x 10][y 20][selected? true]
    ;;                          [x-off 10][y-off 10]))
    ;; (send tgt tgt-y) -> 20
    ;; returns 20 i.e the y coordinate of the example
    
    (define/public (tgt-y)
      y)
    
    ;; tgt-selected? : -> Boolean
    ;; GIVEN: no arguments
    ;; RETURNS: true if the target is selected, false otherwise
    ;; EXAMPLE: Consider this target
    ;; (define tgt (new Target% [x 10][y 20][selected? true]
    ;;                          [x-off 10][y-off 10]))
    ;; (send tgt tgt-selected?) -> true
    ;; returns true as the target(in example) is selected
    
    (define/public (tgt-selected?)
      selected?)    
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; A SquareToy is a (new SquareToy% [x PosInt][y PosInt][speed Velocity])
;; Interpretation: represents a square toy , containing it's centre 
;; x y coordinate and a speed at which it will travel.

(define SquareToy%            
  (class* object% (StatefulToy<%>)         
    (init-field x)                                  ; PosInt -- x coordinate of 
                                                    ; centre of square
    (init-field y)                                  ; PosInt -- y coordinate of 
                                                    ; centre of square 
    (init-field speed)                              ; Velocity -- the constant 
                                                    ; speed at which the
                                                    ; rectangle will move 
    (field [SQUARE-WIDTH FOURTY])                   ;PosInt -- the width of the 
                                                    ; square
    (field [HALF-SQUARE-WIDTH (/ SQUARE-WIDTH TWO)]) ;PosInt -- half the width 
                                                     ;of the square
    (field [COLOR "green"])                  ;ColorString --color of the square
    
    ;image --image for displaying the square toy
    (field [SQUARE-TOY-IMG       
            (square SQUARE-WIDTH "outline" COLOR)])
   
    
    (super-new)
    
    ;; on-tick : -> Void
    ;; GIVEN: no arguments
    ;; EFFECT: updates this SquareToy% to the state it should be in after a
    ;; tick. 
    ;; EXAMPLE: refer test
    ;; STRATEGY: Cases on (x+speed) : PosInt, (x+speed) is the position of
    ;; of x coordinate of centre of this toy after a tick
    
    (define/public (on-tick)
      (cond
        ;toy at left boundary
        [(<= (+ x speed) HALF-SQUARE-WIDTH)
         (set! x HALF-SQUARE-WIDTH)
         (set! speed (- speed))]
        ;toy at right boundary
        [(>= (+ x speed) (- CANVAS-WIDTH HALF-SQUARE-WIDTH))
         (set! x (- CANVAS-WIDTH HALF-SQUARE-WIDTH))
         (set! speed (- speed))]
        ;toy between the right and left boundary
        [else (set! x (+ x speed))]))
    
    
    ;; add-to-scene: Scene -> Scene
    ;; GIVEN: a scene
    ;; RETURNS: a Scene like the given one, but with this square toy drawn
    ;; on it.
    ;; EXAMPLE: Consider this square toy
    ;; (define sq1 (new SquaretToy% [x 10][y 20][speed 10]))
    ;; (send sq1 add-to-scene EMPTY-CANVAS) ->
    ;; (place-image (square SQUARE-WIDTH "outline" COLOR) 10 20 EMPTY-CANVAS)
    ;; the square image is painted at 10,20(coordinates of square toy's centre)
    ;; on the given scene
    
    (define/public (add-to-scene scene)
      (place-image SQUARE-TOY-IMG x y scene))    
    
    ;; toy-x: -> PosInt
    ;; GIVEN: no arguments
    ;; RETURNS: x coordinate of the centre of this square toy
    ;; EXAMPLE: Consider this square toy
    ;; (define sq1 (new SquaretToy% [x 10][y 20][speed 10]))
    ;; (send sq1 toy-x) -> 10
    ;; returns the x coordinate i.e 10 in the example.
    
    (define/public (toy-x)
      x)
    
    ;; toy-y: -> PosInt
    ;; GIVEN: no arguments
    ;; RETURNS: y coordinate of the centre of this square toy
    ;; EXAMPLE: Consider this square toy
    ;; (define sq1 (new SquaretToy% [x 10][y 20][speed 10]))
    ;; (send sq1 toy-y) -> 20
    ;; returns the y coordinate i.e 20 in the example.
    
    (define/public (toy-y)
      y)    
    
    ;; toy-color : -> ColorString
    ;; GIVEN: no arguments
    ;; RETURNS: the current color of this square toy
    ;; EXAMPLE: Consider this square toy
    ;; (define sq1 (new SquaretToy% [x 10][y 20][speed 10])) 
    ;; (send sq1 toy-color) -> "green"
    ;; the color is constant for all the square toys
    
    (define/public (toy-color)
      COLOR)
    ))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; A CircleToy is a (new CircleToy% [x PosInt][y PosInt]
;;                                  [counter NonNegInt])
;; Interpretation: represents a square toy , containing it's centre x y 
;; coordinate and a counter which tells it when to change color. 

(define CircleToy%
  (class* object% (StatefulToy<%>) 
    (init-field
     x           ; PosInt --the x coordinate of circle's center,
                 ; relative to the upper-left corner of the canvas
     y)          ; PosInt --the y coordinate of circle's center,
                 ; relative to the upper-left corner of the canvas
    
    (init-field counter) ; NonNegInt the counter which is initialized to zero 
                         ; at every five ticks
                         ; WHERE: 0 <= counter < 5
    (init-field color)   ; ColorString --color of the circle toy
    
    (super-new)
    
    ;; on-tick : -> Void
    ;; GIVEN: no arguments
    ;; EFFECT: updates this CircleToy% to the state it should be in after a
    ;; tick. 
    ;; at every fifth tick this circle toy changes its color
    ;; to either red or green
    ;; EXAMPLE: refer test
    
    (define/public (on-tick)
      (if (= counter FOUR)
          (begin
            (set! counter ZERO)
            (set! color (color-change color)))
          (set! counter (+ counter ONE))))
    
    
    ;;color-change : ColorString -> ColorString
    ;;GIVEN: color of this circle toy
    ;;RETURNS: the changed color of the circle toy
    ;;EXAMPLE: (color-change "red") = "green"
    ;;(color-change "green") = "red"
    ;;STRATEGY: structural decomposition on color : ColorString
    
    (define (color-change color)
      (cond
        [(string=? color "red") "green"]
        [(string=? color "green") "red"]))
    
    ;; add-to-scene : Scene -> Scene
    ;; GIVEN: a scene
    ;; RETURNS: a scene like the given one, but with this circle toy painted
    ;; on it.
    ;; EXAMPLE: Consider this circle toy, whose current color is red
    ;; (define cir 1 (new CircleToy% [x 10][y 20][count 1]))
    ;; (send cir1 add-to-scene EMPTY-CANVAS) ->
    ;; (place-image (circle 5 "solid" "red") 10 20 scene)
    ;; returns a scene with the image of the circle toy painted on the scene
    ;; centred at 10,20 i.e the circle toy's centre coordinate
    
    (define/public (add-to-scene scene)
      (local
        ((define image (circle FIVE "solid" color)))
        (place-image image x y scene)))
    
    ;; toy-x: -> PosInt
    ;; GIVEN: no arguments
    ;; RETURNS: x coordinate of the centre of this circle toy
    ;; EXAMPLE: Consider this circle toy
    ;; (define cir 1 (new CircleToy% [x 10][y 20][count 1]))
    ;; (send cir1 toy-x) -> 10
    ;; returns 10 i.e is the x-coordinate of the centre of circle toy
    ;; in the example
    
    (define/public (toy-x)
      x)
    
    ;; toy-y: -> PosInt
    ;; GIVEN: no arguments
    ;; RETURNS: y coordinate of the centre of this circle toy
    ;; EXAMPLE: Consider this circle toy
    ;; (define cir1 (new CircleToy% [x 10][y 20][count 1]))
    ;; (send cir1 toy-y) -> 20
    ;; returns 20 i.e is the y-coordinate of the centre of circle toy
    ;; in the example
    
    (define/public (toy-y)
      y)
    
    ;; toy-color : -> ColorString
    ;; GIVEN: no arguments
    ;; RETURNS: the current color of this circle toy
    ;; EXAMPLE: Consider this circle toy
    ;; (define cir1 (new CircleToy% [x 10][y 20][count 1]))
    ;;(send cir1 toy-color) ->
    ;; returns "red" if the current color of the circle toy is red,
    ;; returns "green" if the current color of the circle toy is green,
    
    (define/public (toy-color)
      color)                     
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  

;; make-world : PosInt -> World%
;; GIVEN: a speed
;; RETURNS: an object representing a world with a target, 
;; but no toys, and in which any square
;; toy created in the future will travel at the given speed (in pixels/tick).
;; EXAMPLE: (make-world 8)->
;; (new World% [tgt (new Target% [x 200][y 250][selected? false]
;;                               [x-off 200][y-off 250])]
;;             [toys empty]
;;             [speed 8])
;; STRATEGY: function composition

(define (make-world speed)
  (new World% 
       [tgt (new Target% 
                 [x TARGET-INITIAL-X]
                 [y TARGET-INITIAL-Y]
                 [selected? false]
                 [x-off TARGET-INITIAL-X]
                 [y-off TARGET-INITIAL-Y])]
       [toys empty]
       [speed speed]))

 
;; make-square-toy : PosInt PosInt PosInt -> SquareToy%
;; GIVEN: an x and a y position, and a speed
;; RETURNS: an object representing a square toy centred at the given position,
;; travelling right at the given speed.
;; EXAMPLE: (make-square-toy 10 20 8)
;; (new SquareToy% [x 10][y 20][speed 8])
;; STRATEGY: function composition

(define (make-square-toy x y speed)
  (new SquareToy% 
       [x x]
       [y y]
       [speed speed]))

;; make-circle-toy : PosInt PosInt -> CircleToy%
;; GIVEN: an x and a y position
;; RETURNS: an object represeenting a circle toy centred at the given position.
;; EXAMPLE: (make-circle-toy 10 20)->
;; (new CircleToy% [x 10][y 20][counter 0][color "green"])
;; STRATEGY: function composition 

(define (make-circle-toy x y)
  (new CircleToy% 
       [x x]
       [y y]
       [counter ZERO]
       [color CIRCLE-INIT-COLOR]))

;; run : PosNum PosInt -> World%
;; GIVEN: a frame rate (in seconds/tick) and a square-speed (in pixels/tick),
;; creates and runs a world.  Returns the final state of the world.
;; EFFECT: runs the world at the given frame rate
;; RETURNS: the final state of the world
;; EXAMPLE: (run 0.25 8) -> final state of the world
;; STRATEGY: function composition

(define (run rate speed)
  (big-bang (make-world speed)
            (on-tick
             ;World% -> World%
             ;GIVEN: a world object
             ;RETURNS: a world like the given one, but as it should be 
             ;after a tick
             (lambda (w) (send w on-tick) w) 
             rate)
            (on-draw
             ;World% -> Scene
             ;GIVEN: a world
             ;RETURNS: a scene with the given world painted on it
             (lambda (w) (send w on-draw)))
            (on-key
             ;World% KeyEvent -> World%
             ;GIVEN: a world and a key event
             ;RETURNS: a world like the given one, but as it should be 
             ;after the given key event
             (lambda (w kev) (send w on-key kev) w))
            (on-mouse
             ;World% Integer Integer MouseEvent -> World%
             ;GIVEN: a world, x and y coordinates of the mouse pointer,
             ;and a mouse event
             ;RETURNS: a world like the given one, but as it should be 
             ;after the given mouse event
             (lambda (w x y evt) (send w on-mouse x y evt) w))))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Testing Framework
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; toy-equal? : toy toy -> Boolean
;; GIVEN: two toys
;; RETURNS: true iff they have the same x, y, fields
;; STRATEGY: structural decomposition on the two toys t1,t2

(define (toy-equal? t1 t2)
  (and
   (= 
    (send t1 toy-x)
    (send t2 toy-x))
   (=
    (send t1 toy-y)
    (send t2 toy-y))
   (equal?
    (send t1 toy-color)
    (send t2 toy-color))))

;; target-equal? : tgt tgt -> Boolean
;; GIVEN: two targets
;; RETURNS: true iff they have the same x, y and selected? fields
;; STRATEGY: structural decomposition on two targets tg1,tg2

(define (target-equal? tgt1 tgt2)
  (and
   (= (send tgt1 tgt-x) (send tgt2 tgt-x))
   (= (send tgt1 tgt-y) (send tgt2 tgt-y))
   (equal? (send tgt1 tgt-selected?) (send tgt2 tgt-selected?))))

;; world-equal? : world world -> Boolean
;; GIVEN: two worlds
;; RETURNS: true iff they have the same target and toy fields
;; STARTEGY: structural decomposition on two worlds w1,w2

(define (world-equal? w1 w2)
  (and
   (target-equal? (send w1 for-test:get-tgt) (send w2 for-test:get-tgt))
   (andmap
    ; StatefulToy<%> StatefulToy<%> -> Boolean
    ; GIVEN: two toys
    ; RETURNS: true if the two toys are same, else returns false
    (lambda (t1 t2) (toy-equal? t1 t2))
    (send w1 get-toys)
    (send w2 get-toys))))

;;TEST
(begin-for-test
  (local
    ((define t1 (new Target% 
                     [x 20][y 30]
                     [selected? false]
                     [x-off 20][y-off 30])))
    (define w1 (new World% [tgt t1][toys empty][speed 10]))
    (define t5 (new Target%
                    [x 200][y 250][selected? false][x-off 200][y-off 250]))
    (define cir8 (new CircleToy% [x 200][y 250][counter 0][color "green"]))
    (define sq7 (new SquareToy% [x 200][y 250][speed 20]))
    (define w10 (new World% [tgt t5][toys (list cir8 sq7)][speed 20]))
    (define sq1 (new SquareToy% [x 20][y 30][speed 10]))
    (define sq2 (new SquareToy% [x 30][y 30][speed 10]))
    (define sq3 (new SquareToy% [x 20][y 30][speed -10]))
    (define sq4 (new SquareToy% [x 380][y 30][speed 10]))
    (define cir1 (new CircleToy% [x 20][y 30][counter 0][color "green"]))
    (define cir2 (new CircleToy% [x 20][y 30][counter 4][color "green"]))
    (define cir3 (new CircleToy% [x 20][y 30][counter 4][color "red"]))
    ;; world on draw example
    (check-equal? (send w10 on-draw)
                  (place-image (square 40 "outline" "green") 200 250
                               (place-image 
                                (circle 5 "solid" "green") 200 250
                                (place-image (circle 10 "outline" "red")
                                             200 250
                                             EMPTY-CANVAS)))
                  "image of world with a square and circle toy at 200 250
                   should appear")
    ;; target-selected example
    (check-equal? (send w10 target-selected?)
                  false
                  "target is not selected in the given world")
    ;; world on-tick example
    (send w1 on-tick)
    (check world-equal? w1 (new World% [tgt t1][toys empty][speed 10])
           "world with a target and no toys, will remain same after tick")
    ;; make-world example
    (check world-equal? (make-world 8) (new World% 
                                            [tgt (new Target% [x 200][y 250]
                                                      [selected? false]
                                                      [x-off 200][y-off 250])]
                                            [toys empty]
                                            [speed 8])
           "world with spped 8, a target and no toys should be created")
    ;; world on-key example
    (send w1 on-key "x")
    (check world-equal? w1 (new World% 
                                [tgt t1][toys empty][speed 10])
           "no effect of any other key")
    ;; new square toy example
    (send w1 on-key "s")
    (check world-equal? w1 (new World% [tgt t1][toys (list sq1)][speed 10])
           "a new square toy should be created in the world")
    ;; world with a square toy, on tick example 
    (send w1 on-tick) 
    (check world-equal? w1 (new World% [tgt t1][toys (list sq2)][speed 10])
           "the square toy in the world is moved by 10 towards right boundary")
    ;; world with square toy, button down example
    (send w1 on-mouse 100 100 "button-down")
    (check world-equal? w1 (new World% [tgt t1][toys (list sq2)][speed 10])
           "no effect of button down as the mouse pointer is outside target")
    ;; new circle toy example
    (send w1 on-key "c")
    (check world-equal? w1 (new World% 
                                [tgt t1][toys (list cir1 sq2)][speed 10])
           "new circle toy is created in the world")
    ;; square toy on tick example
    (send sq1 on-tick)
    (check toy-equal? sq1 (new SquareToy% [x 30][y 30][speed 10])
           "x coordinate of square toy should increase by 10")
    (send sq3 on-tick)
    (check toy-equal? sq3 (new SquareToy% [x 20][y 30][speed 10])
           "square toy at left boundary, the speed should be positive")
    (send sq4 on-tick)
    (check toy-equal? sq4 (new SquareToy% [x 380][y 30][speed -10])
           "square toy at right boundary, the speed should be negative")
    ;; circle toy on tick example
    (send cir1 on-tick)
    (check toy-equal? cir1 (new CircleToy% 
                                [x 20][y 30][counter 1][color "green"])
           "the counter value should be increased by one")
    (send cir2 on-tick)
    (check toy-equal? cir2 (new CircleToy% 
                                [x 20][y 30][counter 4][color "red"])
           "the color of circle toy should change from green to red")
    (send cir3 on-tick)
    (check toy-equal? cir3 (new CircleToy% 
                                [x 20][y 30][counter 0][color "green"])
           "the color of circle toy should change from red to green")
    ;; tgt-on-mouse, button down example, mouse pointer outside
    (send t1 tgt-on-mouse 100 100 "button-down")
    (check target-equal? t1 (new Target% 
                                 [x 20][y 30]
                                 [selected? false]
                                 [x-off 20][y-off 30])
           "no effect as the mouse pointer is outside target")
    ;; tgt-on-mouse, drag example, target not selected
    (send t1 tgt-on-mouse 100 100 "drag")
    (check target-equal? t1 (new Target% 
                                 [x 20][y 30]
                                 [selected? false]
                                 [x-off 20][y-off 30])
           "no effect as the target is not selected")
    ;; other mouse event on target example
    (send t1 tgt-on-mouse 100 100 "move")
    (check target-equal? t1 (new Target% 
                                 [x 20][y 30]
                                 [selected? false]
                                 [x-off 20][y-off 30])
           "no effect of other mouse event")
    ;; tgt-on-mouse, button-down example, mouse pointer inside
    (send t1 tgt-on-mouse 23 33 "button-down")
    (check target-equal? t1 (new Target% 
                                 [x 20]
                                 [y 30]
                                 [selected? true]
                                 [x-off 23]
                                 [y-off 33])
           "the target should be selected")
    ;; tgt-on-mouse, drag  example, slected target
    (send t1 tgt-on-mouse 30 40 "drag")
    (check target-equal? t1 (new Target% 
                                 [x 27]
                                 [y 37]
                                 [selected? true]
                                 [x-off 30]
                                 [y-off 40])
           "the x y coordinates of target should be 27 and 37")
    ;; tgt-on-mouse, button-up example
    (send t1 tgt-on-mouse 20 30 "button-up")
    (check target-equal? t1 (new Target% 
                                 [x 27]
                                 [y 37]
                                 [selected? false]
                                 [x-off 30]
                                 [y-off 40]))
    "the target should be unselected"))

           
