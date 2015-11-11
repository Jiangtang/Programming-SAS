%put NOTE: You have called the macro SAS2CODA, 2007/10/20;
%put NOTE: Copyright (c) 1999-2005 Matthew Hayat and 2005-2007 Rodney Sparapani;
%put;

/*
Author:  Matthew Hayat <hayatm@nidcd.nih.gov>
Created: 1999-00-00

This file is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2, or (at your option)
any later version.

This file is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this file; see the file COPYING.  If not, write to
the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

In short: you may use this file any way you like, as long as you
don't charge money for it, remove this notice, or hold anyone liable
for its results.
*/

/* SAS2CODA Documentation
    Read a SAS dataset and create CODA files from it.
    
    REQUIRED Parameters  

    DATA=                   SAS dataset for input
    
    FILE=                   filename of the CODA index file
    
    CODAIND=FILE            alias
                            
    OPTIONAL Parameter
    
    CHAIN=                  filename of the CODA chain file
    
    CODAOUT=CHAIN           alias
    
    As you long as you stick to the file name extensions of
    .ind and .out, then you only need to specify CODAIND
*/

%macro SAS2CoDA(data=, file=, codaind=&file, chain=, codaout=&chain) ;
  %local i cnt;

  %if %length(&codaout)=0 %then %let codaout=%scan(&codaind, 1, .).out;
  
  data _null_ ;
   set &data ;
   if _n_ = 1 ;
   array vars(*) _numeric_ ;
   cnt = dim(vars) ;
   call symput("cnt", left(cnt)) ;
  run;

  data all_ ;
   if _n_ < 1 ;
  run;

   %do i = 1 %to &cnt ;
    data d&i (keep = iter__ samp__) ;
     set &data ;
     iter__ = _n_ ;
     array num(*) _numeric_ ;

     do j__ = &i to &i ;
      samp__ = num(j__) ;
     end ;
    run;

    data all_ ;
     set all_ d&i ;
    run;
   %end ;

   data numb_ (keep = first_ last_) ;
    set all_ end = lstrec ;
    file "&codaout" ;
    put @1 iter__ samp__ e10.  ;
    retain first_ ;

    if _n_ = 1 then first_ = iter__ ;

    if lstrec then last_ = iter__ ;

    if lstrec then output numb_ ;
   run;

   proc transpose data=&data out=temp_ ;
   run;

   data _null_ ;
    if _n_ = 1 then set numb_ ;
    set temp_ (keep=_name_) ;

    if _n_ = 1 then do ;
     first = first_ ;
     last  = last_ ;
    end ;
    else do ;
     last  = _n_ * last_ ;
     first = (_n_-1) * last_ + 1 ;
    end ;

    file "&codaind" ;
    put _name_ first last ;
   run;

   proc datasets nolist;
    delete numb_ all_ temp_ d1-d&cnt ;
   run ;
%mend SAS2CoDA ;

