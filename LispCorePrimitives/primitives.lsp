(DEFMACRO if (X Y Z)
  `(LET ((*C* ,X))
     (COND ((EQ *C* 'true) ,Y)
           ((EQ *C* 'false) ,Z)
           (T (ERROR "~S is not a boolean~%" *C*)))))

(SETQ *language* "Common Lisp"
      *implementation* (LISP-IMPLEMENTATION-TYPE)
      *porters* "Mark Tarver"
      *port* 3.1
      *os* (SOFTWARE-TYPE)
      *stinput* *STANDARD-INPUT*
      *stoutput* *STANDARD-OUTPUT*)

#+SBCL
(SETQ *release* "1.3.10")

#+CLISP
(SETQ *release* "2.49")

(DEFUN cons? (X) (IF (CONSP X) 'true 'false))

(DEFUN hd (X) (CAR X))

(DEFUN absvector? (X) (IF (ARRAYP X) 'true 'false))

(DEFUN shen.write-string (String Stream)
  (WRITE-STRING String Stream)
  (FORCE-OUTPUT Stream)
  String)

(DEFUN write-byte (Byte S) (WRITE-BYTE Byte S))

(DEFUN intern (String) (INTERN String))

(DEFUN value (X) (SYMBOL-VALUE X))

(DEFMACRO trap-error (X F)
  `(HANDLER-CASE ,X (ERROR (Condition) (FUNCALL ,F Condition))))

(DEFUN type (X MyType) (DECLARE (IGNORE MyType)) X)

(DEFUN tlstr (X)
  (trap-error
   (SUBSEQ X 1) (LAMBDA (E) (ERROR "~S is not a non-empty string~%" X))))

