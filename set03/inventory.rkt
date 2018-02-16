;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-abbr-reader.ss" "lang")((modname inventory) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
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
                                                                                

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;CONSTANTS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define NULL 0)
(define HUNDRED 100)

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
; Integer String String String NonNegInt NonNegInt NonNegInt ReorderStatus Real)
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
  (reorder-present? 
   expected-shipment-arrival-in-days 
   expected-number-of-copies))

;; A ReorderStatus is a
;;  (make-reorder-status Boolean PosInt PosInt)
;; Interpretation:
;; reorder-present? describes whether the book has an outstanding order or not.
;; expected-shipment-arrival-in-days is the number of days in which the 
;; shipment is expected to arrive.
;; expected-number-of-copies is the number of copies which is expected to 
;; arrive.

;; Template:
;   reorder-status-fn : ReorderStatus -> ??
;   (define (reorder-status-fn r)
;     (...
;      (reorder-status-reorder-present? r)
;      (reorder-status-expected-shipment-arrival-in-days r)
;      (reorder-status-expected-number-of-copies r)))

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
;;STRATEGY: structural decomposition on lob : Inventory

(define (inventory-potential-profit lob)
  (cond
    [(empty? lob) NULL]
    [else (+
           (book-potential-profit (first lob))
           (inventory-potential-profit (rest lob)))]))

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

;;inventory-total-volume : Inventory -> Real
;;GIVEN: an inventory of books
;;RETURNS: the total volume needed to store all the books in stock.
;;EXAMPLE: refer test for example
;;STRATEGY: structural decomposition on lob: Inventory

(define (inventory-total-volume lob)
  (cond
    [(empty? lob) NULL]
    [else (+
           (book-inventory-volume (first lob))
           (inventory-total-volume (rest lob)))]))

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

;;price-for-line-item : Inventory LineItem -> MaybeInteger
;;GIVEN: an inventory and a line item
;;RETURNS: the price for that line item (the quantity times the unit
;;price for that item).  Returns false if that isbn does not exist in
;;the inventory. 
;;EXAMPLE: refer test for example
;;STRATEGY: structural decomposition on lob : Inventory

(define (price-for-line-item lob item)  
  (cond
    [(empty? lob) false]
    [else (if (isbn-equal? item (first lob))
               (line-item-total-price item (first lob))
               (price-for-line-item (rest lob) item))]))

;; TEST : test follow help functions

;;isbn-equal? : LineItem Book -> Boolean
;;GIVEN: a line item and a book
;;RETURNS: true if the isbn of line item is same as the isbn of book, 
;;false otherwise.
;;EXAMPLE: (isbn-equal? lineitem2 lob1) = false
;;(isbn-equal? line-item1 lob1) = true
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
  
;;fillable-now? : Order Inventory -> Boolean.
;;GIVEN: an order and an inventory
;;RETURNS: true iff there are enough copies of each book on hand to fill
;;the order. If the order contains a book that is not in the inventory,
;;then the order is not fillable.
;;EXAMPLE: refer test for example
;;STRATEGY: structural decomposition on loli : Order

(define (fillable-now? loli lob)
  (cond
    [(empty? loli) true]
    [else (and (line-item-fillable-now? (first loli) lob)
               (fillable-now? (rest loli) lob))]))

;; TEST: Test follow help functions

;;line-item-fillable-now? : LineItem Inventory -> Boolean.
;;GIVEN: a line item and an inventory
;;RETURNS: true iff there are enough copies of each book on hand to fill
;;the line item.  If the line item has a book that is not present in the
;;inventory then the function returns false.
;;EXAMPLE: (line-item-fillable-now? line-item1 lob1) = true
;;line-item1 requires 5 copies which is present in lob1
;;STRATEGY: structural decomposition on lob : Inventory

(define (line-item-fillable-now? item lob)
  (cond
    [(empty? lob) false]
    [else (if (isbn-equal? item (first lob))
              (enough-copies? item (first lob))
              (line-item-fillable-now? item (rest lob)))]))

;; TEST : test follow help functions

;;enough-copies? : LineItem Book -> Boolean
;;GIVEN: a line item and a book
;;RETURNS: true if there are enough copies of the given book available,
;;false otherwise
;;EXAMPLE: (enough-copies? 
;;          (make-line-items 0001 5) 
;           (make-book 
;;           0001 "HtDP/1" "Felleisen" "abc" 30 20 5 reorder-status1 50))=true
;;STRATEGY: structural decomposition on item : LineItem

(define (enough-copies? item b)
  (enough-copies-helper? (line-item-quantity item) b))

;; TEST: test follow help functions

;;enough-copies-helper? : PosInt Book -> Boolean
;;GIVEN: quantity of line item and a book
;;RETURNS: true if there are enough copies of the book available,
;;false otherwise
;;EXAMPLE: (enough-copies-helper? 
;;          5 
;;          (make-book 
;;           0001 "HtDP/1" "Felleisen" "abc" 30 20 5 reorder-status1 50))=true
;;STRATEGY: structural decomposition on b : Book

