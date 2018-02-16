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
(provide World<%>)
(provide Toy<%>)

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

;; ListofToy<%>

;; A ListOfToy<%> (LOT) is either
;; -- empty              Interpretation:empty represents an empty list of toys
;; -- (cons Toy<%> LOT)  Interpretation:(cons Toy<%> LOT) represents a list 
;;                       of toys

;; template:
;; lot-fn : LOT -> ??
;; (define (lot-fn lot)
;;   (cond
;;     [(empty? lot) ...]
;;     [else (...
;;             (... (first lot))
;;             (lot-fn (rest lot)))]))

;; example
;;empty
;;(list Toy<%> Toy<%>)

;; Velocity

;; A Velocity is one of 

;; --PosInt         Interpretation: velocity is a positive integer
;; --NegInt         Interpretation: velocity is a negative integer

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
;red
;green

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;INTERFACES:

(define World<%>
  (interface ()
    
    ;; -> World<%>
    ;; GIVEN: no arguments
    ;; RETURNS: the state of this object that should follow a
    ;; tick.   
    on-tick                           
    
    ;; Integer Integer MouseEvent -> World<%>
    ;; GIVEN: x y coordinate of the mouse pointer and a mouse event
    ;; Returns: the World<%> that should follow this one after the
    ;; given MouseEvent 
    on-mouse
    
    ;; KeyEvent -> World<%>
    ;; GIVEN: a key event
    ;; RETURNS: the state of this object that should follow the
    ;; key event.
    on-key  
    
    ;; -> Scene
    ;; GIVEN: no arguments
    ;; RETURNS: a Scene depicting this world
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
    
    ;; -> ListOfToy<%>
    ;; GIVEN: no arguments
    ;; RETURNS: the list of toys on the canvas
    get-toys    
    ))

(define Toy<%> 
  (interface ()
    
    ;; -> Toy<%>
    ;; GIVEN: no arguments
    ;; RETURNS: the Toy that should follow this one after a tick
    on-tick                             
    
    ;; Scene -> Scene
    ;; GIVEN: a scene
    ;; RETURNS: a Scene like the given one, but with this toy drawn
    ;; on it.
    add-to-scene
    
    ;; -> PosInt
    ;; GIVEN: no arguments
    ;; RETURNS: x coordinate of the centre of the toy
    toy-x
    
    ;; -> PosInt
    ;; GIVEN: no arguments
    ;; RETURNS: y coordinate of the centre of the toy
    toy-y
    
    ;; -> ColorString
    ;; GIVEN: no arguments
    ;; RETURNS: the current color of this toy
    toy-color    
    ))

(define Target<%>
  (interface ()
    
    ;; -> PosInt
    ;; GIVEN: no arguments
    ;; RETURNS: the x coordinate of the centre of the target
    tgt-x
    
    ;; -> PosInt
    ;; GIVEN: no arguments
    ;; RETURNS: the y coordinate of the centre of the target
    tgt-y
    
    ;; -> Boolean
    ;; GIVEN: no arguments
    ;; RETURNS: true if the target is selected
    tgt-selected?
    
    ;; Integer Integer MouseEvent -> Target<%>
    ;; GIVEN: x y coordinate of the mouse pointer and a mouse event
    ;; Returns: the Target<%> that should follow this one after the
    ;; given MouseEvent 
    tgt-on-mouse
    
    
    ;; Scene -> Scene
    ;; GIVEN: a scene
    ;; RETURNS: a Scene like the given one, but with this target drawn
    ;; on it.
    add-to-scene    
    ))


;;;;;;;;;;;;;;;;;;;;;;;;;;;CLASS DEFINITIONS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

