;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname pretty) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))
;; pretty.rkt

(require rackunit)
(require "extras.rkt")

(provide expr-to-strings)
(provide make-sum-exp)
(provide sum-exp-exprs)
(provide make-mult-exp)
(provide mult-exp-exprs)


;;;;;;;;;;;;;;;;;;;;;;;CONSTANTS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define LENGTH-OF-BRACKET-OPERATOR-SPACE 3)
(define INDENT "   ")
(define NO-TAIL "")

;;;;;;;;;;;;;;;;;;;;;;;DATA DEFINITIONS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(define-struct sum-exp (exprs))
;;a sum-exp is a (make-sum-exp NELOExpr)
;;Interpretation:
;;exprs is a non-empty list of expr

;;Template:
;; 
;(define (sum-exp-fn  expr)
;  (... (sum-exp-exprs expr)))

;; example
;(make-sum-exp (list 11 22))

(define-struct mult-exp (exprs))
;;a mult-exp is a (make-mult-exp NELOExpr)
;;Interpretation:
;;exprs is a non-empty list of expr

;;Template:
;; 
;(define (mult-exp-fn expr)
;  (... (mult-exp-exprs expr)))

;; example
;(make-mult-exp (list 11 22))

;; An Expr is one of
;; -- Integer
;; -- (make-sum-exp NELOExpr)
;; -- (make-mult-exp NELOExpr)
;; Interpretation: An Expr can be an integer, sum-exp or mult-exp.
;; a (make-sum-exp NELOExpr) represents a sum-exp
;; ,and (make-mult-exp NELOExpr) represents a mult-exp
;; represents a multiplication. 
;(define (expr-fn expr)
;  (cond
;    [(Integer? expr) ... expr]
;    [(sum-exp? expr)... (sum-exp-exprs expr)]
;    [(mult-exp? expr)... (mult-exp-exprs expr)]))

;;example
;1
;(make-sum-exp (list 11 22))
;(make-mult-exp (list 11 22))

;; A LOExpr is one of
;; -- empty                  Interpretation: empty represents an empty
;                            list of expr
;; -- (cons Expr LOExpr)     Interpretation: (cons Expr LOExpr) represents a 
;                            non empty list of expr


;Template:
;(define (loexpr-fn loe)
;  (cond
;    [(empty? loe)  ...]
;    [else  (...(expr-fn (first loe))
;               (loexpr-fn (rest loe)))]))

;;example
;empty
;(list 1 (make-sum-exp (list 11 22)) (make-mult-exp (list 11 22)))



;; A NELOExpr is a non-empty LOExpr.   
; -- (cons Expr empty)       Interpretation: (cons Expr empty) represents a
;                            list of expr with one expr
; -- (cons Expr NELOExpr)    Interpretation: (cons Expr NELOExpr) represents a
;                            non empty list of expr
;Template:
;(define (nelist-fn ne) 
; (cond 
;  [(empty? (rest ne)) (... (first ne))]
;  [else (... 
;         (expr-fn (first ne))
;         (nelist-fn (rest ne)))]))

;;example
;(list 1 (make-sum-exp (list 11 22)) (make-mult-exp (list 11 22)))

;; A ListOfString(LOS) is one of
;; -- empty                  Interpretation: empty represents an empty
;                            list of string
;; -- (cons String LOS)      Interpretation: (cons String LOS) represents a 
;                            non empty list of string

;Template:
;(define (los-fn los)
;  (cond
;    [(empty? los)  ...]
;    [else  (.. (first los)
;               (los-fn (rest los)))]))

;example
;empty
;(list "1")

;; A NonEmptyListOfString(NELOS) is 

;-- (cons String LOS)            Interpretation: (cons String LOS) 
;                                represents a non empty list of 
;                                string.

;Template:
;(define (nelos-fn nelos)
;  (...(first nelos)
;      (los-fn (rest nelos))))

;example
;(list "1" "2" "3")



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;FUNCTION DEFINITIONS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;expr-to-strings : Expr NonNegInt -> LOS
;;GIVEN: An expression and a non negative integer
;;RETURNS: A representation of the given expression as a sequence of lines
;;with each line represented as a string of length not greater than the width.
;;If the expression cannot fit in the given width then the error 
;;"not enough room" is raised.
;;EXAMPLE:
;;(expr-to-strings (make-sum-exp (list 22 333 44)) 10)
;;=> (list "(+ 22" "   333" "   44)")
;;STRATEGY: function composition

(define (expr-to-strings expr space)
  (expr-to-strings-helper expr space NO-TAIL))

;;TEST: test follow function definitions

