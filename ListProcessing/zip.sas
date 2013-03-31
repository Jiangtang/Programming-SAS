%macro zip(
       l1   =        /* first list */
     , lv1 =        /* external variable override for first list */
     , sep1 =%str( ) /* separator between the joined elements */
     , l2   =        /* second list */
     , lv2  =        /* external variable override for second list */
     , sep2 =%str( ) /* separator between the joined elements */
     , osep =%str( ) /* separator between new elements */
     ) ;

 /* %zip ( l1= a b , l2= c d ) produces ac bd

examples:
 %let list1 = a b ;
 %let list2 = c d ;
 %put %zip (lv1=list1, lv2=list2);
 %put %zip (lv1=list1, lv2=list2,osep =%str(,));
 %put %zip (l1=a b, l2=c d,osep =%str(,));

 If lists do not have same length shorter length used and warning to the log.
 Empty lists result in empty list and no message.
 If the LV options are used then L1, L2, and ZIP_: should be avoided for variable names.

Credit:
    source code from Ian Whitlock, Names, Names, Names - Make Me a List
          (SGF 2007)   http://www2.sas.com/proceedings/forum2007/052-2007.pdf
          (SESUG 2008) http://analytics.ncsu.edu/sesug/2008/SBC-128.pdf
 */

 %local zip_i zip_1 zip_2 zip_list ;
 %if %length(&lv1) = 0 %then
 %let lv1 = l1 ;
 %if %length(&lv2) = 0 %then
 %let lv2 = l2 ;
 %do zip_i = 1 %to &sysmaxlong ;
   %let zip_1 = %qscan(%superq(&lv1) , &zip_i, &sep1 ) ;
   %let zip_2 = %qscan(%superq(&lv2) , &zip_i, &sep2 ) ;
   %if %length(&zip_1) = 0 or %length(&zip_2) = 0 %then
   %goto check ;
   %if &zip_i = 1 %then
   %let zip_list = &zip_1&zip_2 ;
   %else
   %let zip_list = &zip_list&osep&zip_1&zip_2 ;
 %end ;
 %check:
 %if %length(&zip_1) > 0 or %length(&zip_2) > 0 %then
 %put WARNING: Macro ZIP - list lengths do not match - shorter used. ;
 %unquote(&zip_list)
%mend zip ;
