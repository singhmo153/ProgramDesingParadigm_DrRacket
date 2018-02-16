;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname trees) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
;;trees.rkt


(require rackunit)
(require "extras.rkt")
(require 2htdp/universe)
(require 2htdp/image)

(provide initial-world)
(provide run)
(provide world-after-mouse-event)
(provide world-after-key-event)
(provide world-to-roots)
(provide node-to-center)
(provide node-to-sons)
(provide node-to-selected?)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; node's dimension constants
(define SQUARE-SIZE 20)
(define HALF-SQUARE-SIZE (/ SQUARE-SIZE 2))

;; color constant for vertical line
(define VERTICAL-LINE-COLOR "red")

;; color constant for downlines
(define DOWNLINE-COLOR "blue")

;; canvas's dimension constants
(define CANVAS-WIDTH 400)
(define CANVAS-HEIGHT 400)

;; image constants
(define GREEN-SQUARE (square SQUARE-SIZE "solid" "green"))
(define RED-SQUARE (square SQUARE-SIZE "solid" "red"))
(define OUTLINE-SQUARE (square SQUARE-SIZE "outline" "green"))
(define EMPTY-CANVAS (empty-scene CANVAS-WIDTH CANVAS-HEIGHT))

;; root's initial center coordinates
(define ROOT-INITIAL-X  (/ CANVAS-WIDTH 2))
(define ROOT-INITIAL-Y  (/ SQUARE-SIZE 2))

;; boundary constants
(define TOP-BOUNDARY 0)
(define LEFT-BOUNDARY 0)

;; number constants
(define NULL 0)

;; center of new son square has an x-coordinate which is two square-lengths to 
;; the left of the center of the currently leftmost son

(define X-SPACE (* 2 SQUARE-SIZE)) 

;; center of new son square has a y-coordinate which is three squares down 
;; from the center of the parent
(define Y-SPACE (* 3 SQUARE-SIZE))

;; key-event-constants
(define NEW-ROOT-EVENT "t")
(define NEW-SON-EVENT "n")
(define DELETE-TREE-EVENT "d")
(define DELETE-TREES-ON-UPPER-CANVAS-EVENT "u")

;;;;;;;;;;;;;;;;;;;;;;;;;;;DATA DEFINITIONS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(define-struct node (x-pos y-pos selected? sons))
;; a Node is a (make-node Integer Integer Boolean LON)
;; Interpretation: 
;; (x-posn y-posn) is the location of the square node's center in pixel
;; selected? describes whether a node is selected or not
;; sons is a list of all sons(nodes) that a node has
;; Template:
;; node-fn: Node -> ???
;(define (node-fn node) 
;  (...
;   (node-x-posn node)
;   (node-y-posn node)
;   (node-selected? node)
;   (node-sons node)))

;; Example:
(define DEFAULT-ROOT-NODE 
  (make-node ROOT-INITIAL-X ROOT-INITIAL-Y false empty))


;; A  ListOfNodes(LON) is one of

;; -- empty             Interpretation: empty represents an empty list of nodes
;; -- (cons Node LON)   Interpretation: (cons Node LON) represents a non-empty
;;                                      list of nodes

;;Template:
;; lon-fn : LON-> ???
;(define (lon-fn lon)
;  (cond
;    [(empty? lon) ...]
;    [else (... (node-fn (frist lon))
;               (lon-fn (rest lon)))]))

(define-struct world (roots))
;; a World is a (make-world LON)
;; Interpretation: 
;; roots is a list of roots(nodes) the world has

;; Template:
;; world-fn : world -> ???
;(define (world-fn w)
;  (... (world-roots w)))

;; Example:
;(define world1 (make-world (list (make-node 100 150 false empty))))


;;;;;;;;;;;;;;;;;;;;;;;;;;FUNCTION DEFINITIONS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;initial-world : Any -> World
;;GIVEN: any value
;;RETURNS: an initial world.  The given value is ignored.
;;EXAMPLE: refer tests
;;STRATEGY: function composition

(define (initial-world n)
  (make-world empty))

;;TEST: test follow function definitions

;;run : Any -> World
;;GIVEN: any value
;;EFFECT: runs a copy of an initial world
;;RETURNS: the final state of the world.  The given value is ignored.
;;EXAMPLE: (run 1) creates and runs a world that is a blank canvas.
;;STRATEGY: function composition

(define (run n)
  (big-bang (initial-world 0)
            (on-draw world->scene)
            (on-mouse world-after-mouse-event)    
            (on-key world-after-key-event)))

;;world->scene: World -> Scene
;;GIVEN: a world
;;RETURNS: a scene of the given world 
;;EXAMPLE: refer tests
;;STRATEGY: structural decomposition on w : World

