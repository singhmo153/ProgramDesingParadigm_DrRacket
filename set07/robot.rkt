;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname robot) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))


;;robot.rkt

;;Algorithm:
;The algorithm finds the path from the source to target by placing tracers on 
;the chessboard. A tracer is a struct that has information of its location and
;its distance (number of steps) to the source. For examples, the tracers placed
;at the source cell has a distance value of 0. The goal is to place tracers 
;starting at the source on the chessboard until the target is reached.

;Suppose at a given time, all the cells who have equal to or less than n steps 
;to the source have been marked. At the n+1 iteration, the cells who have n+1
;distance to the source are the neighbors of tracers placed in the the previous
;iteration, and we mark them with distance value of n+1.  

;Keep doing this until we reach the target, or  we fail to reach the target 
;after populating all the reachable cells on the chessboard, in which case, 
;the target is not reachable.

;Once we have the tracer map. we can extract the path by tracing from the 
;target back to the source. Starting at the target, the next tracer is the
;tracer with minimum distance value among the neighboring tracers of the last 
;tracer. The distance value decreases by 1 for each iteration, and eventually 
;we will trace back to the target when the distance is 0. Reverse the obtained 
;position sequence and we get the path from source to target.


(require rackunit)
(require "extras.rkt")
(require "sets.rkt")

(provide path)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;CONSTANTS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define ZERO 0)
(define ONE 1)


;;;;;;;;;;;;;;;;;;;;;;;;;;;DATA DEFINITION;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; A Position is a (list PosInt PosInt)
;;Interpretation:
;; (x y) represents the position at position x, y.
;;WHERE: position is the position of a square on a chessboard

;; Template:
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

;; A Move is a (list Direction PosInt)
;; Interpretation: a move of the specified number of steps in the indicated
;; direction. 

;; Template:
; (define (move-fn m)
;   (...
;    (direction-fn (first m))
;    (second m)))

;;Example:
;;(list "north" 1)
;; move one step in north direction

;; A Direction is one of

;; -- "north" Interpretation: north represents that the robot should
;;                            move in north direction on chessboard                           
;; -- "east"  Interpretation: east represents that the robot should
;;                            move in east direction on chessboard
;; -- "south" Interpretation: south represents that the robot should
;;                            move in south direction on chessboard
;; -- "west"  Interpretation: west represents that the robot should
;;                            move in west direction on chessboard

;;Template:
;; direction-fn : Direction -> ??

;(define (direction-fn dir)
;  (cond
;    [(string=? dir "north") ...]
;    [(string=? dir "east") ...]
;    [(string=? dir "south") ...]
;    [(string=? dir "west") ...]))

;;Example:
;"north", "east", "south", "west"


;; A ListOf<Direction> (LOD) is one of

;;-- empty                Interpretation: empty represents an empty list of
;;                        direction
;;-- (cons Direction LOD) Interpretation: (cons Direction LOD) represents  
;;                        a non-empty list of direction

;;Template:
;
;(define (lod-fn lod)
;  (cond
;    [(empty? lod) ...]
;    [else (...
;           (direction-fn (first lod))
;           (lod-fn (rest lod)))]))

;;Example:
;empty
;(list "north" "south" "east" "west")


;; A ListOf<Move> (LOM) is either

;; -- empty           Interpretation: empty represents an empty list of move
;; -- (cons Move LOM) Interpretation: (cons Move LOM) represents a non-empty 
;;                    list of move

;; Template:
;; lom-fn : LOM -> ??
;; (define (lom-fn lom)
;;   (cond
;;     [(empty? lom) ...]
;;     [else (...
;;             (move-fn (first lom))
;;             (lom-fn (rest lom)))]))

;;Example:
;(list (list "north" 1) (list "east" 2))



;; A Plan is a ListOf<Move>
;; WHERE: the list does not contain two consecutive moves in the same
;; direction. 

;; A Maybe<Plan> is

;; --false  Interpretation: false represents that there is no plan
;;          from start position to the target position.
;; --Plan   Interpretation: plan represents the list of moves from
;;          start position to the target position

;;Template:
; (define (maybeplan-fn mp)
;   (cond
;     [(false? mp) ...]
;     [(list? mp) (lom-fn mp)]))


(define-struct tracer (position distance))

;; A Tracer is a (make-tracer position distance)
;; Interpretation:
;; position is the location of the tracer
;; distance is the distance from the tracer to the source cell on the 
;; chessboard

