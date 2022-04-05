(SETF (READTABLE-CASE *READTABLE*) :PRESERVE)

(PROCLAIM '(OPTIMIZE (DEBUG 0) (SPEED 3) (SAFETY 3)))

(DECLAIM (SB-EXT:MUFFLE-CONDITIONS SB-EXT:COMPILER-NOTE))

(SETF SB-EXT:*MUFFLED-WARNINGS* T)

(IN-PACKAGE :CL-USER)

(DEFUN objectcode (File)
       (LET* ((ObjectCode (COMPILE-FILE File))
              (Load (LOAD ObjectCode)))
             (DELETE-FILE ObjectCode)))

(DEFUN boot (KLFile)
       (LET* ((In (OPEN KLFile :DIRECTION :INPUT
                        :ELEMENT-TYPE :DEFAULT))
              (SourceCode (readsource In))
              (ObjectCode (MAPCAR 'cl.kl-to-lisp SourceCode))
              (LispFile (FORMAT NIL "~A.lsp" KLFile))
              (Out (OPEN LispFile :DIRECTION :OUTPUT
                         :ELEMENT-TYPE :DEFAULT
                         :IF-EXISTS :SUPERSEDE))
              (Write (MAPC (LAMBDA (X) (FORMAT Out "~S~%~%" X)) ObjectCode))
              (CloseOut (CLOSE Out))
              (CloseIn  (CLOSE In))
              (Compiled (COMPILE-FILE LispFile))
              (Load (LOAD Compiled))
              (Cleanup (MAPC 'DELETE-FILE (LIST LispFile Compiled))))
             'booted))

(DEFUN readsource (Stream)
       (LET ((R (READ Stream NIL 'eof!!)))
            (IF (EQ R 'eof!!)
                (PROG2 (CLOSE Stream) NIL)
                (CONS R (readsource Stream)))))

(MAPC 'COMPILE '(objectcode boot readsource))

(MAPC 'objectcode '("backend.lsp" "primitives.lsp"))

(MAPC 'boot '("KLambda/sys.kl" "KLambda/writer.kl" "KLambda/core.kl"
              "KLambda/reader.kl" "KLambda/declarations.kl"
              "KLambda/toplevel.kl" "KLambda/macros.kl" "KLambda/load.kl"
              "KLambda/prolog.kl" "KLambda/sequent.kl" "KLambda/track.kl"
              "KLambda/t-star.kl" "KLambda/yacc.kl" "KLambda/types.kl"
	      "KLambda/extended-declarations.kl" "KLambda/extended-types.kl"
	      "KLambda/main.kl"))

(MAPC 'FMAKUNBOUND '(boot readsource objectcode))

(SAVE-LISP-AND-DIE "aski"
		   :EXECUTABLE T
		   :SAVE-RUNTIME-OPTIONS T
		   :TOPLEVEL 'aski.main)
