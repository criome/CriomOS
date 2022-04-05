(DEFUN compile-lisp-file (filepath) (COMPILE-FILE filepath))

(DEFUN delete-file (filepath) (DELETE-FILE filepath))

(DEFUN load-lisp (filepath) (LOAD filepath))

(DEFUN posix-argv () SB-EXT:*POSIX-ARGV*)

(DEFUN exit (code)
  (SB-EXT:EXIT :CODE code))

(DEFUN directory-files (Path)
       (UIOP:DIRECTORY-FILES Path))

(DEFUN ensure-directories-exist (Path)
  (ENSURE-DIRECTORIES-EXIST Path))

(DEFUN copy-file (FilePath Path)
  (UIOP:COPY-FILE FilePath Path))

(DEFUN run-program (Command)
  (UIOP:RUN-PROGRAM Command))
