(define-module kinesis
  (use srfi-11)
  (use util.levenshtein)
  (use util.match)
  (export kinesis-layout kinesis-compile-layout))

(select-module kinesis)

(define (kinesis-normalize-token x)
  (cond
   ((symbol? x)
    x)
   ((string? x)
    (string->symbol x))
   ((char? x)
    (kinesis-normalize-token (string x)))
   (else
    (error "symbol, string, or char required. but got:" x))))

(define lower-alphabets
  (string->list "abcdefghijklmnopqrstuvwxyz"))

;; See Advantage2-Users-Manual-9-7-16.pdf p.35
(define-values (kinesis-qwerty-location-token-dictionary
                kinesis-dvorak-location-token-dictionary
                kinesis-action-token-dictionary)
  (let ()
    (define (f xs)
      (map (lambda (x)
             (cond ((pair? x)
                    (cons (kinesis-normalize-token (car x))
                          (kinesis-normalize-token (cdr x))))
                   (else
                    (let ((v (kinesis-normalize-token x)))
                      (cons v v)))))
           xs))
    (define (kp keys)
      (map (lambda (k)
             (cons (format "kp:~A" k)
                   (format "kp-~A" k)))
           keys))
    ;; Map of Location Tokens
    (define dict
      (f
       `(
         ;; top layer
         escape
         ,@(map (cut format "f~A" <>) (iota 12 1))
         (print-screen . prtscr)
         (scroll-lock . scroll)
         pause

         =
         ,@(map (cut format "~A" <>) (iota 10 0))
         (- . hyphen)

         ,@lower-alphabets

         tab
         "\\"

         (caps-lock . caps)
         ";"
         "'"

         (left-shift . lshift)
         ","
         "."
         "/"
         (right-shift . rshift)

         "`"
         (international . "intl-\\")
         left
         right
         up
         down
         ("[" . obrack)
         ("]" . cbrack)

         (left-control . lctrl)
         (left-alt . lalt)
         (backspace . bspace)
         delete
         home
         end

         (right-windows . rwin)
         (right-control . rctrl)
         space
         enter
         (page-up . pup)
         (page-down . pdown)

         (left-pedal . lp-tab)
         (middle-pedal . mp-kpshf)
         (right-pedal . rp-kpent)

         ;; keypad-layer (common)
         (kp:escape . kp-escape)
         (kp:left-windows . kp-lwin)
         (kp:right-alt . kp-ralt)
         menu
         play
         prev
         next
         calc
         kpshift
         (kp:f9 . kp-F9)
         (kp:f10 . kp-F10)
         (kp:f11 . kp-F11)
         (kp:f12 . kp-F12)
         mute
         vol+
         vol-

         (kp:= . kp-=)
         ,@(kp (iota 1 6))
         (kp:- . kp-hyphen)

         (kp:caps-lock . kp-caps)
         (kp:left-shift . kp-lshift)
         (kp:right-shift . kp-rshift)
         ,@(kp '("`"))
         (kp:insert . kp-insert)
         (kp:left . kp-left)
         (kp:right . kp-right)
         (kp:up . kp-up)
         (kp:down . kp-down)

         (num-lock . numlk)
         kp=
         (kp/ . kpdiv)
         (kp* . kpmult)
         kp7
         kp8
         kp9
         (kp- . kpmin)
         kp4
         kp5
         kp6
         (kp+ . kpplus)
         kp1
         kp2
         kp3
         kp.
         kpenter

         (kp:left-control . kp-lctrl)
         (kp:left-alt . kp-lalt)
         (kp:backspace . kp-bspace)
         (kp:delete . kp-delete)
         (kp:home . kp-home)
         (kp:end . kp-end)

         (kp:right-windows . kp-rwin)
         (kp:right-control . kp-rctrl)
         kp0
         (kp:enter . kp-enter)
         (kp:page-up . kp-pup)
         (kp:page-down . kp-pdown)

         (kp:left-pedal . kp-lp-tab)
         (kp:middle-pedal . kp-mp-kpshf)
         (kp:right-pedal . kp-rp-kpent)
         )))
    ;; Fig 31. Location Tokens: QWERTY, keypad layer
    (define kp-qwerty-dict
      (f
       `(
         ,@(kp '(q w e r t y)) ,@(kp '("\\"))
         ,@(kp '(a s d f g h)) ,@(kp '("'"))
         ,@(kp '(z x c v b n))
         )))
    ;; Fig 33. Location Tokens: Dvorak, keypad layer
    (define kp-dvorak-dict
      (f
       `(
         ,@(kp '("'" "," "." "p" "y" "f")) ,@(kp '("/"))
         ,@(kp '("a" "o" "e" "u" "i" "d")) ,@(kp '("\\"))
         ,@(kp '(";" "q" "j" "k" "x" "b"))
         )))
    ;; Dictionary of Action Tokens
    (define action-dict
      (f
       `(
         ,@(map (cut format "f~A" <>) (iota 16 1))

         ,@(map (cut format "~A" <>) (iota 10 0))
         "`"
         -
         =

         ,@lower-alphabets

         ,@(string->list "\\;',./")
         ("[" . obrack)
         ("]" . cbrack)

         (left-shift . lshift)
         (left-windows . lwin)
         (left-command . lwin)
         (left-control . lctrl)
         (right-control . rctrl)
         (right-shift . rshift)
         (right-windows . rwin)
         (right-command . rwin)
         (right-alt . ralt)
         (left-alt . lalt)

         next
         prev
         play
         mute
         vol-
         vol+

         enter
         tab
         space
         (" " . space)
         delete
         backspace
         home
         end
         (page-up . pup)
         (page-down . pdown)
         left
         right
         up
         down
         (caps-lock . caps)

         escape
         (print-screen . prtscr)
         (scroll-lock . scroll)
         pause
         calc
         (shutdown . shutdn)
         (international . "intl-\\")
         menu

         kptoggle
         kpshift

         (num-lock . numlk)
         ,@(map (cut format "kp~A" <>) (iota 10 0))
         kp.
         kp=
         (kp- . kpmin)
         (kp=/mac . kp=mac)
         (kp+ . kpplus)
         (kp* . kpmult)
         kpenter
         )))
    (values `(,@dict ,@kp-qwerty-dict)
            `(,@dict ,@kp-dvorak-dict)
            action-dict
            )))

(define kinesis-shift-dictionary
  `(
    (#\1 . #\!)
    (#\2 . #\@)
    (#\3 . #\#)
    (#\4 . #\$)
    (#\5 . #\%)
    (#\6 . #\^)
    (#\7 . #\&)
    (#\8 . #\*)
    (#\9 . #\()
    (#\0 . #\))
    (#\` . #\~)
    (#\- . #\_)
    (#\= . #\+)
    ,@(map (lambda (c)
             (cons c (char-upcase c)))
           lower-alphabets)
    (#\\ . #\|)
    (#\; . #\:)
    (#\' . #\")
    (#\, . #\<)
    (#\. . #\>)
    (#\/ . #\?)
    (#\[ . #\{)
    (#\] . #\})
    ))

(define-condition-type &lookup-error &condition lookup-error?
  (key lookup-error-key)
  (candidates lookup-error-candidates))

(define (compile-token dict tok)
  (cond
   ((assq (kinesis-normalize-token tok)
          dict)
    => cdr)
   (else
    (let* ((tokens (map (compose symbol->string car) dict))
           (t (symbol->string tok))
           (candidates
            (map cdr
                 (sort
                  (filter-map (lambda (token d)
                                (and d
                                     (cons d token)))
                              tokens
                              (re-distances
                               t
                               tokens
                               :cutoff (min 2 (+ -1 (string-length t)))))))))
      (raise (condition
              (&lookup-error
               (key tok)
               (candidates candidates))))))))

;;;      <layout> := (<base-layout> <def> ...)
;;; <base-layout> := qwerty | dvorak
;;;         <def> := (remap <location-token> <action-token>)
;;;                | (macro (seq <location-token> ...) (seq <macro> ...))
;;;       <macro> := <action-token>
;;;                | (shift <action-token> ...)
;;;                | (keyseq <string>)
;;;                | (delay <integer-which-is-multiple-of-125>)
;;;                | (speed <speed>)
;;;       <speed> := 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9
(define (kinesis-compile-layout defs)
  (define (compile-macro dict macro-token)
    (define (token tok)
      (format #t "{~A}" (compile-token dict tok)))
    (define (compile tok)
      (match tok
        (('shift . tokens)
         (format #t "{-shift}")
         (for-each token tokens)
         (format #t "{+shift}"))
        (('speed (? integer? n))
         (unless (<= 1 n 9)
           (error "speed should be in 1..9:" n))
         (format #t "{speed~A}" n))
        (('delay (? integer? n))
         (let*-values (((d500 m) (div-and-mod n 500))
                       ((d125 r) (div-and-mod m 125)))
           (unless (zero? r)
             (error "delay should be multiple of 125:" n))
           (dotimes (_ d500) (format #t "{d500}"))
           (dotimes (_ d125) (format #t "{d125}"))))
        (('keyseq ks)
         (for-each (lambda (c)
                     (compile
                      (cond ((rassv c kinesis-shift-dictionary)
                             => (lambda (c)
                                  `(shift ,(car c))))
                            (else
                             c))))
                   (string->list ks)))
        (tok
         (token tok))))
    (with-output-to-string
      (lambda ()
        (for-each compile macro-token))))
  (define (compile-def dict def)
    (match def
      (('remap from to)
       (format "[~A]>[~A]"
               (compile-token dict from)
               (compile-token kinesis-action-token-dictionary to)))
      (('macro ('seq . from) ('seq . to))
       (format "~A>~A"
               (compile-macro dict from)
               (compile-macro kinesis-action-token-dictionary to)))))
  (receive (dict defs)
      (match defs
        (('qwerty . defs)
         (values kinesis-qwerty-location-token-dictionary defs))
        (('dvorak . defs)
         (values kinesis-dvorak-location-token-dictionary defs)))
    (map (cut compile-def dict <>) defs)))

(define (kinesis-layout layout :optional (oport (current-output-port)))
  (with-output-to-port oport
    (lambda ()
      (guard (exc
              ((lookup-error? exc)
               (with-output-to-port (current-error-port)
                 (lambda ()
                   (format #t "unknown token: ~S~%" (lookup-error-key exc))
                   (let ((cs (lookup-error-candidates exc)))
                     (unless (null? cs)
                       (format #t "Did you mean:~%")
                       (for-each (cut format #t "-  ~A~%" <>) cs)))
                   1))))
        (for-each print (kinesis-compile-layout layout))
        0))))
