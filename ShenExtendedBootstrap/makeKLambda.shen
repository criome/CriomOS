(define writeCode
  [] Open -> (close Open)
  [Datom | Rest] Open -> (writeCode
			  Rest
			  (do
			   (pr (make-string "~R~%~%" Datom) Open)
                           Open)) where (cons? Datom)
  [_ | Rest] Open -> (writeCode Rest Open))

(define codeFile
  "" -> "code.shen"
   ".shen" -> "-code.shen"
  (@s S Ss) -> (@s S (codeFile Ss)))

(define generateCodeFile
  File -> (let Code (read-file File)
	       CodeFile (codeFile File)
	       OpenedCodeFile (open CodeFile out)
	       WritenCodeFile (writeCode Code OpenedCodeFile)
             WritenCodeFile))

(define generateKLambdaFile
  File -> (let KLFile (shen.klfile File)
               Code (read-file File)
               Open (open KLFile out)
               KL (map (/. X (shen.shen->kl-h X)) Code)
	       Write (shen.write-kl KL Open)
             KLFile))

(let ExtendedShenFiles
    ["extended-types.shen" "extended-declarations.shen" "main.shen" "aski.shen"]
  (map (fn generateKLambdaFile) ExtendedShenFiles))