(DEFUN string->n (S)
  (LET ((L (COERCE S 'LIST)))
    (IF (= (LIST-LENGTH L) 1)
        (CHAR-CODE (CAR L))
        (ERROR "~S is not a unit string.~%" S))))

(DEFUN tl (X) (CDR X))

(DEFUN str (X)
  (COND ((NULL X) (ERROR "[] is not an atom in cl; str cannot convert it to a string.~%"))
        ((SYMBOLP X)
         (cl.process-string (SYMBOL-NAME X)))
        ((NUMBERP X)
         (cl.process-number (FORMAT NIL "~A" X)))
        ((STRINGP X) (FORMAT NIL "~S" X))
        ((STREAMP X) (FORMAT NIL "~A" X))
        ((FUNCTIONP X) (FORMAT NIL "~A" X))
        (T (ERROR "~S is not an atom, stream or closure; str cannot convert it to a string.~%" X))))

(DEFUN cl.process-number (S)
  (COND ((STRING-EQUAL S "") "")
        ((STRING-EQUAL (pos S 0) "d")
         (IF (STRING-EQUAL (pos S 1) "0")
             ""
             (cn "e" (tlstr S))))
        (T (cn (pos S 0) (cl.process-number (tlstr S))))))

(DEFUN cl.process-string (X)
  (COND ((STRING-EQUAL X "") X)
        ((AND (> (LENGTH X) 8)
              (STRING-EQUAL X "_hash1957" :END1 9))
         (cn "#" (cl.process-string (SUBSEQ X 9))))
        ((AND (> (LENGTH X) 9)
              (STRING-EQUAL X "_quote1957" :END1 10))
         (cn "'" (cl.process-string (SUBSEQ X 10))))
        ((AND (> (LENGTH X) 13)
              (STRING-EQUAL X "_backquote1957" :END1 14))
         (cn "`" (cl.process-string (SUBSEQ X 14))))
        ((AND (> (LENGTH X) 7)
              (STRING-EQUAL X "bar!1957" :END1 8))
         (cn "|" (cl.process-string (SUBSEQ X 8))))
        (T (cn (pos X 0) (cl.process-string (tlstr X))))))

(DEFUN simple-error (String) (ERROR "~A" String))

(DEFUN set (X Y) (SET X Y))

(DEFUN read-byte (S)
  (READ-BYTE S NIL -1))

(DEFUN shen.read-unit-string (Stream) (COERCE (LIST (READ-CHAR Stream)) 'STRING))

(DEFUN pos (X N) (trap-error (COERCE (LIST (CHAR X N)) 'STRING)
                             (LAMBDA (E)
                               (IF (NOT (STRINGP X))
                                   (ERROR "~A is not a string~%" X)
                                   (ERROR "~A is not a natural number less than the length of the string~%"
                                          N)))))

(DEFUN open (String Direction)
  (LET ((Path (FORMAT NIL "~A~A" *home-directory* String)))
    (cl.openh Path Direction)))

(DEFUN cl.openh (Path Direction)
  (COND ((EQ Direction 'in)
         (OPEN Path :DIRECTION :INPUT
                    :ELEMENT-TYPE '(UNSIGNED-BYTE 8)))
        ((EQ Direction 'out)
         (OPEN Path :DIRECTION :OUTPUT
                    :ELEMENT-TYPE '(UNSIGNED-BYTE 8)
                    :IF-EXISTS :SUPERSEDE))
        (T (ERROR "invalid direction"))))

(DEFMACRO or (X Y) `(if ,X 'true (if ,Y 'true 'false)))

(DEFUN n->string (N)
  (trap-error
   (FORMAT NIL "~C" (CODE-CHAR N)) (ERROR "~A is not a natural number~%" N)))

(DEFMACRO lambda (X Y) `(FUNCTION (LAMBDA (,X) ,Y)))

(DEFMACRO let (X Y Z) `(LET ((,X ,Y)) ,Z))

(DEFUN string? (S) (IF (STRINGP S) 'true 'false))

(DEFMACRO freeze (X) `(FUNCTION (LAMBDA () ,X)))

(DEFUN get-time (Time)
  (COND ((EQ Time 'run)
         (* 1.0 (/ (GET-INTERNAL-RUN-TIME)
                   INTERNAL-TIME-UNITS-PER-SECOND)))
        ((EQ Time 'unix)
         (- (GET-UNIVERSAL-TIME) 2208988800))
        (T (ERROR "get-time does not understand the parameter ~A~%" Time))))

(DEFUN eval-kl (X)
  (LET ((E (EVAL (cl.kl-to-lisp X))))
    (IF (AND (CONSP X) (EQ (CAR X) 'defun))
        (COMPILE E)
        E)))

(DEFUN cl.equal? (X Y)
  (IF (cl.ABSEQUAL X Y) 'true 'false))

(DEFUN cl.ABSEQUAL (X Y)
  (COND ((AND (CONSP X) (CONSP Y) (cl.ABSEQUAL (CAR X) (CAR Y)))
         (cl.ABSEQUAL (CDR X) (CDR Y)))
        ((AND (STRINGP X) (STRINGP Y)) (STRING= X Y))
        ((AND (NUMBERP X) (NUMBERP Y)) (= X Y))
        ((AND (ARRAYP X) (ARRAYP Y)) (CF-VECTORS X Y (LENGTH X) (LENGTH Y)))
        (T (EQUAL X Y))))

(DEFUN CF-VECTORS (X Y LX LY)
  (AND (= LX LY)
       (CF-VECTORS-HELP X Y 0 (1- LX))))

(DEFUN CF-VECTORS-HELP (X Y COUNT MAX)
  (COND ((= COUNT MAX) (cl.ABSEQUAL (AREF X MAX) (AREF Y MAX)))
        ((cl.ABSEQUAL (AREF X COUNT) (AREF Y COUNT)) (CF-VECTORS-HELP X Y (1+ COUNT) MAX))
        (T NIL)))

(DEFUN error-to-string (E)
  (IF (TYPEP E 'CONDITION)
      (FORMAT NIL "~A" E)
      (ERROR "~S is not an exception~%" E)))

(DEFUN cons (X Y) (CONS X Y))

(DEFUN close (Stream) (CLOSE Stream) NIL)

(DEFUN shen.char-stoutput? (Stream)
  (IF (EQ Stream *stoutput*) 'true 'false))

#+SBCL
(DEFUN shen.char-stinput? (Stream) 'false)

#+CLISP
(DEFUN shen.char-stinput? (Stream)
  (IF (EQ Stream *stinput*) 'true 'false))

(DEFUN cl.double-precision (X)
  (IF (INTEGERP X) X (COERCE X 'DOUBLE-FLOAT)))

(DECLAIM (INLINE cl.double-precision))

(DEFUN cl.multiply (X Y)
  (IF (OR (ZEROP X) (ZEROP Y))
      0
      (* (cl.double-precision X) (cl.double-precision Y))))

(DEFUN cl.add (X Y)
  (+ (cl.double-precision X) (cl.double-precision Y)))

(DEFUN cl.subtract (X Y)
  (- (cl.double-precision X) (cl.double-precision Y)))

(DEFUN cl.divide (X Y)
  (LET ((Div (/ (cl.double-precision X)
                (cl.double-precision Y))))
    (IF (INTEGERP Div)
        Div
        (* (COERCE 1.0 'DOUBLE-FLOAT) Div))))

(DEFUN cl.greater? (X Y) (IF (> X Y) 'true 'false))

(DEFUN cl.less? (X Y) (IF (< X Y) 'true 'false))

(DEFUN cl.greater-than-or-equal-to? (X Y)
  (IF (>= X Y) 'true 'false))

(DEFUN cl.less-than-or-equal-to? (X Y)
  (IF (<= X Y) 'true 'false))

(DEFUN number? (N) (IF (NUMBERP N) 'true 'false))

(DEFUN cn (Str1 Str2) (CONCATENATE 'STRING Str1 Str2))

(DEFMACRO and (X Y) `(if ,X (if ,Y 'true 'false) 'false))

(DEFUN <-address (Vector N) (SVREF Vector N))

(DEFUN address-> (Vector N Value) (SETF (SVREF Vector N) Value) Vector)

(DEFUN absvector (N) (MAKE-ARRAY (LIST N) :INITIAL-ELEMENT 'shen.fail!))
