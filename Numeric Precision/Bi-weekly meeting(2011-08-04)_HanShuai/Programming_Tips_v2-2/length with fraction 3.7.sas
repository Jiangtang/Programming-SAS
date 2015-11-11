data issloc (drop=i j) ; 
   do i= 1 to 2 ; 
      patno=i; 
   do j= 1 to 4 ; 
         dose=j ;  
         tempc1=37.2 + i/10 + j/10 ; 
         tempc2=37.2 + i/10 + 2*(j/10) ; 
         tempc3=37.2 + i/10 + 3*(j/10) ; 
         tmpc1=tempc1 ; 
         tmpc2=tempc2 ; 
         tmpc3=tempc3 ; 
         output ; 
   end ; 
   end ; 
run ; 
 
data loc (drop=i) ; 
   do i= 1 to 2 ; 
      patno=i; 
   dose=6 ;  
         tempc1=37.2  + 3*(i/10) ; 
         tempc2=37.2  + 2*(i/10) ; 
         tempc3=37.2  + i/2 ; 
         tmpc1=tempc1 ; 
         tmpc2=tempc2 ; 
         tmpc3=tempc3 ; 
         output ; 
   end ; 
run ;

data issloc3 ; 
     length tempc1 3 tempc2 4 tempc3 7; 
     set issloc ; 
run ; 
 
data local ; 
     set issloc loc ; 
run ; 
data local3 ; 
     set issloc3 loc ; 
run ; 
 
proc sort data=local ;  
     by patno dose;  
run ; 
proc sort data=local3 ;  
     by patno dose;  
run ; 
 
data chk ; 
     set local ; 
  if tmpc1=tempc1 then a=1 ; 
  else a=0 ; 
  if tmpc2=tempc2 then b=1 ; 
  else b=0 ; 
  if tmpc3=tempc3 then c=1 ; 
  else c=0 ; 
run ; 
 
data chk3 ; 
     set local3 ; 
  if tmpc1=tempc1 then a=1 ; 
  else a=0 ; 
  if tmpc2=tempc2 then b=1 ; 
  else b=0 ; 
  if tmpc3=tempc3 then c=1 ; 
  else c=0 ; 
run ;
