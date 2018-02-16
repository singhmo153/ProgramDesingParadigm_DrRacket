;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname regexp) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))

;; regexp.rkt

;; PURPOSE: To illustrate the working of a finite state machine.

;;******************************************************************************


(require 2htdp/universe)
(require rackunit)
(require "extras.rkt")


(provide initial-state
         next-state
         accepting-state?
         error-state?)

;A State is one of
;-- "start"         interp: starting state
;-- "ab"            interp: an intermediate state ab
;-- "cd"            interp: an intermediate state cd
;-- "e"             interp: goal state
;-- "error"         interp: an error state

;; state-fn : State -> ??

;(define (state-fn i)
;  (cond
;    [(string=? i "start") ...]
;    [(string=? i "ab") ...]
;    [(string=? i "cd") ...]
;    [(string=? i "e") ...]
;    [(string=? i "error") ...]))


;initial-state : Number -> State
;GIVEN: a number
;RETURNS: a representation of the initial state
;of machine.  The given number is ignored.
;EXAMPLE:
;(initial-state 0) = "start"
;STRATEGY:function composition


(define (initial-state n)
  "start")

;; TEST

(begin-for-test
  (check-equal?
   (initial-state 0)
   "start"))

;next-state : State KeyEvent -> State
;GIVEN: a state of the machine and a key event.
;RETURNS: the state that should follow the given key event.  A key
;event that is to be discarded should leave the state unchanged.
;EXAMPLE:
;(next-state (initial-state 0) "a") = "ab"
;STRATEGY:cases on KeyEvent

(define (next-state s ke)
  (cond
    [(= (string-length ke) 1) (state-after-next-state s ke)]
    [else s]))

;; TEST

(begin-for-test
  (check-equal?
   (next-state (initial-state 0) "a")
   "ab")
  (check-equal?
   (next-state (next-state (initial-state 0) "a") "c")
   "cd")
  (check-equal?
   (next-state (next-state (initial-state 0) "a") "f")
   "error")
  (check-equal?
   (next-state (next-state (initial-state 0) "a") "e")
   "e")
  (check-equal?
   (next-state (next-state (next-state (initial-state 0) "a") "e") "e")
   "error")
  (check-equal?
   (next-state (next-state (next-state (initial-state 0) "a") "f") "e")
   "error")
  (check-equal?
   (next-state (next-state (next-state (initial-state 0) "a") "a") "left")
   "ab"))


;state-after-next-state : State KeyEvent -> State
;GIVEN: a state of the machine and a key event.
;RETURNS: the state that should follow the given key event.the state can
;remain in the old state or enter a new state.
;EXAMPLE:
;(state-after-next-state "a" "d") = "cd"
;STRATEGY: function composition


(define (state-after-next-state s ke)
  (if (or (accepting-state? s) (error-state? s))
      "error" 
      (state-after-key-event s ke)))


;;TEST

(begin-for-test
  (check-equal?
   (state-after-next-state "e" "e")
   "error") 
  (check-equal?
   (state-after-next-state "error" "e")
   "error")
  (check-equal?
   (state-after-next-state "a" "e")
   "e"))



;state-after-key-event : State KeyEvent -> State
;GIVEN: a state of the machine and a key event.
;RETURNS: the state that should follow the given key event.
;EXAMPLES:
;(state-after-key-event "ab" "d") = "cd"
;STRATEGY :cases on KeyEvent


(define (state-after-key-event s ke)
  (cond
    [(or (string=? ke "a") (string=? ke "b")) "ab"]
    [(or (string=? ke "c") (string=? ke "d")) "cd"]
    [(string=? ke "e") "e"]
    [else "error"]))

;; TEST

(begin-for-test
  (check-equal?
   (state-after-next-state "ab" "d")
   "cd"))

;accepting-state? : State -> Boolean
;GIVEN: a state of the machine
;RETURNS: true iff the given state is a final (accepting) state
;EXAMPLE:
;(accepting-state? "e") = true
;STRATEGY: function composition

(define (accepting-state? s)
  (if (string=? s "e") true false))

;; TEST

(begin-for-test
  (check-equal?
   (accepting-state? "e")
   true))


;error-state? : State -> Boolean
;GIVEN: a state of the machine
;RETURNS: true iff the string seen so far does not match the specified
;regular expression and cannot possibly be extended to do so.
;EXAMPLE:
;(error-state? "error") = true
;STRATEGY: function composition

(define (error-state? s)
  (if (string=? s "error") true false))

;; TEST

(begin-for-test
  (check-equal?
   (error-state? "error")
   true))



