;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname pitchers) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
;;pitchers.rkt


;Approach:
;We use DFS to find the solution to pitchers problem.
;Initially the first pitcher is filled to capacity, then 
;the goal path function uses DFS and constructs a list of
;pitchers internal rep recursively. The recursion terminates 
;when the goal internal state is reached or when the goal state
;is not reachable. If the goal is not reachable then false is returned,
;else the list of pitchers internal rep is given as input to the
;function int-rep-lst-to-moves which will convert the sequence of pitchers
;internal rep into list of moves that is to be taken to reach the goal.

(require rackunit)
(require "extras.rkt")
(require "sets.rkt")



(provide list-to-pitchers)
(provide pitchers-to-list)
(provide pitchers-after-moves)
(provide make-move)
(provide move?)
(provide move-src)
(provide move-tgt)
(provide solution)

;;;;;;;;;;;;;;;;;;;;;;;;CONSTANTS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define ZERO 0)
(define ONE 1)
(define TWO 2)
(define NEG-ONE -1)


;;;;;;;;;;;;;;;;;;;;;;;;DATA DEFINITION;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;A Pitcher is a (list PosInt NonNegInt)

;Interpretation: (list capacity, contents)
;capacity represents the maximum amount
;of liquid the pitcher can hold, and contents represent the current
;amount of liquid the pitcher holds
;WHERE: 0 <= cotents <= capacity

;;Template:
; pitcher-fn : Pitcher -> ??
;(define (pitcher-fn p)
;  (...
;   (...(first p))
;   (...(second p))))

;Example:
;(list 10 5)

;; A ListOf<Pitcher> (LOP) is either

;; --empty              Interpretation: empty represents an empty list 
;;                      of pitcher
;; --(cons Pitcher LOP) Interpretation: (cons Pitcher LOP) represents a 
;;                      non-empty list of Pitcher

;; Template:
;; lop-fn : LOP -> ??
;; (define (lop-fn lop)
;;   (cond
;;     [(empty? lop) ...]
;;     [else (...
;;             (pitcher-fn (first lop))
;;             (lop-fn (rest lop)))]))

;;Example:
;empty
;(list (list 10 2) (list 8 3))


; A NonEmptyListOf<Pitcher> (NELOP) is a
; -- (cons Pitcher ListOf<Pitcher>)  Interpretation: (cons Pitcher LOP) 
;                                    represents a non empty list of 
;                                    Pitcher.

