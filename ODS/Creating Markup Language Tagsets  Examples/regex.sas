
options papersize=(8in 11in);
options papersize=('8in', '11in');
options papersize=("8in", "11in");
*options papersize=("8", "11");
options leftmargin=1in;
options rightmargin=2in;
options topmargin=4in;
options bottommargin=4cm;


proc template;
    
   define tagset tagsets.regex;

      define event doc;

         put getoption('papersize') nl;

         set $pp_size getoption('papersize');

         /*------------------------------------------------------eric-*/
         /*-- get rid of the quotes.  It makes the regex easier.    --*/
         /*---------------------------------------------------13Jun03-*/
         
         set $pp_size tranwrd($pp_size, '"', " ");
         set $pp_size tranwrd($pp_size, "'", " ");

         put "after tranwrd: " $pp_size nl;


        /*-------------------------------------------------------eric-*/
        /*-- Compile the regular expression.  The return of         --*/
        /*-- prxparse is a number so we need to use eval.           --*/
        /*----------------------------------------------------13Jun03-*/
         eval $regex prxparse('( *([0-9]+) *(IN|CM)* *[,]+ *([0-9]+) *(IN|CM)*.*)') ; 

         eval $match prxmatch($regex, $pp_size);
         
         put "match is :" " " $match nl;
         
         /* for some reason the value from the where is padded.... */
         eval $first prxposn($regex, 1, $pp_size) ;
         put "first position match using eval" ": " $first '|' nl;
         
         /* but it's not when I use set. */
         set $first prxposn($regex, 1, $pp_size) ;
         put "first position match using set" ": " $first '|' nl;
         
         set $pwidth prxposn($regex, 1, $pp_size) ;
         set $pwidth_unit prxposn($regex, 2, $pp_size) ;
         
         set $pheight prxposn($regex, 3, $pp_size) ;
         set $pheight_unit prxposn($regex, 4, $pp_size) ;
      
         put nl "Here's what the different positions '()' of the regex match on:" nl;
         
         put "first position match "  ": " prxposn($regex, 1, $pp_size) nl ;
         put "second position match " ": " prxposn($regex, 2, $pp_size) nl ;
         put "third position match "  ": " prxposn($regex, 3, $pp_size) nl ;
         put "fourth position match " ": " prxposn($regex, 4, $pp_size) nl ;

         put nl "The Margins are:" nl;
         put getoption('leftmargin') nl;
         put getoption('rightmargin') nl;
         put getoption('topmargin') nl;
         put getoption('bottommargin') nl;
         
        /*---------------------------------------------------------------eric-*/
        /*-- Compile the regex for margins.                                 --*/
        /*------------------------------------------------------------13Jun03-*/
         eval $regex prxparse('(([0-9]+)(IN|CM)*)') ; 
         
         put nl "Separating the margins for reformatting" nl;
         
         set $which_margin 'leftmargin';
         trigger put_margin;

         set $which_margin 'rightmargin';
         trigger put_margin;

         set $which_margin 'topmargin';
         trigger put_margin;

         set $which_margin 'bottommargin';
         trigger put_margin;

   end;

   define event put_margin;
         set $margin getoption($which_margin);
         eval $match prxmatch($regex, $margin);
         put nl $which_margin ":" nl;
         put 'measurement: ' prxposn($regex, 1, $margin) ;
         put ' Unit: '       prxposn($regex, 2, $margin) nl;
   end;

end;

run;

ods tagsets.regex file="regex_out.txt";
ods tagsets.regex close;


