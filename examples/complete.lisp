(defun add (a b)
  (+ a b))

(defun curryAdd (a)
  (lambda (b)
    (+ a b)))

(add 10 5)

((curryAdd 10) 5)