;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname snacks) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
;; snacks.rkt

;; PURPOSE: To illustrate working of a snacks machine.

(require rackunit)
(require "extras.rkt")

(provide initial-machine
         machine-next-state
         machine-chocolates
         machine-carrots
         machine-bank)

;;******************************************************************************


;A CustomerInput is one of
;-- a PosInt          interp: insert the specified number of cents
;-- "chocolate"       interp: request a chocolate bar
;-- "carrots"         interp: request a package of carrot sticks
;-- "release"         interp: return all the coins that the customer has put in

;; customer-fn : CustomerInput -> ??

;(define (customer-fn i)
;  (cond
;    [(number=? i) ...]
;    [(string=? i "chocolate") ...]
;    [(string=? i "carrots") ...]
;    [(string=? i "release") ...]))


(define-struct machine(nchoco-bar ncarrot-sticks money-in-bank cust-cents))

;  A Machine is a (make-machine NonNegInt NonNegInt NonNegInt NonNegInt)
;  It represents the state of the machine.
;  Interpretation:
;  nchoco-bar = the number of chocolate bars in the machine.
;  ncarrot-sticks = the number of package of carrot sticks in the machine.
;  money-in-bank = the money machine's in bank.
;  cust-cents = the amount in cents the customer has inputted in the machine.

;; TEMPLATE:
;(define (machine-fn m)
;  (...
;   (machine-nchoco-bar m)
;   (machine-ncarrot-sticks m)
;   (machine-money-in-bank m)
;   (machine-cust-cents m)))



;initial-machine : NonNegInt NonNegInt-> Machine
;GIVEN: the number of chocolate bars and the number of packages of
;carrot sticks
;RETURNS: a machine loaded with the given number of chocolate bars and
;carrot sticks, with an empty bank.
;EXAMPLE:
;(initial-machine 10 10) = (make-machine 10 10 0 0)
;STRATEGY : function composition.

(define (initial-machine ncs ncb)
  (make-machine ncs ncb 0 0))

;; TEST

(begin-for-test
  (check-equal?
   (initial-machine 10 10)
   (make-machine 10 10 0 0)
   "the machine should be, (make-machine 10 10 0 0)"))


;machine-next-state : Machine CustomerInput -> Machine
;GIVEN: a machine state and a customer input
;RETURNS: the state of the machine that should follow the customer's
;input
;EXAMPLE: 
;(machine-next-state (initial-machine 10 10) 10) =
;(make-machine 10 10 0 10)
;STRATEGY : cases on customer input.

(define (machine-next-state  m customer-input)
  (cond
    [(number? customer-input) (machine-updated-cust-cents m customer-input)]
    [(string=? "chocolate" customer-input) (machine-after-chocolate m)]  
    [(string=? "carrots" customer-input) (machine-after-carrots m)]
    [(string=? "release" customer-input) (machine-updated-cust-cents m 0)]))

;; TEST

(begin-for-test
  (check-equal?
   (machine-next-state (initial-machine 10 10) 10)
   (make-machine 10 10 0 10)
   "the machine should be, (make-machine 10 10 0 10)")
  (check-equal?
   (machine-next-state (make-machine 10 10 0 1000) "chocolate")
   (make-machine 9 10 175 825)
   "the machine should be, (make-machine 9 10 175 825)")
  (check-equal?
   (machine-next-state (make-machine 10 10 0 1000) "carrots")
   (make-machine 10 9 70 930)
   "the machine should be, (make-machine 10 9 70 930)")
  (check-equal?
   (machine-next-state  (make-machine 10 10 0 10) "release")
   (make-machine 10 10 0 0)
   "the machine should be, (make-machine 10 10 0 0)")
  (check-equal?
   (machine-next-state  (make-machine 10 10 0 50) "chocolate")
   (make-machine 10 10 0 50)
   "the machine should be, (make-machine 10 10 0 50)")
  (check-equal?
   (machine-next-state  (make-machine 10 10 0 50) "carrots")
   (make-machine 10 10 0 50)
   "the machine should be, (make-machine 10 10 0 50)")
  (check-equal?
   (machine-next-state  (make-machine 0 10  0 1000) "chocolate")
   (make-machine 0 10 0 1000)
   "the machine should be, (make-machine 0 10 0 1000)")
  (check-equal?
   (machine-next-state  (make-machine 10 0  0 1000) "carrots")
   (make-machine 10 0 0 1000)
   "the machine should be, (make-machine 10 0 0 1000)"))

