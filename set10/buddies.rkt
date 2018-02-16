#lang racket

;;toys.rkt
(require rackunit)
(require "extras.rkt")
(require 2htdp/universe)   
(require 2htdp/image)
(require "sets.rkt")


(provide World%)
(provide SquareToy%)
(provide make-world)
(provide run)
(provide make-square-toy)
(provide StatefulWorld<%>)
(provide StatefulToy<%>)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; toy consists of a canvas, initially a circle called the target.
;; the target appears at the centre of the canvas
;; the target is smoothly draggable

;; Press s for new square-shaped toy to pop up. 
;; When a square-shaped toy appears.

;; Squares may also move if they are buddies with another toy. Squares become 
;; buddies when they overlap while one of those squares is moving. 
;; Once two squares are buddies they stay that way forever.
;; Squares are normally green, but when a square is selected, 
;; both it and its buddies are displayed in red.

;; start with (run framerate).  Typically: (run 0.25)

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
(define THIRTY 30)
(define FIVE 5)
(define TEN 10)

;;;;;;;;;;;;;;;;;;;;;;DATA DEFINITION;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

;; ListOfStatefulToy<%>

;; A ListOfStatefulToy<%> (LOST) is either
;; -- empty                      Interpretation:empty represents an empty list
;;                               of toys
;; -- (cons StatefulToy<%> LOST) Interpretation:(cons StatefulToy<%> LOST) 
;;                               represents a list of toys

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

;; for square toy
;; A ColorString is one of 

;; --"red"         Interpretation: red represents red color, when a square is  
;;                 selected, both it and it's buddies are displayed in red.
;; --"green"       Interpretation: green represents green color, all squares
;;                 are normally green when not slected or dragged.

;; template:
;; color-fn :  ColorString-> ??

;;(define (color-fn c)
;;  (cond    
;;    [(string=? c "red") ...]
;;    [(string=? c "green") ...]))

;; example
;"red"
;"green"


;; for target
;; A ColorString is one of 

;; --"orange"         Interpretation: orange represents orange color, when a    
;;                    target is selected, it is represented in orange
;; --"black"          Interpretation: black represents black color, 
;;                    target is normally black when not slected or dragged.

;; template:
;; color-fn :  ColorString-> ??

;;(define (color-fn c)
;;  (cond    
;;    [(string=? c "orange") ...]
;;    [(string=? c "black") ...]))

;; example
;"orange"
;"black"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;INTERFACES:

(define StatefulWorld<%>
  (interface ()
    
    ;; -> Void
    ;; GIVEN: no arguments
    ;; EFFECT: updates this StatefulWorld<%> to the 
    ;;         state that it should be in after a tick.
    on-tick                             
    
    ;; Integer Integer MouseEvent -> Void
    ;; GIVEN:  x y coordinate of the mouse pointer and a mouse event
    ;; EFFECT: updates this StatefulWorld<%> to the 
    ;;         state that it should be in after the given MouseEvent
    on-mouse
    
    ;; KeyEvent -> Void
    ;; GIVEN: a key event
    ;; EFFECT: updates this StatefulWorld<%> to the 
    ;;         state that it should be in after the given KeyEvent
    on-key
    
    ;; -> Scene
    ;; GIVEN: no arguments
    ;; RETURNNS: a Scene depicting this StatefulWorld<%> on it.
    on-draw 
    
    ;; -> Integer
    ;; GIVEN: no arguments
    ;; RETURNS: the x coordinate of the target's centre
    target-x
    
    ;; -> Integer
    ;; GIVEN: no arguments
    ;; RETURNS: the y coordinate of the target's centre
    target-y
    
    ;; -> Boolean
    ;; GIVEN: no arguments
    ;; RETURNS: true if the target is selcted, false otherwise
    target-selected?
    
    ;; -> ColorString
    ;; GIVEN: no arguments
    ;; RETURNS: color of the target
    target-color
    
    ;; -> ListOfStatefulToy<%>
    ;; GIVEN: no arguments
    ;; RETURNS: the list of toys on the canvas
    get-toys 
    
    ;; -> Target<%>
    ;; GIVEN: no arguments
    ;; RETURNS: the target of this StatefulWorld<%>
    for-test:get-tgt 
    
    ))

