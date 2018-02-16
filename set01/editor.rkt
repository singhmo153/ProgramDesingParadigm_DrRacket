;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname editor) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))

;; editor.rkt

;;PURPOSE: To make an illustarte working of an editor.

(require rackunit)
(require "extras.rkt")
(require 2htdp/universe)

(provide make-editor
         editor-pre
         editor-post
         edit)

;;*****************************************************************************

(define-struct editor(pre post))

;; An Editor is a (make-editor String String)
;; It represents an editor with a pre and post field.
;; Interpretation:
;; pre = the portion of the editor before a cursor.
;; post = the portion of the editor after a cursor.

;; TEMPLATE:
;(define (editor-fn e)
;  (...
;   (editor-pre r)
;   (editor-post r))

;; edit : Editor KeyEvent-> Editor
;; GIVEN: an editor and a KeyEvent.
;; RETURNS: an editor with changes caused by KetEvent.
;; EXAMPLES:
;; (edit (make-editor "Monisha" "Singh" "a") = (make-editor "Monishaa" "Singh")
;; STRATEGY: cases on Key-Event

(define (edit ed ke) 
  (cond
    [(or (key=? "\t" ke) 
         (key=? "\u007F" ke)) (new-editor (editor-pre ed) (editor-post ed))]
    [(= (string-length ke) 1) (new-editor 
                               (string-first ed ke) (editor-post ed))]
    [(key=? "left" ke) (new-editor (string-first ed ke) (string-last ed ke))]
    [(key=? "right" ke) (new-editor (string-first ed ke) (string-last ed ke))]))

;; TEST

(begin-for-test
  (check-equal?
   (edit (make-editor "Monisha" "Singh") "a")
   (make-editor "Monishaa" "Singh")
   "the editor, should be (make-editor Monishaa Singh)")
  
  (check-equal?
   (edit (make-editor "Monisha" "Singh") "\t")
   (make-editor "Monisha" "Singh")
   "the editor, should be (make-editor Monisha Singh)")
  
  (check-equal?
   (edit (make-editor "Monisha" "Singh") "left")
   (make-editor "Monish" "aSingh")
   "the editor, should be (make-editor Monish aSingh)")
  
  (check-equal?
   (edit (make-editor "Monisha" "Singh") "right")
   (make-editor "MonishaS" "ingh")
   "the editor, should be (make-editor MonishaS ingh)"))

;; new-editor : "String" "String" -> Editor
;; GIVEN: pre and post fields of an editor
;; RETURNS: an editor with the given pre and post field
;; EXAMPLES:
;; (new-editor "Monisha" "Singh") = (make-editor "Monisha" "Singh")
;; STRATEGY: function composition


(define (new-editor pre-field post-field)
  (make-editor pre-field post-field))

;; TEST

(begin-for-test
  (check-equal?
   (new-editor "My" "Home")
   (make-editor "My" "Home")
   "the editor, should be (make-editor My Home)"))


;; string-first : Editor KeyEvent -> Editor
;; GIVEN: an editor and a KeyEvent
;; RETURNS: an editor with changes in the pre field.
;; EXAMPLES:
;; (string-first (make-editor "Monisha" "Singh" "a") = 
;  (make-editor "Monishaa" "Singh")
;; STRATEGY: cases on KeyEvent



(define (string-first ed ke)
  (cond
    [(key=? ke "\b") (string-first-after-modification (editor-pre ed))] 
    [(key=? ke "left") (string-first-after-modification (editor-pre ed))]
    [(key=? ke "right") (string-first-after-cursor-right ed)] 
    [else (string-append (editor-pre ed) ke)]))

;; TEST

(begin-for-test
  (check-equal?
   (edit (make-editor "Monisha" "Singh") "a")
   (make-editor "Monishaa" "Singh")
   "the editor, should be (make-editor Monishaa Singh)")
  
  (check-equal?
   (edit (make-editor "Monisha" "Singh") "\b")
   (make-editor "Monish" "Singh")
   "the editor, should be (make-editor Monish Singh)")
  
  (check-equal?
   (edit (make-editor "Monisha" "Singh") "left")
   (make-editor "Monish" "aSingh")
   "the editor, should be (make-editor Monish aSingh)")
  
  (check-equal?
   (edit (make-editor "Monisha" "Singh") "right")
   (make-editor "MonishaS" "ingh")
   "the editor, should be (make-editor MonishaS ingh)"))


;; string-first-after-modification : String -> String
;; GIVEN: pre field of an editor
;; RETURNS: a new string which is a substring of first string.
;; EXAMPLES:
;; (string-first-after-modification("Monisha") 
;  "Monish"
;; STRATEGY: function composition

(define (string-first-after-modification s)
  (substring s 0 (- (string-length s) 1)))

;; TEST

(begin-for-test
  (check-equal?
   (string-first-after-modification "Monisha")
   "Monish"
   "The string should be Monish"))

;; string-first-after-cursor-right : Editor -> String
;; GIVEN: an Editor
;; RETURNS: the pre field of the editor after cursor moves right.
;; EXAMPLES:
;; (string-first-after-cursor-right ("Monisha") 
;  "Monish"
;; STRATEGY: Structural Decomposition


(define (string-first-after-cursor-right ed)
  (string-append 
   (editor-pre ed) (string-ith (editor-post ed) 0)))

;; TEST

(begin-for-test
  (check-equal?
   (string-first-after-cursor-right (make-editor "Monisha" "Singh"))
   "MonishaS")
  "the value, should be MonishaS")

;; string-last : Editor KeyEvent -> Editor
;; GIVEN: an editor and a KeyEvent
;; RETURNS: an editor with changes in the post field.
;; EXAMPLES:
;  (string-last (make-editor "Monisha" "Singh") "left") = 
;  (make-editor "Monish" "aSingh")
;; STRATEGY: cases on KeyEvent



(define (string-last ed ke)
  (cond
    [(key=? ke "left") (string-last-after-left ed)]
    [(key=? ke "right") (string-last-after-right ed)]))

;; TEST
(begin-for-test
  (check-equal?
   (edit (make-editor "Monisha" "Singh") "left")
   (make-editor "Monish" "aSingh")
   "the editor, should be (make-editor Monish aSingh)")
  
  (check-equal?
   (edit (make-editor "Monisha" "Singh") "right")
   (make-editor "MonishaS" "ingh")
   "the editor, should be (make-editor MonishaS ingh)"))


;; string-last-after-left : Editor -> String
;; GIVEN: an Editor
;; RETURNS: the post field of the editor after cursor moves left.
;; EXAMPLES:
;; (string-last-after-left (make-editor "Monisha" "Singh")) = 
;  (make-editor "Monish" "aSingh")
;; STRATEGY: structural decomposition



(define (string-last-after-left ed)
  (string-append (string-ith 
                  (editor-pre ed) 
                  (- (string-length (editor-pre ed)) 1)) 
                 (editor-post ed)))

;; TEST

(begin-for-test
  (check-equal?
   (string-last-after-left (make-editor "Monisha" "Singh"))
   "aSingh")
  "the value, should be aSingh")


;; string-last-after-right : Editor -> String
;; GIVEN: an Editor
;; RETURNS: the post field of the editor after cursor moves right.
;; EXAMPLES:
;; (string-last-after-right (make-editor "Monisha" "Singh"))= 
;  "ingh"
;; STRATEGY: structural decomposition


(define (string-last-after-right ed)
  (substring 
   (editor-post ed) 1 (- (string-length (editor-post ed)) 0)))

;; TEST

(begin-for-test
  (check-equal?
   (string-last-after-right (make-editor "Monisha" "Singh"))
   "ingh")
  "the value, should be ingh")