;;expr-to-strings-helper : Expr NonNegInt String -> LOS
;;GIVEN: An expression, a non negative integer that tells the space that the  
;;expression must fit into and a String that represents the tail of the
;;expression
;;WHERE: tail is a string sequence of closing brackets.
;;RETURNS: A representation of the given expression as a sequence of lines
;;with each line represented as a string of length not greater than the space
;;minus the length of tail
;;In addition, the given tail is appended to the end of the last element  
;;EXAMPLES:
;; (expr-to-strings-helper 22 5 "))") => (list "22))")
;; (expr-to-strings-helper (make-sum-exp (list 22 33)) 20 ")))")
;;   => (list "(+ 22 33))))")
;; (expr-to-strings-helper (make-sum-exp (list 22 33)) 10 ")))")
;;   => (list "(+ 22" "   33))))")
;;STRATEGY: function composition

(define (expr-to-strings-helper expr space tail)
  (if (enough-space? expr space tail)
      (list (string-append (expr-to-string-inline expr) tail))
      (expr-to-strings-stacked expr space tail)))


;;longer-tail: String -> String
;;GIVEN: a string that represents the tail
;;WHERE: tail is a string sequence of closing brackets.
;;RETURNS: the tail by appending a ")" to the given tail
;;EXAMPLES: 
;;(longer-tail "))") => ")))"
;;STRATEGY: function comosition

(define (longer-tail tail)
  (string-append ")" tail))

;;enough-space? : Expr NonNegInt String-> Boolean
;;GIVEN: An expression, a non negative integer that tells the space, and 
;;a string that represents the tail that will follow the expression
;;WHERE: tail is a string sequence of closing brackets.
;;RETURN: returns true iff the expr can be transformed into a single line
;;of string of length not greater than the given space minus the length
;;of the tail
;;EXAMPLE: (enough-space? 22 3 "") => true
;;STRATEGY: function composition

(define (enough-space? expr space tail)
  (<=
   (string-length (expr-to-string-inline expr)) 
   (- space (string-length tail))))


