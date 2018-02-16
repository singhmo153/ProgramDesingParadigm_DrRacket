;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname inventory) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
;; inventory.rkt

(require rackunit)
(require "extras.rkt")

(provide inventory-potential-profit)
(provide inventory-total-volume)
(provide price-for-line-item)
(provide fillable-now?)
(provide days-til-fillable)
(provide price-for-order)
(provide inventory-after-order)
(provide increase-prices)
(provide make-book)
(provide make-line-item)
(provide reorder-present?)
(provide make-empty-reorder)
(provide make-reorder)
(provide inventory-after-deliveries)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;CONSTANTS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define NULL 0)
(define HUNDRED 100)
(define ONE 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; DATA DEFINITIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Book

(define-struct book 
  (isbn 
   title 
   author 
   publisher 
   unit-price 
   unit-cost 
   copies-on-hand 
   reorder-status 
   cuft))

;; A Book is a 
;(make-book 
; Integer String String String NonNegInt 
; NonNegInt NonNegInt ReorderStatus Real)
;; Interpretation:
;; isbn is the unique identifier of the book
;; title is title of the book
;; author is name of the book's author
;; publisher is the publisher of the book
;; unit-price is the selling price of the book in USD*100
;; unit-cost is the cost price of the book in USD*100
;; copies-on-hand is the number of copies on hand
;; reorder-status is a ReorderStatus. It gives information about
;; the outstanding orders of a book.
;; cuft is the volume taken up by one unit of the book, in cubic feet.

;; Template:
;; book-fn : Book -> ??
;;(define (book-fn b)
;;  (... (book-isbn b) 
;;       (book-title b) 
;;       (book-author b) 
;;       (book-publisher b) 
;;       (book-unit-price b) 
;;       (book-unit-cost b) 
;;       (book-copies-on-hand b) 
;;       (book-reorder-status b) 
;;       (book-volume b)))

;; Example:
;  (make-book 0001 "HtDP/1" "Felleisen" "abc" 30 20 5 reorder-status1 50)

;; ReorderStatus

(define-struct reorder-status
  (reorder-present? days copies))

;; A ReorderStatus is a
;;  (make-reorder-status Boolean PosInt PosInt)
;; Interpretation:
;; reorder-present? describes whether the book has an outstanding order or not.
;; days is the number of days in which the 
;; shipment is expected to arrive.
;; copies is the number of copies of book which is expected to 
;; arrive.

;; Template:
;   reorder-status-fn : ReorderStatus -> ??
;   (define (reorder-status-fn r)
;     (...
;      (reorder-status-reorder-present? r)
;      (reorder-status-days r)
;      (reorder-status-copies r)))

;; Example:
;  (define reorder-status2 (make-reorder-status true 15 2))

;; LineItem
(define-struct line-item(isbn quantity))
;; A LineItem is a 
;; (make-line-item Integer PosInt)
;; Interpretation:
;; isbn is the unique identifier for a book that has been ordered.
;; quantity is the quantity that has been ordered.

;; Template:
;  line-item-fn : LineItem -> ??
;  (define (line-item-fn item)
;    (...
;     (line-item-isbn item)
;     (line-item-quantity item)))

;; Example:
; (make-line-item 0001 5)

;; ListOfBooks

;; A ListOfBooks (LOB) is either

;; -- empty           Interpretation: empty represents an empty list of books
;; -- (cons Book LOB) Interpretation: (cons Book LOB) represents a non-empty 
;;                    list of books

;; Template:
;; lob-fn : LOB -> ??
;; (define (lob-fn lob)
;;   (cond
;;     [(empty? lob) ...]
;;     [else (...
;;             (book-fn (first lob))
;;             (lob-fn (rest lob)))]))

;; Example:
;;(define lob10
;;  (list
;;    (make-book 0001 "HtDP/1" "Felleisen" "abc" 30 20 10 reorder-status1 1/20)
;;    (make-book 0002 "EOPL" "Wand" "def" 50 40 20 reorder-status1 1/10)
;;    (make-book 0003 "Hamlet" "Shakespeare" "ghi" 70 60 1 reorder-status2 1))

;; ListOfLineItems

;; A ListOfLineItems (LOLI) is either

;; -- empty                Interpretation: empty represents an empty list of 
;;                         line items.
;; -- (cons LineItem LOLI) Interpretation: (cons LineItem LOLI) represents a 
;;                         non-empty list of line items.

;; Template:
;; loli-fn : LOLI -> ??
;; (define (loli-fn loli)
;;   (cond
;;     [(empty? loli) ...]
;;     [else (...
;;             (line-item-fn (first loli))
;;             (loli-fn (rest loli)))]))

;; Example:
;;(define loli1
;;  (list
;;   (make-line-item 0001 5)
;;   (make-line-item 0002 10)))


;; Inventory
;; An Inventory is a ListOfBooks.
;; Interpretation: the list of books that the bookstore carries, in any order.
;; WHERE : no isbn is duplicated.

;; Order
;; An Order is a ListOfLineItems.
;; Interpretation: the list of line items that has been ordered.

;; A MaybeInteger is one of:
;; -- Integer
;; -- false

;; Template:
;; maybe-integer-fn : MaybeInteger -> ??
;; (define (maybe-integer-fn m)
;;   (cond
;;     [(integer? m) ...]
;;     [(false? m) ...]))

;; ListOf<MaybeInteger>

;; A ListOf<MaybeInteger> (LOMI) is either

;; -- empty                    Interpretation: empty represents an empty list
;;                             of MaybeInteger
;; -- (cons MaybeInteger LOMI) Interpretation: (cons MaybeInteger LOMI) 
;;                             represents a non-empty list of MaybeInteger

;; Template:
;; lomi-fn : LOMI -> ??
;; (define (lomi-fn lomi)
;;   (cond
;;     [(empty? lomi) ...]
;;     [else (...
;;             (maybe-integer-fn (first lomi))
;;             (lomi-fn (rest lomi)))]))

;;EXAMPLE:
;;(define maybelist (list 1 2 false))

;; ListOf<NonNegInt>

;; A ListOf<NonNegInt> (LONI) is either

;; -- empty                    Interpretation: empty represents an empty list
;;                             of NonNegInt
;; -- (cons NonNegInt LONI)    Interpretation: (cons NonNegInt LONI) 
;;                             represents a non-empty list of NonNegInt

;; Template:
;; loni-fn : LONI -> ??
;; (define (loni-fn loni)
;;   (cond
;;     [(empty? loni) ...]
;;     [else (...
;;             (... (first loni))
;;             (loni-fn (rest loni)))]))

;;EXAMPLE:
;;(define nonneglist (list 1 2 0))


;; examples of reorder-status for testing

(define reorder-status1 (make-reorder-status false 0 0))
(define reorder-status2 (make-reorder-status true 15 2))
(define reorder-status3 (make-reorder-status true 20 10))

;; examples of ListOfBooks for testing

(define lob1
  (list
   (make-book 0001 "HtDP/1" "Felleisen" "abc" 30 20 10 reorder-status1 1/20)
   (make-book 0002 "EOPL" "Wand" "def" 50 40 20 reorder-status1 1/10)
   (make-book 0003 "Hamlet" "Shakespeare" "ghi" 70 60 1 reorder-status2 1)
   (make-book 0004 "Macbeth" "Shakespeare" "jkl" 90 75 0 reorder-status3 1/5)))

(define lob2
  (list
   (make-book 0001 "HtDP/1" "Felleisen" "abc" 30 20 5 reorder-status1 1/20)
   (make-book 0002 "EOPL" "Wand" "def" 50 40 10 reorder-status1 1/10)
   (make-book 0003 "Hamlet" "Shakespeare" "ghi" 70 60 1 reorder-status2 1)
   (make-book 0004 "Macbeth" "Shakespeare" "jkl" 90 75 0 reorder-status3 1/5)))

(define lob3
  (list
   (make-book 0001 "HtDP/1" "Felleisen" "abc" 30 20 5 reorder-status1 1/20)
   (make-book 0002 "EOPL" "Wand" "def" 50 40 10 reorder-status1 1/10)
   (make-book 0003 "Hamlet" "Shakespeare" "abc" 70 60 1 reorder-status2 1)
   (make-book 0004 "Macbeth" "Shakespeare" "jkl" 90 75 0 reorder-status3 1/5)))

(define lob4
  (list
   (make-book 0001 "HtDP/1" "Felleisen" "abc" 33 20 5 reorder-status1 1/20)
   (make-book 0002 "EOPL" "Wand" "def" 50 40 10 reorder-status1 1/10)
   (make-book 0003 "Hamlet" "Shakespeare" "abc" 77 60 1 reorder-status2 1)
   (make-book 0004 "Macbeth" "Shakespeare" "jkl" 90 75 0 reorder-status3 1/5)))

(define lob5
  (list
   (make-book 0001 "HtDP/1" "Felleisen" "abc" 33 20 5 reorder-status1 50)
   (make-book 0002 "EOPL" "Wand" "def" 50 40 10 reorder-status1 60)
   (make-book 0003 "Hamlet" "Shakespeare" "abc" 77 60 5 reorder-status2 80)
   (make-book 0004 "Macbeth" "Shakespeare" "jkl" 90 75 10 reorder-status3 10)))

(define lob6
  (list
   (make-book 0001 "HtDP/1" "Felleisen" "abc" 33 20 5 reorder-status1 50)
   (make-book 0002 "EOPL" "Wand" "def" 50 40 10 reorder-status1 60)
   (make-book 0003 "Hamlet" "Shakespeare" "abc" 77 60 0 reorder-status2 80)
   (make-book 0004 "Macbeth" "Shakespeare" "jkl" 90 75 5 reorder-status3 10)))

;; examples of ListOfLineItems for testing

(define loli1
  (list
   (make-line-item 0001 5)
   (make-line-item 0002 10)))

(define loli2
  (list
   (make-line-item 0001 15)
   (make-line-item 0002 10)))

(define loli3
  (list
   (make-line-item 0001 15)
   (make-line-item 0003 10)))

(define loli4
  (list
   (make-line-item 0003 2)
   (make-line-item 0004 10)))

(define loli5
  (list
   (make-line-item 0003 15)
   (make-line-item 0004 10)))

(define loli6
  (list
   (make-line-item 0003 3)
   (make-line-item 0004 15)))

(define loli7
  (list
   (make-line-item 0008 3)
   (make-line-item 0004 15)))

(define loli8
  (list
   (make-line-item 0001 20)
   (make-line-item 0004 15)))

(define loli9
  (list
   (make-line-item 0003 5)
   (make-line-item 0004 5)))

(define lineitem1 (make-line-item 0001 5))
(define lineitem2 (make-line-item 0008 5))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;inventory-potential-profit : Inventory -> Integer
;;GIVEN: an inventory of books
;;RETURNS: the total profit, in USD*100, for all the items in stock
;;EXAMPLE: refer test for example
;;STRATEGY: HOFC

(define (inventory-potential-profit lob)
  (foldr
   ; Book Integer -> Integer
   ; GIVEN : a book and and total potential profit computed so far
   ; RETURNS : sum of potential profit for all the books in stock
   (lambda (b profit-for-rest) (+ (book-potential-profit b) profit-for-rest))
   NULL
   lob))

;; TEST: Test follow helper functions

;; book-potential-profit : Book -> Integer
;; GIVEN: a book
;; RETURNS: the total profit, in USD*100 for all copies of the book in stock
;; EXAMPLE: (book-potential-profit 
;;           (make-book 
;;             0001 "HtDP/1" "Felleisen" "abc" 30 20 5 reorder-status1 50))=50
;; STRATEGY: structural decomposition on b : Book

(define (book-potential-profit b)
  (* 
   (book-copies-on-hand b) 
   (- (book-unit-price b) 
      (book-unit-cost b))))

;; TEST:

(begin-for-test
  (check-equal?
   (inventory-potential-profit lob1)
   310
   "the total potential profit for inventory should be 310"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;inventory-total-volume : Inventory -> Real
;;GIVEN: an inventory of books
;;RETURNS: the total volume needed to store all the books in stock.
;;EXAMPLE: refer test for example
;;STRATEGY: HOFC

(define (inventory-total-volume lob)
  (foldr
   ; Book Real -> Real
   ; GIVEN : book and total volume computed so far
   ; RETURNS : total volume of all books in stock
   (lambda (b volume-for-rest) (+ (book-inventory-volume b) volume-for-rest))
   NULL
   lob))

;; TEST: Test follow help functions

;;book-inventory-volume : Book -> Real
;;GIVEN: a book
;;RETURNS: the total volume needed to store all on-hand-copies of the book.
;;EXAMPLE: (book-inventory-volume 
;;          (make-book 
;;           0001 "HtDP/1" "Felleisen" "abc" 30 20 5 reorder-status1 1/5))= 1
;;STRATEGY: structural decomposition on b : Book

(define (book-inventory-volume b)
  (* (book-cuft b)
     (book-copies-on-hand b)))

;; TEST:

(begin-for-test
  (check-equal?
   (inventory-total-volume lob1)
   3.5
   "the total volume of books in inventory should be 3.5"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;price-for-line-item : Inventory LineItem -> MaybeInteger
;;GIVEN: an inventory and a line item
;;RETURNS: the price for that line item (the quantity times the unit
;;price for that item).  Returns false if that isbn does not exist in
;;the inventory. 
;;EXAMPLE: refer test for example
;;STRATEGY: function composition

(define (price-for-line-item lob item)
  (if (= (price-for-line-item-helper lob item) NULL)
      false
      (price-for-line-item-helper lob item)))

;; TEST : test follow help functions

;;price-for-line-item-helper : Inventory LineItem -> NonNegInt
;;GIVEN: an inventory and a line item
;;RETURNS: the price for the line item
;;EXAMPLE: (price-for-line-item-helper lob1 line-item1) = 150
;;STRATEGY: HOFC

(define (price-for-line-item-helper lob item)
  (foldr
   ; Book NonNegInt -> NonNegInt
   ; GIVEN : a book and price computed so far
   ; RETURNS : price for item if isbn of book equals item's isbn
   ;           else returns zero
   (lambda (b price-for-rest) (if (isbn-equal? item b) 
                                  (+ (line-item-total-price item b) 
                                     price-for-rest) 
                                  (+ NULL price-for-rest)))
   NULL
   lob))

;; TEST : test follow help functions

;;isbn-equal? : LineItem Book -> Boolean
;;GIVEN: a line item and a book
;;RETURNS: true if the isbn of line item is same as the isbn of book, 
;;false otherwise.
;;EXAMPLE:
;;(isbn-equal? 
;;  line-item1 
;;  (make-book 
;;            0001 "HtDP/1" "Felleisen" "abc" 30 20 5 reorder-status1 50))
;;= true
;;STRATEGY: structural decomposition on item : LineItem

(define (isbn-equal? item b)
  (isbn-equal-helper?
   (line-item-isbn item)
   b))

;; TEST: test follow help functions

;;isbn-equal-helper? : Integer Book -> Boolean
;;GIVEN: an isbn value and a book
;;RETURNS: true if the isbn value is same as that of the book's isbn,
;;false otherwise.
;;EXAMPLE: (isbn-equal-helper? 
;;           0001 
;;           (make-book 
;;            0001 "HtDP/1" "Felleisen" "abc" 30 20 5 reorder-status1 50))=true
;;STRATEGY: structural decomposition on b : Book

(define (isbn-equal-helper? item-isbn b)
  (= 
   item-isbn
   (book-isbn b)))

;; TEST: test follow help functions

;;line-item-total-price : LineItem Book -> Integer
;;GIVEN: a line item and a book
;;RETURNS: the total unit-price for the line item
;;EXAMPLE: (line-item-total-price 
;;          line-item1 
;;          (make-book 
;;           0001 "HtDP/1" "Felleisen" "abc" 30 20 5 reorder-status1 50))= 150
;;STRATEGY: structural decomposition on item : LineItem

(define (line-item-total-price item b)
  (line-item-total-price-helper (line-item-quantity item) b))

;; TEST: test follow help functions

;;line-item-total-price-helper : PosInt Book -> Integer
;;GIVEN: quantity of line item and a book
;;RETURNS: the total unit-price for the given quantity
;;EXAMPLE: (line-item-total-price-helper 
;;          5 
;;          (make-book 
;;           0001 "HtDP/1" "Felleisen" "abc" 30 20 5 reorder-status1 50)) = 150
;;STRATEGY: structural decomposition on b : Book

(define (line-item-total-price-helper q b)
  (* q (book-unit-price b)))

;; TEST

(begin-for-test
  (check-equal?
   (price-for-line-item lob1 lineitem1)
   150
   "the price of line item should be 150")
  (check-equal?
   (price-for-line-item lob1 lineitem2)
   false
   "the value should be false, as the book is not present in the inventory"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;fillable-now? : Order Inventory -> Boolean.
;;GIVEN: an order and an inventory
;;RETURNS: true iff there are enough copies of each book on hand to fill
;;the order. If the order contains a book that is not in the inventory,
;;then the order is not fillable.
;;EXAMPLE: refer test for example
;;STRATEGY: HOFC


(define (fillable-now? loli lob)
  (andmap
   ; LineItem -> Boolean
   ; GIVEN: a line item
   ; RETURNS: true if the line item is fillable
   (lambda (item) (fillable-now-helper? item lob))
   loli))


;; TEST: Test follow help functions

;;fillable-now-helper? : LineItem Inventory -> Boolean.
;;GIVEN: a line item and an inventory
;;RETURNS: true iff there are enough copies of each book on hand to fill
;;the line item.  If the line item has a book that is not present in the
;;inventory then the function returns false.
;;EXAMPLE: (line-item-fillable-now? line-item1 lob1) = true
;;line-item1 requires 5 copies which is present in lob1
;;STRATEGY: HOFC

(define (fillable-now-helper? item lob)
  (ormap
   ; Book -> Boolean
   ; GIVEN: a book
   ; RETURNS: true iff the given book can fill the item
   (lambda (b) (is-item-fillable? item b)) 
   lob))

;; TEST : test follow help functions

;;is-item-fillable? : LineItem Book -> Boolean
;;GIVEN: a line item and a book
;;RETURNS: true if the item is fillable, false otherwise 
;;EXAMPLE: (is-item-fillable? 
;;          (make-line-items 0001 5) 
;           (make-book 
;;           0001 "HtDP/1" "Felleisen" "abc" 30 20 5 reorder-status1 50))=true
;;STRATEGY: structural decomposition on item : LineItem

(define (is-item-fillable? item b)
  (if (isbn-equal? item b)
      (enough-copies? (line-item-quantity item) b)
      false))

;; TEST: test follow help functions

;;enough-copies? : PosInt Book -> Boolean
;;GIVEN: quantity of line item and a book
;;RETURNS: true if there are enough copies of the book available,
;;false otherwise
;;EXAMPLE: (enough-copies? 
;;          5 
;;          (make-book 
;;           0001 "HtDP/1" "Felleisen" "abc" 30 20 5 reorder-status1 50))=true
;;STRATEGY: structural decomposition on b : Book

(define (enough-copies? item-quantity b)
  (<= item-quantity
      (book-copies-on-hand b)))

;; TEST:

(begin-for-test
  (check-equal?
   (fillable-now? loli1 lob1)
   true
   "the order is fillable, so the value should be true")
  (check-equal?
   (fillable-now? loli2 lob1)
   false
   "the order is not fillable, so the value should be fasle")
  (check-equal?
   (fillable-now? loli3 lob1)
   false
   "the order is not fillable, so the value should be false")
  (check-equal?
   (fillable-now? loli7 lob1)
   false
   "the order is not fillable, so the value should be false"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;days-til-fillable : Order Inventory -> MaybeInteger
;;GIVEN: an order and an inventory
;;RETURNS: the number of days until the order is fillable, assuming all
;;the shipments come in on time.  Returns false if there won't be enough
;;copies of some book, even after the next shipment of that book comes in.
;;EXAMPLES: refer test for example
;;STRATEGY: HOFC

(define (days-til-fillable loli lob)
  (if (andmap maybeinteger-integer? (days-til-fillable-helper loli lob)) 
      (maximum-days (days-til-fillable-helper loli lob))
      false))

;;TEST: test follow help functions

;;days-til-fillable-helper : Order Inventory -> ListOf<MaybeInteger>
;;GIVEN: an order and an inventory
;;RETURNS: a list of maybeintegers. if a line item is fillable then the number
;;of days of expected shipment delivery is appended to the list, else false
;;is appended.
;;EXAMPLES: (days-til-fillable-helper (list (make-line-item 0003 10)) lob1) 
;;= (list false)
;;lob1 will have 3 copies of the book even after reorder. 
;;So the order is not fillable.
;;STRATEGY: HOFC


(define (days-til-fillable-helper loli lob)
  (foldr
   ; LineItem ListOf<MayBeInteger> -> ListOf<MayBeInteger>
   ; GIVEN : a line item and a list of maybeintegers constructed so far
   ; RETURNS : a list of maybeintegers for order
   (lambda (item lomi) (cons (days-til-item-fillable lob item) lomi))
   empty
   loli))

;; TEST : test follow help functions

;;days-til-item-fillable : Inventory LineItem -> MaybeInteger
;;GIVEN: an inventory and a line item
;;RETURNS: returns zero if the line-item is fillable now. 
;;Else it returns the number of days until the line item is fillable.
;;Returns false if there won't be enough
;;copies of the book, even after the next shipment of the book comes in.
;;EXAMPLES: (days-til-item-fillable (make-line-item 0001 5) lob1) = 0
;;lob1 has 10 copies on hand of book with isbn 0001
;;STRATEGY: HOFC

(define (days-til-item-fillable lob item)
  (foldr
   ; Book MayBeInteger -> MayBeInteger
   ; GIVEN : book and days til fillable computed so far
   ; RETURNS : days til fillable if the item is fillable, else returns false
   (lambda (b mi) (if (isbn-equal? item b) 
                      (days-til-fillable-after-reorder item b)  
                      mi))
   false
   lob))

;;TEST: test follow help functions

;;maximum-days : ListOf<NonNegInt> -> NonNegInt
;;GIVEN: a list of days
;;RETURNS: the maximum on the list
;;EXAMPLE: (maximum-days list(1 2 3)) = 3
;;STRATEGY: HOFC

(define (maximum-days lst)
  (foldr
   ; NonNegInt NonNegInt -> NonNegInt
   ; GIVEN : value for days and maximum value of days on list computed so far.
   ; RETURNS : maximum value of days on the list.
   (lambda (days max-days) (max days max-days))
   0
   lst)) 

;;TEST : test follow help functions  

;;maybeinteger-integer? : MaybeInteger -> Boolean
;;GIVEN: a maybeinteger
;;RETURNS: true if the value is an integer, false otherwise.
;;EXAMPLE: (maybe-integer-integer? 4) = true
;;(maybe-integer-integer? false) = false
;;STRATEGY: structural decomposition on m : MaybeInteger

(define (maybeinteger-integer? m)
  (cond
    [(integer? m) true]
    [(false? m) false]))

;; TEST : Test follow help functions

;;days-til-fillable-after-reorder : LineItem Book -> MaybeInteger
;;GIVEN: a line item and a book
;;RETURNS: the number of days until the line item is fillable after reorder.
;;Returns false if there won't be enough
;;copies of the book, even after the next shipment of the book comes in.
;;EXAMPLES:
;;(days-til-fillable-after-reorder 
;; (make-line-item 0003 10)
;;  (make-book 0003 "Hamlet" "Shakespeare" "ghi" 70 60 1 reorder-status2 1))
;;= false
;;(days-til-fillable-after-reorder 
;; (make-line-item 0003 3)
;;  (make-book 0003 "Hamlet" "Shakespeare" "ghi" 70 60 1 reorder-status2 1)) 
;;= 15
;;reorder status2 has 2 copies of book arriving after 15 days.
;;STRATEGY: structural decomposition on item : LineItem

(define (days-til-fillable-after-reorder item b)
  (if (is-item-fillable? item b)
      NULL
      (days-til-fillable-after-reorder-helper (line-item-quantity item) b)))

;;TEST : test follow help functions

;;days-til-fillable-after-reorder-helper : PosInt Book -> MaybeInteger
;;GIVEN: quantity of line item and a book
;;RETURNS: the number of days until the line item is fillable after reorder.
;;Returns false if there won't be enough copies of the book, 
;;even after the next shipment of the book comes in.
;;EXAMPLES: 
;;(days-til-fillable-after-reorder-helper 
;; 10
;; (make-book 0003 "Hamlet" "Shakespeare" "ghi" 70 60 1 reorder-status2 1))
;;= false
;;(days-til-fillable-after-reorder-helper 
;; 3
;; (make-book 0003 "Hamlet" "Shakespeare" "ghi" 70 60 1 reorder-status2 1))
;;= 15
;;reorder status2 has 2 copies of book arriving after 15 days.
;;STRATEGY: structural decomposition on b : Book

(define (days-til-fillable-after-reorder-helper q b)
  (days-if-book-sufficient q (book-reorder-status b) (book-copies-on-hand b)))

;;TEST: test follow help functions

;;days-if-book-sufficient : PosInt ReorderStatus NonNegInt -> MaybeInteger
;;GIVEN: quantity of line item, reorder status and quantity of book copies
;;available on hand.
;;RETURNS: the number of days until the line item is fillable after reorder. 
;;Returns false if there won't be enough copies of the book, 
;;even after the next shipment of the book comes in.
;;EXAMPLES: (days-if-book-sufficient 3 reorderstatus2 1) = 15
;;reorderstatus2 has 2 copies of book arriving in the next 15 days.
;;STRATEGY: structural decomposition on status : ReorderStatus

(define (days-if-book-sufficient q status copies-on-hand)
  (if (reorder-status-reorder-present? status)
      (if (<= q 
              (+ 
               (reorder-status-copies status) 
               copies-on-hand))
          (reorder-status-days status)
          false)
      false))

;; TEST

(begin-for-test
  (check-equal?
   (days-til-fillable loli4 lob1)
   20
   "the number of days for order fillable should be 20")
  (check-equal?
   (days-til-fillable loli5 lob1)
   false
   "the order should not be fillable")
  (check-equal?
   (days-til-fillable loli6 lob4)
   false
   "the order should not be fillable")
  (check-equal?
   (days-til-fillable loli7 lob1)
   false
   "the order should not be fillable")
  (check-equal?
   (days-til-fillable loli1 lob1)
   0
   "the order is in stock so 0 should be returned")
  (check-equal?
   (days-til-fillable loli8 lob1)
   false
   "the order is should not be fillable"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;price-for-order : Inventory Order -> NonNegInteger
;;GIVEN: an inventory of books, order of books
;;RETURNS: the total price for the given order, in USD*100. 
;;The price does not depend on whether any particular line item is in stock.
;;Line items for an isbn that is not in the inventory count as 0.
;;EXAMPLE: refer test for example
;;STRATEGY: HOFC


(define (price-for-order lob loli)
  (foldr
   ; LineItem NonNegInt -> NonNegInt
   ; GIVEN : a LineItem and total price computed so far
   ; RETURNS : total price for order
   (lambda (item price) (+ (price-for-item lob item) price))
   0
   loli))


;; TEST: test follow help function

;;price-for-item :Inventory  LineItem -> NonNegInteger
;;GIVEN: an inventory of books and a line item 
;;RETURNS: the total price for the line item, in USD*100.
;;if the item is not present in the inventory then 0 is returned
;;EXAMPLE: (price-for-item line-item1 lob1) = 150
;;line-item has isbn 0001 and quantity 5 and the unit-price for 0001 is 30.
;;STRATEGY: function composition

(define (price-for-item lob item)
  (if (maybeinteger-integer? (price-for-line-item lob item))
      (price-for-line-item lob item)
      NULL))

;; TEST:

(begin-for-test
  (check-equal?
   (price-for-order lob1 loli1)
   650
   "the total price should be 650")
  (check-equal?
   (price-for-order lob1 loli7)
   1350
   "the total price should be 1350"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;inventory-after-order : Inventory Order -> Inventory.
;;GIVEN: an inventory and an order
;;WHERE: the order is fillable now
;;RETURNS: the inventory after the order has been filled.
;;EXAMPLE: refer test for example
;;STRATEGY: HOFC

(define (inventory-after-order lob loli)
  (foldr
   ; LineItem Inventory -> Inventory
   ; GIVEN : a line item and an inventory
   ; RETURNS : the inventory after filling the order
   (lambda (item lob) (inventory-after-order-helper lob item))
   lob
   loli))

;; TEST: Test follow help functions

;;inventory-after-order-helper : Inventory LineItem -> Inventory
;;GIVEN: an inventory and a line item.
;;RETURNS: the inventory after the line item has been filled.
;;EXAMPLE: (inventory-after-order-helper lob1 line-item1) =
;;returns the inventory with the number of coies on hand for 
;;isbn 0001 reduced by 5.
;;5 is the quantity in line-item1 for isbn 0001.
;;STRATEGY: HOFC


(define (inventory-after-order-helper lob item)
  (foldr
   ; Book Inventory -> Inventory
   ; GIVEN : a book and inventory constructed so far
   ; RETURNS : the inventory after filling the line item
   (lambda (b rest-lob) (cons (if (isbn-equal? item b) 
                                  (return-updated-book b item) 
                                  b) 
                              rest-lob))
   empty
   lob))

;; TEST: Test follow help functions

;;return-updated-book : Book LineItem -> Book.
;;GIVEN: a book and a line item.
;;RETURNS: the book after the item has been filled.
;;EXAMPLE: 
;;(return-updated-book 
;; (make-book 
;;  0001 "HtDP/1" "Felleisen" "abc" 30 20 10 reorder-status1 1/20) line-item1)
;;= (make-book 0001 "HtDP/1" "Felleisen" "abc" 30 20 5 reorder-status1 1/20)
;;line-item1 has a quantity of 5 for isbn 0001.
;;STRATEGY: structural decomposition on b: Book

(define (return-updated-book b item)
  (make-book 
   (book-isbn b) 
   (book-title b) 
   (book-author b) 
   (book-publisher b) 
   (book-unit-price b) 
   (book-unit-cost b)
   (return-updated-copies (book-copies-on-hand b) item)
   (book-reorder-status b) 
   (book-cuft b)))

;; TEST: Test follow help functions

;;return-updated-copies : NonNegInt LineItem -> NonNegInt
;;GIVEN: quantity of book available on hand and a line item.
;;RETURNS: the number of book available after the line item has been filled.
;;EXAMPLE: (return-updated-book-helper 10 line-item1) = 5
;;line-item1 has a quantity of 5 for isbn 0001
;;STRATEGY: structural decomposition on item: LineItem

(define (return-updated-copies copies-on-hand item)
  (- copies-on-hand (line-item-quantity item)))

;; TEST:

(begin-for-test
  (check-equal?
   (inventory-after-order lob1 loli1)
   lob2
   "the copies-on-hand of isbn 0001 should be 5 and isbn 0002 should be 10")
  (check-equal?
   (inventory-after-order lob5 loli9)
   lob6
   "the copies-on-hand of isbn 0001 should be 5 and isbn 0002 should be 10")
  (check-equal?
   (inventory-after-order empty loli9)
   empty
   "the copies-on-hand of isbn 0001 should be 5 and isbn 0002 should be 10"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;increase-prices : Inventory String Real -> Inventory
;;GIVEN: an inventory, a publisher, and a percentage
;;RETURNS: an inventory like the original, except that all items by the given
;;publisher have their unit prices increased by the specified percentage.
;;EXAMPLE: refer test for example.
;;STRATEGY: HOFC


(define (increase-prices lob publisher percentage)
  (foldr
   ; Book Inventory -> Inventory
   ; GIVEN : a book and inventory constructed so far
   ; RETURNS : inventory after increase in prices of book of a publisher
   (lambda (b rest-lob) (cons 
                         (increase-prices-helper b publisher percentage) 
                         rest-lob))
   empty
   lob))


;; TEST: Test follow help functions

;;increase-prices-helper : Book String Real -> Book
;;GIVEN: a book, name of a publisher and percentage increase in price
;;RETURNS: the book with updated price value if the publisher of the book
;;is same as given, else returns the same book
;;EXAMPLE: 
;;(increase-prices-helper
;; (make-book 
;;  0001 "HtDP/1" "Felleisen" "abc" 30 20 10 reorder-status1 1/20)) "abc" 10)
;;= (make-book 
;;  0001 "HtDP/1" "Felleisen" "abc" 33 20 10 reorder-status1 1/20)
;;STRATEGY: structural decomposition on b : Book

(define (increase-prices-helper b publisher percentage)
  (if (string=? (book-publisher b) publisher)
      (updated-price-book-entry b percentage)
      b))

;; TEST: Test follow help functions

;;updated-price-book-entry : Book Real -> Book
;;GIVEN: a book and percentage increase in price
;;RETURNS: a book with updated unit price value
;;EXAMPLE:
;;(updated-price-book-entry 
;; (make-book 
;;  0001 "HtDP/1" "Felleisen" "abc" 30 20 10 reorder-status1 1/20)) 10)
;;=(make-book 0001 "HtDP/1" "Felleisen" "abc" 33 20 10 reorder-status1 1/20))
;;STRATEGY: structural decomposition on b : Book

(define (updated-price-book-entry b percentage)
  (make-book (book-isbn b) 
             (book-title b) 
             (book-author b) 
             (book-publisher b) 
             (update-price (book-unit-price b) percentage)
             (book-unit-cost b) 
             (book-copies-on-hand b) 
             (book-reorder-status b) 
             (book-cuft b)))

;; TEST:Test follow help functions

;;update-price : NonNegInt Real -> NonNegInt
;;GIVEN: unit price of a book and percentage of increase in price
;;RETURNS: updated unit price.
;;EXAMPLE:(update-price 30 10) = 33
;;STRATEGY: function composition

(define (update-price unit-price percentage)
  (round(+ unit-price (* unit-price (/ percentage HUNDRED)))))

;; Test

(begin-for-test
  (check-equal?
   (increase-prices lob3 "abc" 10)
   lob4
   "the price of books by publisher abc should increase by 10 percent")
  (check-equal?
   (increase-prices lob3 "star" 10)
   lob3
   "there will not be any change as there is no publisher named star"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;reorder-present? : ReorderStatus -> Boolean
;;GIVEN: a reorder-status
;;RETURNS: true iff the given ReorderStatus shows a pending re-order
;;EXAMPLE: refer test for example
;;STRATEGY: structural decomposition on r : ReorderStatus

(define (reorder-present? r)
  (reorder-status-reorder-present? r))

;;TEST

(begin-for-test
  (check-equal?
   (reorder-present? reorder-status1)
   false
   "the value should be false")
  (check-equal?
   (reorder-present? reorder-status2)
   true
   "the value should be true"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;make-empty-reorder : Any -> ReorderStatus
;;GIVEN: any value
;;Ignores its argument
;;RETURNS: a ReorderStatus showing no pending re-order.
;;the reorder-status-present? becomes false.
;;rest fields are ignored.
;;EXAMPLE:refer test for example
;;STRATEGY: function composition

(define (make-empty-reorder any-value)
  (make-reorder-status false NULL NULL))

;; TEST :

(begin-for-test
  (check-equal?
   (make-empty-reorder 0)
   reorder-status1
   "reorder-status should be (make-reorder-status false NULL NULL)"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;make-reorder : PosInt PosInt -> ReorderStatus
;;GIVEN: number of days and number of copies
;;RETURNS: a ReorderStatus with the given data.
;;EXAMPLE: refer test for example
;;STRATEGY: function composition

(define (make-reorder days copies)
  (make-reorder-status true days copies))

;; TEST
(begin-for-test
  (check-equal?
   (make-reorder 15 2)
   reorder-status2
   "reorder-status should be (make-reorder-status true 15 2)"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;inventory-after-deliveries : Inventory -> Inventory
;;GIVEN: today's inventory
;;RETURNS: an Inventory representing tomorrow's inventory, in which all
;;reorders that were due in 1 day are now available, and all other
;;reorders have their expected times decreased by 1. 
;;EXAMPLE: refer test for examle
;;STRATEGY: HOFC

(define (inventory-after-deliveries lob)
  (map inventory-after-deliveries-helper lob))

;;TEST : test follow help functions

;;inventory-after-deliveries-helper : Book -> Book
;;GIVEN: a book
;;RETURNS: the updated book if reorder is present, else
;;returns the same book
;;EXAMPLE:
;;(inventory-after-deliveries-helper
;; (make-book 0001 "HtDP/1" "Felleisen" "abc" 33 
;;            20 10 (make-reorder-status true 2 5) 1/20))
;;=(make-book 0001 "HtDP/1" "Felleisen" "abc" 33 
;;            20 10 (make-reorder-status true 1 5) 1/20))
;;STRATEGY:structural decomposition on b: book

(define (inventory-after-deliveries-helper b)
  (if (reorder-present? (book-reorder-status b))      
      (reorder-status-update b)
      b))

;;TEST: test follow help functions

;;reorder-status-update: Book -> Book
;;GIVEN: a book
;;RETURNS: the updated book for tomorrow,
;;if the book is available after one day then the copies
;;on hand of the book as well as the reorder status is updated
;;else just the reorder status is updated.
;;EXAMPLE:
;;(reorder-status-update
;; (make-book 0001 "HtDP/1" "Felleisen" "abc" 33 
;;            20 10 (make-reorder-status true 2 5) 1/20))
;;=(make-book 0001 "HtDP/1" "Felleisen" "abc" 33 
;;            20 10 (make-reorder-status true 1 5) 1/20))
;;STRATEGY: structural decomposition on b : book

(define (reorder-status-update b)
  (if (book-available-after-one-day? (book-reorder-status b))
      (book-after-delivery-available b)
      (book-after-one-day b)))

;;TEST: test follow help functions

;;book-available-after-one-day? ReorderStatus -> Boolean
;;GIVEN: a reorder status
;;RETURNS: true iff the expected day of delivery is one
;;EXAMPLE:(book-available-after-one-day? (make-reorder-status true 1 10)
;=;true
;;STRATEGY: structural decomposition on r : ReorderStatus

(define (book-available-after-one-day? r)      
  (= (reorder-status-days r) ONE))

;;TEST: test follow help functions

;;book-after-delivery-available: Book -> Book
;;GIVEN: a book
;;RETURNS: the updated book after delivery
;;EXAMPLE: 
;;(book-after-delivery-available
;; (make-book 0001 "HtDP/1" "Felleisen" "abc" 33 
;;            20 10 (make-reorder-status true 1 5) 1/20))
;;=(make-book 0001 "HtDP/1" "Felleisen" "abc" 33 
;;            20 15 (make-reorder-status false NULL NULL) 1/20))
;;STRATEGY: stuructural decomposition on b : Book

(define (book-after-delivery-available b)
  (make-book 
   (book-isbn b) 
   (book-title b) 
   (book-author b) 
   (book-publisher b) 
   (book-unit-price b) 
   (book-unit-cost b) 
   (update-copies-on-hand 
    (book-copies-on-hand b) 
    (book-reorder-status b))
   (make-empty-reorder NULL) 
   (book-cuft b)))

;;TEST : test follow help functions

;;update-copies-on-hand : NonNegInt ReorderStatus -> PosInt
;;GIVEN: a value for copies on hand and a reorder status
;;RETURNS: the sum of copies on hand and the copies received after delivery
;;EXAMPLE:(update-copies-on-hand 10 (make-reorder-status true 1 5)) = 15
;;STRATEGY:structural decomposition on r: ReorderStatus

(define (update-copies-on-hand copies-on-hand r)
  (+ copies-on-hand (reorder-status-copies r)))

;;TEST : test follow help functions

;;book-after-one-day: Book -> Book
;;GIVEN: a book having pending reorder
;;RETURNS: updated book having pending reorder,
;;the expected days of delivery is now decreased by 1
;;EXAMPLE:
;;(book-after-one-day
;; (make-book 0001 "HtDP/1" "Felleisen" "abc" 33 
;;            20 10 (make-reorder-status true 2 5) 1/20))
;;=(make-book 0001 "HtDP/1" "Felleisen" "abc" 33 
;;            20 10 (make-reorder-status true 1 5) 1/20))
;;STRATEGY: structural decomposition on b : Book

(define (book-after-one-day b)
  (make-book (book-isbn b) 
             (book-title b) 
             (book-author b) 
             (book-publisher b) 
             (book-unit-price b)
             (book-unit-cost b) 
             (book-copies-on-hand b)
             (update-reorder-status (book-reorder-status b)) 
             (book-cuft b)))

;;TEST : refer test for example

;;update-reorder-status: ReorderStatus -> ReorderStatus
;;GIVEN: a reorder status
;;RETURNS: the given reorder status with expected shipment arrival
;;in days decreased by 1
;;EXAMPLE:
;;(update-reorder-status (make-reorder-status true 2 5))
;;=(make-reorder-status true 1 5)
;;STRATEGY: structural decomposition on r: ReorderStatus

(define (update-reorder-status r)
  (make-reorder 
   (- (reorder-status-days r) ONE) 
   (reorder-status-copies r)))

;; TEST

(define reorder-status5 (make-reorder-status true 1 10))
(define reorder-status6 (make-reorder-status true 5 10))
(define reorder-status7 (make-reorder-status false 0 0))
(define reorder-status8 (make-reorder-status true 4 10))

;; examples of ListOfBooks for testing

(define lob12
  (list
   (make-book 0001 "HtDP/1" "Felleisen" "abc" 30 20 10 reorder-status7 1/20)
   (make-book 0002 "EOPL" "Wand" "def" 50 40 20 reorder-status7 1/10)
   (make-book 0003 "Hamlet" "Shakespeare" "ghi" 70 60 1 reorder-status5 1)
   (make-book 0004 "Macbeth" "Shakespeare" "jkl" 90 75 0 reorder-status6 1/5)))

(define lob21
  (list
   (make-book 0001 "HtDP/1" "Felleisen" "abc" 30 20 10 reorder-status7 1/20)
   (make-book 0002 "EOPL" "Wand" "def" 50 40 20 reorder-status7 1/10)
   (make-book 0003 "Hamlet" "Shakespeare" "ghi" 70 60 11 reorder-status7 1)
   (make-book 0004 "Macbeth" "Shakespeare" "jkl" 90 75 0 reorder-status8 1/5)))

;;test

(begin-for-test
  (check-equal?
   (inventory-after-deliveries lob12)
   lob21))




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;