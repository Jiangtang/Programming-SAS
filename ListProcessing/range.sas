%macro range (
       to  =        /* end integer value */
     , from=1       /* starting integer value */
     , step=1       /* increment integer */
     , osep=%str( ) /* sparator between integers */
     , opre=%str()  /* prefix for sequence of integers*/
     , osuf=%str()  /* suffix for sequence of integers*/
     ) ;

/*
return sequence of integers like 1 2 3 or
    strings endded with sequences of intergers lile data1 data2 data3
    starting at &FROM going to &TO in steps of &step

examples:
   %put %range(to=10);
   %put %range(to=10, opre=%str(data));
   %put %range(from=2,to=10,step=3,osep=%str(,));
   %put %range(from=2,to=10,step=3,osep=%str(,),osuf=%str(a));

Credit:
    source code from Ian Whitlock, Names, Names, Names - Make Me a List
               (SGF 2007)   http://www2.sas.com/proceedings/forum2007/052-2007.pdf
               (SESUG 2008) http://analytics.ncsu.edu/sesug/2008/SBC-128.pdf
    This snippet used a more efficient style from Chang Chung(http://changchung.com)
    Jiangtang Hu (2013, http://www.jiangtanghu.com):
        1)used %let rg_i = ; to initiate the macro variable rather than %local rg_i;
        2)added two parameters (prefix/suffix) so it works more than generating sequence of integers
        3)archived in https://github.com/Jiangtang/Programming-SAS/tree/master/ListProcessing
*/

 %let rg_i = ;
 %do rg_i = &from %to &to %by &step ;
     %if &rg_i = &from %then
     %do;&opre.&rg_i.&osuf%end ;
     %else
     %do;&osep.&opre.&rg_i.&osuf%end ;
 %end ;
%mend range ;
