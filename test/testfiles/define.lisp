(defun display-something (val1 val2)
  (if (< val1 val2)
    (console-log "First is greater")
    (console-log "Second is greater")))

(display-something (arg 1) (arg 2))
