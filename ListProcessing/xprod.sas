%macro xprod(
     l1  =        /* first list */
   , lv1 =        /* external variable override for first list */
   , sep1=%str( ) /* separator between elements of first list */
   , l2  =        /* second list */
   , lv2 =        /* external variable override for second list */
   , sep2=%str( ) /* separator between elements of second list */
   , osep=%str( ) /* separator between elements of new list */
 );

 /* %xprod ( l1= a b , l2= c d ) produces ac ad bc bd

examples:
 %let list1 = a b ;
 %let list2 = c d ;
 %put %xprod (lv1=list1, lv2=list2);
 %put %xprod (lv1=list1, lv2=list2,osep=%str(,));

 LV1 and LV2 provide override to specify external variable name instead of lists.
 If one or more of the lists are empty then the empty list is returned.
 If the LV options are used then L1, L2, and XP_: should be avoided for variable names.

Credit:
    source code from Ian Whitlock, Names, Names, Names - Make Me a List
        (SGF 2007)   http://www2.sas.com/proceedings/forum2007/052-2007.pdf
        (SESUG 2008) http://analytics.ncsu.edu/sesug/2008/SBC-128.pdf
 */

 %local xp_i xp_j xp_1 xp_2 xp_list ;
 %if %length(&lv1) = 0 %then
 %let lv1 = l1 ;
 %if %length(&lv2) = 0 %then
 %let lv2 = l2 ;
 %do xp_i = 1 %to &sysmaxlong ;
   %let xp_1 = %qscan(%superq(&lv1), &xp_i, &sep1) ;
   %if %length(&xp_1) = 0 %then %goto endloop1 ;
   %do xp_j = 1 %to &sysmaxlong ;
     %let xp_2 = %qscan(%superq(&lv2), &xp_j, &sep2) ;
     %if %length(&xp_2) = 0 %then %goto endloop2 ;
     %if &xp_i = 1 and &xp_j = 1 %then
     %let xp_list = &xp_1&xp_2 ;
     %else
     %let xp_list = &xp_list&osep&xp_1&xp_2 ;
   %end ;
   %endloop2:
 %end ;
 %endloop1:
 %unquote(&xp_list)
%mend xprod ;