(define StatefulToy<%> 
  (interface ()
    
    ;; Integer Integer MouseEvent -> Void
    ;; GIVEN: x y coordinate of the mouse pointer and a mouse event
    ;; EFFECT: updates this StatefulToy<%> to the 
    ;;         state that it should be in after the given MouseEvent
    on-mouse
    
    ;; Scene -> Scene
    ;; GIVEN: a scene
    ;; RETURNS: a Scene like the given one, but with this  
    ;; StatefulToy<%> drawn on it.
    add-to-scene
    
    ;; -> Int
    ;; GIVEN: no arguments
    ;; RETURNS: the x coordinate of this StatefulToy<%>
    toy-x 
    
    ;; -> Int
    ;; GIVEN: no arguments
    ;; RETURNS: the y coordinate of this StatefulToy<%>
    toy-y
    
    ;; -> ColorString
    ;; GIVEN: no arguments
    ;; RETURNS: the current color of this StatefulToy<%>
    toy-color
    
    ;; -> Boolean
    ;; GIVEN: no arguments
    ;; RETURNS: true if this StatefulToy<%> is selected, false otherwise
    toy-selected?
    
    ;; toys-after-finding-buddies : 
    ;; ListOfStatefulToy<%> Integer Integer-> ListOfStatefulToy<%>
    ;; GIVEN: the list of stateful toys on canvas, and coordinates
    ;; of mouse pointer
    ;; RETURNS: the list of of toys with buddies of this StatefulToy<%>
    ;; appended to its buddy list and vice versa
    toys-after-finding-buddies
    
    ;;buddy-add : StatefulToy<%> Integer Integer -> Void
    ;;GIVEN: a square toy and coordinates of mouse pointer
    ;;EFFECT: updates this stateful toy buddy list, by adding the given toy 
    ;;to its buddy list and also updates the x-off and y-off of this toy
    buddy-add
    
    ;; buddy-after-button-down : Integer Integer -> Void
    ;; GIVEN:  coordinates of mouse pointer
    ;; EFFECT: updates this stateful toy by changing its color
    ;; to red, and updating its x-off set and y-off values
    buddy-after-button-down
    
    ;; buddy-after-drag : Integer Integer-> Void
    ;; GIVEN: coordinates of mouse pointer
    ;; EFFECT: updates this stateful toy after changing its color
    ;; to red and dragging it relative to the given mouse pointer
    ;; position
    buddy-after-drag
    
    ;; buddy-after-button-up : -> Void
    ;; GIVEN: no arguments
    ;; EFFECT: updates this stateful toy by changing its color
    ;; to green 
    buddy-after-button-up
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
    ;; RETURNS: true if the target is selected, false otherwise
    tgt-selected?
    
    ;; Integer Integer MouseEvent -> Target<%>
    ;; GIVEN: x y coordinate of the mouse pointer and a mouse event
    ;; RETURNS: the Target<%> that should follow this one after the
    ;; given MouseEvent 
    tgt-on-mouse
    
    
    ;; Scene -> Scene
    ;; GIVEN: a scene
    ;; RETURNS: a Scene like the given one, but with this target drawn
    ;; on it.
    add-to-scene    
    ))


;;;;;;;;;;;;;;;;;;;;;;;;;;;CLASS DEFINITIONS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

;; A World is a (new World% [tgt Target][toys ListOfStatefulToy<%>])
;; Interpretation: represents a world, containing a target, and a list of 
;; stateful toys on the canvas

