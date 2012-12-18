(defun fact (n)
  (if (= n)
    1
    (* (- n 1) n)))

(console-log (fact 3))