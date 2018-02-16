;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname outlines) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t write repeating-decimal #f #t none #f ())))

;outlines.rkt


(require rackunit)
(require "extras.rkt")


(provide nested-rep?)
(provide flat-rep?)
(provide nested-to-flat)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;CONSTANTS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define INITIAL-SECTION (list 1))
(define NEW-SUBSECTION (list 1))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;DATA DEFINITIONS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;An Sexp is one of the following
;-- a String
;-- a NonNegInt
;-- a ListOfSexp

;Interpretation: An sexp is either a String, a Non Negative Integer, or a
;list of Sexp

;; Template

;(define (sexp-fn sexp)
;  (cond
;    [(string? sexp) ... ]
;    [(integer? sexp) ... ]    
;    [(list? sexp) (los-fn sexp)]))

;;examples
;1
;"a"
;(list 1 "a" "b" "c" 3)


;A ListOfSexp(LOS) is one of
;-- empty                    Interpretation: empty represents an empty
;                            list of sexp
;-- (cons Sexp ListOfSexp)   Interpretation: (cons Sexp LOS) represents a 
;                            non empty list of sexp

;; Template
;(define (los-fn los)
;  (cond
;    [(empty? los) ...]
;    [else (... (sexp-fn (first los))
;               (los-fn (rest los)))]))

;;examples
;(list 1 "a" "b" "c" 3)

;;a NestedRep is one of
;-- (list String)                  Interpretation:It represents a list of 
;                                  string
;-- (list String ListOfNestedRep)  Interpretation: It represents a list of
;                                  string and list of NestedRep


;Template
;(define (nr-fn nr)
;  (cond
;    [(string? nr) ... ]
;    [(list? nr) (lnr-fn nr)]))

;;examples
;"abcd"
;(list "a" "b" "c")


;; a ListOfNestedRep(LONR) is 
;;-- empty                           Interpretation: empty represents an empty
;                                    list of nested representation.
;-- (cons NestedRep ListOfNestedRep) Interpretation: (cons NestedRep LONR)  
;                                    represents a non empty list of nested
;                                    representation.

;
;(define (lnr-fn lnr)
;  (cond
;    [(empty? lnr) ...]
;    [else (...(nr-fn (first lnr))
;              (lnr-fn (rest lnr)))]))

;;example
;(list "a" "b" "c")


;; A FlatRep is a 

;--empty                            Interpretation: empty represents an empty
;                                   list of flat representation
;--<cons flat-section FlatRep>      Interpretation: <cons flat-section FlatRep>
;                                   represents a list of flat-section 
;                                   and FlatRep

;;Template:
;(define (fr-fn fr)
;  (cond
;    [(empty? fr) ...]
;    [else (...(fs-fn (first fr))
;              (fr-fn (rest fr)))]))

;;example
;empty
;(list (list 1) "This is a section")

;;A flat-section is a
;--(list NELONI String)              Interpretation: (list NELONI String) 
;                                    represents a list of NELONI and a String

;;Template:
;(define (fs-fn fs)
;  (...(nelist-fn (first fs))
;      (... (rest fs))))
      
;;example:
;(list (list 1 1) "This is a sub-section")

;; a ListOfNonNegInt(LONI) is 
;-- empty                            Interpretation: empty represents an empty
;                                    list of non negative integers.
;-- (cons NonNegInt LONI)            Interpretation: (cons NonNegInt LONI) 
;                                    represents a non empty list of non
;                                    negative integers.