(define World%            
  (class* object% (StatefulWorld<%>)         
    (init-field tgt)        ; a Target<%>            -- the Target in this
                            ;                           world
    (init-field toys)       ; a ListOfStatefulToy<%> -- the list of toys on 
                            ;                           the canvas. 
    
    (super-new)
    
    ;; on-tick : -> Void
    ;; GIVEN: no arguments
    ;; EFFECT: updates this StatefulWorld<%> to the 
    ;;         state that it should be in after a tick.
    ;; EXAMPLE: refer test
    
    (define/public (on-tick)
      this)    
    
    ;; on-mouse : Integer Integer MouseEvent -> Void
    ;; GIVEN: x and y coordinates of the mouse pointer, and a mouse event
    ;; EFFECT: updates this StatefulWorld<%> to the 
    ;;         state that it should be in after the given MouseEvent
    ;; EXAMPLE: refer test  
    ;; STRATEGY: Cases on me: MouseEvent
    
    (define/public (on-mouse x y me)
      (set! tgt (send tgt tgt-on-mouse x y me))
      (cond 
        [(mouse=? me "drag")
         (for-each
          ;StatefulToy<%> -> Void
          ;GIVEN: a stateful toy
          ;EFFECT: updates the given satefultoy as it should
          ;be after the drag mouse event
          (lambda (toy)
            (send toy on-mouse x y me)
            (send toy toys-after-finding-buddies toys x y))
          toys)]
        [else (for-each
               ;StatefulToy<%> -> Void
               ;GIVEN: a stateful toy
               ;EFFECT: updates the given satefultoy as it should
               ;be after the given mouse event
               (lambda (toy)
                 (send toy on-mouse x y me))
               toys)])) 
    
    ;; on-key : KeyEvent -> Void
    ;; GIVEN: a key event
    ;; EFFECT: updates this StatefulWorld<%> to the 
    ;;         state that it should be in after the given KeyEvent
    ;; EXAMPLE: refer test
    ;; STRATEGY: Cases on kev : KeyEvent 
    
    (define/public (on-key kev)
      (cond
        [(key=? kev "s")
         (set! toys 
               (cons (make-square-toy (target-x) (target-y)) toys))]
        [else this]))    
    
    ;; on-draw : -> Scene
    ;; GIVEN: no arguments
    ;; RETURNS: a scene with this world painted on it.
    ;; EXAMPLE: refer test
    
    (define/public (on-draw)
      (local
        ;; first add the target to the scene
        ((define scene-with-target (send tgt add-to-scene EMPTY-CANVAS)))
        ;; then tell each toy to add itself to the scene
        (foldr
         ; StatefulToy<%> Scene -> Scene
         ; GIVEN: a stateful toy and a scene constructed so far
         ; RETURNS: the given stateful toy painted on the given scene
         (lambda (toy scene) (send toy add-to-scene scene))
         scene-with-target
         toys)))
    
    ;; target-x: -> PosInt
    ;; GIVEN: no arguments
    ;; RETURNS: the x coordinate of the centre of the target
    ;; EXAMPLE: 
    ;; (define w1 (new World% [tgt (new Target% [x 10][y 20][selected? false]
    ;;                               [x-off 10][y-off 10][color "black"])]
    ;;             [toys empty]))
    ;;(send w1 target-x) => 10
    
    (define/public (target-x)
      (send tgt tgt-x))
    
    ;; target-y: -> PosInt
    ;; GIVEN: no arguments
    ;; RETURNS: the y coordinate of the centre of the target
    ;; EXAMPLE: 
    ;; (define w1 (new World% [tgt (new Target% [x 10][y 20][selected? false]
    ;;                               [x-off 10][y-off 10][color "black"])]
    ;;             [toys empty]))
    ;;(send w1 target-y) => 20
    
    (define/public (target-y)
      (send tgt tgt-y))
    
    ;; target-selected?: -> Boolean
    ;; GIVEN: no arguments
    ;; RETURNS: true if the target is selected, false otherwise
    ;; EXAMPLE: Consider the target object of this world
    ;; (define w1 (new World% [tgt (new Target% [x 10][y 20][selected? false]
    ;;                               [x-off 10][y-off 10][color "black"])]
    ;;             [toys empty]))
    ;; (send w1 target-selected?) => false
    ;; Consider another target object of this world
    ;; (define w2 (new World% [tgt (new Target% [x 10][y 20][selected? true]
    ;;                               [x-off 10][y-off 10][color "black"])]
    ;;             [toys empty]))
    ;; (send w2 target-selected?) => true
    
    (define/public (target-selected?)
      (send tgt tgt-selected?))
    
    ;; target-color: -> ColorString
    ;; GIVEN: no arguments
    ;; RETURNS: color of the target
    ;; EXAMPLE: Consider the target object of this world
    ;; (define w1 (new World% [tgt (new Target% [x 10][y 20][selected? false]
    ;;                               [x-off 10][y-off 10][color "black"])]
    ;;             [toys empty]))
    ;; (send w1 target-color) => "black"
    
    (define/public (target-color)
      (send tgt tgt-color))
    
    ;; get-toys: -> ListOfToy<%>
    ;; GIVEN: no arguments
    ;; RETURNS: the list of toys on the canvas
    ;; EXAMPLE:
    ;; (define sq (new SquareToy% [x 10][y 10][x-off 10][y-off 10]
    ;;                            [selected? false][buddies empty]
    ;;                            [color "green"]))
    ;; (define w (new World% [tgt (new Target% [x 10][y 20][selected? true]
    ;;                               [x-off 10][y-off 10][color "black"])]
    ;;                       [toys sq]))
    ;; (send w get-toys) -> (list sq)
    
    (define/public (get-toys)
      toys)
    
    ;; for-test:get-tgt : -> Target<%>
    ;; GIVEN: no arguments
    ;; RETURNS: the target of this world
    ;; EXAMPLE: Consider this world with this target,
    ;; (define w (new World% [tgt (new Target% [x 10][y 20][selected? true]
    ;;                               [x-off 10][y-off 10][color "black"])]
    ;;                       [toys empty]))
    ;; (send w for-test:get-tgt) -> 
    ;; (new Target% [x 10][y 20][selected? true]
    ;;              [x-off 10][y-off 10][color "black"])
    (define/public (for-test:get-tgt)
      tgt)    
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; A Target is a (new Target% [x PosInt][y PosInt][selected? Boolean]
;;                  [x-off PosInt][y-off PosInt][color ColorString])
;; Interpretation: represents a target, containing x,y coordinates of centre 
;; of the target, selected? which describes whether or not the target is 
;; selected and x-off, y-off which describes the position of the mouse pointer 
;; inside the target when the target is selected for smooth dragging, and color
;; describes the current color of the target.

(define Target%            
  (class* object% (Target<%>)         
    (init-field x)         ;PosInt --The x position of centre of the target 
                           ;relative to the upper left corner of the screen
    (init-field y)         ;PosInt --The y position of centre of the target 
                           ;relative to the upper left corner of the screen
    (init-field selected?) ;Boolean --true if target is selected
    (init-field
     x-off                 ;PosInt -- x position of the mouse pointer inside
                           ;the target when the target is selected for 
                           ;smooth dragging.
     y-off)                ;PosInt -- y position of the mouse pointer inside
                           ;the target when the target is selected for 
                           ;smooth dragging.
    (init-field color)     ;ColorString -- the current color of the target
    (field [r TEN])        ;PosInt --the radius of the target. 
    
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
          (begin
            (set! selected? true)
            (set! x-off mouse-x)
            (set! y-off mouse-y)
            (set! color "orange")
            this)
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
          (begin
            (set! x (+ x (- mouse-x x-off)))
            (set! y (+ y (- mouse-y y-off)))
            (set! x-off mouse-x)
            (set! y-off mouse-y)
            this)
          this))   
    
    ;; target-after-button-up : ->  Target%
    ;; GIVEN: no arguments
    ;; RETURNS: the target that should follow this one after a button-up  
    ;; ,button-up unselects the target
    ;; EXAMPLE: refer test
    
    (define (target-after-button-up)
      (begin (set! selected? false)
             (set! color "black")
             this))
    
    ;; in-target? : Integer Integer -> Boolean
    ;; GIVEN: x,y coordinates of a location on the canvas
    ;; RETURNS: true iff the location is inside this target.
    ;; EXAMPLE: Consider this target
    ;; (define tgt (new Target% [x 10][y 20][selected? true]
    ;;                          [x-off 10][y-off 10][color "black"]))
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
    ;;                          [x-off 10][y-off 10][color "black"]))
    ;; (send tgt add-to-scene EMPTY-CANVAS) ->
    ;; a scene with a black outline circle of radius 10 centred at 10, 20
    ;; painted on the empty canvas
    
    (define/public (add-to-scene scene)
      (place-image (circle r "outline" color) x y scene))
    
    ;; tgt-x : -> PosInt
    ;; GIVEN: no arguments 
    ;; RETURNS: the x position of the target
    ;; EXAMPLE: Consider this target
    ;; (define tgt (new Target% [x 10][y 20][selected? true]
    ;;                          [x-off 10][y-off 10][color "black"]))
    ;; (send tgt tgt-x) -> 10
    ;; returns 10 i.e the x coordinate of the example
    
    (define/public (tgt-x)
      x)
    
    ;; tgt-y : -> PosInt
    ;; GIVEN: no arguments
    ;; RETURNS: the y-position of the target
    ;; EXAMPLE: Consider this target
    ;; (define tgt (new Target% [x 10][y 20][selected? true]
    ;;                          [x-off 10][y-off 10][color "black"]))
    ;; (send tgt tgt-y) -> 20
    ;; returns 20 i.e the y coordinate of the example
    
    (define/public (tgt-y)
      y)
    
    ;; tgt-selected? : -> Boolean
    ;; GIVEN: no arguments
    ;; RETURNS: true if the target is selected, false otherwise
    ;; EXAMPLE: Consider this target
    ;; (define tgt (new Target% [x 10][y 20][selected? true]
    ;;                          [x-off 10][y-off 10][color "black"]))
    ;; (send tgt tgt-selected?) -> true
    ;; returns true as the target(in example) is selected
    
    (define/public (tgt-selected?)
      selected?)
    
    ;; tgt-color : -> ColorString
    ;; GIVEN: no arguments
    ;; RETURNS: the color of the target
    ;; EXAMPLE: Consider this target
    ;; (define tgt (new Target% [x 10][y 20][selected? true]
    ;;                          [x-off 10][y-off 10][color "black"]))
    ;; (send tgt tgt-color) -> "black"
    
    (define/public (tgt-color)
      color)
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; A SquareToy is a (new SquareToy% [x PosInt][y PosInt][x-off PosInt]
;;                       [y-off PosInt][selected? Boolean]
;;                       [buddies ListOfStatefulToy<%>][color ColorString])
;; Interpretation: represents a square toy , containing x,y coordinates of  
;; centre of the square toy, x-off, y-off which describes the position of the 
;; mouse pointer inside the square toy when the square toy is selected for 
;; smooth dragging, selected? which describes whether or not the 
;; square toy is selected, buddies describes the list of toys that are buddy of
;; this square toy, and color describes the current color of this square toy.


