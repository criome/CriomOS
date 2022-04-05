(package shen [compile-lisp-file delete-file load-lisp posix-argv
                                 exit directory-files
                                 ensure-directories-exist copy-file
                                 run-program]

 (define add-primitives
   [] -> []
   [Symbol Arity | ArityTable]
     -> (let \* ArityTableInitialized (initialize-arity-table [Symbol Arity]) *\
             LambdaTableUpdated (update-lambda-table Symbol Arity)
           (add-primitives ArityTable)))

 (add-primitives
  [compile-lisp-file 1 delete-file 1 load-lisp 1 posix-argv 0 exit 1
                     directory-files 1 ensure-directories-exist 1 copy-file 2
                     run-program 1]))
