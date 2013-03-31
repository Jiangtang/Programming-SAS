%macro changesep(
       l=           /* value list */
     , lv=          /* external variable override for value list */
     , lsep=%str( ) /* separator between values */
     , osep=%str(,) /* separator for rteurned list */
     ) ;
 
 /* L (or &LV) is list of quoted items separated by LSEP
 return unquoted list of items separated by OSEP
 LV provides override to specify external variable name instead list.
 If the LV option is used then L and CHG_: should be avoided for variable names.

 examples:
    %put %changesep ( l=a b c, lv= , lsep= %str( ), osep=%str(,) );

Credit:
    source code from Ian Whitlock, Names, Names, Names - Make Me a List
               (SGF 2007)   http://www2.sas.com/proceedings/forum2007/052-2007.pdf
               (SESUG 2008) http://analytics.ncsu.edu/sesug/2008/SBC-128.pdf
 */

 %local chg_list ;
 %if %length(&lv) = 0 %then
 %let lv = l ;
 %if %length(%superq(&lv)) > 0 %then
 %do ;
     %if %superq(osep)= %str( ) %then
     %do ;
         %let chg_list = %qsysfunc(strip(%superq(&lv))) ;
         %let chg_list = %qsysfunc(compbl(&chg_list)) ;
     %end ;
     %else
     %let chg_list = %superq(&lv) ;
     %let chg_list = %qsysfunc(translate(&chg_list,&osep,&lsep)) ;
 %end ;
 %unquote(&chg_list)
%mend changesep ;