(define (enough-copies-helper? item-quantity b)
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

;;days-til-fillable : Order Inventory -> MaybeInteger
;;GIVEN: an order and an inventory
;;RETURNS: the number of days until the order is fillable, assuming all
;;the shipments come in on time.  Returns false if there won't be enough
;;copies of some book, even after the next shipment of that book comes in.
;;EXAMPLES: refer test for example
;;STRATEGY: structural decomposition on loli : Order

(define (days-til-fillable loli lob)
  (cond
    [(empty? loli) NULL]
    [else (if (and (maybeinteger-integer? 
                    (days-til-fillable-now-helper (first loli) lob)) 
                   (maybeinteger-integer? (days-til-fillable (rest loli) lob)))                    
              (max (days-til-fillable-now-helper (first loli) lob)
                   (days-til-fillable (rest loli) lob))
              false)]))

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
 
;; TEST: test follow help functions

;;days-til-fillable-now-helper : LineItem Inventory -> MaybeInteger
;;GIVEN: a line item and an inventory
;;RETURNS: returns zero if the line-item is fillable now. 
;;Else it returns the number of days until the line item is fillable.
;;Returns false if there won't be enough
;;copies of the book, even after the next shipment of the book comes in.
;;EXAMPLES: (days-till-fillable-now-helper (make-line-item 0001 5) lob1) = 0
;;lob1 has 10 copies on hand of book with isbn 0001
;;STRATEGY: function composition

(define (days-til-fillable-now-helper item lob)
  (if (line-item-fillable-now? item lob)
      NULL
      (days-til-fillable-helper item lob)))

;;days-til-fillable-helper : LineItem Inventory -> MaybeInteger
;;GIVEN: a line item and an inventory
;;RETURNS: the number of days until the line item is fillable, assuming all
;;the shipments come in on time.  Returns false if there won't be enough
;;copies of the book, even after the next shipment of the book comes in.
;;EXAMPLES: (days-til-fillable-helper (make-line-item 0003 10) lob1) = false
;;lob1 will have 3 copies of the book even after reorder. 
;;So the line item is not fillable.
;;STRATEGY: structural decomposition on lob : Inventory

(define (days-til-fillable-helper item lob)
  (cond
    [(empty? lob) false]
    [else (if (isbn-equal? item (first lob))
              (days-til-fillable-after-reorder item (first lob))
              (days-til-fillable-helper item (rest lob)))]))

;; TEST : Test follow help functions

;;days-til-fillable-after-reorder : LineItem Book -> MaybeInteger
;;GIVEN: a line item and a book
;;RETURNS: the number of days until the line item is fillable after reorder.
;;Returns false if there won't be enough
;;copies of the book, even after the next shipment of the book comes in.
;;EXAMPLES:
;;(days-till-fillable-after-reorder 
;; (make-line-item 0003 10)
;;  (make-book 0003 "Hamlet" "Shakespeare" "ghi" 70 60 1 reorder-status2 1))
;;= false
;;(days-till-fillable-after-reorder 
;; (make-line-item 0003 3)
;;  (make-book 0003 "Hamlet" "Shakespeare" "ghi" 70 60 1 reorder-status2 1)) 
;;= 15
;;reorder status2 has 2 of book arriving after 15 days.
;;STRATEGY: structural decomposition on item : LineItem

(define (days-til-fillable-after-reorder item b)
  (days-til-fillable-after-reorder-helper (line-item-quantity item) b))

;;TEST : test follow help functions

;;days-til-fillable-after-reorder-helper : PosInt Book -> MaybeInteger
;;GIVEN: quantity of line item and a book
;;RETURNS: the number of days until the line item is fillable after reorder.
;;Returns false if there won't be enough copies of the book, 
;;even after the next shipment of the book comes in.
;;EXAMPLES: 
;;(days-till-fillable-after-reorder-helper 
;; 10
;; (make-book 0003 "Hamlet" "Shakespeare" "ghi" 70 60 1 reorder-status2 1))
;;= false
;;(days-till-fillable-after-reorder-helper 
;; 3
;; (make-book 0003 "Hamlet" "Shakespeare" "ghi" 70 60 1 reorder-status2 1))
;;= 15
;;reorder status2 has 2 copies of book arriving after 15 days.
;;STRATEGY: structural decomposition on b : Book

(define (days-til-fillable-after-reorder-helper q b)
  (days-if-book-sufficient q (book-reorder-status b) (book-copies-on-hand b)))

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
               (reorder-status-expected-number-of-copies status) 
               copies-on-hand))
          (reorder-status-expected-shipment-arrival-in-days status)
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
  
;;price-for-order : Inventory Order -> NonNegInteger
;;GIVEN: an inventory of books, order of books
;;RETURNS: the total price for the given order, in USD*100. 
;;The price does not depend on whether any particular line item is in stock.
;;Line items for an ISBN that is not in the inventory count as 0.
;;EXAMPLE: refer test for example
;;STRATEGY: structural decomposition on loli: Order

