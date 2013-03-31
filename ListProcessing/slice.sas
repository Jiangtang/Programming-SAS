%macro slice(
    L,            /*list*/
    i,            /*index*/
    sep_L=%str( ),/*separator for list*/
    sep_i=%str( ) /*separator for index*/
    );

    /*
    return a sub-list sliced by a index

    examples(all produce a c d):
       %put %slice(a b c d,1 3  4);                                   
       %put %slice(%str(a, b, c, d),1 3  4,sep_L=%str(,));
       %put %slice(%str(a, b, c, d),%str(1, 3, 4),sep_L=%str(,),sep_i=%str(,)); 

    Credit:
        Jiangtang Hu (2013-03-31, http://www.jiangtanghu.com):
    */

    %let VarList = ;
    %let count=%sysfunc(countw(&i,&sep_i));

    %do j = 1 %to &count;
      %let index=%qscan(&i,&j,&sep_i);
      %let VarList = &VarList.%str( )%qscan(&L,&index,&sep_L);
    %end;

    &VarList
%mend slice;