;Template:
;nelop-fn : NELOP -> ??
;(define (nelop-fn nelop)
;  (...(pitcher-fn (first nelop)
;      (lop-fn (rest nelop))))

;example
;(list (list 10 5))
;(list (list 10 5) (list 8 3))

;; A NonEmptyListOf<Pitcher> (NELOP) is a 

; -- (cons Pitcher empty)   Interpretation: (cons Pitcher empty) represents a
;                           list of Pitcher with one element
; -- (cons Pitcher NELOP)   Interpretation: (cons Pitcher NELOP) represents a
;                           non empty list of Pitcher with more than one 
;                           element

;Template:
;nelop-fn : NELOP -> ??
;(define (nelop-fn nelop) 
; (cond 
;  [(empty? (rest nelop)) (... (first nelop))]
;  [else (... 
;         (pitcher-fn (first nelop))
;         (nelop-fn (rest nelop)))]))

;;example
;(list (list 10 5))
;(list (list 10 5) (list 8 3))


;PitchersExternalRep is a NELOP.
;PitchersInternalRep is a NELOP.

;; A ListOf<PitchersInternalRep> (LOPIR) is either

;; --empty                            Interpretation: empty represents an empty 
;                                     list of PitchersInternalRep
;; --(cons PitchersInternalRep LOPIR) Interpretation: 
;                                     (cons PitcherInternalRep LOPIR)   
;;                                    represents a non-empty list of  
;                                     PitchersInternalRep

;; Template:
;; lopir-fn : LOPIR -> ??
;; (define (lopir-fn lopir)
;;   (cond
;;     [(empty? lopir) ...]
;;     [else (...
;;             (nelop-fn (first lopir))
;;             (lopir-fn (rest lopir)))]))

;;Example:
;empty
;(list (list (list 10 2) (list 8 3)))


; A NEListOf<PitchersInternalRep> (NELOPIR) is a
; -- (cons PitchersInternalRep LOPIR)  Interpretation: 
;                                      (cons PitchersInternalRep LOPIR) 
;                                      represents a non empty list of 
;                                      PitchersInternalRep.

;Template:
;nelopir-fn : NELOPIR -> ??
;(define (nelopir-fn nelopir)
;  (...(nelop-fn (first nelopir)
;      (lopir-fn (rest nelopir))))

;example
;(list (list (list 10 2) (list 8 3)))

;; A NEListOf<PitchersInternalRep> (NELOPIR) is a 

; -- (cons PitchersInternalRep empty)   Interpretation: 
;                                       (cons PitcherInternalRep empty) 
;                                       represents a list of Pitcher with one
;                                       element
; -- (cons PitchersInternalRep NELOPIR) Interpretation: 
;                                       (cons PitcherInternalRep NELOPIR) 
;                                       represents a non empty list of Pitcher  
;                                       with more than one element

;Template:
;nelopir-fn : NELOPIR -> ??
;(define (nelopir-fn nelopir) 
; (cond 
;  [(empty? (rest nelopir)) (... (first nelopir))]
;  [else (... 
;         (nelop-fn (first nelopir))
;         (nelopir-fn (rest nelopir)))]))

;;example
;(list (list (list 10 2) (list 8 3)))

;; A Maybe<NEListOf<PitchersInternalRep>> is

;; --false                          Interpretation: false represents that the  
;;                                  goal internal rep cannot be reached.
;; --NEListOf<PitchersInternalRep>  Interpretation: 
;;                                  NEListOf<PitchersInternalRep> represents 
;;                                  the list of internal reps processed to
;;                                  reach the goal internal rep.

;;Template:
;; maybepitchersinternalreps-fn : Maybe<NEListOf<PitchersInternalRep>> -> ??
;; (define ( maybepitchersinternalreps-fn m-nelopir)
;;   (cond
;;     [(false? m-nelopir) ...]
;;     [(list? m-nelopir) (nelopir-fn m-nelopir)]))

;;Example:
;false
;(list (list (list 10 2) (list 8 3)))


;; A NonEmptyListOf<PosInt> (NELOPosInt) is a 

; -- (cons PosInt empty)       Interpretation: (cons PosInt empty) represents a
;                              list of PosInt with one element
; -- (cons PosInt NELOPosInt)  Interpretation: (cons PosInt NELOPosInt) 
;                              represents a non empty list of Pitcher with more
;                              than one element

;Template:
;neloposint-fn : NELOPosInt -> ??
;(define (neloposint-fn neloposint) 
; (cond 
;  [(empty? (rest neloposint)) (... (first neloposint))]
;  [else (... 
;         (... (first neloposint))
;         (neloposint-fn (rest neloposint)))]))

;;example
;(list 10 5)



(define-struct move (src tgt))
;A Move is a (make-move PosInt PosInt)
;WHERE: src and tgt are different
;INTERPRETATION: (make-move i j) means pour from pitcher i to pitcher j.
;'pitcher i' refers to the i-th pitcher in the 
;PitchersExternalRep,PitchersInternalRep.
;'pitcher j' refers to the j-th pitcher in the 
;PitchersExternalRep,PitchersInternallRep.

;;Template:
; move-fn : Move -> ??
;(define (move-fn m)
;  (...
;   (move-src m)
;   (move-tgt m)))

;;Example:
;(make-move 1 2)
;;pour from pitcher 1 to pitcher 2

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
;empty
;(list (make-move 1 2) (make-move 2 3))

;; A NEListOf<Move> (NELOM) is either

; -- (cons Move empty)      Interpretation: (cons Move empty) represents a
;                           list of Move with one element
; -- (cons Move NELOM)      Interpretation: (cons Move NELOM) represents a
;                           non empty list of Move with more than one 
;                           element

;Template:
;nelom-fn : NELOM -> ??
;(define (nelom-fn nelom) 
; (cond 
;  [(empty? (rest nelom)) (... (first nelom))]
;  [else (... 
;         (move-fn (first nelom))
;         (nelom-fn (rest nelom)))]))

;;example
;(list (make-move 1 2) (make-fill 1))


;; A Maybe<ListOf<Move>> is

;; --false          Interpretation: false represents that there is no list of
;;                  move to reach the goal.
;; --ListOf<Move>   Interpretation: ListOf<Move> represents the list of moves 
;;                  to reach the goal

;;Template:
;; maybemoves-fn : Maybe<ListOf<Move>> -> ??
;; (define (maybemoves-fn mp)
;;   (cond
;;     [(false? mp) ...]
;;     [(list? mp) (lom-fn mp)]))

;;Example:
;false
;(list (make-move 1 2) (make-move 2 3))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;list-to-pitchers : PitchersExternalRep -> PitchersInternalRep
;GIVEN: PitchersExternalRep
;RETURNS: internal representation of the given input.
;EXAMPLE: refer test
;STRATEGY: function composition

(define (list-to-pitchers ext-rep)
  ext-rep)

;;TEST:

(define ext-rep1 (list (list 10 10) (list 7 0) (list 3 0)))

(begin-for-test
  (check-equal?
   (list-to-pitchers ext-rep1)
   ext-rep1
   "the value shaould be same as external represenation is
    same as internal-represenation"))

;pitchers-to-list : PitchersInternalRep -> PitchersExternalRep
;GIVEN: an internal representation of a set of pitchers
;RETURNS: a PitchersExternalRep that represents them.
;EXAMPLE: refer test
;STRATEGY: function composition

(define (pitchers-to-list int-rep)
  int-rep)

;;TEST:

(begin-for-test
  (check-equal?
   (pitchers-to-list ext-rep1)
   ext-rep1
   "the value shaould be same as external represenation is
    same as internal-represenation"))


;pitchers-after-moves : PitchersInternalRep LOM -> PitchersInternalRep
;GIVEN: An internal representation of a set of pitchers, and a sequence
;of moves.
;WHERE: every move refers only to pitchers that are in the set of pitchers.
;RETURNS: the internal representation of the set of pitchers that should
;result after executing the given list of moves, in order, on the given
;set of pitchers.
;EXAMPLE: refer test
;STRATEGY: structural decomposition on mov-lst : LOM.
(define (pitchers-after-moves int-rep mov-lst)
  (cond
    [(empty? mov-lst) int-rep]
    [else (all-pitchers-after-moves int-rep int-rep mov-lst)]))

;TESTS:
(define pitchers-before-moves1 (list (list 8 8) (list 5 0) (list 3 0)))
(define moves1 (list (make-move 1 2) (make-move 2 3)))
(define moves2 (list (make-move 2 3) (make-move 1 2)))
(define pitchers-after-moves1 (list (list 8 3) (list 5 2) (list 3 3)))
(define pitchers-after-moves2 (list (list 8 3) (list 5 5) (list 3 0)))

(begin-for-test
  (check-equal?
   (pitchers-after-moves pitchers-before-moves1 moves1)
   pitchers-after-moves1
   "the value should be ((8 3) (5 2) (3 3))")
  (check-equal?
   (pitchers-after-moves pitchers-before-moves1 moves2)
   pitchers-after-moves2
   "the value should be ((8 3) (5 5) (3 0))")
  (check-equal?
   (pitchers-after-moves pitchers-before-moves1 empty)
   pitchers-before-moves1
   "this should return the same internal representation of the pitchers"))


;all-pitchers-after-moves : PitchersInternalRep PitchersInternalRep 
;                           NEListOf<Move> -> PitchersInternalRep
;GIVEN: an PitchersInternalRep, a constant PitchersInternalRep and a
;List of moves.
;WHERE: the constant PitchersInternalRep is the original PitchersInternalRep
;RETURNS: a PitchersInternalRep following a sequence of moves contained in
;mov-lst
;EXAMPLES: 
;(all-pitchers-after-moves '((4 4) (3 2)) '((4 4) (3 2)) (list (make-move 1 2)))
; => (list (list 4 3) (list 3 3))
;STRATEGY: structural decomposition on mov-lst:NEListOf<Move>
;TEST: refer example.
(define (all-pitchers-after-moves int-rep int-rep-const mov-lst)
  (cond  
    [(empty? (rest mov-lst)) (pitchers-after-move 
                          int-rep int-rep-const (first mov-lst) ZERO)]
    [else (all-pitchers-after-moves  
           (pitchers-after-move int-rep int-rep-const (first mov-lst) ZERO)
           (pitchers-after-move int-rep int-rep-const (first mov-lst) ZERO)
           (rest mov-lst))]))

;pitchers-after-move : PitchersInternalRep PitchersInternalRep Move
;                      NonNegInt -> PitchersInternalRep
;GIVEN: an PitchersInternalRep, a constant PitchersInternalRep, a move
;and a count.
;WHERE: the constant PitchersInternalRep is the original PitchersInternalRep
;and the count is the index of a pitcher within the PitchersInternalRep
;RETURNS: PitchersInternalRep after a move.
;EXAMPLES: 
;(pitchers-after-move '((6 4) (5 2)) '((6 4) (5 2)) (make-move 1 2) 0)
; => (list (list 6 1) (list 5 5))
;STARTEGY: structural decomposition on int-rep:PitcherInternalRep
;TESTS: refer example.
(define (pitchers-after-move int-rep int-rep-const move count)
  (cond 
    [(empty? int-rep) empty]
    [else (cons
           (if (= (pitcher-type move count) NEG-ONE)
               (first int-rep)
               (if (= (pitcher-type move count) ONE)
                   (pitcher-after-move
                    src-after-move move int-rep-const)
                   (pitcher-after-move
                    tgt-after-move move int-rep-const)))
           (pitchers-after-move (rest int-rep)
                                int-rep-const move 
                                (+ count ONE)))]))

;pitcher-after-move : (PitchersInternalRep PitchersInternalRep ->
;                     PitchersInternalRep) Move PitchersInternalRep ->
;                     Pitcher
;GIVEN: a function, a move and a PitchersInternalRep
;WHERE: the function takes in two PitchersInternalRep and returns a
;PitchersInternalRep.
;RETURNS: a Pitcher which can be either a source or target pitcher
;depending upon the function.
;STRATEGY: structural decomposition on move:Move
;EXAMPLES: 
;(pitcher-after-move tgt-after-move (make-move 1 2) '((6 6) (4 0)))
; => (list 4 4)
;TEST: refer example
(define (pitcher-after-move f move int-rep-const)
  (f 
   (list-ref int-rep-const (- (move-src move) ONE)) 
   (list-ref int-rep-const (- (move-tgt move) ONE))))

;pitcher-type : Move NonNegInt -> PosInt
;GIVEN: a move and a NonNegInt
;RETURNS: 1 if the move refers to a source pitcher
;         2 if the move refers to a target pitcher
;EXAMPLES: 
;(pitcher-type (make-move 3 4) 3) => 2
;STRATEGY: structural decomposition on move:Move
;TESTS: refer example.
(define (pitcher-type move count)
  (cond
    [(= count (- (move-src move) ONE)) ONE]
    [(= count (- (move-tgt move) ONE)) TWO]
    [else NEG-ONE]))

;src-after-move : Pitcher Pitcher -> Pitcher
;GIVEN: two pitchers
;RETURNS: the contents of the first pitcher after the first
;pitcher is poured into the second one.
;EXAMPLES: (src-after-move '(5 3) '(3 2)) => (list 5 2)
;STRATEGY: structural decomposition on p1,p2:Pitcher
;TEST: refer example.
(define (src-after-move p1 p2)
  (list 
   (first p1)
   (if (extra? p1 p2)
       (- (second p1) (- (first p2) (second p2)))
       ZERO)))

;tgt-after-move : Pitcher Pitcher -> Pitcher
;GIVEN: two pitchers
;RETURNS:  the contents of the second pitcher after the first
;pitcher is poured into the second one.
;EXAMPLES: (tgt-after-move '(5 3) '(3 2)) => (list 3 3)
;STRATEGY: structural decomposition on p1,p2:Pitcher.
;TEST: refer example.
(define (tgt-after-move p1 p2)
  (list 
   (first p2)
   (if(extra? p1 p2)
      (first p2)
      (+ (second p2) (second p1)))))

;extra? : Pitcher Pitcher -> Boolean
;GIVEN: two pitchers
;RETURNS: true if the second pitcher exceeds its capacity if the contents
;of the first pitcher is poured into it.
;EXAMPLES: 
;(extra? '(7 7) '(5 0)) => true
;(extra? '(7 2) '(5 0)) => false
;STRATEGY: structural decomposition on p1,p2:Pitcher
(define (extra? p1 p2)
  (< (- (first p2) (second p2)) (second p1)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;solution : NEListOf<PosInt> PosInt -> Maybe<ListOf<Move>>
;GIVEN: a list of the capacities of the pitchers and the goal amount
;RETURNS: a sequence of moves which, when executed from left to right,
;results in one pitcher (not necessarily the first pitcher) containing
;the goal amount.  Returns false if no such sequence exists.
;EXAMPLE: refer test
;STRATEGY: function composition

(define (solution capacities goal)
  (maybe-path (initial-int-rep capacities empty true) goal))



;;TEST

;examples for testing
(define capacities1 (list 8 5 3))
(define goal1 4)
(define solution1 (list (make-move 1 3) (make-move 3 2) (make-move 1 3) 
                        (make-move 3 2) (make-move 3 1) (make-move 2 3) 
                        (make-move 3 1) (make-move 2 3) (make-move 1 2) 
                        (make-move 2 3)))
(define capacities2 (list 3 8 5))
;test
(begin-for-test
  (check-equal?
   (solution capacities1 goal1)
   solution1
   "the above problem is solvable, so a list of moves to reach
    the solution will be returned")
  (check-equal?
   (solution capacities2 goal1)
   false
   "the above problem is not solvable as the capacity of first
    pitcher is less than the goal, so false is returned")
  (check-equal? (solution '(5) 5)
                empty
                "should return empty since the goal is already present in 
                  the pitcher given"))


;initial-int-rep : NEListOf<PosInt> LOP Boolean -> PitchersInternalRep
;GIVEN: a list of capacities of the pitchers, a list of pitchers and 
;a flag f-pos? which is set to true for the first element in the LOP
;and false for the rest.
;WHERE: the list of pitchers is the representation of the pitchers
;processed so far.
;RETURNS: An internal representation of a set of pitchers after processing
;all the capacities.
;EXAMPLE: (initial-int-rep (list 10 8) empty true)
;= (list (list 10 10) (list 8 0))
;STRATEGY: structural decomposition on capacities:  NEListOf<PosInt>.

(define (initial-int-rep capacities int-rep f-pos?)
    (cond
    [(empty? (rest capacities)) (if f-pos?
                                    (append int-rep 
                                            (list (list (first capacities) 
                                                        (first capacities))))
                                    (append int-rep 
                                            (list (list (first capacities)
                                                        ZERO))))]
    [else (if f-pos?
              (initial-int-rep (rest capacities)
                               (append int-rep
                                       (list (list (first capacities)
                                                   (first capacities))))
                               false)
              (initial-int-rep (rest capacities)
                               (append int-rep
                                       (list (list (first capacities)
                                                   ZERO)))
                               f-pos?))]))

;goal-reached? : PitchersInternalRep PosInt -> Boolean
;GIVEN: an internal represntation of pitchers and a goal amont
;RETURNS: true iff the goal amount is present in any of the
;pitchers
;EXAMPLE:(goal-reached? (list (list 10 8) (list 10 5)) 5)
;= true
;(goal-reached? (list (list 10 8) (list 10 5)) 6)
;= false
;STRATEGY: structural decomposition on pitcher: Pitcher

(define (goal-reached? int-rep goal)
  (ormap
   ;Pitcher -> Boolean
   ;GIVEN: a pitcher
   ;RETURNS: true iff the given pitcher contains the goal amount
   (lambda (pitcher) (= (second pitcher) goal))
   int-rep))

;maybe-path: PitchersInternalRep PosInt ->  Maybe<ListOf<Move>>
;GIVEN: a PitchersInternalRep which represents the initial
;set of pitchers, and a goal amount.
;RETURNS: a sequence of moves which, when executed from left to right,
;results in one pitcher (not necessarily the first pitcher) containing
;the goal amount.  Returns false if no such sequence exists.
;EXAMPLE: (maybe-path (list (list 10 10) (list 8 0)) 12)
;= false
;(maybe-path (list (list 10 10) (list 8 0)) 2)
;= (list (make-move 1 2))
;STRATEGY: function composition

(define (maybe-path int-rep goal)
  (if (false? (goal-path (list int-rep) empty goal empty))
      false
      (int-rep-lst-to-moves (goal-path (list int-rep) 
                                       empty
                                       goal 
                                       empty) 
                            empty)))

;goal-path : ListOf<PitchersInternalRep> ListOf<PitchersInternalRep> PosInt 
;<ListOf<PitchersInternalRep>> -> Maybe<NEListOf<PitchersInternalRep>>
;GIVEN: a stack which stores the list of internal representation of pitchers,
;another list of internal representation of pitchers that represents those
;internal represenatations of pitchers that have already been seen, a goal
;amount and a list of internal representation of pitchers which 
;represents the list of internal representation of 
;pitchers processed so far to reach the goal.
;RETURNS: the list of internal representation processed to reach
;the goal if there exists a path else returns false.
;EXAMPLE:(goal-path (list (list (list 10 10) (list 8 0))) empty 2 empty)
;=(list (list (list 10 10) (list 8 0)) (list (list 10 2) (list 8 8)))
;STRATEGY: general recursion
;HALTING MEASURE:number of all possible variations of the internal
;representation starting from the first item in the stack - (length visited) 

(define (goal-path stack visited goal path)
  (cond
    [(empty? stack) false]
    [else (local
            ((define new-visited (cons (first stack) visited))
             (define new-stack (all-adjacents stack new-visited))
             (define new-path (set-union path (list (first stack)))))
            (if (goal-reached? (first stack) goal)
                new-path
                (goal-path new-stack
                           new-visited
                           goal
                           new-path)))]))

;TERMINATION ARGUMENT: on every recursion the length of visited is increased by
;1 and thus halting measure decreases. The function terminates when either the
;goal capacity is found in one of the pitchers from one of the internal 
;representations of the stack or the stack becomes empty.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;all-adjacents : NEListOf<PitchersInternalRep> ListOf<PitchersInternalRep> ->
;                ListOf<PitchersInternalRep>
;GIVEN: a stack which stores the list of internal representation of pitchers,
;another list of internal representation of pitchers that represents those
;internal represenatations of pitchers that have been visited so far.
;RETURNS: all the internal representation of pitchers that are adjacent to the
;internal representation of pitchers on the top of the stack
;EXAMPLE:(all-adjacents (list (list (list 10 10) (list 8 0))) 
;                       (list (list (list 10 10) (list 8 0))))
;= (list (list (list 10 2) (list 8 8)))
;STRATEGY: structural decomposition of stack: NEListOf<PitchersInternalRep>

(define (all-adjacents stack visited)
  (append (all-successors (first stack) 
                          visited 
                          ONE 
                          TWO 
                          (length (first stack)) 
                          empty)
          (rest stack)))

;all-successors : PitchersInternalRep ListOf<PitchersInternalRep> PosInt PosInt
;PosInt ListOf<PitchersInternalRep> -> ListOf<PitchersInternalRep>
;GIVEN: an internal representation of pitchers, a list of internal 
;representation of pitchers that represent the internal representations that 
;have been seen so far, index of source pitcher, index of target pitcher, 
;total number of pitchers, 
;and a list of internal representations of pitchers that represents
;the successors that have been processed so far.
;EXAMPLE:
;(all-successors (list (list 10 10) (list 8 0)) 
;                (list (list (list 10 10) (list 8 0))) 1 2 2 empty)
;= (list (list (list 10 2) (list 8 8)))
;STRATEGY: general recursion
;HALTING MEASURE: number of variations of int-rep possible with a single move
;from the int-rep which are not present in visited. 


(define (all-successors int-rep visited s-indx t-indx pitchers-count successors)
  (cond
    [(> s-indx pitchers-count) successors]
    [(> t-indx pitchers-count) (all-successors int-rep visited 
                                               (+ s-indx ONE) ONE 
                                               pitchers-count successors)]
    [(= s-indx t-indx) (all-successors int-rep visited s-indx 
                                       (+ t-indx ONE) pitchers-count 
                                       successors)]
    [else 
     (local 
       ((define succ-rep (pitchers-after-moves int-rep 
                                               (list 
                                                (make-move s-indx t-indx)))))
       (if (member? succ-rep visited)
           (all-successors int-rep visited s-indx (+ t-indx ONE) 
                           pitchers-count successors)
           (all-successors int-rep visited s-indx (+ t-indx ONE) pitchers-count
                           (append (list succ-rep)
                                   successors))))]))


;TERMINATION ARGUMENT:
;on every recursion a different variation on int-rep after a single move is 
;found and the halting measure decreases by 1 as the number of possible 
;variations is decreased by 1. The function terminates after all different
;variations possible have been found.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;int-rep-lst-to-moves : NEListOf<PitchersInternalRep> ListOf<Move> ->
;                       ListOf<Move>
;GIVEN: a non empty list of internal representation of pitchers that was
;processed to reach some goal, a list of move that represents the moves that
;has been processed so far.
;RETURNS: the list of moves required to reach some goal.
;EXAMPLE: 
;(int-rep-lst-to-moves (list (list (list 10 10) (list 8 0)) 
;                            (list (list 10 2) (list 8 8))) empty)
;= (list (make-move 1 2))
;STRATEGY: 
;structural decomosition on int-rep-lst: NEListOf<PitchersInternalRep>

(define (int-rep-lst-to-moves int-rep-lst mov-lst)
  (cond
    [(empty? (rest int-rep-lst)) mov-lst]
    [else (int-rep-lst-to-moves (rest int-rep-lst)
                                (append mov-lst
                                        (list (int-reps-to-move 
                                               (first int-rep-lst)
                                               (second int-rep-lst)
                                               ONE
                                               ZERO
                                               ZERO
                                               ZERO))))]))

;int-reps-to-move: 
;PitchersInternalRep PitchersInternalRep PosInt NonNegInt NonNegInt NonNegInt
;-> Move
;GIVEN: an internal representation from which the move has to be taken, 
;another internal representation that will be reached after the move, a 
;reference, the source index, the destination index, count and
;the number of pitchers.
;WHERE: the reference is pitcher number of the pitcher being processed 
;from both the internal representations and the count is the number of 
;differences found among the pitchers of both the internal representations.
;RETURNS: a move.
;EXAMPLE:
;(int-reps-to-move '((8 4) (5 3) (13 8)) '((8 2) (5 5) (13 8)) 1 0 0 0 3)
; => (make-move 1 2)
;STRATEGY: general recursion
;HALTING MEASURE: (length int-rep1)

(define (int-reps-to-move int-rep1 int-rep2 ref src-indx tgt-indx count)
  (cond
    [(= count TWO) (make-move src-indx tgt-indx)]
    [(> (second (first int-rep1)) (second (first int-rep2)))
     (int-reps-to-move (rest int-rep1) (rest int-rep2) 
                       (+ ref ONE) ref tgt-indx (+ count ONE))]
    [(< (second (first int-rep1)) (second (first int-rep2)))
     (int-reps-to-move (rest int-rep1) (rest int-rep2) 
                       (+ ref ONE) src-indx ref (+ count ONE))]
    [else (int-reps-to-move (rest int-rep1) (rest int-rep2) 
                            (+ ref ONE) src-indx tgt-indx count)]))

;TERMINATION ARGUMENT:
;on each recursion the length of int-rep1 will decrease by 1 and the function 
;terminates when count hits 2 or when there are no more pitchers to be processed
;from int-rep1.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;









