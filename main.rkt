#lang racket
(require racket/os)

(define (str-begins-with? a)
  (curryr string-prefix? a))

(define (trim-size line val)
  (string-trim
    (string-replace
     (string-trim line val) " " "") "kB"))

(define usr  (~a (getenv "USER") "@" (gethostname)))
(define arch (system-type 'arch))
(define kern (let ([proc/version (open-input-file "/proc/version")])
               (read-string 21 proc/version)))

(define sh   (last
              (explode-path
               (string->path (getenv "SHELL")))))

(define dist  (string-trim
               (string-trim
                (first
                 (filter
                  (str-begins-with? "PRETTY_NAME=")
                  (file->lines "/etc/os-release")))
                "PRETTY_NAME=") "\""))

(define cpu  (string-trim
              (first
               (filter
                (str-begins-with? "model name")
                (file->lines "/proc/cpuinfo")))
              "model name	: "))

(define uptime-raw (string->number
                    (first (string-split
                            (file->string "/proc/uptime") " "))))
(define uptime-d  (exact-floor (/ (/ (/ uptime-raw 60) 60) 24)))
(define uptime-h  (- (exact-floor
                      (/ (/ uptime-raw 60) 60))
                     (* uptime-d 24)))
(define term (getenv "TERM"))
(define mem-raw (file->lines "/proc/meminfo"))
(define mem-total (exact->inexact
`                   (/ (string->number
                       (trim-size (first mem-raw) "MemTotal:"))
                      (* 1024 1024))))

(define mem-used (exact->inexact
                  (- mem-total (/ (string->number
                                   (trim-size (list-ref mem-raw 2)
                                              "MemAvailable:"))
                                  (* 1024 1024)))))

(displayln "(Racketfetch)")
(displayln usr)
(displayln (~a "    .--. "     "    OS       : " dist " " arch ))
(displayln (~a "   |o_o |"     "    Kernel   : " kern))
(displayln (~a "   |:_/ |"     "    Shell    : " sh))
(displayln (~a "  //   \\ \\"   "   CPU      : " cpu))
(displayln (~a " (|     | )"     "  Uptime   : " uptime-d " days, "
                                                 uptime-h " hours"))
(displayln (~a "/'\\_   _/`\\"   "  Terminal : " term))
(displayln (~a "\\___)=(___/"    "  Memory   : "
               (~r mem-used #:precision 2)  " / "
               (~r mem-total #:precision 2) " GiB"))
