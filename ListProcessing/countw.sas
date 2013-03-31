/*Retrieving the number of words in a macro variable*/
/* valid in SAS 9.1 and above. */

/*
http://support.sas.com/kb/26/152.html
*/

%macro countw(L);
    %let countw=%sysfunc(countw(&L));
    %eval(&countw);
%mend countw;


/*example

%put %countw(e 5 5);

*/

