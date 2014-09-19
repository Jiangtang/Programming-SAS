/*------------------------------------------------------------eric-*/
/*-- This tagset creates sql statements to create a table        --*/
/*-- and insert all the records in the dataset.  The resulting   --*/
/*-- output will have the table create statement followed by     --*/
/*-- the insert statements.                                      --*/
/*--                                                             --*/
/*-- This has only been tested with proc print, although it may  --*/
/*-- Work with other proc's as well.                             --*/
/*--                                                             --*/
/*-- This isn't anything fancy, all it handles are strings,      --*/
/*-- integers and numbers.  It could do more by using the        --*/
/*-- value of sasformat.                                         --*/
/*---------------------------------------------------------12Feb04-*/

proc template;
  define tagset tagsets.sql;

      /*---------------------------------------------------------------eric-*/
      /*-- Set up some look-up tables for convenience.                    --*/
      /*------------------------------------------------------------11Feb04-*/
      /* type translations */
      define event type_translations;
          set $types['string'] 'varchar';
          set $types['double'] 'float';
          set $types['int']    'integer';
      end;

      /* column name translation */
      define event name_translations;
          set $name_trans['desc'] 'description';
      end;
  
      define event initialize;
          trigger type_translations;
          trigger name_translations;

          /* types that need widths */
          set $types_with_widths['string'] "True";

          /* types that need quotes */
          set $types_with_quotes['string'] "True";
      end;
  
      /*---------------------------------------------------------------eric-*/
      /*-- Reset everything so we can run one proc print after another.   --*/
      /*------------------------------------------------------------11Feb04-*/
      define event table;
          unset $names;
          unset $col_types;
          unset $columns;
          unset $values;
          unset $lowname;
      end;


      define event colspec_entry;
          /*---------------------------------------------------------------eric-*/
          /*-- Ignore the obs column.  The value will get ignored because     --*/
          /*-- it will be in a header cell and we don't define a header       --*/
          /*-- event to catch it.                                             --*/
          /*------------------------------------------------------------12Feb04-*/
          break /if cmp(name, 'obs');

          /*---------------------------------------------------------------eric-*/
          /*-- Create a list of column names.  Translate the names            --*/
          /*-- if they are in the translate list.                             --*/
          /*------------------------------------------------------------11Feb04-*/
          set $lowname lowcase(name);
          do /if $name_trans[$lowname];      
              set $names[] $name_trans[$lowname];
          else;
              set $names[] $lowname;
          done;

          /* keep a list of types */
          set $col_types[] type;

          /* make a list of column type definitions */
          set $col_def $types[type];

          /* append width if needed */
          set $col_def $col_def "(" width ")" /if $types_with_widths[type];
          
          set $columns[] $col_def;
      end;
      
      /*---------------------------------------------------------------eric-*/
      /*-- Catch the data label and get the data set name from it.        --*/
      /*------------------------------------------------------------11Feb04-*/
      define event output;
          start:
              set $table_name reverse(label);
              set $table_name scan($table_name, 1, '.');
              set $table_name reverse($table_name);
              set $table_name lowcase($table_name);
      end;    

     /*---------------------------------------------------------------eric-*/
     /*-- Print out the create table statement before Any data           --*/
     /*-- rows come along.                                               --*/
     /*------------------------------------------------------------11Feb04-*/
      define event table_body;
          put "Create table " $table_name "(";
          /* put "           "; */

          /* loop over the names, and column definitions */
          eval $i 1;
          unset $not_first;
          do /while $i <= $names;      
              /* comma's only after the first name */
              put ', ' /if $not_first;
              put $names[$i] " ";
              put $columns[$i];
              eval $i $i+1;
              set $not_first "True";
          done;    

          put ");" nl;
      end;
  
      /*---------------------------------------------------------------eric-*/
      /*-- Reset the values at the beginning of each row.  Print the      --*/
      /*-- insert statement at the end of each row.                       --*/
      /*------------------------------------------------------------11Feb04-*/
      define event row;
          start:
              unset $values;
          finish:
              trigger insert;
      end;

      /*---------------------------------------------------------------eric-*/
      /*-- Save away the data.  The Obs column won't hit this because     --*/
      /*-- it's a header.                                                 --*/
      /*------------------------------------------------------------12Feb04-*/
      define event data;
          do /if value;
              set $values[] strip(value);
          else;
              set $values[] ' ';
          done;
      end;
          
      /*---------------------------------------------------------------eric-*/
      /*-- Create the insert statement                                    --*/
      /*------------------------------------------------------------12Feb04-*/
      define event insert;
          finish:
              break /if ^$values;
          
              put "Insert into " $table_name;
              trigger print_names;
              put " Values";
              trigger print_values;
              put ";" nl;
      end;    
      
      /*---------------------------------------------------------------eric-*/
      /*-- Print the list of names.  This could use                       --*/
      /*-- a single putvars statement if it weren't for                   --*/
      /*-- the commas.                                                    --*/
      /*------------------------------------------------------------12Feb04-*/
      define event print_names;
          put "(";
          iterate $names;
          unset $not_first;
          do /while _value_;
              /* comma's only after the first name */
              put ", " /if $not_first;
              put lowcase(_value_);
              set $not_first "true";
              next $names;
          done;
          put ")";
      end;

      /*---------------------------------------------------------------eric-*/
      /*-- Print the values for the insert statement. Commas and quoting  --*/
      /*-- are an issue.  double up the quotes in strings.  Remove        --*/
      /*-- commas from numbers.                                           --*/
      /*------------------------------------------------------------12Feb04-*/
      define event print_values;
          put "(";

          eval $i 1;
          unset $not_first;

          iterate $values;

          do /while _value_;
              put ", " /if $not_first;

              do /if $types_with_quotes[$col_types[$i]]; 
                  put "'" ;
                  put tranwrd(_value_, "'", "''") /if ^cmp(_value_, ' ');
                  put "'";
              else;
                  do /if cmp(_value_, ' ');
                      put '0';
                  else;    
                      put tranwrd(_value_, "," , "") ;
                  done;
              done;    

              set $not_first "true";

              next $values;
              eval $i $i+1;
          done;

          put ")";
      end;
      
  end;
run;

ods tagsets.sql file="foo.sql";

  proc print data=sashelp.class;
  run;

ods _all_ close;
