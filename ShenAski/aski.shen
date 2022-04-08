(package aski []

 (define aski->shen
   [neksys | Code] -> (mkNeksys Code)
   [mein | Code] -> (mkMein Code))

 (datatype neksys
    Astriz: astriz Krimynz : krimynz Trost: neksysTrost;
     --------------------------------------------------
            [Astriz Krimynz Trost] : neksys;)

 (define mkNeksys
   [] -> [])

 (define mkMein
   [] -> [])

 )