(define SquareToy%            
  (class* object% (StatefulToy<%>)         
    (init-field x)         ;PosInt --The x position of centre of this square  
                           ;toy relative to the upper left corner of the screen
    (init-field y)         ;PosInt --The y position of centre of this square 
                           ;toy relative to the upper left corner of the screen
    (init-field x-off)     ;PosInt -- x position of the mouse pointer inside
                           ;this square toy when this square toy is selected  
                           ;for smooth dragging.
    (init-field y-off)     ;PosInt -- y position of the mouse pointer inside
                           ;this square toy when this square toy is selected 
                           ;for smooth dragging.
    (init-field selected?) ;Boolean -- true if this square toy is selected, 
                           ;false otherwise
    (init-field buddies)   ;ListOfStatefulToy<%> -- the list of buddies of this
                           ;square toy
    (init-field color)     ;ColorString -- the current color of this square toy
    
    (field [SQUARE-WIDTH THIRTY])  ;PosInt --the width of the square
    (field [HALF-SQUARE-WIDTH (/ SQUARE-WIDTH TWO)]) ;PosInt -- half the width  
                                                     ;of the square toy
    
    (super-new) 
    
    ;; on-mouse : Integer Integer MouseEvent -> Void
    ;; GIVEN: x y coordinate of the mouse pointer and a mouse event
    ;; EFFECT: updates this SquareToy% to the 
    ;;         state that it should be in after the given MouseEvent
    ;; EXAMPLE: refer test
    ;; STRATEGY: Cases on evt : MouseEvent
    
    (define/public (on-mouse x y evt)
      (cond
        [(mouse=? evt "button-down")
         (toy-after-button-down x y)]
        [(mouse=? evt "drag") 
         (toy-after-drag x y)]
        [(mouse=? evt "button-up")
         (toy-after-button-up)]
        [else this]))
    
    ;; toy-after-button-down : Integer Integer -> Void
    ;; GIVEN: x y coordinate of the mouse pointer
    ;; EFFECT: updates this SquareToy% to the 
    ;; state that it should be in after the button down MouseEvent
    ;; If the event is inside the square toy, updates the square toy
    ;; otherwise returns the square toy unchanged.
    ;; EXAMPLE: refer test    
    
    (define (toy-after-button-down mouse-x mouse-y)
      (if (in-toy? mouse-x mouse-y)
          (begin
            (set! x-off (- mouse-x x))
            (set! y-off (- mouse-y y))
            (set! selected? true)
            (set! color "red")
            (for-each
             ;StatefulToy<%> -> Void
             ;GIVEN: a buddy of this SquareToy%
             ;EFFECT: updates the state of the buddy as it should be, after
             ;a button down
             (lambda (b) (send b buddy-after-button-down mouse-x mouse-y))
             buddies))
          this))
    
    ;; buddy-after-button-down : Integer Integer -> Void
    ;; GIVEN: x y coordinate of the mouse pointer
    ;; EFFECT: updates the square toy buddy to the state it should be,
    ;; after a button down.
    ;; EXAMPLE: Consider the square toy buddy
    ;; (define b (new SquareToy% [x 100][y 100][x-off 100]
    ;;                           [y-off 100][selected? false]
    ;;                           [buddies (list sq)][color "green"])
    ;; (send b buddy-after-button-down 110 110)
    ;; upadtes the x-off field to 10, y-off field to 10 and color
    ;; field to red.
    
    (define/public (buddy-after-button-down mx my)
      (set! x-off (- mx x))
      (set! y-off (- my y))
      (set! color "red"))
     
    ;; toys-after-finding-buddies : 
    ;; ListOfStatefulToy<%> Integer Integer-> ListOfStatefulToy<%>
    ;; GIVEN: the list of stateful toys on canvas, and coordinates
    ;; of mouse pointer
    ;; RETURNS: the list of stateful toy with buddies of this StatefulToy<%>
    ;; appended to its buddy list and vice versa
    ;; EXAMPLE:
    ;; (define sq1 (new SquareToy% [x 100][y 100][x-off 100]
    ;;                             [y-off 100][selected? false]
    ;;                             [buddies empty][color "red"]))
    ;; (define sq2 (new SquareToy% [x 120][y 120][x-off 120]
    ;;                             [y-off 130][selected? false]
    ;;                             [buddies empty][color "green"]))
    ;; (define sq3 (new SquareToy% [x 100][y 100][x-off 100]
    ;;                             [y-off 100][selected? false]
    ;;                             [buddies (list sq2)][color "red"]))
    ;; (define sq4 (new SquareToy% [x 120][y 120][x-off 120]
    ;;                             [y-off 130][selected? false]
    ;;                             [buddies (list sq3)][color "green"]))
    ;; (find-buddies (list sq1 sq2)) -> (list sq3 sq4)
    
    
    (define/public (toys-after-finding-buddies toys mx my)   
      (for-each
       ;StatefulToy<%> -> Void
       ;GIVEN: a toy
       ;EFFECT: updates the buddy list of the toy if there
       ;exist a buddy, else returns the same toy
       (lambda (toy) (if (and (overlaps? toy)
                              (not (my-member? toy buddies))
                              (not (equal? this toy)))
                         (begin
                           (set! buddies (cons toy buddies))
                           (set! x-off (- mx x))
                           (set! y-off (- my y))
                           (send toy buddy-add this mx my))
                         this))
       toys))
    
    
    ;;buddy-add : StatefulToy<%> Integer Integer -> Void
    ;;GIVEN: a square toy and coordinates of mouse pointer
    ;;EFFECT: updates this toy buddy list, by adding the given toy to its
    ;;buddy list and also updates the x-off and y-off of this toy
    ;; (define sq1 (new SquareToy% [x 100][y 100][x-off 100]
    ;;                             [y-off 100][selected? false]
    ;;                             [buddies empty][color "red"]))
    ;; (define sq2 (new SquareToy% [x 120][y 120][x-off 120]
    ;;                             [y-off 130][selected? false]
    ;;                             [buddies empty][color "green"]))
    ;; (add-this-as-buddy sq2 100 100)
    ;; sq1 updates to sq3
    ;; (define sq3 (new SquareToy% [x 100][y 100][x-off 0]
    ;;                             [y-off 0][selected? false]
    ;;                             [buddies (list sq2)][color "red"]))
    ;; sq2 updates to sq4
    ;; (define sq4 (new SquareToy% [x 120][y 120][x-off 120]
    ;;                             [y-off 130][selected? false]
    ;;                             [buddies (list sq3)][color "green"]))
    
    (define/public (buddy-add toy mx my)
      (set! buddies (cons toy buddies))
      (set! x-off (- mx x))
      (set! y-off (- my y)))
    
    ;; overlaps? : StatefulToy<%> -> Boolean
    ;; GIVEN: a stateful toy
    ;; RETURNS: true if the given toy overlaps 
    ;; this square toy
    ;; EXAMPLE: Consider this square toy
    ;; (define sq (new SquareToy% [x 100][y 100][x-off 100]
    ;;                           [y-off 100][selected? false]
    ;;                           [buddies empty][color "red"])
    ;; Consider other toy as
    ;; (define o-sq (new SquareToy% [x 120][y 120][x-off 120]
    ;;                              [y-off 130][selected? false]
    ;;                              [buddies empty][color "green"])
    ;; (send this overlaps? o-sq)
    ;; -> true
    
    (define (overlaps? toy)
      (local
        ((define other-x (send toy toy-x))
         (define other-y (send toy toy-y)))
        (and 
         (<= (- x HALF-SQUARE-WIDTH) (+ other-x HALF-SQUARE-WIDTH))
         (>= (+ x HALF-SQUARE-WIDTH) (- other-x HALF-SQUARE-WIDTH))
         (<= (- y HALF-SQUARE-WIDTH) (+ other-y HALF-SQUARE-WIDTH))
         (>= (+ y HALF-SQUARE-WIDTH) (- other-y HALF-SQUARE-WIDTH)))))   
    
    
    ;; toy-after-drag : Integer Integer -> Void
    ;; GIVEN: x y coordinate of the mouse pointer
    ;; EFFECT: updates this SquareToy% to the 
    ;; state that it should be in after the drag MouseEvent
    ;; If this square toy is selected, updates the square toy
    ;; otherwise returns the square toy unchanged.
    ;; EXAMPLE: refer test
    
    
    (define (toy-after-drag mouse-x mouse-y)
      (if selected?
          (begin
            (set! x (- mouse-x x-off))
            (set! y (- mouse-y y-off))
            (for-each
             ;StatefulToy<%> -> Void
             ;GIVEN: a buddy of this square toy
             ;EFFECT: updates the buddy of this square toy, to
             ;the state that it should be in after drag
             (lambda (toy)
               (send toy buddy-after-drag mouse-x mouse-y))
             buddies))
          this))
    
    ;; buddy-after-drag : Integer Integer-> Void
    ;; GIVEN: x and y coordinates of mouse pointer
    ;; EFFECT: updates the buddy of the square toy, to the state
    ;; it should be in after drag
    ;; EXAMPLE: Consider the buddy
    ;; (define b (new SquareToy% [x 100][y 100][x-off 100]
    ;;                           [y-off 100][selected? false]
    ;;                           [buddies (list sq)][color "green"])
    ;; (send b buddy-after-drag 10 10)
    ;; updates x field of b to 110, y filed to 110 and color of b to
    ;; red    
    
    (define/public (buddy-after-drag mx my)
      (set! x (- mx x-off))
      (set! y (- my y-off))
      (set! color "red"))   
    
    
    ;; toy-after-button-up : -> Void
    ;; GIVEN: no arguments
    ;; EFFECT: updates this StatefulToy<%> to the 
    ;; state that it should be in after the button up MouseEvent
    ;; EXAMPLE: refer test
    
    (define (toy-after-button-up)
      (set! selected? false)
      (set! color "green")
      (for-each
       ;StatefulToy<%> -> Void
       ;GIVEN: a buddy of this square toy
       ;EFFECT: updates the state of the buddy to the state that
       ;it should be in after button up
       (lambda (toy) (send toy buddy-after-button-up))
       buddies)) 
    
    
    ;; buddy-after-button-up : -> Void
    ;; GIVEN: no arguments
    ;; EFFECT: updates the state of buddy of the square toy to the state that
    ;; it should be in after button up
    ;; EXAMPLE: Consider the buddy
    ;; (define b (new SquareToy% [x 100][y 100][x-off 100]
    ;;                           [y-off 100][selected? false]
    ;;                           [buddies (list sq)][color "red"])
    ;; (send b buddies-after-button-down)
    ;; updates the color field of b to green
    
    (define/public (buddy-after-button-up)
      (set! color "green"))   
    
    ;; in-toy? : Integer Integer -> Boolean
    ;; GIVEN: x,y coordinates of a location on the canvas
    ;; RETURNS: true iff the location is inside this square toy.
    ;; EXAMPLE: Consider this square toy
    ;; (define b (new SquareToy% [x 100][y 100][x-off 100]
    ;;                           [y-off 100][selected? false]
    ;;                           [buddies (list sq)][color "green"])
    ;; (in-toy? 90 90) -> true
    ;; (in-toy? 200 200) -> false
    
    (define (in-toy? mouse-x mouse-y)
      (and (and (<= mouse-x (+ x HALF-SQUARE-WIDTH))
                (>= mouse-x (- x HALF-SQUARE-WIDTH)))
           (and (<= mouse-y (+ y HALF-SQUARE-WIDTH))
                (>= mouse-y (- y HALF-SQUARE-WIDTH)))))
    
    ;; add-to-scene: Scene -> Scene
    ;; GIVEN: a scene
    ;; RETURNS: a Scene like the given one, but with this square toy drawn
    ;; on it.
    ;; EXAMPLE: Consider this square toy
    ;; (define sq1 (new SquareToy% [x 100][y 100][x-off 100]
    ;;                           [y-off 100][selected? false]
    ;;                           [buddies empty][color "green"]))
    ;; (send sq1 add-to-scene EMPTY-CANVAS) ->
    ;; (place-image (square SQUARE-WIDTH "outline" COLOR) 100 100 EMPTY-CANVAS)
    ;; the square image is painted at 100,100(coordinates of square toy's 
    ;; centre) on the given scene
    
    (define/public (add-to-scene scene)
      (place-image (square SQUARE-WIDTH "outline" color) x y scene))    
    
    ;; toy-x: -> PosInt
    ;; GIVEN: no arguments
    ;; RETURNS: x coordinate of the centre of this square toy
    ;; EXAMPLE: Consider this square toy
    ;; (define sq1 (new SquareToy% [x 100][y 110][x-off 70]
    ;;                           [y-off 80][selected? false]
    ;;                           [buddies empty][color "green"]))
    ;; (send sq1 toy-x) -> 100
    ;; returns the x coordinate i.e 100 in the example.
    
    (define/public (toy-x)
      x)
    
    ;; toy-y: -> PosInt
    ;; GIVEN: no arguments
    ;; RETURNS: y coordinate of the centre of this square toy
    ;; EXAMPLE: Consider this square toy
    ;; (define sq1 (new SquareToy% [x 100][y 110][x-off 70]
    ;;                           [y-off 80][selected? false]
    ;;                           [buddies empty][color "green"]))
    ;; (send sq1 toy-y) -> 110
    ;; returns the y coordinate i.e 110 in the example.
    
    (define/public (toy-y)
      y)    
    
    ;; toy-selected?: -> Boolean
    ;; GIVEN: no arguments
    ;; RETURNS: true if this square toy is selected, false otherwise
    ;; EXAMPLE: Consider this square toy
    ;; (define sq1 (new SquareToy% [x 100][y 110][x-off 70]
    ;;                           [y-off 80][selected? false]
    ;;                           [buddies empty][color "green"]))
    ;; (send sq1 toy-selected?) -> false
    
    (define/public (toy-selected?)
      selected?)
    
    ;; toy-color: -> ColorString
    ;; GIVEN: no arguments
    ;; RETURNS: current color of this square toy
    ;; EXAMPLE: Consider this square toy
    ;; (define sq1 (new SquareToy% [x 100][y 110][x-off 70]
    ;;                           [y-off 80][selected? false]
    ;;                           [buddies empty][color "green"]))
    ;; (send sq1 toy-color) -> "green"
    
    (define/public (toy-color)
      color)    
    ))




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  

;; make-world : PosInt -> World%
;; GIVEN: a speed
;; RETURNS: a world with a target, but no toys, and in which any square
;; toys created in the future will travel at the given speed (in pixels/tick).
;; EXAMPLE: (make-world)->
;; (new World% [tgt (new Target% [x 200][y 250][selected? false]
;;                               [x-off 200][y-off 250][color "black"])]
;;             [toys empty])
;; STRATEGY: function composition

(define (make-world)
  (new World% 
       [tgt (new Target% 
                 [x TARGET-INITIAL-X]
                 [y TARGET-INITIAL-Y]
                 [selected? false]
                 [x-off TARGET-INITIAL-X]
                 [y-off TARGET-INITIAL-Y]
                 [color "black"])]
       [toys empty]))


;; make-square-toy : PosInt PosInt PosInt -> SquareToy%
;; GIVEN: an x and a y position
;; RETURNS: an object representing a square toy centred at the given position,
;; EXAMPLE: (make-square-toy 10 20)
;; -> (new SquareToy% [x 10][y 20][x-off 10]
;;                    [y-off 20][selected? false]
;;                    [buddies empty][color "green"]))
;; STRATEGY: function composition

(define (make-square-toy x y)
  (new SquareToy% 
       [x x]
       [y y]
       [x-off x]
       [y-off y]
       [selected? false]
       [buddies empty]
       [color "green"]))


;; run : PosNum -> World%
;; GIVEN: a frame rate (in seconds/tick)
;; EFFECT: runs the world at the given frame rate
;; RETURNS: the final state of the world
;; EXAMPLE: (run 0.25) -> final state of the world
;; STRATEGY: function composition

(define (run rate)
  (big-bang (make-world)
            (on-tick
             ;World% -> World%
             ;GIVEN: a world
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
    ((define t1 (new Target% [x TARGET-INITIAL-X][y TARGET-INITIAL-Y]
                     [selected? false][x-off TARGET-INITIAL-X]
                     [y-off TARGET-INITIAL-Y][color "black"])))
    (define sq1 (new SquareToy% [x 100][y 100][x-off 100][y-off 100]
                     [selected? false][buddies empty][color "green"]))
    (define sq2 (new SquareToy% [x 90][y 90][x-off 90][y-off 90]
                     [selected? false][buddies empty][color "green"]))
    (define sq3 (new SquareToy% [x 100][y 100][x-off 100][y-off 100]
                     [selected? true][buddies empty][color "red"]))
    (define sq4 (new SquareToy% [x 100][y 100][x-off 100][y-off 100]
                     [selected? false][buddies empty][color "green"]))
    (define sq5 (new SquareToy% [x 200][y 200][x-off 200][y-off 200]
                     [selected? true][buddies (list sq2)][color "red"]))
    (define sq6 (new SquareToy% [x 190][y 190][x-off 90][y-off 90]
                     [selected? false][buddies (list sq5)][color "red"]))
    (define sq7 (new SquareToy% [x 190][y 190][x-off 10][y-off 10]
                     [selected? false][buddies (list sq5)][color "red"]))
    (define initial-world (make-world))
    (define world1 (new World% 
                        [tgt t1]
                        [toys (list sq1 sq2)]))
    ;; world on draw example  
    (check-equal? (send world1 on-draw)
                  (place-image (square 30 "outline" "green") 90 90
                               (place-image 
                                (square 30 "outline" "green") 100 100
                                (place-image (circle 10 "outline" "black")
                                             200 250
                                             EMPTY-CANVAS)))
                  "image of world with a two squares at 90,90 and 100,100
                   should appear")
    ;; world on-tick example
    (send initial-world on-tick)
    (check world-equal? initial-world (make-world)
           "the same world should be returned")
    ;; world on key example 
    (send initial-world on-key "x")
    (check world-equal? initial-world (make-world)
           "no-change should occur for any other key event")
    (send initial-world on-key "s")
    (check world-equal? initial-world  
           (new World% 
                [tgt t1]
                [toys (list (new SquareToy% 
                                 [x TARGET-INITIAL-X][y TARGET-INITIAL-Y]
                                 [x-off TARGET-INITIAL-X]
                                 [y-off TARGET-INITIAL-Y]
                                 [selected? false][buddies empty]
                                 [color "green"]))])
           "a new square toy should be generated at the centre of canvas") 
    ;; world on mouse example
    (send world1 on-mouse 100 100 "button-down")
    (check world-equal? world1 (new World% 
                                    [tgt t1]
                                    [toys (list sq3 sq2)])
           "sq1 should get selected")
    (send world1 on-mouse 200 200 "drag")
    (check world-equal? world1 (new World% 
                                    [tgt t1]
                                    [toys (list sq5 sq6)])
           "the toys should be dragged")
    (send world1 on-mouse 200 200 "button-down")
    (check world-equal? world1 (new World% 
                                    [tgt t1]
                                    [toys (list sq5 sq6)])
           "sq5 should be selected")
    (send world1 on-mouse 200 200 "drag")
    (check world-equal? world1 (new World% 
                                    [tgt t1]
                                    [toys (list sq5 sq6)])
           "the toys should be dragged")
    (send sq5 on-mouse 300 300 "button-up")
    (send sq6 on-mouse 300 300 "button-up")
    (send world1 on-mouse 300 300 "button-up")
    (check world-equal? world1 (new World% 
                                    [tgt t1]
                                    [toys (list sq5 sq6)])
           "sq5 should be unselected")
    ;; target-selected example 
    (check-equal? (send world1 target-selected?)
                  false
                  "target is not selected in the given world")
    ;; target-color example 
    (check-equal? (send world1 target-color)
                  "black"
                  "target color is black in the given world")
    ;; square-toy on-mouse example
    (send sq4 on-mouse 300 300 "button-down")
    (check toy-equal? sq4 (new SquareToy% [x 100][y 100][x-off 100][y-off 100]
                               [selected? false][buddies empty][color "green"])
           "no effect as the mouse pointer is outside toy")
    (send sq4 on-mouse 100 100 "drag")
    (check toy-equal? sq4 (new SquareToy% [x 100][y 100][x-off 100][y-off 100]
                               [selected? false][buddies empty][color "green"])
           "no effect as the toy is not selected")
    (send sq4 on-mouse 100 100 "move")
    (check toy-equal? sq4 (new SquareToy% [x 100][y 100][x-off 100][y-off 100]
                               [selected? false][buddies empty][color "green"])
           "no effect of other mouse event")
    (send sq4 on-mouse 105 105 "button-down")
    (check toy-equal? sq4 (new SquareToy% [x 100][y 100][x-off 105][y-off 105]
                               [selected? true][buddies empty][color "red"])
           "the toy should be selected")
    (send sq4 on-mouse 300 300 "drag")
    (check toy-equal? sq4 (new SquareToy% [x 295][y 295][x-off 300][y-off 300]
                               [selected? true][buddies empty][color "red"])
           "the toy should be dragged to the new position 295, 295")
    (send sq4 on-mouse 300 300 "button-up")
    (check toy-equal? sq4 (new SquareToy% [x 295][y 295][x-off 300][y-off 300]
                               [selected? false][buddies empty][color "green"])
           "the toy should be unselected")    
    (check-equal? (send sq4 toy-color) "green"
                  "the value should be green")
    (check-equal? (send sq4 toy-selected?) false
                  "the value should be false")    
    ;; tgt-on-mouse, button down example, mouse pointer outside 
    (send t1 tgt-on-mouse 300 300 "button-down")
    (check target-equal? t1 (new Target% 
                                 [x 200][y 250]
                                 [selected? false]
                                 [x-off 200][y-off 250]
                                 [color "black"])
           "no effect as the mouse pointer is outside target")
    ;; tgt-on-mouse, drag example, target not selected
    (send t1 tgt-on-mouse 100 100 "drag")
    (check target-equal? t1 (new Target% 
                                 [x 200][y 250]
                                 [selected? false]
                                 [x-off 200][y-off 250]
                                 [color "black"])
           "no effect as the target is not selected")
    ;; other mouse event on target example
    (send t1 tgt-on-mouse 100 100 "move")
    (check target-equal? t1 (new Target% 
                                 [x 200][y 250]
                                 [selected? false]
                                 [x-off 200][y-off 250]
                                 [color "black"])
           "no effect of other mouse event")
    ;; tgt-on-mouse, button-down example, mouse pointer inside
    (send t1 tgt-on-mouse 195 245 "button-down")
    (check target-equal? t1 (new Target% 
                                 [x 200]
                                 [y 250]
                                 [selected? true]
                                 [x-off 195]
                                 [y-off 245]
                                 [color "orange"])
           "the target should be selected")
    ;; tgt-on-mouse, drag  example, slected target
    (send t1 tgt-on-mouse 300 300 "drag")
    (check target-equal? t1 (new Target% 
                                 [x 305]
                                 [y 305]
                                 [selected? true]
                                 [x-off 300]
                                 [y-off 300]
                                 [color "orange"])
           "the x y coordinates of target should be 305 and 305")
    ;; tgt-on-mouse, button-up example
    (send t1 tgt-on-mouse 300 300 "button-up")
    (check target-equal? t1 (new Target% 
                                 [x 305]
                                 [y 305]
                                 [selected? false]
                                 [x-off 300]
                                 [y-off 300]
                                 [color "black"]))
    "the target should be unselected"))


