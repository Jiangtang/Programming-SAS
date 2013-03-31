%macro replace(
       l=           /* value list */
     , lv=          /* external variable override for value list */
     , lsep=%str( ) /* separator between values */
     , code=        /* block of code containing symbolic variable */
     , key=#        /* symbolic variable to replace (#abc# etc.) */
     , osep=%str( ) /* separator between new elements */
                    /* may be %str(;) when code is statement */
                    /* if so remember to add closing semicolon */
     ) ;

 /* for elt in the list replace key in code
     LV provides override to specify external variable name instead of list.
     If the LV option is used then L and RG_: should be avoided for variable names.

examples:
    %macro rename ( list, pref=__ ) ;
         %* make a rename list from &LIST *;
         %replace ( l=&list, code = # = &pref# )
    %mend rename ;
    %put %rename ( x y z, pref=__ );

     %macro char2num ( list , pref = __ ) ;
     %* make list of char to num assignments *;
     %replace ( l=&list
        , code= %str(# = input(&pref#,best32.);)
      )
    %mend char2num ;
    %put %char2num(x y z);

Credit:
    source code from Ian Whitlock, Names, Names, Names - Make Me a List
               (SGF 2007)   http://www2.sas.com/proceedings/forum2007/052-2007.pdf
               (SESUG 2008) http://analytics.ncsu.edu/sesug/2008/SBC-128.pdf
 */

 %local rg_i rg_w rg_list ;
 %if %length(&lv) = 0 %then
 %let lv = l ;
 %if %length(%superq(&lv)) = 0 /*or %index(%superq(code),&key) = 0*/ %then
 %do ;
     %let rg_list = %superq(code) ;
     %goto mexit ;
 %end ;
 %do rg_i = 1 %to &sysmaxlong ;
     %let rg_w = %qscan(%superq(&lv),&rg_i,&lsep) ;
     %if %length(&rg_w) = 0 %then %goto mexit ;
     %if &rg_i = 1 %then
     %let rg_list = %sysfunc(tranwrd(%superq(code),&key,&rg_w)) ;
     %else
     %let rg_list =
     &rg_list&osep%sysfunc(tranwrd(%superq(code),&key,&rg_w)) ;
 %end ;
 %mexit:

 %unquote(&rg_list)
%mend replace ;
