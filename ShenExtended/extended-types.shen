(package shen []

 (declare compile-lisp-file [string --> string])
 (declare delete-file [string --> boolean])
 (declare load-lisp [string --> boolean])
 (declare posix-argv [--> [list A]])
 (declare exit [int -->])
 (declare directory-files [string --> [list string]])
 (declare ensure-directories-exist [string --> boolean])
 (declare copy-file [string --> [string --> boolean]])
 (declare run-program [[list string] --> [Output --> [ErrorOutput --> ExitCode]]]))