(define (world->scene w)
  (place-trees  (world-roots w) EMPTY-CANVAS))

;;TEST: test follow function definitions

;;place-trees: LON Scene -> Scene
;;GIVEN: a list of nodes with each node representing the root of a tree, 
;;and a scene. 
;;RETURNS: return a scene just like the given scene except that the given
;;list of nodes and its subtrees are drawn in it
;;EXAMPLE: (place-trees (list root1 root2) EMPTY-CANVAS)
;;This will return a scene with root1 and root2 node, and their subtrees
;;drawn to the empty-canvas.
;;STRATEGY: HOFC

(define (place-trees lon scene)
  (foldr 
   place-tree 
   scene
   lon))

;;TEST: test follow function definitions

;;place-tree: Node Scene -> Scene
;;GIVEN: the root node of a tree and a scene. 
;;RETURNS: return a scene just like the given scene except that the given
;;node and its subtrees are drawn in it
;;EXAMPLE: (place-tree root1 EMPTY-CANVAS)
;;This will return a scene with root1, and its subtrees drawn to the empty
;;canvas
;;STRATEGY: structural decomposition on root : Node

(define (place-tree root scene)  
  (place-a-node-and-its-downlines-redline root   
                                          (place-trees (node-sons root) 
                                                       scene)))

;;TEST: test follow function definitions

;;place-a-node-and-its-downlines-redline: Node Scene -> Scene
;;GIVEN: a node and a scene
;;RETURNS: a scene like the given scene except the given node and
;;its downlines to its sons and redline are drawn to it
;;EXAMLE: 
;;(place-a-node-and-its-downlines-redline
;; (make-node 100 150 true (list (make-node 100 210 false empty)))) 
;; EMPTY-CANVAS)
;;It will return a scene with a image of two nodes with their center at 
;;(100,150) and (100 210), a blue line drawn between the centre of the node
;;and its son and a vertical red line drawn at x coordinate 50, representing
;;the leftmost edge of the next son.
;;STRATEGY: HOFC

(define (place-a-node-and-its-downlines-redline node scene)
  (place-a-node 
   node 
   (place-downlines 
    node
    (place-redline
     node scene))))

;;TEST: test follow function definitions

;;place-redline: Node Scene -> Scene
;;GIVEN: a node and a scene
;;RETURNS: a scene like the given except that if the node is selected 
;;a vertical line is drawn at the position where the left edge of a new
;;son would be if it were created
;;EXAMPLE:
;;(place-redline (make-node 100 150 true empty) EMPTY-CANVAS)
;;It will return a scene with a red line vertical line drawn at 
;;x-coordinate 90 representing the left edge of the new son.
;;STRATGEY: structural decomposition on node: Node

(define (place-redline node scene)
  (if (node-selected? node)
      (scene+line scene
                  (verticalLine-X node)
                  TOP-BOUNDARY
                  (verticalLine-X node)
                  CANVAS-HEIGHT
                  VERTICAL-LINE-COLOR)
      scene))

;;TEST: test follow function definitions

;;place-a-node: Node Scene -> Scene
;;GIVEN: a node and a scene
;;RETURN: a scene just like the given scene except that the given node 
;;is drawn in it
;;EXAMPLE:
;;(place-a-node (make-node 100 150 true empty) EMPTY-CANVAS))
;;It will return a scene with the image of a solid green square centred at
;;(100,150) drawn to it.
;;STRATEGY: structural decomposition on node:Node

(define (place-a-node node scene)
  (if (node-selected? node)
      (place-selected-node node scene)
      (place-unselected-node node scene)))

;;TEST: test follow function definitions

;;place-unselected-node: Node Scene -> Scene
;;GIVEN: a node and a scene
;;WHERE: the node is unselected
;;RETURN: a scene just like the given scene except that the given node 
;;is drawn in it
;;EXAMPLE: 
;;(place-unselected-node (make-node 100 150 false empty) EMPTY-CANVAS)
;;It will return a scene with the image of a outline green square centred at
;;(100,150) drawn to it.
;;STRATEGY: structural decomposition on node:Node

(define (place-unselected-node node scene)
  (place-image 
   OUTLINE-SQUARE
   (node-x-pos node)
   (node-y-pos node)
   scene))

;;TEST: test follow function definitions

;;place-selected-node: Node Scene -> Scene
;;GIVEN: a node and a scene
;;WHERE: the node is selected
;;RETURNS: a scene just like the given scene except that the given node 
;;is drawn in it
;;(place-selected-node (make-node 100 150 true empty) EMPTY-CANVAS))
;;It will return a scene with the image of a solid green square centred at
;;(100,150) drawn to it.
;;STRATEGY: structural decomposition on node:Node

