(add-load-path "." :relative #t)
(use gauche.parseopt)
(use kinesis)

(define mac-extras
  `(
    ;; mac bindings
    (remap scroll-lock shutdown)
    (remap kp= kp=/mac)
    (remap left-control left-command)
    (remap kp:left-control left-command)
    (remap right-control right-command)
    (remap kp:right-control right-command)
    (remap right-windows right-control)
    (remap kp:right-windows right-control)
    ))

(define (main args)
  (let-args (cdr args)
      ((mac "m|mac" #f))
    (kinesis-layout
     `(qwerty
       ,@(cond
          (mac
           mac-extras)
          (else
           '()))
       ;; place up and down in the same order as in vi
       (remap up down)
       (remap down up)
       (remap kp:up down)
       (remap kp:down up)

       ;; esc at the right of `
       (remap international escape)

       ;; swap caplock and ctrl
       (remap caps-lock left-control)
       (remap kp:caps-lock left-control)

       ;; F1, ..., F15 in keypad layer
       (remap kp:q f1)
       (remap kp:w f2)
       (remap kp:e f3)
       (remap kp:r f4)
       (remap kp:t f5)

       (remap kp:a f6)
       (remap kp:s f7)
       (remap kp:d f8)
       (remap kp:f f9)
       (remap kp:g f10)

       (remap kp:z f11)
       (remap kp:x f12)
       (remap kp:c f13)
       (remap kp:v f14)
       (remap kp:b f15)))))
