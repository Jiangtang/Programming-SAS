data DETAILS ;
 input KEY VAR ;
cards ;
1 1
1 1
1 2
1 2
2 1
2 2
2 2
2 3
;
run ; 

data AGGREGATE (drop = VAR) ;
 do until (last.KEY) ;
     set DETAILS ;
     by KEY VAR ;
     SUM_VAR = sum (SUM_VAR, VAR) ;
     CNT_VAR = sum (CNT_VAR, first.VAR) ;
 end ;
run ; 

data _null_ ;
 dcl hash H (ordered: "A") ;
 h.definekey ("KEY") ;
 h.definedata ("KEY", "SUM", "UNQ") ;
 h.definedone () ;

 dcl hash U () ;
 u.definekey ("KEY", "VAR") ;
 u.definedone () ; 
  do until (end) ;
 set DETAILS end = end ;
 if h.find() ne 0 then call missing (SUM, UNQ) ;
 SUM = sum (SUM, VAR) ;
 if u.check() ne 0 then do ;
 UNQ = sum (UNQ, 1) ;
 u.add() ;
 end ;
 h.replace() ;
 end ;

 h.output (dataset: "hash_agg") ;
 stop ;
run ;