;; A World is a (new World% [tgt Target] [toys ListOfToy<%>] [speed PosInt])
;; Interpretation: represents a world, containing a target, list of toy, and
;; speed which represents the rate at which the square toy will move when
;; created
(define World%            
  (class* object% (World<%>)         
    (init-field tgt)        ; a Target<%>    -- the Target in the marvelous toy
    (init-field toys)       ; a ListOfToy<%> -- the list of toys on the canvas. 
    (init-field speed)      ; PosInt        -- the constant speed at which the
                            ;                  rectangle will move   
    (super-new)
    
    ;; on-tick : -> World%
    ;; GIVEN: no arguments
    ;; RETURNS: A world like this one, but as it should be after a tick
    ;; EXAMPLE: refer test
    (define/public (on-tick)
      (new World%
           [tgt tgt] 
           [toys   (map
                    ;Toy<%> -> Toy<%>
                    ;GIVEN: a toy
                    ;RETURNS: a toy like this one, but as it should be
                    ;after a tick
                    (lambda (toy) (send toy on-tick))
                    toys)]
           [speed speed]))    
    
    ;; on-mouse : Integer Integer MouseEvent -> World%
    ;; GIVEN: x and y coordinates of the mouse pointer, and a mouse event
    ;; RETURNS: A world like this one, but as it should be after the
    ;; given mouse event.
    ;; EXAMPLE: refer test
    
    (define/public (on-mouse x y me)
      (new World%
           [tgt (send tgt tgt-on-mouse x y me)]
           [toys toys]
           [speed speed]))
    
    ;; on-key : KeyEvent -> World%
    ;; GIVEN: a key event
    ;; RETURNS: A world like this one, but as it should be after the
    ;; given key event.
    ;; EXAMPLE: refer test
    ;; STRATEGY: Cases on kev : KeyEvent 
    
    (define/public (on-key kev)
      (cond
        [(key=? kev "s")
         (new World%
              [tgt tgt]
              [toys (cons (make-square-toy (target-x) (target-y) speed) toys)]
              [speed speed])]
        [(key=? kev "c")
         (new World%
              [tgt tgt]
              [toys (cons (make-circle-toy (target-x) (target-y)) toys)]
              [speed speed])]
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
         ; Toy<%> Scene -> Scene
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
    
    ;; get-toys: -> ListOfToy<%>
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
    
    ;; for-test:get-tgt : -> Target%
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
;; [x-off PosInt][y-off PosInt])
;; Interpretation: represents a target, containing x,y coordinates of centre 
;; of the target, selected? which describes whether or not the target is 
;; selected and x-off, y-off which describes the offset in x and y coordinates
;; of centre of the target

(define Target%            
  (class* object% (Target<%>)         
    (init-field x)         ;PosInt --The x position of centre of the target 
                           ;relative to the upper left corner of the screen
    (init-field y)         ;PosInt --The y position of centre of the target 
                           ;relative to the upper left corner of the screen
    (init-field selected?) ;Boolean --true if target is selected
    (init-field
     x-off                 ;PosInt --The offset in x position of centre 
                           ;of the target 
     y-off)                ;PosInt --The offset in y position of centre 
                           ;of the target 
    (field [r TEN])        ;PosInt --the radius of the target. 
    (field [IMG (circle r "outline" "red")]) ;image --the target image
    
    (super-new)
    
    ;; tgt-on-mouse: Integer Integer MouseEvent -> Target%
    ;; GIVEN: x y coordinate of the mouse pointer and a mouse event
    ;; RETURNS: the target that should follow this one after the
    ;; given MouseEvent 
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
    
    ;; target-after-button-down : Integer Integer -> Target%
    ;; GIVEN: x and y coordinates of the mouse pointer
    ;; RETURNS: the target that should follow this one after a button
    ;; down at the given location
    ;; If the event is inside the target, returns a target just like 
    ;; this target, except that it is selected.  
    ;; Otherwise returns the target unchanged.
    ;; EXAMPLE: refer test
    
    (define (target-after-button-down mouse-x mouse-y)
      (if (in-target? mouse-x mouse-y)
          (new Target% [x x][y y][selected? true][x-off x-off][y-off y-off])
          this))
    
    ;; target-after-drag : Integer Integer -> Target%
    ;; GIVEN: x and y coordinates of the mouse pointer
    ;; RETURNS: the target that should follow this one after a drag at
    ;; the given location 
    ;; if target is selected, move the target relative to the mouse 
    ;; location, otherwise ignore.
    ;; EXAMPLE: refer test
    
    (define (target-after-drag mouse-x mouse-y)
      (if selected?
          (new Target% 
               [x (+ x (- mouse-x x-off))]
               [y (+ y (- mouse-y y-off))]
               [selected? true]
               [x-off mouse-x]
               [y-off mouse-y])
          this))    
    
    ;; target-after-button-up : -> Target%
    ;; GIVEN: no arguments
    ;; RETURNS: the target that should follow this one after a button-up 
    ;; ,button-up unselects the target
    ;; EXAMPLE: refer test
    
    (define (target-after-button-up)
      (new Target% [x x][y y][selected? false][x-off x-off][y-off y-off]))
    
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
    ;; EXAMPLE: Consider the this target
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
    ;; EXAMPLE: Consider the this target
    ;; (define tgt (new Target% [x 10][y 20][selected? true]
    ;;                          [x-off 10][y-off 10]))
    ;; (send tgt tgt-x) -> 10
    ;; returns 10 i.e the x coordinate of the example
    
    (define/public (tgt-x)
      x)
    
    ;; tgt-y : -> PosInt
    ;; GIVEN: no arguments
    ;; RETURNS: the y-position of the target
    ;; EXAMPLE: Consider the this target
    ;; (define tgt (new Target% [x 10][y 20][selected? true]
    ;;                          [x-off 10][y-off 10]))
    ;; (send tgt tgt-y) -> 20
    ;; returns 20 i.e the y coordinate of the example
    
    (define/public (tgt-y)
      y)
    
    ;; tgt-selected? : -> Boolean
    ;; GIVEN: no arguments
    ;; RETURNS: true if the target is selected, false otherwise
    ;; EXAMPLE: Consider the this target
    ;; (define tgt (new Target% [x 10][y 20][selected? true]
    ;;                          [x-off 10][y-off 10]))
    ;; (send tgt tgt-selected?) -> true
    ;; returns true as the target(in example) is selected
    
    (define/public (tgt-selected?)
      selected?)    
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; A SquareToy is a (new SquareToy% [x PosInt][y PosInt][speed Velocity])
;; Interpretation: represents a square toy , containing its x y coordinate
;; and a speed at which it will travel.

(define SquareToy%            
  (class* object% (Toy<%>)         
    (init-field x)        ; PosInt      -- x coordinate of centre of square
    (init-field y)        ; PosInt      -- y coordinate of centre of square 
    (init-field speed)    ; Velocity    -- the constant speed at which the
                          ;                rectangle will move 
    (field [SQUARE-WIDTH FOURTY])  
                          ;PosInt --the width of the square
    (field [HALF-SQUARE-WIDTH (/ SQUARE-WIDTH 2)])
                          ;PosInt half the width of the square
    (field [COLOR "green"])         
                          ;ColorString --color of the square
    (field [SQUARE-TOY-IMG       
            (square SQUARE-WIDTH "outline" COLOR)])
                          ;image --image for displaying the square toy
    
    (super-new)
    
    ;; on-tick : -> SquareToy%
    ;; GIVEN: no arguments
    ;; RETURNS: this square toy as it should be after a tick
    ;; EXAMPLE: refer test
    
    (define/public (on-tick)
      (cond
        [(<= (+ x speed) HALF-SQUARE-WIDTH) 
         (new SquareToy%
              [x HALF-SQUARE-WIDTH]
              [y y]
              [speed (- speed)])]
        [(>= (+ x speed) (- CANVAS-WIDTH HALF-SQUARE-WIDTH)) 
         (new SquareToy%
              [x (- CANVAS-WIDTH HALF-SQUARE-WIDTH)]
              [y y]
              [speed (- speed)])]
        [else (new SquareToy%
                   [x (+ x speed)]
                   [y y]
                   [speed speed])]))   
    
    
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
;; Interpretation: represents a square toy , containing its x y coordinate
;; and a counter which tells it when to change color.

(define CircleToy%
  (class* object% (Toy<%>) 
    (init-field
     x           ; PosInt --the circle's x position,
                 ; relative to the upper-left corner of the canvas
     y)          ; PosInt --the circle's y position
                 ; relative to the upper-left corner of the canvas
    
    (init-field counter) ; NonNegInt the counter which is initialized to zero 
                         ; at every five ticks
                         ; WHERE: 0 <= counter < 5
    (init-field color)   ; ColorString --color of the circle toy
    
    (super-new)
    
    ;; on-tick : -> CircleToy%
    ;; GIVEN: no arguments
    ;; RETURNS: this circle toy as it should be after a tick
    ;; at every fifth ticks this circle toy changes its color
    ;; to either red or green
    ;; EXAMPLE: refer test
    
    (define/public (on-tick)
      (if (change-color?)
          (new CircleToy% 
               [x x]
               [y y]
               [counter ZERO]
               [color (color-change color)])
          (new CircleToy% [x x][y y][counter (+ counter ONE)][color color])))
    
    ;; change-color? : -> Boolean
    ;; GIVEN: no arguments
    ;; RETURNS: true iff the color needs to be changed for the circle toy, i.e
    ;; the counter value becomes 4
    ;; EXAMPLE: Consider this circle toy
    ;; (define cir1 (new CircleToy% [x 10][y 20][counter 4]))
    ;; (change-color?) -> true
    ;; Consider another circle toy
    ;; (define cir2 (new CircleToy% [x 10][y 20][counter 1]))
    ;; (change-color?) -> false
    
    (define (change-color?)
      (= counter FOUR))
    
    ;;color-change : ColorString -> ColorString
    ;;GIVEN: no arguments
    ;;RETURNS: the changed color for the circle toy
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
;; RETURNS: a world with a target, but no toys, and in which any square
;; toys created in the future will travel at the given speed (in pixels/tick).
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
             ;GIVEN: a world
             ;RETURNS: a world like the given one, but as it should be 
             ;after a tick
             (lambda (w) (send w on-tick))
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
             (lambda (w kev) (send w on-key kev)))
            (on-mouse
             ;World% Integer Integer MouseEvent -> World%
             ;GIVEN: a world, x and y coordinates of the mouse pointer,
             ;and a mouse event
             ;RETURNS: a world like the given one, but as it should be 
             ;after the given mouse event
             (lambda (w x y evt) (send w on-mouse x y evt)))))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Testing Framework
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; toy-equal? : toy toy -> Boolean
;; GIVEN: two toys
;; RETURNS: true iff they have the same x, y, fields
;; STRATEGY: structural decomposition on the two toys t1,t2
;; EXAMPLES: 
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
    ; Toy<%> Toy<%> -> Boolean
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
                     [x-off 20][y-off 30]))
     (define t2 (send t1 tgt-on-mouse 20 30 "button-down"))
     (define t3 (send t2 tgt-on-mouse 23 33 "drag"))
     (define t4 (send t2 tgt-on-mouse 20 30 "button-up"))
     (define t5 (new Target%
                     [x 200][y 250][selected? false][x-off 200][y-off 250]))
     (define w1 (new World% [tgt t1][toys empty][speed 10]))
     (define w2 (send w1 on-tick))
     (define w3 (send w1 on-mouse 20 30 "button-down"))
     (define w4 (send w1 on-key "s"))
     (define w5 (send w1 on-key "c"))
     (define w6 (make-world 10))
     (define w7 (send w1 on-key "x"))
     (define sq1 (new SquareToy% [x 20][y 30][speed 10]))
     (define sq2 (send sq1 on-tick))
     (define sq3 (new SquareToy% [x 380][y 50][speed 10]))
     (define sq4 (send sq3 on-tick))
     (define sq5 (new SquareToy% [x 30][y 20][speed -20]))
     (define sq6 (send sq5 on-tick))
     (define sq7 (new SquareToy% [x 200][y 250][speed 20]))
     (define cir1 (new CircleToy% [x 20][y 30][counter 0][color "green"]))
     (define cir2 (send cir1 on-tick))
     (define cir3 (new CircleToy% [x 20][y 30][counter 4][color "green"]))
     (define cir4 (send cir3 on-tick))
     (define cir5 (new CircleToy% [x 20][y 30][counter 4][color "red"]))
     (define cir6 (send cir5 on-tick))
     (define cir7 (new CircleToy% [x 20][y 30][counter 1][color "green"]))
     (define cir8 (new CircleToy% [x 200][y 250][counter 0][color "green"]))
     (define w8 (new World% [tgt t1][toys (list cir1)][speed 10]))
     (define w9 (send w8 on-tick))
     (define w10 (new World% [tgt t5][toys (list cir8 sq7)][speed 20])))
  
    (check target-equal? t1 (new Target% 
                                 [x 20]
                                 [y 30]
                                 [selected? false]
                                 [x-off 20]
                                 [y-off 30])
           "testing the framework")
    ;; target after button down example
    (check target-equal? t2 (new Target% 
                                 [x 20]
                                 [y 30]
                                 [selected? true]
                                 [x-off 20]
                                 [y-off 30])
           "target after button down error")
    ;; target after drag example
    (check target-equal? t3 (new Target% 
                                 [x 23]
                                 [y 33]
                                 [selected? true]
                                 [x-off 20]
                                 [y-off 30])
           "target after drag error")
    ;; target after button up example
    (check target-equal? t4 (new Target%
                                 [x 20]
                                 [y 30]
                                 [selected? false]
                                 [x-off 20]
                                 [y-off 30])
           "target after button up error")
    ;; world on tick example
    (check world-equal? w1 w2 "world after tick error")
    ; world on mouse example
    (check world-equal? w3 (new World% [tgt t2][toys empty][speed 10])
           "world on mouse error")
    ;; world on key example
    (check world-equal? w4 (new World%
                                [tgt t1]
                                [toys (list (make-square-toy 20 30 10))]
                                [speed 10])
           "world after creating a square toy error")
    ;; world on ey example
    (check world-equal? w5 (new World%
                                [tgt t1]
                                [toys (list (make-circle-toy 20 30))]
                                [speed 10])
           "world after creating circle toy error")
    ;; world on key example
    (check world-equal? w7 w1 "world on pressing random key other than s or c")
    ;; square toy on tick example
    (check toy-equal? sq2 (new SquareToy% [x 30][y 30][speed 10])
           "square toy after tick error")
    ;; circle toy on tick example
    (check toy-equal? cir2 cir1 "circle after tick error")
    ;; circle toy on tick color change example
    (check toy-equal? cir4 (new CircleToy% 
                                [x 20][y 30][counter 0]
                                [color "red"])
           "circle after tick color changing error")
    ;; circle toy on tick color change example
    (check toy-equal? cir6 (new CircleToy%
                                [x 20][y 30][counter 0]
                                [color "green"])
           "circle after tick color changing error")
    (check world-equal? w6 (new World%
                                [tgt (new Target%
                                          [x TARGET-INITIAL-X]
                                          [y TARGET-INITIAL-Y]
                                          [selected? false]
                                          [x-off TARGET-INITIAL-X]
                                          [y-off TARGET-INITIAL-Y])]
                                [toys empty]
                                [speed 10])
           "world-equal function not working properly")
    ;; square toy on tick example
    (check toy-equal? sq4 (new SquareToy% [x 380][y 50][speed -10])
           "square toy on right boundary error")
    ;; square toy on tick example
    (check toy-equal? sq6 (new SquareToy% [x 20][y 20][speed 20])
           "square toy on left boundary error")
    ;; world on tick example
    (check world-equal? w9 (new World% [tgt t1][toys (list cir7)][speed 10])
           "world on tick with a circle toy error")
    ;; world on draw example
    (check-equal? (send w10 on-draw)
                  (send (send (send (make-world 20) 
                                    on-key 
                                    "c")
                              on-key "s")
                        on-draw)
                  "world on-draw with a circle and a square toy error")
    ;; target-selected example
    (check-equal? (send w10 target-selected?)
                  false
                  "world's target selection error encountered")
    ;; target on mouse example
    (check target-equal? (send t1 tgt-on-mouse 20 30 "move")
                   t1
                   "target on-mouse function error")
    ;; target on mouse example
    (check target-equal? (send t1 tgt-on-mouse 100 70 "button-down")
           t1
           "target-after-button-down function error")
    ;; target on mouse example
    (check target-equal? (send t1 tgt-on-mouse 30 40 "drag")
           t1
           "target-after-drag function error")))

 