;;Template:
;(define (tracer-fn t)
;  (...
;   (tracer-position t)
;   (tracer-distance t)))

;;Example:
;(make-tracer (list 3 1) 2)
;(make-tracer (list 2 2) 2)


;;A ListOf<Tracer> (LOT) is one of

;;--empty                       Interpretation: empty represents an empty 
;;                              list of tracer
;;--(cons Tracer LOT)           Interpretation: (cons Tracer LOT)  
;;                              represents a non empty list of tracer

;;Template:
;(define (lot-fn lot)
;  (cond
;    [(empty? lot) ...]
;    [else  ...
;           (tracer-fn (first lot)) 
;           (lot-fn (rest lot))]))

;Example:
;empty
;(list (make-tracer (list 2 4) 2)
;      (make-tracer (list 2 3) 1)
;      (make-tracer (list 1 4) 1)
;      (make-tracer (list 1 3) 0))

;; A Maybe<ListOfTracer> is one of
;; --false          Interpretation: false represents that no tracer can reach 
;;                  the target
;; --ListOfTracer   Interpretation: a list of tracers that has the target
;;                  marked

;;Template:
; (define (maybelot-fn mlot)
;   (cond
;     [(false? mlot) ...]
;     [(list? mlot) (lot-fn mlot)]))

;; Example:

;false
;(list (make-tracer (list 2 4) 2)
;      (make-tracer (list 2 3) 1)
;      (make-tracer (list 1 4) 1)
;      (make-tracer (list 1 3) 0))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;FUNCTION DEFINITION;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;place-tracers: Position Position LOT LOT LOP NonNegInt -> Maybe<ListOfTracer>
;;GIVEN: a source position, a target position,a list of tracers that was  
;;added in the last recursion to the sublist of tracers, a sublist of tracers 
;;that has been marked on the chessboard so far, a list of position that 
;;represents the blocks,and an integer that represents the farthest distance 
;;of the tracers-sofar to the source 
;;WHERE: all the cell on the chessboard within the given distance to the source
;;have been marked by the given tracers-sofar
;;RETURN: a list of tracers that marked all the cells on the chessboard whose 
;;distance to the source is less than or equal to the target's distance to the 
;;source. return false if the target can't be reached and marked
;;EXAMPLES: 
;; (place-tracers (list 1 1) (list 2 2) (list (make-tracer (list 1 1) 0))
;;               (list (make-tracer (list 1 1) 0)) (list (list 1 2)) 0)
;;= (list
;;   (make-tracer (list 3 1) 2) (make-tracer (list 2 2) 2)
;;   (make-tracer (list 2 1) 1) (make-tracer (list 1 1) 0))
;;STRATEGY: general recursion
;;HALTING MEASURE: the number of the unmarked cells on the chessboard whose  
;;distance to the source is less than or equal to the target's distance to the
;;source 

(define (place-tracers source target last tracers-sofar blocks distance-sofar)
  (cond
    [(member? target (tracers-to-positions last)) tracers-sofar]
    [else 
     (local 
       ((define new  
          (get-newtracers 
           source target last tracers-sofar blocks distance-sofar)))
       (cond
         [(empty? new) false]     
         [else (place-tracers
                source target new
                (append new tracers-sofar) 
                blocks (+ distance-sofar ONE))]))]))

;; TERMINATION ARGUMENT:
;;At each recursive call, at least one cell whose distance to the source
;;is less or equal to the target's distance to the source is marked by  
;;the tracer, otherwise the function returns false. Since the total number  
;;of the cells on the chessboard whose distance to the source is less than 
;;or equal to the target's distance to the source is finite, the recursion
;;will terminate when the target is reached, or when all the eligible cells
;;on the chessboard are marked, in which case, the target is unreachable.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;get-newtracers:Position Position LOT LOT LOP NonNegInt -> LOT
;;GIVEN: a source position, a target position,a list of tracers, 
;;a list of tracers, a list of positions that represent blocks,
;;and an integer that represent the farthest  
;;distance of the marked cells (tracers) to the source
;;RETURN: a list of tracers who are neighbors of the given tracers 
;;and have one step farther distance to the source than the given distance
;;EXAMPLES:
;;(get-newtracers 
; (list 1 1) (list 3 3) (list (make-tracer (list 1 1) 0)) 
; (list (make-tracer (list 1 1) 0)) empty 0)
;;=> (list (make-tracer (list 2 1) 1) (make-tracer (list 1 2) 1))
;;STRATEGY: function composition

