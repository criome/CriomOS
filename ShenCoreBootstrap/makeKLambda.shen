(set *maximum-print-sequence-size* 10000)

(let ShenSourceFileNames
    ["yacc.shen" "core.shen" "declarations.shen" "load.shen" "macros.shen"
      "prolog.shen" "reader.shen" "sequent.shen" "sys.shen" "t-star.shen"
      "toplevel.shen" "track.shen" "types.shen" "writer.shen" "backend.shen"]
  (map (fn bootstrap) ShenSourceFileNames))
