(package aski []

 (define aski->shen
   [neksys | Code] -> (mkNeksys Code)
   [mein | Code] -> (mkMein Code))

 (datatype neksys
    PriNeksiz: (list priNeksys); Krimynz : (list krimyn);
		     Trost: neksysTrost;
     ===============================================
            [PriNeksiz Krimynz Trost] : neksys;)

 (define mkNeksys
   [] -> [])

 (define mkMein
   [] -> [])

 )
