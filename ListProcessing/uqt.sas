%macro uqt(
       l=           /* value list */
     , lv=          /* external variable override for value list */
     , lsep=%str( ) /* separator between values */
     , qt=%str(%")  /* type of quote mark */
     ) ;

 /* L (or &LV) is list of quoted items separated by LSEP

 return unquoted list of items separated by space
 LV provides override to specify external variable name instead list.
 If the LV option is used then L and UQT_: should be avoided for variable names.

examples:
    %put %Uqt(l="a" "b" "c");

Credit:
    source code from Ian Whitlock, Names, Names, Names - Make Me a List
               (SGF 2007)   http://www2.sas.com/proceedings/forum2007/052-2007.pdf
               (SESUG 2008) http://analytics.ncsu.edu/sesug/2008/SBC-128.pdf
 */

 %if %length(&lv) = 0 %then
 %let lv = l ;
 %if %length(%superq(&lv)) > 0 %then
 %do ;
     %sysfunc(compbl(%sysfunc(translate(%superq(&lv),%str( ),&qt&lsep))))
 %end ;
%mend uqt ;
