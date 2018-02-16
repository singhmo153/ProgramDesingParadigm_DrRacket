;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname obstacles) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
;; obstacles.rkt


;;Algorithm:
;we take the list of blocks and a list of obstacles, which is initially
;empty. Then we pop blocks one by one from the blocks list and check
;if they can be added to any obstacle in the obstacle list, if they 
;can't then they are added as a new obstacle in the obstacle list, else
;they are added to that obstacle in the obstacle list which remains an 
;obstacle after appending the block to it. The block is then removed from
;the blocks list. The above described operation is performed recursively 
;on all the elements of the block list, and it ends when the block list
;becomes empty. The list of obstacles so formed is the final output.

(require rackunit)
(require "extras.rkt")
(require "sets.rkt")

(provide position-set-equal?)
(provide obstacle?)
(provide blocks-to-obstacles)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;CONSTANTS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(define EMPTY-OBSTACLE-SET empty)
(define ONE 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;DATA DEFINITION;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; A Position is a (list PosInt PosInt)
;; (x y) represents the position x, y.
;; WHERE: position is position of a square on a chessboard.

;; Template
; (define (pos-fn p)
;  (...
;      (first p)
;      (second p)))

;;Example:
;;(list 1 1)
;;(list 2 1)

;; A ListOf<Position> (LOP) is either

;; -- empty                Interpretation: empty represents an empty list of 
;;                         position
;; -- (cons Position LOP)  Interpretation: (cons Position LOP) represents a  
;;                         non-empty list of position

;; Template:
;; lop-fn : LOP -> ??
;; (define (lop-fn lop)
;;   (cond
;;     [(empty? lop) ...]
;;     [else (...
;;             (pos-fn (first lop))
;;             (lop-fn (rest lop)))]))

;;Example:
;;(list (list 1 1) (list 1 2))

;; A PositionSet is a list of positions without duplication.

;; A ListOf<PositionSet> (LOPS) is either

;; -- empty                  Interpretation: empty represents an empty list of 
;;                           position set
;; -- (cons PositionSet LOP) Interpretation: (cons PositionSet LOPS) represents   
;;                           a non-empty list of position set

;; Template:
;; lops-fn : LOPS -> ??
;; (define (lops-fn lops)
;;   (cond
;;     [(empty? lops) ...]
;;     [else (...
;;             (lop-fn (first lops))
;;             (lops-fn (rest lops)))]))

;;Example:
;;(list (list (list 1 1) (list 2 2)) (list (list 1 3) (list 1 4)))

;; A PositionSetSet is a list of PositionSets without duplication,
;; that is, no two position-sets denote the same set of positions.

;; A Maybe<Position> is one of
;;-- false                 Interpretation: false represents that there isn't 
;;                         any position
;;-- Position              Interpretation: Position is the x,y position of a 
;;                         square on chessboard
;;                         WHERE: position is (list PosInt PosInt)

;;Template: 

;(define (maybepos-fn maybepos)
;(cond
;  [(false? maybepos) ...]
;  [(list? maybepos) (pos-fn maybepos)]))

;;Example:
;false
;(list 1 1)

;;examples of position, for testing
(define p1 (list 1 2))
(define p2 (list 1 3))
(define p3 (list 2 3))
(define p4 (list 3 2))
(define p5 (list 3 4))
(define p6 (list 4 1))
(define p7 (list 4 4))

;;examples of position set, for testing
(define o0 (list p1))
(define o1 (list p1 p3))
(define o2 (list p1 p2 p3))
(define o4 (list p1 p3 p4 p6))
(define o5 (list p1 p3 p4 p6))

;;example of positionset set, for testing
(define obstacle-set (list (list p7) (list p2) (list p6 p5 p4 p3 p1)))
(define obstacle-set1 (list (list p1 p3) (list p2)))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;FUNCTION DEFINITIONS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;position-set-equal? : PositionSet PositionSet -> Boolean
;;GIVEN: two PositionSets
;;RETURNS: true iff they denote the same set of positions.
;;EXAMPLE:
;;(position-set-equal? (list p1 p2) (list p1 p2))= true
;;(position-set-equal? (list p1 p2) (list p1 p3)) = false
;;STRATEGY: function composition

(define (position-set-equal? ps1 ps2)
  (set-equal? ps1 ps2))

;;TEST:

(begin-for-test
  (check-equal?
   (position-set-equal? o0 o1)
   false
   "the value should be false, o0 is not equal to o1")
  (check-equal?
   (position-set-equal? o4 o5)
   true
   "the value should be true, o4 is equal to o5"))
   
;;obstacle? : PositionSet -> Boolean
;;GIVEN: a PositionSet
;;RETURNS: true iff the set of positions would be an obstacle if they
;;were all occupied and all other positions were vacant.
;;EXAMPLE: 
;;(obstacle? (list (list 1 2) (list 2 3)) = true
;;(obstacle? (list (list 1 2) (list 1 3)) = false
;;STRATEGY: structural decomposition on ps: PositionSet

(define (obstacle? ps)
  (cond
    [(empty? ps) false]
    [else (if (= ONE (length ps))
              true
              (andmap
               ;Position -> Boolean
               ;GIVEN: a position of a square on a chess board
               ;RETURNS: true iff the position is an adjacent position
               ;and share no edge with any position in some position set
               (lambda (p-in-set) (and 
                                   (adjacent-position-in-set? p-in-set ps)
                                   (share-no-edge-with-set? p-in-set ps)))
               ps))]))

;;TEST:

(begin-for-test
  (check-equal?
   (obstacle? o1)
   true
   "the value should be true, the given position set is an obstacle")
  (check-equal?
   (obstacle? o2)
   false
   "the value should be false, the given position set is not an obstacle")
  (check-equal?
   (obstacle? empty)
   false
   "the value should be false")
  (check-equal?
   (obstacle? o0)
   true
   "the value should be true, the given position set is an obstacle"))

;;share-no-edge-with-set?: Position PositionSet -> Boolean  
;;GIVEN:a position p and a position set
;;RETURNS: true iff the given position p doesn't share edge with any
;;positions in the given position set
;;EXAMPLE:
;;(share-no-edge? (list (list 1 2) (list 2 3)) = true
;;(share-no-edge? (list (list 1 2) (list 1 3)) = false
;;STRATEGY: HOFC

(define (share-no-edge-with-set? p ps)
  (andmap
   ;Position -> Boolean
   ;GIVEN: a position of a square on chessboard
   ;RETURNS: true if the position does not share an
   ;edge with any position in some position set
   (lambda (p-in-set) 
     (not (share-edge? p p-in-set)))
   ps))

;;share-edge?: Position Position -> Boolean
;;GIVEN: a position p1 and a position p2
;;RETURNS: true iff the two given positions share an edge with each other
;;EXAMPLE:
;;(share-edge? (list 1 2) (list 2 3)) = false
;;(share-edge? (list 1 2) (list 1 3)) = true
;;STRATEGY: structural decomposition on p1,p2 : Position

(define (share-edge? p1 p2)
  (or
   (and
    (= (first p1) (first p2))
    (= ONE (abs (- (second p1) (second p2)))))
   (and
    (= (second p1) (second p2))
    (= ONE (abs (- (first p1) (first p2)))))))


;;adjacent-position-in-set? : Position PositionSet -> Boolean
;;GIVEN:a position p and a position set
;;RETURNS:true iff the given position p is adjacent to (share a corner with)
;;at least one position in the given position set
;;EXAMPLE:
;;(adjacent-position-in-set? (list 1 2) (list (list 1 2) (list 2 3)) = true
;;(adjacent-position-in-set? (list 1 2) (list (list 1 2) (list 1 3)) = false
;;STRATEGY: HOFC

(define (adjacent-position-in-set? p ps)   
  (ormap
   ;Position -> Boolean
   ;GIVEN: position of a square on some chessboard
   ;RETURNS: true iff the position is adjacent to some
   ;position in some position set
   (lambda (p-in-set)     
     (adjacent-position? p p-in-set))
   ps))

;;adjacent-postion? Position Position -> Boolean
;;GIVEN: a position p1 and a position p2
;;RETURNS: true iff the two given positions are adjacent to each other
;;EXAMPLE:
;;(adjacent-position? (list 1 2) (list 2 3)) = true
;;(adjacent-position? (list 1 2) (list 1 3)) = false
;;STRATEGY: structural decomposition on p1,p2 : Position

(define (adjacent-position? p1 p2)
  (and
   (= ONE (abs (- (first p1) (first p2))))  
   (= ONE (abs (- (second p1) (second p2))))))


;;blocks-to-obstacles: PositionSet -> PositionSetSet
;;GIVEN: the set of occupied positions on some chessboard
;;RETURNS: the set of obstacles on that chessboard
;;EXAMPLE: 
;;(blocks-to-obstacles (list (list 1 2) (list 2 3) (list 3 3)))
;;= (list (list (list 1 2) (list 2 3)) (list (list 3 3)))
;;STRATEGY: function composition

(define (blocks-to-obstacles blocks)
  (blocks-to-obstacles-helper blocks EMPTY-OBSTACLE-SET))

;; TEST:
(begin-for-test
  (check-equal?
   (blocks-to-obstacles (list p1 p2 p3 p4 p5 p6 p7))
   obstacle-set
   "the obstacle set has following elements ((p7) (p2) (p6 p5 p4 p3 p1))")
  (check-equal?
   (blocks-to-obstacles (list p2 p3 p1))
   obstacle-set1
   "the obstacle set has following elements ((p1 p3) (p2))"))

;;blocks-to-obstacles-helper : PositionSet PositionSetSet -> PositionSetSet
;;GIVEN: a sublist list of position that represent the blocks,
;;and a sublist of list of position that represent the obstacles
;;WHERE: the blocks are those blocks that haven't been 
;;put into the obstacles list, and the
;;obstacles list is the obstacles that have been built so far
;;RETURNS: the set of obstacles on that chessboard.
;;EXAMPLE:
;;(blocks-to-obstacles-helper (list (list 1 2) (list 2 3) (list 3 3)) empty)
;;= (list (list (list 3 3)) (list (list 2 3) (list 1 2)))
;;(blocks-to-obstacles-helper (list (list 3 3)) (list (list 2 3) (list 1 2)))
;;= (list (list (list 3 3)) (list (list 2 3) (list 1 2)))
;;STRATEGY: general recursion
;;HALTING MEASURE: the number of blocks-remained 

(define (blocks-to-obstacles-helper blocks-remained obstacles-sofar)
  (local ((define candidate (eligible-block blocks-remained obstacles-sofar)))   
    (cond
      [(empty? blocks-remained) obstacles-sofar]
      [else                   
       (if (false? candidate) 
           (blocks-to-obstacles-helper                
            (rest blocks-remained) 
            (cons (list (first blocks-remained)) obstacles-sofar))        
           (blocks-to-obstacles-helper                
            (blocks-after-removing-block 
             candidate
             blocks-remained)        
            (obstacles-after-adding-candidate
             candidate
             obstacles-sofar)))])))

;;TERMINATION ARGUMENT:
;;At each recursive call, at least one block in the blocks-remained is
;;moved into the obstacle-sofar. Therefore the halting measure
;;decreases. The recursion ends when the blocks-remained becomes empty.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;eligible-block: PositionSet PositionSetSet ->  Maybe<Position>
;;GIVEN: a list of blocks, and a list of obstacles
;;RETURNS: a position in the given blocks that is eligible to be added to
;;one of the obstalce in the given obstacles. return false if there doesn't
;;exist any eligible block
;;EXAMPLE:
;;(eligible-block (list (list 3 3)) (list (list (list 2 3) (list 1 2))))=false
;;(eligible-block (list (list 2 3) (list 3 3)) (list (list (list 1 2))))
;;=(list 2 3)
;;STRATEGY: structural decomposition on blocks: PositionSet


(define (eligible-block blocks obstacles) 
  (cond
    [(empty? blocks) false]
    [else (if  (eligible? (first blocks) obstacles)
               (first blocks)
               (eligible-block (rest blocks) obstacles))]))

;;eligible? : Position PositionSetSet -> Boolean
;;GIVEN: a position 'block' and a list of positions 'obstacles'
;;RETURNS: true iff the given block is eligible to be added to
;;one of the obstalce in the given obstacles.
;;EXAMPLE:
;;(eligible? (list 2 3) (list (list (list 1 2)))) = true
;;(eligible? (list 3 3) (list (list (list 2 3) (list 1 2))))= false
;;STRATEGY: HOFC
         
(define (eligible? block obstacles)
  (ormap
   ;PositionSet -> Boolean
   ;Given : an obstacle
   ;RETURNS : true iff after appending some block to the given
   ;obstacle, the newly formed list of blocks forms an obstacle
   (lambda (obstacle) (obstacle? (cons block obstacle)))
  obstacles))
   

;;blocks-after-removing-block : Position PositionSet -> PositionSet
;;GIVEN: a position 'block' and a list of positions 'blocks'
;;WHERE: the given block is a member of the given blocks
;;RETURNS: a blocks just like the given blocks, except that the 
;; given block is removed
;;EXAMPLE:
;;(blocks-after-removing-block (list 2 3) (list (list 1 2) (list 2 3)))
;;=(list (list 1 2))
;;STRATEGY: HOFC

(define (blocks-after-removing-block block  blocks)
  (filter
   ;Position -> Boolean
   ;GIVEN: position of a square on chessboard
   ;RETURNS: true iff the given position is not
   ;equal to some position 
   (lambda (b) (not (equal? b block)))
     blocks))

;;obstacles-after-adding-candidate: Position PositionSetSet -> PositionSetSet
;;GIVEN: a position 'candidate' and a list of positions 'obstacles'
;;RETURNS; an obstalces just like the given obstacels except that 
;;the given candidate is added to one of the obstacles as long as the new 
;;obstacle is still an obstalce
;;EXAMPLE:
;(obstacles-after-adding-candidate (list 2 3) 
;                                  (list (list (list 1 3)) (list (list 1 2))))
;;= (list (list (list 1 3)) (list (list 2 3) (list 1 2)))
;;STRATEGY: HOFC


(define (obstacles-after-adding-candidate candidate obstacles)
  (map
   ;PositionSet -> PositionSet
   ;GIVEN: an obstacle
   ;RETURNS: a new obstacle if after appending some block it forms
   ;an obstacle else returns the same obstacle
   (lambda (obstacle) 
     (if (obstacle? (cons candidate obstacle))
         (cons candidate obstacle)
         obstacle))    
   obstacles))

 