;Template:
;(define (loni-fn loni)
;  (cond
;    [(empty? loni) ...]
;    [else (... (first loni)
;               (loni-fn (rest loni))]))

;example
;(list 1 2)

;; a NonEmptyListOfNonNegInt(NELONI) is 

; -- (cons NonNegInt empty)          Interpretation: (cons NonNegInt empty)
;                                    represents that there is one NonNegInt
;                                    in the list.
;
; -- (cons NonNegInt NELONI)         Interpretation: (cons NonNegInt NELONI) 
;                                    represents a non empty list of non
;                                    negative integers.

;Template:
;(define (nelist-fn ne)
; (cond 
;  [(empty? (rest ne)) (... (first ne))]
;  [else (... 
;         (... (first ne))
;         (nelist-fn (rest ne)))]))

;example
;(list 1 2 3)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;FUNCTION DEFINITION;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;nested-rep? : Sexp -> Boolean
;;GIVEN: an Sexp
;;RETURNS: true iff it is the nested representation of some outline
;;EXAMPLE: refer test
;;STRATEGY: strutural decomposition on sexp: Sexp

(define (nested-rep? sexp)  
  (cond
    [(string? sexp) true]
    [(integer? sexp) false]    
    [(list? sexp) (andmap nested-rep? sexp)]))

;;TEST: test follow function definitions

;;flat-rep? : Sexp -> Boolean
;;GIVEN: an Sexp
;;RETURNS: true iff it is the flat representation of some outline
;;EXAMPLE: refer test
;;STRATEGY: strutural decomposition on sexp: Sexp

(define (flat-rep? sexp)  
  (cond
    [(string? sexp) true]
    [(integer? sexp) true]    
    [(list? sexp) (andmap flat-rep? sexp)]))



;;increment-section: NELONI -> NELONI
;;GIVEN: a non empty list of non negative numbers that represents a section
;;of some nested rep nr0
;;RETURN: a non-empty list of non negative numbers that represents a section
;;that is immediately after the given section at the same level
;;Examples: (increment-section (list 1)) => (list 2)
;;(increment-section (list 2 3)) => (list 2 4)
;;STRATEGY: structural decomposition on lon: NELONI

(define (increment-section neloni)
  (cond 
    [(empty? (rest neloni)) (list (+ 1 (first neloni)))]
    [else (cons (first neloni) 
                (increment-section (rest neloni)))]))
  

;;nested-to-flat : NestedRep -> FlatRep
;;GIVEN: an outline as a nested representation
;;RETURNS: the flat representation of the outline
;;EXAMPLE: refer test
;;STRATEGY: function composition

(define (nested-to-flat nr)  
   (nested-to-flat-helper INITIAL-SECTION nr))

;;TEST: test follow function definitions

;;nested-to-flat-helper : NELONI NestedRep -> FlatRep
;;GIVEN: a non empty list of non negative integer 
;;that represents the current section of the given nestedrep and
;;the representation of an outline as a nested representation
;;WHERE: On start of processing the section represents the 
;;INITIAL-SECTION and is later on modified based on the given
;;nested rep's position in some list nr0.
;;RETURNS: the flat representation of the outline
;;EXAMPLE:
;;(nested-to-flat-helper (list 1) "nr-string")
;;=> (list (list (list 1) "nr-string"))
;;STRATEGY: structural decomposition on nr: NestedRep

(define (nested-to-flat-helper section nr)
  (cond
    [(string? nr) (list (list section nr))]
    [(list? nr) (nested-list-to-flat
                 section nr)]))
  
;;nested-list-to-flat : NELONI LONR -> FlatRep
;;GIVEN: a non empty list of non negative integer
;;that represents the current section of the sublist lonr and
;;a sublist of nested representation of some list of nested
;;representation list nr0
;;RETURNS: flat representation of the outline
;;EXAMPLE:
;;(nested-list-to-flat (list 1) (list "abc" (list "def"))
;;=> (list (list (list 1) "abc") (list (list 1 1) "def"))
;;STRATEGY: structural decomposition on lnr : LONR

(define (nested-list-to-flat section lnr)
  (cond
    [(empty? lnr) empty]
    [else   (append (nested-to-flat-helper section (first lnr))
                    (nested-list-to-flat 
                     (next-section section (first lnr)) (rest lnr)))])) 


;;next-section: NELONI NestedRep -> NELONI
;;GIVEN: a non empty list of non negative integer that represents a section
;;formed based on its position on some list of nestedrep list nr0,and a 
;;nested rep
;;RETURN: a non empty list of non negative integer that represents a section 
;;that should follow the given section depending on the given nested rep.
;;If the given nested rep is string, then it returns a section that is one   
;;level deeper than the given section. 
;;Otherwise, it returns a section by incrementing the last number in the
;;given section by one
;;Examples: (next-section (list 1) "The first section" ) => (list 1 1)
;;(next-section (list 1) empty ) => (list 2)
;;(next-section (list 1 1) (list "A subsection with no subsections")) 
;; => (list 1 2)
;;STRATEGY: structural decomposition on current-nr : NestedRep

(define (next-section current-section current-nr)
  (cond
    [(string? current-nr) (append current-section NEW-SUBSECTION)]
    [(list? current-nr) (increment-section current-section)]))


  
;;TEST

 (define nested-sample 
    '(("The first section"
       ("A subsection with no subsections")
       ("Another subsection"
        ("This is a subsection of 1.2")
        ("This is another subsection of 1.2"))
       ("The last subsection of 1"))
      ("Another section"
       ("More stuff")
       ("Still more stuff"))))

(define flat-sample
  '(((1) "The first section")
 ((1 1) "A subsection with no subsections")
 ((1 2) "Another subsection")
 ((1 2 1) "This is a subsection of 1.2")
 ((1 2 2) "This is another subsection of 1.2")
 ((1 3) "The last subsection of 1")
 ((2) "Another section")
 ((2 1) "More stuff")
 ((2 2) "Still more stuff")))

(begin-for-test  
  (check-equal? 
   (nested-rep? nested-sample)  
   true
   "the value should be true, it is a nested rep")
  (check-equal? 
   (nested-rep? 1) 
   false
   "the value should be false, not a nested rep")
  (check-equal?
   (flat-rep? flat-sample)
   true
   "the value should be true,it is flat rep")
  (check-equal? 
   (nested-to-flat  nested-sample)
   flat-sample
   "the output should be a flat represenation
    of the given nested rep"))
    

    
