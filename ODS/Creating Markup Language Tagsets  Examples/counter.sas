
/*
   Tagset to count the frequency of each event and print a report.
*/

proc template;
define tagset tagsets.counter;
   default_event = 'count';

   /*
      Create an event count dictionary `$events'. Each key in the
      dictionary is an event name. The value is the number of times the
      event occurred.

      At doc start, initialize the event dictionary and the total event
      counter. At finish, sort the event names by decreasing occurrence
      and print a report.
   */
   define event doc;
      start:
         eval $events[event_name] 1;
         eval $total 0;
      finish:
         trigger sort;
         trigger report;
      end;

   define event count;
      do / if $events[event_name];
         eval $events[event_name] $events[event_name] + 1;
      else;
         eval $events[event_name] 1;
      done;
      eval $total $total+1;
   end;

   /*
      Create an array `$evname' that contains the event names. Sort
      `$evname' using the counts in `$events'.
   */
   define event sort;
      trigger dup;
      eval $size $events;        /* $size = size of $events */
      eval $i $size;
      do / while $i > 0;
         eval $j 1;
         do / while $j < $i;
            eval $jplus1 $j+1;
            set $evname_j $evname[$j];
            set $evname_jplus1 $evname[$jplus1];
            do / if $events[$evname_j] < $events[$evname_jplus1];
               set $temp $evname[$j];
               set $evname[$j] $evname[$jplus1];
               set $evname[$jplus1] $temp;
               done;
            eval $j $j+1;
            done;
         eval $i $i-1;
         done;
      end;

   define event dup;
      iterate $events;
      do / while _name_;
         set $evname[] _name_;
         next $events;
         done;
      end;

   /*
      Print the `$events' dictionary in the order specified by the
      `$evname' array.
   */
   define event report;
      put "Number of individual events: " $events nl;
      put "Total number of events: " $total nl nl;
      put "Count   Event name" nl;
      iterate $evname;
      do / while _value_;
         eval $occur $events[_value_];
         eval $occur putn($occur, 'F.', 5);
         put $occur "   " _value_ nl;
         next $evname;
         done;
      end;

   end;

run;

ods listing close;
ods tagsets.counter file="counter.txt";
proc print data=sashelp.class;
run;
ods tagsets.counter close;
ods listing;