(define (price-for-order lob loli)
  (cond
    [(empty? loli) NULL]
    [else (+ (price-for-item  lob (first loli))
             (price-for-order lob (rest loli)))])) 

;; TEST: test follow help function

;;price-for-item :Inventory  LineItem -> NonNegInteger
;;GIVEN: an inventory of books and a line item 
;;RETURNS: the total price for the line item, in USD*100.
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

;;inventory-after-order : Inventory Order -> Inventory.
;;GIVEN: an inventory and an order
;;WHERE: the order is fillable now
;;RETURNS: the inventory after the order has been filled.
;;EXAMPLE: refer test for example
;;STRATEGY: structural decomposition on loli: Order

(define (inventory-after-order lob loli)
  (cond
    [(empty? loli) lob]
    [else  (inventory-after-order 
            (inventory-after-order-helper lob (first loli)) (rest loli))]))

;; TEST: Test follow help functions

;;inventory-after-order-helper : Inventory LineItem -> Inventory
;;GIVEN: an inventory and a line item.
;;RETURNS: the inventory after the line item has been filled.
;;EXAMPLE: (inventory-after-order-helper lob1 line-item1) =
;;returns the inventory with the number of coies on hand for 
;;isbn 0001 reduced by 5.
;;5 is the quantity in line-item1 for isbn 0001.
;;STRATEGY: structural decomposition on lob: Inventory

(define (inventory-after-order-helper lob item)
  (cond
    [(empty? lob) empty]
    [else (if (isbn-equal? item (first lob))
              (cons (return-updated-book (first lob) item) (rest lob))  
              (cons 
               (first lob) (inventory-after-order-helper (rest lob) item)))]))

;; TEST: Test follow help functions

;;return-updated-book : Book LineItem -> Book.
;;GIVEN: a book and a line item.
;;RETURNS: the book after the order has been filled.
;;EXAMPLE: 
;;(return-updated-book 
;; (make-book 
;;  0001 "HtDP/1" "Felleisen" "abc" 30 20 10 reorder-status1 1/20) line-item1)
;;= (make-book 0001 "HtDP/1" "Felleisen" "abc" 30 20 5 reorder-status1 1/20)
;;line-item1 has a quantity of 5 for isbn 0001.
;;STRATEGY: structural decomposition on b: Book

(define (return-updated-book b item) 
  (book-after-update 
   (return-updated-book-helper (book-copies-on-hand b) item) b))

;; TEST: Test follow help functions

;;return-updated-book-helper : NonNegInt LineItem -> NonNegInt
;;GIVEN: quantity of book available on hand and a line item.
;;RETURNS: the number of book available after the line item has been filled.
;;EXAMPLE: (return-updated-book-helper 10 line-item1) = 5
;;line-item1 has a quantity of 5 for isbn 0001
;;STRATEGY: structural decomposition on item: LineItem

(define (return-updated-book-helper copies-on-hand item)
  (- copies-on-hand (line-item-quantity item)))

; TEST: Test follow help functions

;;book-after-update : NonNegInt Book -> Book
;;GIVEN: copies of book available on hand after updation and book.
;;RETURNS: a book same as the one given but with updated value of
;;copies on hand
;;EXAMPLE: 
;;(book-after-update 
;; 5 (make-book 0001 "HtDP/1" "Felleisen" "abc" 30 20 10 reorder-status1 1/20))
;;= (make-book 0001 "HtDP/1" "Felleisen" "abc" 30 20 5 reorder-status1 1/20)
;;STRATEGY: structural decomposition on b: Book

(define (book-after-update q b)
  (make-book 
   (book-isbn b) 
   (book-title b) 
   (book-author b) 
   (book-publisher b) 
   (book-unit-price b) 
   (book-unit-cost b) q 
   (book-reorder-status b) 
   (book-cuft b)))
  

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

;;increase-prices : Inventory String Real -> Inventory
;;GIVEN: an inventory, a publisher, and a percentage
;;RETURNS: an inventory like the original, except that all items by the given
;;publisher have their unit prices increased by the specified percentage.
;;EXAMPLE: refer test for example.
;;STRATEGY: structural decomposition on lob : Inventory

(define (increase-prices lob publisher percentage)
  (cond
    [(empty? lob) empty]
    [else (if (is-publisher-same? (first lob) publisher)
              (cons (updated-price-book-entry (first lob) percentage) 
                    (increase-prices (rest lob) publisher percentage))
              (cons (first lob) 
                    (increase-prices (rest lob) publisher percentage)))]))

;; TEST: Test follow help functions

;;is-publisher-same? : Book String -> Boolean
;;GIVEN: a book and name of publisher
;;RETURNS: true if the name of the publisher is same as the name of 
;;the book's publisher, false otherwise.
;;EXAMPLE: 
;;(is-publisher-same? 
;; (make-book 
;;  0001 "HtDP/1" "Felleisen" "abc" 30 20 10 reorder-status1 1/20)) "abc")
;;= true
;;STRATEGY: structural decomposition on b : Book

(define (is-publisher-same? b publisher)
  (string=? (book-publisher b) publisher))

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