(define (get-newtracers source target last-tracers tracers blocks distance)               
  (positions-to-tracers 
   (set-diff 
    (neighbors-of-positions 
     (tracers-to-positions last-tracers) source target blocks)
    (tracers-to-positions tracers))
   (+ distance ONE)))

;;tracers-to-positions: LOT -> LOP
;;GIVEN: a list of tracers
;;REUTRNS: the list of positions where the given list of tracers are located,
;;in addition,the returned list of positions has the same sequence as the given
;;list of tracers
;;EXAMPLES: 
;;(tracers-to-positions 
;; (list (make-tracer (list 1 1) 0) (make-tracer (list 1 2) 1))) 
;=> (list (list 1 1) (list 1 2))
;;STRATEGY: HOFC

(define (tracers-to-positions tracers)
  (map
   tracer-position
   tracers))

;;positions-to-tracers: LOP NonNegInt -> LOT
;;GIVENS: a list of positions and a non negative integer distance
;;REUTRNS: a list of tracers whose positions are the given list of 
;;positions and whose distance is the given distance
;;EXAMPLES: 
;(positions-to-tracers (list (list 2 1) (list 1 2)) 2)) 
;=> (list (make-tracer (list 2 1) 2) (make-tracer (list 1 2) 2)))
;;STRATEGY: HOFC

(define (positions-to-tracers positions distance)
  (map
   ;Position -> Tracer
   ;GIVEN: position of a square on some chessboard
   ;RETURNS: a tracer with the given position and
   ;some distance
   (lambda (pos) (make-tracer pos distance))   
   positions))

;;neighbors-of-positions: LOP Position Position LOP -> LOP
;;GIVEN: a list of positions, a source position, a target position,
;;and a list of positions that represents the blocks
;;RETURNS: a list of positions that are neighbors to the positions
;;in the given list of positions but not include the blocks 
;;EXAMPLES:
;;(neighbors-of-positions (list (list 2 3) (list 3 2)) 
;;                        (list 1 1) (list 3 3) (list (list 2 2)))
;;=> (list (list 1 3) (list 2 4) (list 3 1) (list 4 2) (list 3 3))
;;STRATEGY: HOFC

(define (neighbors-of-positions positions source target blocks)
  (foldr
   set-union
   empty   
   (map 
    ;Position -> LOP
    ;GIVEN: position of a square on some chessboard
    ;RETURNS: neighbours of the position but not include
    ;some blocks and given position
    (lambda (position) (neighbors position source target blocks)) 
    positions)))


;;set-diff: ListOfPosition ListOfPosition-> ListOfPosition
;;GIVEN: a list of position set1 and a list of position set2
;;RETURNS: a list of posotion like the given set1 except that any of its member 
;;that is also a member of set2 is removed
;;EXAMPLE:
;(set-diff (list (list 1 1) (list 1 2)) (list (list 1 2) (list 2 3)))
;(list (list 1 1))
;;STRATEGY: HOFC

(define (set-diff set1 set2)
  (filter
   ;Position -> Boolean
   ;GIVEN: position of a square on some chessboard
   ;RETURNS: true if the given position is not the
   ;member of some set of position
   (lambda (x) (not (my-member? x set2)))
   set1))

;;neighbors: Position Position Position LOP -> LOP
;;GIVEN: a position, a source position, a target position
;;and a list of positions which is the blocks
;;RETURNS: a list of positions whose members are neighbors of the given 
;;position and does not belong to the blocks
;;EXAMPLE:
;;(neighbors (list 2 3) (list 1 1) (list 3 3) (list (list 2 2)))
;; => (list (list 1 3) (list 3 3) (list 2 4)))
;;STRATEGY: HOFC + structural decomposition on position : Position

(define (neighbors position source target blocks)  
  (filter 
   ;; Position -> Boolean
   ;;GIVEN: a position
   ;;RETURNS: true iff the given position is within the chessboard
   ;;and not one of the blocks
   (lambda (p) (eligible-in-board-position? p source target blocks))
   (list
    (list (- (first position) ONE) (second position))
    (list (first position) (- (second position) ONE))  
    (list (+ (first position) ONE) (second position))
    (list (first position) (+ (second position) ONE)))))


