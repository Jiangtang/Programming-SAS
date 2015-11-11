
proc template;
   define tagset tagsets.list_dict;

   define event doc;
      put "HELLO" nl;

      set $dogs['pola'] "was a nice dog";
      set $dogs['arkas'] "is big for a puppy";

      put nl "dogs['pola'] : " $dogs['pola'] nl;
      put "dogs['arkas'] : " $dogs['arkas'] nl;

      put nl "The dictionary, dogs Contains " $dogs " Entries:" nl;
      putvars $dogs "Name: " _name_ "    Value: " _value_ nl;

      set $mylist[] "one";
      set $mylist[] "two";
      set $mylist[] "pola";

      put nl "mylist[1] : " $mylist[1] nl;
      put "mylist[2] : " $mylist[2] nl;

      put nl "The list, mylist Contains " $mylist " Entries:" nl;
      putvars $mylist "Name: " _name_ "    Value: " _value_ nl;

      set $junk "pola";

      put nl "junk is: " $junk nl;
      put "mylist[3] is: " $mylist[3] nl nl;
      
      put "dogs[$junk] is: " $dogs[$junk] nl;

      put "dogs[$mylist[3]] is: " $dogs[$mylist[3]] nl;
      
      put "Setting mylist[2] to something else" nl; 
      set $mylist[2] "this is two";
      
      put nl "The list, mylist Contains " $mylist " Entries:" nl;
      putvars $mylist "Name: " _name_ "    Value: " _value_ nl;


      put nl "Testing While loop indexing on a list" nl;

      eval $count $mylist;
      eval $i 1;

      do /while $i <= $count;
         put "Value of mylist[" $i "] : " $mylist[$i] nl;
         eval $i $i+1;
      done;

      put nl "Testing iterator on dictionary" nl;
      
      iterate $dogs;
      do /while _value_;
          put "Key: " _name_ " Value: " _value_ nl;
          next $dogs;
      done;

      put nl "Negative indexes come back from the end of the list, -1 is the last one" nl;
      put "The last entry in mylist is, mylist[-1]: " $mylist[-1] nl;

      
      /* Deleting entries */

      put nl "deleting mylist[3]" nl;
      unset $mylist[3];

      put nl "mylist Now contains, " $mylist " Entries" nl;
      putvars $mylist "Name: " _name_ "    Value: " _value_ nl;

      put nl "deleting mylist[1]" nl;
      unset $mylist[1];

      put nl "mylist Now contains, " $mylist " Entries" nl;
      putvars $mylist "Name: " _name_ "    Value: " _value_ nl;
 
      set $mylist[] "this is really two";
      set $mylist[] "pola";
      
      put nl "mylist Now contains, " $mylist " Entries" nl;
      putvars $mylist "Name: " _name_ "    Value: " _value_ nl;

      /* Where clauses */

      put nl nl "Where clauses - eval" nl;
      eval $test $mylist+1;
      put nl "Test is the length of mylist + 1: " $test nl;

      eval $test substr($mylist[1], 6) ;
      put nl "Test substr(mylist[1],6) is: " $test nl;
          
      eval $test substr($dogs[$mylist[3]], 4) ;
      put nl "Test substr(dogs[mylist[3]],4) is: " $test nl;


      /* back to deleting things */

      put nl nl "deleting mylist[-1]" nl;
      unset $mylist[-1];

      put nl "mylist Now contains, " $mylist " Entries" nl;
      putvars $mylist "Name: " _name_ "    Value: " _value_ nl;

      put nl "deleting mylist" nl;
      unset $mylist;
      
      put nl "mylist is gone:" nl;
      putvars $mylist "Name: " _name_ "    Value: " _value_ nl;

      put nl "deleting dogs['pola']" nl;
      unset $dogs['pola'];

      put nl "dogs Now contains, " $dogs " Entries" nl;
      putvars $dogs "Name: " _name_ "    Value: " _value_ nl;

      put nl "GOODBYE" nl;
      
   end;

end;

run;

ods tagsets.list_dict file="list_dict_out.txt";
ods tagsets.list_dict close;

