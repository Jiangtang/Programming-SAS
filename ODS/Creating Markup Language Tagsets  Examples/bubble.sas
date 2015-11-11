proc template;
define tagset tagsets.bubble;

   define event doc;
      trigger get_cities;
      trigger sort;
      trigger put_cities;
   end;

   define event sort;
      eval $size $city;       /* $size = # of cities */

      eval $i $size;
      do / while $i > 0;
         put "Loop $i= " $i nl;
         eval $j 1;
         do / while $j < $i;
            put "Loop $j= " $j nl;
            eval $jplus1 $j+1;
            put "$city[$j]= " $city[$j] " $city[$jplus1]=" $city[$jplus1] nl;
            do / if $city[$j] > $city[$jplus1];
               put "Swapping " $city[$j] " and " $city[$jplus1] nl;
               set $temp $city[$j];
               set $city[$j] $city[$jplus1];
               set $city[$jplus1] $temp;
            done;
            eval $j $j+1;
         done;
         eval $i $i-1;
      done;
   end;

   define event put_cities;
      eval $i 1;
      do / while $i <= $size;
         put "City " $city[$i] nl;
         eval $i $i+1;
      done;
   end;

   define event get_cities;
      set $city[] 'Fort Bragg';
      set $city[] 'Elon';
      set $city[] 'Kannapolis';
      set $city[] 'Durham';
      set $city[] 'Ocracoke';
      set $city[] 'Icard';
      set $city[] 'Statesville';
      set $city[] 'Valdese';
      set $city[] 'Wrightsville Beach';
      set $city[] 'Lenoir';
      set $city[] 'Yadkinville';
      set $city[] 'Burlington';
      set $city[] 'Ahoskie';
      set $city[] 'Charlotte';
      set $city[] 'Zebulon';
      set $city[] 'Union Grove';
      set $city[] 'Rodanthe';
      set $city[] 'Greensboro';
      set $city[] 'Tarboro';
      set $city[] 'Newton';
      set $city[] 'Hickory';
      set $city[] 'Pittsboro';
      set $city[] 'Mocksville';
      set $city[] 'Jonas Ridge';
   end;

end;  /* tagsets.bubble */
run;

ods tagsets.bubble file="bubble.txt";
ods tagsets.bubble close;