;;eligible-in-board-position? Position Position Position LOP -> Boolean
;;GIVEN: a position, a source position, a target position,
;;and a list of postions that represents the blocks
;;RETURN: true iff the position is not in the blocks and is 
;;not out of the chessboard
;;EXAMPLES:
;(in-board? (list 5 5) (list 1 1) (list 3 3) (list (list 2 2)))
;=> false
;;STRATEGY: structural decomposition on position : Position

(define (eligible-in-board-position? position source target blocks)
  (and (> (first position) ZERO)
       (> (second position) ZERO)  
       (<= (first position) (chessboard-sizeX source target blocks))
       (<= (second position) (chessboard-sizeY source target blocks))
       (not (member? position blocks))))

;;chessboard-sizeX: Position Position LOP -> PosInt
;;GIVEN: a source position, a target position and a list of block 
;;positions
;;RETURNS: the horizantal size of the chessboard
;;EXAMPLE:
;;(chessboard-sizeX (list 1 1) (list 3 3) (list (list 2 2)))
;;=>4
;;STRATEGY: HOFC

(define (chessboard-sizeX source target blocks) 
  (+ ONE (apply
          max
          (map
           first
           (cons source (cons target blocks))))))

;;chessboard-sizeY: Position Position LOP -> PosInt
;;GIVEN: a source position, a target position and a list of block 
;;positions
;;RETURNS: the vertical size of the chessboard 
;;EXAMPLES:
;(chessboard-sizeY (list 1 1) (list 3 4) (list (list 2 2)))
;=> 5
;;STRATEGY: HOFC

(define (chessboard-sizeY source target blocks)  
  (+ ONE  (apply
           max
           (map
            second
            (cons source (cons target blocks))))))

;;neighbor?: Position Position -> Boolean
;;GIVEN: a position pos1 and a position pos2
;;RETURNS: true iff the two given positions are neighbors(share an edge)
;;EXAMPLE:
;;(neighbor? (list 1 1) (list 1 2))=> true
;;STRATEGY: structural decomposition on pos1,pos2 : Position

(define (neighbor? pos1 pos2)
  (member? pos1 
           (list
            (list (- (first pos2) ONE) (second pos2))
            (list (first pos2) (- (second pos2) ONE))  
            (list (+ (first pos2) ONE) (second pos2))
            (list (first pos2) (+ (second pos2) ONE)))))


;;increment-step: Move -> Move
;;GIVEN: a move
;;RETURNS: a move just like the given move except the number of
;;steps is increased by 1
;;EXAMPLE:
;;(increment-step (list "north" 2)) => (list "north" 3)
;;STRATEGY: structural decomposition on move: Move

(define (increment-step move)
  (list (first move) (+ (second move) ONE)))

;;direction: Position Position -> Direction
;;GIVEN: the current position and the next position
;;RETURNS: the direction that should be taken to move from the 
;;current position to the next position
;;EXAMPLES:
;; (direction (list 1 1) (list 2 1)) => "east"
;;STRATEGY: structural decomposition on current, next : Position

(define (direction current next)  
  (direction-helper (- (first next) (first current))
                    (- (second next) (second current))))

;;direction-helper : Integer Integer -> Direction
;;GIVEN: a movement in the X axis, and a movement in the Y axis
;;WHERE: the given x y can only be one of four combinations: 
;;1 0, -1 0, 0 -1, 0 1
;;RETURNS: the direction that the given movement represents
;;EXAMPLES:
;(direction-helper 1 0) => "east"
;;STRATEGY: function composition

(define (direction-helper x y)
  (if (= x 1)
      "east"
      (if (= x -1)
          "west"
          (if (= y -1)
              "north"
              "south"))))

;;path : Position Position LOP -> Maybe<Plan>
;;GIVEN:
;; 1. the starting position of the robot,
;; 2. the target position that robot is supposed to reach
;; 3. A list of the blocks on the board
;;RETURNS: a plan that, when executed, will take the robot from
;;the starting position to the target position without passing over any
;;of the blocks, or false if no such sequence of moves exists
;;EXAMPLES: refer tests
;;STRATEGY: function composition

(define (path source target blocks)  
  (local ((define tracers (place-tracers target source 
                                         (list (make-tracer target ZERO))
                                         (list (make-tracer target ZERO)) 
                                         blocks ZERO)))
    (if (or (false? tracers) (member? target blocks))
        false
        (directions-to-plan (tracers-to-directions source tracers)))))