;;expr-to-string-inline : Expr -> String
;;GIVEN: An expression 
;;RETURN: returns a representation of the given expression as 
;; a single line of string
;;EXAMPLE: (expr-to-string-inline (make-sum-exp (list 55 66))
;;=> "(+ 55 66)"
;;STRATEGY: structural decomposition on expr: Expr

(define (expr-to-string-inline expr)
  (cond
    [(integer? expr) (number->string expr)]
    [(sum-exp? expr) (sum-to-string-inline (sum-exp-exprs expr))]
    [(mult-exp? expr) (mult-to-string-inline (mult-exp-exprs expr))]))


;;sum-to-string-inline : NELOExpr -> String
;;GIVEN: A non-empty list of expression 
;;RETURN: returns a single line of string as a representation of 
;;the summation of the given list of expressions 
;;EXAMPLE:(sum-to-string-inline (list 22 333 44))
;;=> "(+ 22 333 44)"
;;STRATEGY: HOFC

(define (sum-to-string-inline exprs)
  (string-append "(+ " 
                 (insert-space 
                  (map 
                   expr-to-string-inline
                   exprs))
                 ")"))

;;mult-to-string-inline : NELOExpr -> String
;;GIVEN: A non-empty list of expression 
;;RETURN: return a single line of string as a representation of 
;;the multiplication of the given list of expressions 
;;EXAMPLE: (mult-to-string-inline (list 22 333 44))
;;=> "(* 22 333 44)"
;;STRATEGY: HOFC

(define (mult-to-string-inline exprs)
  (string-append "(* " 
                 (insert-space 
                  (map 
                   expr-to-string-inline
                   exprs))
                 ")"))

;;insert-space : LOS -> String
;;GIVEN: a list of strings los
;;RETURNS: the string obtained by concatenating all the string in los
;;with " " in between, return "" if the los is empty
;;EXAMPLE: 
;;(insert-space (list "22" "333" "44"))
;;=> "22 333 44"
;;STRATEGY: HOFC

(define (insert-space los)
  (foldr
   ;String String -> String
   ;GIVEN: a string and string computed so far
   ;RETURNS: a string obtained by inserting space in between  
   (lambda (s next)
     (if (string=? "" next)
         s
         (string-append s " " next)))
   "" 
   los))


;;expr-to-strings-stacked : Expr NonNegInt String -> LOS
;;GIVEN : an expression, a non-negative integer that represents
;;the space that this expression must fit into, and a string that
;;represents the tail that should follow this expression
;;WHERE: tail is a string sequence of closing brackets.
;;RETURN : A representation of the given expression as a sequence
;;of lines with each line represented as a string of length not 
;;greater than the given space minus the length of the tail,
;;in addition, the given tail is appended
;;to the last element of the list of string
;;If the expression cannot fit in the space minus the length
;;of tail then error "not enough room" is raised.
;;EXAMPLES: 
;;(expr-to-strings-stacked (make-sum-exp (list 22 33 44)) 10 "))")
;;=> (list "(+ 22" "   33" "   44)))")
;;STRATEGY: structural decomposition on expr: Expr

(define (expr-to-strings-stacked expr space tail)
  (cond
    [(integer? expr) (number-to-string-stacked expr space tail)]
    [(sum-exp? expr)
     (add-indent-and-parenthesis "(+ " 
                                 (exprs-to-strings-stacked 
                                  (sum-exp-exprs expr) 
                                  (- space LENGTH-OF-BRACKET-OPERATOR-SPACE) 
                                  (longer-tail tail)))]
    [(mult-exp? expr) 
     (add-indent-and-parenthesis "(* "
                                 (exprs-to-strings-stacked 
                                  (mult-exp-exprs expr) 
                                  (- space LENGTH-OF-BRACKET-OPERATOR-SPACE) 
                                  (longer-tail tail)))]))



;;exprs-to-strings-stacked: NELOExpr NonNegInt String -> LOS
;;GIVEN: A non-empty list of expressions,a non negative integer
;;that represents the space the expressions must fit into, and a string that
;;represents the tail that should follow the last expression in the list
;;WHERE: tail is a string sequence of closing brackets.
;;RETURN: return a sequance of lines of string as a representation of 
;;the given list of expressions within the given space, in addition,
;;the given string is appended to the last element of the list of string to
;;be returned
;;EXAMPLES:
;;(exprs-to-strings-stacked (list 22 33 44) 6 "))")
;;=>(list "22" "33" "44))")
;;STRATEGY: structural decomposition on exprs: NELOExpr

(define (exprs-to-strings-stacked exprs space tail)
    (cond
    [(empty? (rest exprs))  (expr-to-strings-helper (first exprs) space tail)]
    [else (append (expr-to-strings-helper (first exprs) space NO-TAIL)
                (exprs-to-strings-stacked (rest exprs) space tail))]))


;;add-indent-and-parenthesis: String NELOS -> NELOS
;;GIVEN: a string s, and a non empty list of strings nelos
;;WHERE: s is "(+ " or "(* " and the non empty list of strings is the
;;string representation of some expression expr0.
;;RETURN: the non empty list of string with string s appended to the front of
;;the first string and the rest of the strings in the list are indented 
;;according to the position of first string after append
;;EXAMPLE:       
;;(add-indent-and-parenthesis "(+ " (list "22" "33" "44)"))
;;=> (list "(+ 22" "   33" "   44)")
;;STRATEGY: structural decomposition on los : NELOS

(define (add-indent-and-parenthesis s los)
  (cons (string-append s (first los))                        
        (add-indent-to-los (rest los))))

;;number-to-string-stacked: Integer NonNegInt String -> LOS
;;GIVEN:  An integer,a non negative integer
;;that represents the space, and a string
;;that reresents the tail
;;WHERE: the tail is the string sequence of closing paranthesis that will
;;follow the given integer
;;RETURN: signals an error message if the integer appeneded by the given string
;;can't fit into the given space minus length of tail
;;otherwise, return a list of string that has only only element in it.
;;the element is composed by appending the given string to the given integer
;;EXAMPLES:
;; (number-to-string-stacked 22 7 ")") => (list "22)")
;; (number-to-string-stacked 22 2 ")") => report error "not enough room"
;;STRATEGY: function composition

(define (number-to-string-stacked n space tail)
  (if (> (string-length (number->string n)) (- space  (string-length tail)))
      (error "not enough room")
      (list (string-append (number->string n) tail))))

;;add-indent-to-los: LOS -> LOS
;;GIVEN: a list of string
;;WHERE: every string in the list is the string representation of some 
;;expression expr0.
;;RETURN: a list of string just like the given list of string
;;except that every string in it is appended by the string INDENT
;;in front of it.
;;EXAMPLES:
;;(add-indent-to-los (list "33" "44)")) =>
;;(list "   33" "   44)")
;;STRATEGY: HOFC

(define (add-indent-to-los los) 
  (map
   ;STRING -> STRING
   ;GIVEN: a string
   ;RETURNS: the given string with INDENT appended in front of the string
   (lambda (s)
     (string-append INDENT s))
   los))



;;TESTS


(define e1 (make-sum-exp (list 22 (make-sum-exp (list 55 66)) 44)))


(define e2 (make-sum-exp 
            (list 22 
                  (make-sum-exp
                      (list 
                       (make-mult-exp (list 55 66)) 
                       55 66)) 44 (make-mult-exp (list 55 66)))))


(begin-for-test
  (check-equal?
   (expr-to-strings e2 12)
   (list 
    "(+ 22" 
    "   (+ (* 55" 
    "         66)" 
    "      55" "      66)" "   44" "   (* 55" "      66))")
   "the representation should be stacked")
  (check-equal?
   (expr-to-strings e1 9)
   (list "(+ 22" "   (+ 55" "      66)" "   44)")
   "the representation should be stacked")
  (check-error 
   (expr-to-strings 1111111111 9)
   "not enough room")
  (check-equal? 
   (number-to-string-stacked 222 100  "))") 
   (list "222))")
   "the brackets should be appended to the end of expr"))