(define (place-selected-node node scene)
  (if (new-son-addable? node)      
      (place-image GREEN-SQUARE (node-x-pos node) (node-y-pos node) scene)
      (place-image RED-SQUARE (node-x-pos node) (node-y-pos node) scene)))

;;TEST: test follow function definitions

;;new-son-addable?: Node -> Boolean
;;GIVEN: a node
;;RETURNS: return true iff there is space to add a new son to the given node
;;EXAMPLE: (new-son-addable? (make-node 150 100 true empty)) = true
;;STRATEGY: function composition

(define (new-son-addable? node)
  (> (verticalLine-X node) LEFT-BOUNDARY))

;;TEST: test follow function definitions

;;verticalLine-X: Node-> Integer
;;GIVEN: a node
;;RETURNS: the x cordinate of the vertical line when the given node is 
;;selected.
;;EXAMPLE: (verticalLine-X (make-node 150 100 true empty)) = 140
;;STRATEGY: structural decomposition on node : Node

(define (verticalLine-X node) 
  (if (empty? (node-sons node))
      (- (node-x-pos node) HALF-SQUARE-SIZE)
      (- (minX (node-sons node)) X-SPACE HALF-SQUARE-SIZE))) 

;;TEST: test follow function definitions

;;minX: LON -> Integer
;;GIVEN: a list of nodes
;;WHERE: LON is not empty
;;RETURNS: the minmum x cordinate among the given list of nodes
;;EXAMPLE: (minX (make-node 150 100 true empty) 
;;               (make-node 100 100 true empty)) = 100
;;STRATEGY: HOFC
(define (minX lons)
  (apply 
   min
   (map
    node-x-pos
    lons)))

;;TEST: test follow function definitions

;;place-downlines: Node Scene -> Scene
;;GIVEN: a node and a scene
;;RETURNS: a scene just like the given scene except that the connection lines
;;of the given node and its sons are drawn.
;;EXAMPLE:
;;(place-downlines
;; (make-node 100 150 false (list (make-node 100 210 false empty)
;;                                (make-node 60 210 false empty))) EMPTY-CANVAS)
;;It will return a scene with two blue lines drawn from (100,150) to (100,210)
;;and (100,150) to (60 210).
;;STRATEGY: structural decomposition on node: Node

(define (place-downlines node scene)
  (foldr    
   ; Node  Scene -> Scene
   ;;GIVEN: a node and a scene constructed so far
   ;;RETURN: a scene just like the given scene except that a line is drawn 
   ;;between the given node and its parent node 
   (lambda (son scene) (place-a-line node son scene))     
   scene
   (node-sons node)))

;;TEST: test follow function definitions