;;TESTS:
(define source1 (list 1 1))
(define target1 (list 1 3))
(define blocks1 (list (list 1 2) (list 2 2)))
(define blocks2 (list (list 1 3)))
(define blocks3 (list (list 1 2) (list 2 2) (list 2 3)))
(define blocks4 (list (list 1 2) (list 2 3) (list 1 4)))
(define plan1 (list (list "east" 2) (list "south" 2) (list "west" 2)))
(define plan2 
  (list (list "east" 2) (list "south" 3) (list "west" 2) (list "north" 1)))

(begin-for-test
  (check-equal?
   (path source1 target1 blocks1)
   plan1
   "the robot should move 2 steps in east followed by 
   by two steps in south and finally two steps in west")
  (check-equal?
   (path source1 target1 blocks3)
   plan2
   "the robot should move 2 steps in east followed by 
   by three steps in south followed by two steps in 
   west and finally one step in north")
  (check-equal?
   (path source1 target1 blocks2)
   false
   "the value should be false, as the target is a block")
  (check-equal?
   (path source1 target1 blocks4)
   false
   "the value should be false, as the target is surrounded by blocks")
  (check-equal?
   (path source1 source1 blocks1)
   empty
   "the list should be empty as the source is the target"))


;;tracers-to-directions: Position LOT -> LOD
;;GIVEN: the current position and a list of tracers that marked the
;;chessboard and are descendingly ordered by their distance to the position 
;;of the last tracer in the given list of tracers
;;WHERE: both the current position and the source position are among the 
;;given list of tracers' positions
;;RETURNS: a list of directions that the robot should take to move from
;;the given current position to the target, which is the position of the last
;;tracer in the given list of tracers
;;EXAMPLE:
;(tracers-to-directions (list 1 1) (list
;                                   (make-tracer (list 1 1) 6)
;                                   (make-tracer (list 2 1) 5)
;                                   (make-tracer (list 3 1) 4)
;                                   (make-tracer (list 3 2) 3)
;                                   (make-tracer (list 3 4) 3)
;                                   (make-tracer (list 3 3) 2)
;                                   (make-tracer (list 2 4) 2)
;                                   (make-tracer (list 2 3) 1)
;                                   (make-tracer (list 1 4) 1)
;                                   (make-tracer (list 1 3) 0)))
;=>(list "east" "east" "south" "south" "west" "west")
;;STRATEGY:structural decomposition on tracers: LOT

(define (tracers-to-directions current tracers)  
  (cond
    [(empty? tracers) empty]  
    [else  
     (if (neighbor? current (tracer-position (first tracers)))
         (cons (direction current (tracer-position (first tracers)))         
               (tracers-to-directions
                (tracer-position (first tracers)) (rest tracers)))
         (tracers-to-directions
          current (rest tracers)))]))

;;directions-to-plan: LOD -> Plan
;;GIVEN:a list of directions that the robot takes for each step
;;RETURNS: a plan that represent the same movements sequences as the 
;;given list of direction
;;EXAMPLE:
;;(directions-to-plan (list "east" "east" "south" "south" "west" "west"))
;;=>(list (list "east" 2) (list "south" 2) (list "west" 2))
;;STRATEGY: structural decomposition on directions: LOD

(define (directions-to-plan directions)
  (cond 
    [(empty? directions) empty]
    [else
     (directions-to-plan-helper
      (list (first directions) ONE) (rest directions))]))

;;directions-to-plan-helper: Move LOD ->  LOM
;;GIVEN: the last move and a list of directions
;;WHERE: the lastmove is the last move
;;RETURNS: a list of moves that represent the last move followed by 
;;the movements sequences expressed by the given list of direction
;;EXAMPLES:
;;(directions-to-plan-helper (list "south" 1) (list "south" "west" "west")) =>
;;(list (list "south" 2) (list "west" 2))
;;STRATEGY: structural decomposition on direction : Direction

(define (directions-to-plan-helper lastmove directions)
  (cond
    [(empty? directions) (list lastmove)]
    [else (if (same-direction? lastmove (first directions))
              (directions-to-plan-helper
               (increment-step lastmove) (rest directions))
              (cons lastmove 
                    (directions-to-plan-helper 
                     (list (first directions) ONE) (rest directions))))]))

;;same-direction?: Move Direction -> Boolean
;;GIVEN: a move and a direction
;;RETURNS: true iff the give move has the same direction as the given direction
;;EXAMPLE:
;;(same-direction? (list "east" 2) "east") => true
;;STRATEGY: SD on move : Move

(define (same-direction? move direction)
  (string=? (first move) direction))
  