;machine-updated-cust-cents Machine PosInt: -> Machine
;GIVEN: a machine-state and customer-cents
;RETURNS: a machine-state with the updated value of customer-cents
;in the machine.
;EXAMPLE:
;(machine-updated-cust-cents (make-machine 10 10 0 0) 20) =
;(make-machine 10 10 0 20)
;STRATEGY: Structural decomposition.

(define (machine-updated-cust-cents m cust-cents)
  (make-machine  
   (machine-nchoco-bar m) 
   (machine-ncarrot-sticks m) 
   (machine-bank m) 
   cust-cents))
;TEST

(begin-for-test
  (check-equal?
   (machine-updated-cust-cents (initial-machine 10 10) 20)
   (make-machine 10 10 0 20)
   "the machine should be, (make-machine 10 10 0 20)"))


;machine-after-chocolate : Machine -> Machine
;GIVEN: a machine.
;RETURNS: the state of the machine that should follow after customer's
;input
;EXAMPLE: 
;(machine-after-chocolate (make-machine 10 10 0 175) =
;(make-machine 9 10 175 0)
;STRATEGY: structural decomposition


(define (machine-after-chocolate m)
  (machine-after-selecting-chocolate
   (machine-nchoco-bar m)
   (machine-ncarrot-sticks m)
   (machine-money-in-bank m)
   (machine-cust-cents m)))

;TEST

(begin-for-test
  (check-equal?
   (machine-after-chocolate (make-machine 10 10 0 175))
   (make-machine 9 10 175 0)
   "the machine should be, (make-machine 9 10 175 0)"))

;machine-after-selecting-chocolate : NonNegInt NonNegInt NonNegInt PosInt-> Machine
;GIVEN: number of chocolate bars, number of carrot packages, money in bank, 
;and customer cents.
;RETURNS: a state of the machine with the given values.
;EXAMPLE: 
;(machine-after-selecting-chocolate 10 10 175 175) =
;(make-machine 9 10 350 0)
;STRATEGY: function composition

; 175 is the cost of one chocolate bar in cents
(define (machine-after-selecting-chocolate cb cp a c)
  (if (>= c 175) 
      (machine-new-state-after-chocolate cb cp a c)
      (make-machine cb cp a c)))

;TEST

(begin-for-test
  (check-equal?
   (machine-after-selecting-chocolate 10 10 175 175)
   (make-machine 9 10 350 0)
   "the machine should be, (make-machine 9 10 350 0)"))

;machine-new-state-after-chocolate : NonNegInt NonNegInt NonNegInt PosInt -> Machine
;GIVEN: number of chocolate bars, number of carrot packages, money in bank, 
;customer cents.
;RETURNS: a state of the machine with the given values.
;EXAMPLE: 
;(machine-new-state-after-chocolate 10 10 175 25) =
;(make-machine 10 10 175 25)
;STRATEGY: function composition

; 175 is the cost of a chocolate bar in cents
(define (machine-new-state-after-chocolate cb cp a c)
  (if (= cb 0) 
      (make-machine cb cp a c)
      (make-machine (- cb 1) cp (+ a 175) (- c 175))))

;TEST

(begin-for-test
  (check-equal?
   (machine-after-selecting-chocolate 10 10 175 25)
   (make-machine 10 10 175 25)
   "the machine should be, (make-machine 10 10 175 25)"))

;machine-after-carrots : Machine -> Machine
;GIVEN: a machine state
;RETURNS: the state of the machine that should follow after selecting carrots.
;EXAMPLE: 
;(machine-after-chocolate (make-machine 10 10 0 175) =
;(make-machine 9 10 175 0)
;STRATEGY: structural decomposition

(define (machine-after-carrots m)
  (machine-after-selecting-carrots
   (machine-nchoco-bar m)
   (machine-ncarrot-sticks m)
   (machine-money-in-bank m)
   (machine-cust-cents m)))

;TEST

(begin-for-test
  (check-equal?
   (machine-after-carrots (make-machine 10 10 0 175))
   (make-machine 10 9 70 105)
   "the machine should be, (make-machine 10 9 70 105)"))

;machine-after-selecting-carrots : 
;NonNegInt NonNegInt NonNegInt PosInt-> Machine
;GIVEN: number of chocolate bars, number of carrot packages, money in bank, 
;and customer cents.
;RETURNS: a state of the machine with the given values.
;EXAMPLE: 
;(machine-after-selecting-carrots 10 10 175 175) =
;(make-machine 10 9 245 105)
;STRATEGY: function composition

;70 is cost of one package of carrot-sticks in cents
(define (machine-after-selecting-carrots cb cp a c)
  (if (>= c 70) 
      (machine-new-state-after-carrots cb cp a c)
      (make-machine cb cp a c)))

;TEST

(begin-for-test
  (check-equal?
   (machine-after-selecting-carrots 10 10 175 175)
   (make-machine 10 9 245 105)
   "the machine should be, (make-machine 10 9 245 105)"))

;machine-new-state-after-carrots :
;NonNegInt NonNegInt NonNegInt PosInt -> Machine
;GIVEN: number of chocolate bars, number of carrot-sticks packages, 
;money in bank, customer cents.
;RETURNS: a state of the machine with the given values.
;EXAMPLE: 
;(machine-new-state-after-carrots 10 10 175 25) =
;(make-machine 10 10 175 25)
;STRATEGY: function composition

;70 is cost of one package of carrot-sticks in cents
(define (machine-new-state-after-carrots cb cp a c)
  (if (= cp 0) 
      (make-machine cb cp a c)
      (make-machine cb (- cp 1) (+ a 70) (- c 70))))

;TEST

(begin-for-test
  (check-equal?
   (machine-after-selecting-chocolate 10 10 175 25)
   (make-machine 10 10 175 25)
   "the machine should be, (make-machine 10 10 175 25)"))


;machine-chocolates : Machine ->  NonNegInt
;GIVEN: a machine state
;RETURNS: the number of chocolate bars left in the machine
;EXAMPLE : 
;(machine-chocolates (make-machine 10 9 200 0)
;= 10
;STRATEGY: function composition

(define (machine-chocolates m)
  (machine-nchoco-bar m))

;; TEST

(begin-for-test
  (check-equal?
   (machine-chocolates (make-machine 10 9 200 0))
   10))

;machine-carrots : Machine ->  NonNegInt
;GIVEN: a machine state
;RETURNS: the number of packages of carrot sticks left in the machine
;EXAMPLE : 
;(machine-carrots (make-machine 10 9 200 0)
;= 9
;STRATEGY: function composition

(define (machine-carrots m)
  (machine-ncarrot-sticks m))

;; TEST

(begin-for-test
  (check-equal?
   (machine-carrots (make-machine 10 9 200 0))
   9))

;machine-bank : Machine ->  NonNegInt
;GIVEN: a machine state
;RETURNS: the amount of money in the machine's bank, in cents
;EXAMPLE : 
;(machine-bank (make-machine 10 9 200 0)
;= 200
;STRATEGY: function composition

(define (machine-bank m)
  (machine-money-in-bank m))

;; TEST

(begin-for-test
  (check-equal?
   (machine-bank (make-machine 10 9 200 0))
   200))