;;place-a-line: Node Node Scene -> Scene
;;GIVEN: two nodes and a scene
;;RETURNS: a scene just like the given scene except that a line is drawn 
;;between the centers of the two given nodes
;;EXAMPLE:
;;(place-a-line (make-node 100 150 false (list (make-node 100 210 false empty))
;;              (make-node 100 210 false empty) EMPTY-CANVAS)
;;It will return a scene with a blue line drawn from (100,150) to (100,210)
;;STRATEGY: structural decomposition on parent: Node

(define (place-a-line parent son scene)
  (place-a-line-helper (node-x-pos parent) (node-y-pos parent) son scene))

;;TEST: test follow function definitions

;;place-a-line-helper: Integer Integer Node Scene -> Scene
;;GIVEN: x an y coordinates of some node, a node and a scene
;;RETURNS: a scene just like the given scene except that a line is drawn 
;;between the given coordinates and the node's center
;;EXAMPLE:
;;(place-a-line-helper 
;;  100 150 (make-node 100 210 false empty) EMPTY-CANVAS)
;;=a scene with a blue line drawn from (100,150) to (100,210)
;;STRATEGY: structural decomposition on son: Node


(define (place-a-line-helper parent-x parent-y son scene)
  (scene+line scene parent-x
              parent-y
              (node-x-pos son)
              (node-y-pos son)
              DOWNLINE-COLOR))

;;TEST: test follow function definitions

;;world-after-key-event: World KeyEvent -> World
;;GIVEN: a world w and a keyevent
;;RETURNS: the world that should follow the given world after the given
;;key event.
;;EXAMPLES: refer test
;;STRATEGY: Cases on kev : KeyEvent

(define (world-after-key-event w kev)
  (cond    
    [(key=? kev NEW-ROOT-EVENT) 
     (world-after-creating-new-root w)]    
    [(key=? kev NEW-SON-EVENT) 
     (world-after-creating-new-son w)]    
    [(key=? kev DELETE-TREE-EVENT)  
     (world-after-deleting-nodes w node-selected?)]    
    [(key=? kev DELETE-TREES-ON-UPPER-CANVAS-EVENT) 
     (world-after-deleting-nodes w node-in-upper-canvas?)]    
    [else w]))

;;TEST: test follow function definitions

;;world-after-creating-new-root : World -> World
;;GIVEN: a world
;;RETURNS: a world just like the given world except that a new root node 
;;is added
;;EXAMPLE: refer test
;;STRATEGY: structural decomposition on w : world

(define (world-after-creating-new-root w)
  (make-world 
   (cons DEFAULT-ROOT-NODE (world-roots w))))

;;TEST: test follow function definitions

;;world-after-creating-new-son: World -> World
;;GIVEN: a world
;;RETURNS: a world just like the given world except that a new son is added 
;;to the selected node in the world
;;EXAMPLE: refer test
;;STRATEGY: structural decomposition on w : world

(define (world-after-creating-new-son w)
  (make-world 
   (trees-after-son-added-to-selected-nodes
    (world-roots w))))

;;TEST: test follow function definitions

;;trees-after-son-added-to-selected-nodes: LON -> LON
;;GIVEN: a list of nodes(trees)
;;RETURNS: a list of nodes(trees) just like the given trees except that
;;son are added to any selected nodes in the given trees
;;EXAMPLE:
;;(trees-after-son-added-to-selected-nodes
;; (list (make-node 100 150 true empty) (make-node 200 150 false empty)))
;;=(list (make-node 100 150 true (list (make-node 100 210 false empty)))
;;       (make-node 200 150 false empty))
;;STRATEGY: HOFC

(define (trees-after-son-added-to-selected-nodes lon)
  (map  
   tree-after-son-added-to-selected-node
   lon))

;;TEST: test follow function definitions

;;tree-after-son-added-to-selected-node: Node -> Node
;;GIVEN: a node that represents a tree
;;RETURNS: return the given tree after a son is added to any selected
;;node in this tree
;;EXAMPLE: 
;;(tree-after-son-added-to-selected-node
;; (make-node 100 150 true empty))
;;=(make-node 100 150 true (list (make-node 100 210 false empty)))
;;STRATEGY: structural decomposition on node: Node

(define (tree-after-son-added-to-selected-node node)
  (if (node-selected? node)
      (node-after-son-added node)                  
      (node-after-son-added-to-selected-nodes-in-subtrees node)))

;;TEST: test follow function definitions

;;node-after-son-added: Node -> Node
;;GIVEN: a node
;;WHERE: the node is selected
;;RETURN: a node just like the given node except that a son is added to it,
;;and sons are added to any slected nodes in the given node's subtrees
;;EXAMPLE: 
;;(node-after-son-added
;; (make-node 100 150 true empty))
;;=(make-node 100 150 true (list (make-node 100 210 false empty)))
;;STRATEGY: structural decomposition on node: Node

(define  (node-after-son-added node)     
  (make-node 
   (node-x-pos node)
   (node-y-pos node)
   (node-selected? node)
   (add-new-node-to-lon node
                        (trees-after-son-added-to-selected-nodes 
                         (node-sons node)))))    

;;TEST: test follow function definitions

;;node-after-son-added-to-selected-nodes-in-subtrees: Node -> Node
;;GIVEN: a node
;;WHERE: the node is NOT selected
;;RETURN: a node just like the given node except that sons are added to any
;;selected nodes in the given node's subtrees
;;EXAMPLE:
;;(node-after-son-added-to-selected-nodes-in-subtrees
;; (make-node 100 150 false (list (make-node 100 210 true empty))))
;;=(make-node 100 150 false 
;;  (list (make-node 100 210 true (list (make-node 100 270 false empty)))))
;;STRATEGY: structural decomposition on node: Node

(define  (node-after-son-added-to-selected-nodes-in-subtrees node)
  (make-node 
   (node-x-pos node)
   (node-y-pos node)
   (node-selected? node)
   (trees-after-son-added-to-selected-nodes (node-sons node))))

;;TEST: test follow function definitions

;;add-new-node-to-lon: Node ListOfNodes -> ListOfNodes
;;GIVEN: the parent node and its sons 
;;RETURNS: a list of nodes just like the given list of nodes except 
;;that a new node is added to it
;;EXAMPLE:
;;(add-new-node-to-lon (make-node 100 150 true empty) empty)
;;=(list (make-node 100 210 false empty))
;;STRATEGY: structural decomposition on parent: Node

(define (add-new-node-to-lon parent sons)
  (if (new-son-addable? parent)      
      (cons (make-node 
             (+ (verticalLine-X parent) HALF-SQUARE-SIZE)
             (+ (node-y-pos parent) Y-SPACE)
             false
             empty)
            sons)         
      sons))

;;TEST: test follow function definitions

;;world-after-deleting-nodes: World [Node -> Boolean] -> World
;;GIVEN: a world, a function named delete? that takes a node and 
;;returns true iff a node meet the deletion condition    
;;RETURNS: a world that the given world should become after all the nodes that 
;;meet the given deletion condition are deleted
;;EXAMPLE: refer tests
;;STRATEGY: structural decomposition on w : World


(define  (world-after-deleting-nodes w delete?)
  (make-world
   (trees-after-deleting-nodes
    (world-roots w) delete?)))

;;TEST: test follow function definitions

;;trees-after-deleting-nodes: ListOfNodes [Node -> Boolean] -> ListOfNodes
;;GIVEN: a list of nodes, a function named delete? that takes a node and 
;;returns true iff a node meet the deletion condition   
;;RETURN: a list of nodes that the given list of nodes should become after all
;;the nodes that meet the given deletion condition are deleted
;;EXAMPLE:
;;(trees-after-deleting-nodes
;; (list (make-node 100 150 true empty)
;;       (make-node 200 150 false empty)) node-selected?)
;;= (list (make-node 200 150 false empty))
;;STRATEGY: HOFC

(define (trees-after-deleting-nodes nodes delete?)
  (filter
   node?
   (map
    (lambda (node) (tree-after-deleting-node node delete?))       
    nodes)))  

;;TEST: test follow function definitions

;;tree-after-deleting-node: Node [Node -> Boolean] -> Node
;;GIVEN: a node, a function named delete? that takes a node and 
;;returns true iff a node meet the deletion condition   
;;RETURNS: returns empty if the node meet the deletion codition, otherwise
;;return a node just like the given node except that all the nodes in its 
;;subtrees that meet the given deletion condition are deleted
;;EXAMPLE:
;;(tree-after-deleting-node (make-node 100 150 true empty) node-selected?)
;;= empty
;;STRATEGY:structural decomposition on node: Node

(define (tree-after-deleting-node node delete?)
  (if (delete? node) 
      empty
      (make-node 
       (node-x-pos node)   (node-y-pos node)   false
       (trees-after-deleting-nodes 
        (node-sons node) delete?))))

;;TEST: test follow function definitions

;;node-in-upper-canvas? : Node -> Boolean
;;GIVEN: a node
;;RETURNS: return true iff the given node is in the upper section of the canvas
;;EXAMPLE: (node-in-upper-canvas? (make-node 100 100 false empty)) = true
;;STRATEGY: structural decomposition on node: Node


(define (node-in-upper-canvas? node)
  (< (node-y-pos node )(/ CANVAS-HEIGHT 2)))


;;TEST: test follow function definitions

;;world-after-mouse-event : World Integer Integer MouseEvent -> World
;;GIVEN:a World, a position and a MouseEvent
;;RETURNS: the world that should follow the given mouse event
;;EXAMPLE: refer test
;;STRATEGY: structural decomposition on w: World

(define (world-after-mouse-event w mx my mev)
  (make-world 
   (nodes-after-mouse-event (world-roots w) mx my mev)))

;;TEST: test follow function definitions

;;nodes-after-mouse-event: LON Integer Integer MouseEvent -> LON
;;GIVEN: a list of nodes(roots), x and y coordinates of mouse
;;pointer and a mouse event.
;;RETURNS: the list of nodes that should follow the given mouse event
;;EXAMPLE: 
;;(nodes-after-mouse-event 
;; (list (make-node 100 150 false empty) (make-node 200 150 false empty))
;; 100 150 "button-down")
;; = (list (make-node 100 150 true empty) (make-node 200 150 false empty))
;;STRATEGY: HOFC


(define (nodes-after-mouse-event lon mx my mev)
  (map 
   ;;Node -> Node
   ;;GIVEN: a node
   ;;RETURN: a node that the given node should be after the
   ;;mouse event
   (lambda (node) (node-after-mouse-event node mx my mev))
   lon))

;;TEST: test follow function definitions

;;node-after-mouse-event: Node Integer Integer MouseEvent -> Node
;;GIVEN: a node, cursor position and mouse event type
;;RETURNS: a node that the given node should become after the given moust event
;;EXAMPLE: 
;;(node-after-mouse-event (make-node 100 150 false empty) 100 150 "button-down")
;;=(make-node 100 150 true empty)
;;STRATEGY: Cases on mev : MouseEvent

(define (node-after-mouse-event node mx my mev)
  (cond 
    [(mouse=? mev "button-down") (node-after-button-down node mx my)]
    [(mouse=? mev "drag") (node-after-drag node mx my)]
    [(mouse=? mev "button-up")(node-after-button-up node mx my)]
    [else node]))

;;TEST: test follow function definitions

;;node-after-button-down: Node Integer Integer -> Node
;;GIVEN: a node, cursor position 
;;RETURNS:a node that the given node should become after a button down occurs 
;;at the given position
;;EXAMPLE:
;;(node-after-button-down (make-node 100 150 false empty) 100 150)
;;=(make-node 100 150 true empty)
;;STRATEGY: structural decomposition on node: Node

(define (node-after-button-down node mx my)
  (make-node
   (node-x-pos node)
   (node-y-pos node)
   (mouse-in-square? node mx my)    
   (nodes-after-mouse-event (node-sons node) mx my "button-down")))

;;TEST: test follow function definitions

;;node-after-drag: Node Integer Integer -> Node
;;GIVEN: a node, cursor position 
;;RETURNS:a node that the given node should become after a mouse drag occurs at 
;;the given position
;;EXAMPLE: 
;;(node-after-drag (make-node 100 150 true empty) 200 100)
;;=(make-node 200 100 true empty)
;;STRATEGY: structural decomposition on node: Node

(define (node-after-drag node mx my)
  (if (node-selected? node)       
      (make-node
       mx my true        
       (nodes-moved-by-xy (node-sons node) 
                          (- mx (node-x-pos node)) (- my (node-y-pos node))))                                                                                                
      (make-node
       (node-x-pos node)
       (node-y-pos node)
       false
       (nodes-after-mouse-event (node-sons node) mx my "drag"))))

;;TEST: test follow function definitions


;;node-moved-by-xy: Node Integer Integer -> Node
;;GIVEN: a node and  x shift distance in pixel, y shift distance in pixel
;;RETURNS: returns the given node after shifting it and its subtree by the 
;;given distance
;;EXAMPLE:
;;(node-moved-by-xy (make-node 200 100 true empty) 100 -50)
;;=(make-node 200 100 true empty)
;;STRATEGY: structural decomposition on node: Node

(define (node-moved-by-xy node x-shift y-shift)
  (make-node
   (+ (node-x-pos node) x-shift)
   (+ (node-y-pos node) y-shift)
   (node-selected? node)
   (nodes-moved-by-xy (node-sons node) x-shift y-shift)))

;;TEST: test follow function definitions

;;nodes-moved-by-xy: LON Integer Integer -> LON
;;GIVEN: a list of nodes and x y shift distance in pixel
;;RETURNS: a list of nodes just like the given list of nodes except that
;;they are displaced by the given x y pixels
;;EXAMPLE:
;;(nodes-moved-by-xy
;; (list (make-node 100 210 false empty) (make-node 60 210 false empty) 
;; 100 -50)
;;= (list (make-node 200 160 false empty) (make-node 160 160 false empty))
;;STRATEGY: HOFC

(define (nodes-moved-by-xy lon x-shift y-shift)
  (map
   ;; Node -> Node
   ;;GIVEN: a node
   ;;RETURN: a node like the given node except that it has been 
   ;; displaced by the given x-shift and y-shift in pixels
   (lambda (node) (node-moved-by-xy node x-shift y-shift))
   lon))

;;TEST: test follow function definitions

;;node-after-button-up: Node Integer Integer -> Node
;;GIVEN: a node, cursor position 
;;RETURN:a node that the given node should become after a button up occurs at 
;;the given position
;;EXAMPLE:
;;(node-after-button-up (make-node 100 150 true empty) 100 150)
;;= (make-node 100 150 false empty)
;;STRATEGY: structural decomposition on node: Node

(define (node-after-button-up node mx my)            
  (make-node
   (node-x-pos node)
   (node-y-pos node)
   false
   (nodes-after-mouse-event (node-sons node) mx my "button-up")))

;;TEST: test follow function definitions

;;mouse-in-square? : Node Integer Integer -> Boolean
;;GIVEN: a node, and a position
;;RETURNS: true iff the position is inside the node's square
;;EXAMPLE:
;;(mouse-in-square? (make-node 100 150 false empty) 100 150)
;;= true
;;STRATEGY: structural decomposition on node:Node

(define (mouse-in-square? node mx my)
  (and
   (<= (- (node-x-pos node) HALF-SQUARE-SIZE)
       mx
       (+ (node-x-pos node) HALF-SQUARE-SIZE))
   (<= (- (node-y-pos node) HALF-SQUARE-SIZE)
       my
       (+ (node-y-pos node) HALF-SQUARE-SIZE))))

;;TEST: test follow function definitions

;;world-to-roots : World -> LON
;;GIVEN: a World
;;RETURNS: a list of all the root nodes in the given world.
;;EXAMPLE: refer test
;;STRATEGY: structural decomposition on w : World

(define (world-to-roots w)
  (world-roots w))

;;TEST: test follow function definitions

;;node-to-center : Node -> Posn
;;GIVEN: a node
;;RETURNS: the center of the given node as it is to be displayed on the scene.
;;EXAMPLE: refer test
;;STRATEGY: structural decomposition on node: Node

(define (node-to-center node)
  (make-posn (node-x-pos node) (node-y-pos node)))

;;TEST: test follow function definitions

;;node-to-sons : Node -> LON
;;GIVEN: a node
;;RETURNS: the list of sons of the given node
;;EXAMPLE: refer test
;;STRATEGY: structural decomposition on node : Node

(define (node-to-sons node)
  (node-sons node))

;;TEST: test follow function definitions

;;node-to-selected? : Node -> Boolean
;;GIVEN: a node
;;RETURNS: true iff the node is selected
;;EXAMPLE: refer test
;;STRATEGY: structural decomposition on node : Node

(define (node-to-selected? node)
  (node-selected? node))

;;TEST : refer test below
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;TEST

; examples for testing

(define node1-son1 (make-node 50 250 false empty))
(define node1-son2 (make-node 100 250 false empty))
(define node1 (make-node 100 150 false (list node1-son1 node1-son2)))
(define node2 (make-node 200 150 false empty))
(define node3 (make-node 300 150 false empty))
(define root1 (make-node 
               ROOT-INITIAL-X ROOT-INITIAL-Y false (list node1 node2 node3)))
;; example of initial world, for testing
(define initial-empty-world (make-world empty))

;; example of world-to-scene, for testing
(define single-node-beyond-boundary-image
  (place-image RED-SQUARE -10 150 EMPTY-CANVAS))
(define world21 (make-world (list (make-node -10 150 true empty))))
(define unselected-node-image
  (place-image OUTLINE-SQUARE 100 150 EMPTY-CANVAS))
(define world22 (make-world (list (make-node 100 150 false empty))))


(define selected-node-with-son-image
  (place-image GREEN-SQUARE 100 90 
               (scene+line (scene+line 
                            (place-image OUTLINE-SQUARE 100 150 EMPTY-CANVAS)
                            50 0 50 400 "red")
                           100 90 100 150 "blue")))

(define world23 (make-world (list 
                             (make-node 100 90 true
                                        (list 
                                         (make-node 100 150 false empty))))))

;; example of world-after-new-root-event, for testing
(define initial-world-after-new-root-event 
  (make-world (list (make-node ROOT-INITIAL-X ROOT-INITIAL-Y false empty))))

;; examples of world-after-new-son-event(single son), for testing
(define root2 (make-node 100 150 true empty))
(define root2-son (make-node 100 210 false empty))
(define world1 (make-world (list root2)))
(define world1-after-new-son-event 
  (make-world (list (make-node 100 150 true (list root2-son)))))

;; examples of world-after-new-son-event (additional son), for testing
(define root3 
  (make-node 100 150 false 
             (list  
              (make-node 100 210 true 
                         (list (make-node 100 270 false empty)
                               (make-node 150 270 false empty))))))
(define root3-after-new-son-added-to-subtree 
  (make-node 100 150 false 
             (list  
              (make-node 100 210 true 
                         (list 
                          (make-node 60 270 false empty) 
                          (make-node 100 270 false empty)
                          (make-node 150 270 false empty))))))
(define world2 (make-world (list root3)))
(define world3 (make-world (list root3-after-new-son-added-to-subtree)))
(define root11 (make-node 100 150 true (list (make-node 100 210 false empty) 
                                             (make-node 80 100 false empty))))
(define world14 (make-world (list root11)))
(define root12 (make-node 100 150 true (list (make-node 40 210 false empty) 
                                             (make-node 100 210 false empty) 
                                             (make-node 80 100 false empty))))
(define world15 (make-world (list root12)))


;; examples of world-after-new-son-event (son outside campus), for testing
(define node6 (make-node 20 150 true (list (make-node 20 210 false empty))))
(define world4 (make-world (list node6)))

;; examples of world-after-delete-tree-event
(define node8 (make-node 20 150 false (list (make-node 20 210 true empty))))
(define node9 (make-node 20 150 false empty))
(define world10 (make-world (list node8)))
(define world11 (make-world (list node9)))

;; examples of world-after-delete-tree-on-upper-canvas-event
(define node10 (make-node 20 50 false (list (make-node 20 110 false empty))))
(define node11 (make-node 20 250 false (list (make-node 20 310 false empty))))
(define root9 (make-node 20 210 false (list node10 node11)))
(define root10 (make-node 20 210 false (list node11)))
(define world12 (make-world (list root9)))
(define world13 (make-world (list root10)))

;; examples of node-to-center-for-testing
(define node7 (make-node 100 200 false empty))
(define posn-node7 (make-posn 100 200))

;; examples of world-after-mouse-event-for-testing

;; example for button-down

(define root4 
  (make-node 100 150 false 
             (list 
              (make-node 100 210 false 
                         (list (make-node 100 270 false empty))))))
(define world5 (make-world (list root4)))
(define root5 (make-node 100 150 true 
                         (list 
                          (make-node 100 210 false 
                                     (list (make-node 100 270 false empty))))))
(define world6 (make-world (list root5)))

;; example for drag

(define root6 
  (make-node 100 150 false 
             (list (make-node 100 210 true 
                              (list (make-node 100 270 false empty))))))
(define world7 (make-world (list root6)))
(define root7 (make-node 100 150 false 
                         (list 
                          (make-node 50 100 true 
                                     (list (make-node 50 160 false empty))))))
(define world8 (make-world (list root7)))

;; test


(begin-for-test
  ;;initial world tests
  (check-equal?
   (initial-world NULL)
   initial-empty-world
   "the initial world with no nodes should be returned")
  ;;world->scene tests
  (check-equal?
   (world->scene world21)
   single-node-beyond-boundary-image
   "the node should appear red")
  (check-equal?
   (world->scene world22)
   unselected-node-image
   "image of an outlined square should be present on the canvas")
  (check-equal?
   (world->scene world23)
   selected-node-with-son-image
   "image of a node with son and downline and red line should appear")
  ;;world-after-key-event tests
  (check-equal?
   (world-after-key-event initial-empty-world NEW-ROOT-EVENT)
   initial-world-after-new-root-event
   "a new root should be added to the initial world")
  (check-equal?
   (world-after-key-event world1 NEW-SON-EVENT)
   world1-after-new-son-event
   "new son should be created with its centre at 100 210")
  (check-equal?
   (world-after-key-event world2 NEW-SON-EVENT)
   world3
   "new son should be created with its centre at 60 270")
  (check-equal?
   (world-after-key-event world14 NEW-SON-EVENT)
   world15
   "new son should be created with its centre at 20 210")
  (check-equal?
   (world-after-key-event world4 NEW-SON-EVENT)
   world4
   "the same world should be returned as the new son
    will not lie entirely within the canvas")
  (check-equal?
   (world-after-key-event world10 DELETE-TREE-EVENT)
   world11
   "the selected node is deleted")
  (check-equal?
   (world-after-key-event world12 DELETE-TREES-ON-UPPER-CANVAS-EVENT)
   world13
   "the nodes whose centre lies on the upper portion of the canvas 
    should be deleted")
  (check-equal?
   (world-after-key-event world12 " ")
   world12
   "the world should not respond to any other key event")
  ;;world-to-roots test
  (check-equal? 
   (world-to-roots world2)
   (list root3)
   "list with one root should be returned")
  ;;node-to-center
  (check-equal?
   (node-to-center node7)
   posn-node7
   "the vale should be (make-posn 100 200)")
  ;;node-to-sons
  (check-equal?
   ;;node1 has two sons node1-son1 and node1-son2
   (node-to-sons node1)
   (list node1-son1 node1-son2)
   "list with node1-son1 and node1-son2 should be returned")
  ;;node-to-selected
  (check-equal?
   ;;node6 is a selected node
   (node-to-selected? node6)
   true
   "the value should be true")
  ;;world-after-mouse-event test
  (check-equal?
   ;;button-up test
   ;; 100 150 is a point inside the root
   (world-after-mouse-event world5 100 150 "button-down")
   world6
   "the root should be selected")
  ;;drag test
  (check-equal?
   (world-after-mouse-event world7 50 100 "drag")
   world8
   "the selected node should be dragged to the new mouse pointer position
   and all other nodes should also move relatively")
  ;;button up test
  (check-equal?
   (world-after-mouse-event world6 200 200 "button-up")
   world5
   "the root should be unselected")
  ;; test for any other mouse event
  (check-equal?
   (world-after-mouse-event world6 200 200 "leave")
   world6
   "mouse event other than button-up, button-down, and drag
   should not change the world"))


