;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname |1|) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ())))





#|Purpose : To write an expression whose value is the number of seconds
            in a leap year. In addition write two more expressions that
            have the same value.|#

;******************************EXPRESSION*************************************

#|Number of seconds in a leap year equals multiplication of number of days,
total number of hours in a day (i.e. 24), total number of minutes in an hour
(i.e. 60), and total number of seconds in a minute(i.e. 60)|#

(* 366 24 60 60)

;Two more expressions that have the same value as that of the above expression

(* 366 24 (sqr 60))
(* 61 (sqr 20) (expt 6 4))

;*********************************Test****************************************

; The number of seconds in a leap year is 31622400.

  (check-expect (* 366 24 60 60) 31622400)
  (check-expect (* 366 24 (sqr 60)) 31622400)
  (check-expect (* 61 (sqr 20) (expt 6 4)) 31622400)