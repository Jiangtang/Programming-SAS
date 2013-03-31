%macro qt(
       l=           /* value list */
     , lv=          /* external variable override for value list */
     , lsep=%str( ) /* separator between values */
     , qt=%str(%")  /* type of quote mark */
     , osep=%str( ) /* separtor for returned list */
     ) ;

 /* List of items separated by &lsep
     Return items in list quoted with &qt, and separated with &osep
     if lsep is not %STR( ) then there can be only one separator between items.
     Note: leading and trailing spaces are stripped from list when LSEP is %STR( ).
     LV provides override to specify external variable name instead list.
     If the LV option is used then L and QT_: should be avoided for variable names.

examples:
    %put %qt(l=a b c,osep=%str(,));

Credit:
    source code from Ian Whitlock, Names, Names, Names - Make Me a List
               (SGF 2007)   http://www2.sas.com/proceedings/forum2007/052-2007.pdf
               (SESUG 2008) http://analytics.ncsu.edu/sesug/2008/SBC-128.pdf

 */

 %local qt_list ;
 %if %length(&lv) = 0 %then
 %let lv = l ;
 %if %superq(lsep) = %str( ) and %length(&lsep)=1 %then
 %do ;
     %let qt_list = %qsysfunc(strip(%superq(&lv))) ;
     %if %length(&qt_list) > 0 %then
     %let qt_list = %qsysfunc(compbl(&qt_list)) ;
 %end ;
 %else
     %let qt_list = %superq(&lv) ;
 %if %length(&qt_list) > 0 %then
     %do ;
     %unquote(&qt%qsysfunc(tranwrd( &qt_list
     , &lsep
     , &qt&osep&qt
     )
     )&qt
     )
 %end ;
%mend qt ;
