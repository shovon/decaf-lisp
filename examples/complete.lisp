(defun add (a b)
  (+ a b))

(defun curryAdd (a)
  (lambda (b)
    (+ a b)))

(console-log (add 10 5))

(console-log ((curryAdd 10) 5))