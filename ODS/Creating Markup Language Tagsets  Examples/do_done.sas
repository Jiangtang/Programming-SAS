
proc template;
   define tagset tagsets.do_done;

   define event doc;

      put "HELLO" nl ;

      eval $i 0;

      put "i is " $i nl;
      
      put "Going into a Loop to 10" nl;
      put "Continue at 5" nl;
      put "stop at 8" nl;

      do /while $i < 10;
        eval $i $i+1;
        continue /if $i eq 5;
        stop /if $i eq 8;
        put "I is " $i nl;
      else;
        put "do this if i started out > 10" nl;
      done;
        
      eval $i 0;

      put "i is " $i nl;
      
      put "Going into a false Loop" nl;

      do /while $i > 10;
        eval $i $i+1;
        put "I is " $i nl;
      else;
        put "Hello from a while's else" nl;
      done;

      set $poem "Jabberwocky";

      /* Test if ... */
      do /if cmp($poem, "Jabberwocky");
         put "inside simple if: should print" nl;   
      else;
         put "inside else: should not print" nl;   
      done;
      
      /* Test nesting in an else... */
      do /if ^cmp($poem, "Jabberwocky");
         put "inside if: should not print" nl;   
      else;
         put "inside else: should print" nl;   

         do /if cmp($poem, "Jabberwocky");
            put "if inside else, does print" nl;   
         else;
            put "else inside else, doesn't print" nl;   
         done;

         put "Still inside else: should print" nl;   

      done;

      /* test break if */
      trigger bif;
      
      put "GOODBYE" nl;
      
   end;

   /*---------------------------------------------------------------eric-*/
   /*-- This is a more effecient and easier to read construct which is --*/
   /*-- equivalent to:                                                 --*/
   /*--                                                                --*/
   /*-- put "Hello from bif" nl /if cmp($poem, "Jabberwocky");         --*/
   /*-- break /if cmp($poem, "Jabberwocky");                           --*/
   /*------------------------------------------------------------29May03-*/

   define event bif;
      put "Hello from bif: prints" nl / breakif cmp($poem, "Jabberwocky");

      put "This won't print" nl;
   end;   

  
end;

run;

ods tagsets.do_done file="do_done_out.txt";
ods tagsets.do_done close;

