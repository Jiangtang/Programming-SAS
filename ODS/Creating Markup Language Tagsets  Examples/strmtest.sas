proc template;
   define tagset tagsets.streams;
      define event doc;
      start:

        /*---------------------------------------------------------------eric-*/
        /*-- Write some stuff to an Item store stream.                      --*/
        /*------------------------------------------------------------9Mar 02-*/
         open stream1;
         put "this goes to stream1"    nl;
         close;

        /*---------------------------------------------------------------eric-*/
        /*-- write some stuff to the file.  just like usual.                --*/
        /*------------------------------------------------------------9Mar 02-*/
         put "this goes to the file" nl nl;

         put "this shouldn't print:" $not_a_var;

        /*---------------------------------------------------------------eric-*/
        /*-- write out the stuff we put in the stream earlier.              --*/
        /*------------------------------------------------------------9Mar 02-*/
         put "putstream:" nl;
         putstream stream1;
         put "end putstream" nl;

         put "put with stream:" nl;
         put "here it comes" nl $$stream1 "there it was" nl /if exists($$stream1);
         put nl;

        /*---------------------------------------------------------------eric-*/
        /*-- Put some more stuff into our original stream.                  --*/
        /*------------------------------------------------------------9Mar 02-*/
         open stream1;
         put "this goes to stream1 too"    nl;
         close;

        /*-------------------------------------------------------eric-*/
        /*-- Create a new stream.  copy our other stream into it    --*/
        /*-- along with some other stuff.                           --*/
        /*----------------------------------------------------9Mar 02-*/

         open stream2;
         put "this is stream2" nl;
         put "with stream1 in it" nl;
         put $$stream1;
         put "The end of stream2" nl;

        /*---------------------------------------------------------------eric-*/
        /*-- A stream can't write to it's self.  This will do an implicit   --*/
        /*-- close.  Which redirects the output back to the output file.    --*/
        /*------------------------------------------------------------9Mar 02-*/
         putstream stream2;

        /*---------------------------------------------------------------eric-*/
        /*-- if we are currently writing to a stream the output will be     --*/
        /*-- switched to the output file when putvars get's to that stream. --*/
        /*-- Just like the implicit close in the xample above.              --*/
        /*------------------------------------------------------------9Mar 02-*/
         open stream2;
         close;
         
         put nl "Stream variables:" nl;
         putvars stream "<" _name_ ">" _value_ "</" _name_ ">" nl;

         put nl "putstream:" nl;
         putstream junk;

        /*--------------------------------------------------------------eric-*/
        /*-- We can force a flush of the file buffers.  This isn't really  --*/
        /*-- necessary much.  But if you want to do crazy twisted things   --*/
        /*-- like have more than one file write to the same stream it      --*/
        /*-- will be.  It could also be handy if you want to write more    --*/
        /*-- than one file to the same fileref. Franke Poppe's DDE tagset  --*/
        /*-- could benefit from this.                                      --*/
        /*-----------------------------------------------------------9Mar 02-*/
         put nl "We are going to flush this" nl;
         flush;
         
        /*---------------------------------------------------------------eric-*/
        /*-- Delete the stream.  This will happen automatically when the    --*/
        /*-- ODA closes.  But we can force it too.                          --*/
        /*------------------------------------------------------------9Mar 02-*/

         put nl "delstream:" nl;
         delstream stream1;

        /*---------------------------------------------------------------eric-*/
        /*-- junk is gone so we shouldn't get anything but the label here.  --*/
        /*------------------------------------------------------------9Mar 02-*/

         put nl "putstream stream1:" nl;
         putstream stream1;

         put nl;

        /*------------------------------------------------------eric-*/
        /*-- You can set a stream. It will open the stream and     --*/
        /*-- set it.  Then close it. It's like a                   --*/
        /*-- combination unset, open, put, and close.              --*/
        /*---------------------------------------------------10Mar02-*/
        
         set $$stream3 "this is weird" " but it should work";

        /*-----------------------------------------------------------------eric-*/
        /*-- In order to keep putting stuff in stream3 we have to open it or  --*/
        /*-- keep doing sets.  put is a lot nicer than set...                 --*/
        /*--------------------------------------------------------------10Mar02-*/
         open stream3;
         
         put nl "some more stuff for stream3" nl;
         
        /*---------------------------------------------------------------eric-*/
        /*-- A set removes anything that was previously in the stream and   --*/
        /*-- starts over with what is given.                                --*/
        /*------------------------------------------------------------12Mar02-*/
         set $$stream3 "reset stream3"; 

         putstream stream3;

         delstream stream3;
         

         /*--------------------------------------------------------------eric-*/
         /*-- create a stream the 'normal' way.                             --*/
         /*-----------------------------------------------------------12Mar02-*/
         open stream3;
         put "some more stuff for stream3" ;
         close;
         
         put "Open/put Junk4:" $$stream3 nl;
         
         /*---------------------------------------------------------------eric-*/
         /*-- Add to our previously created stream...                        --*/
         /*------------------------------------------------------------12Mar02-*/
         open stream3;
         put " more stuff" ;
         close;

         put "Open/put stream3:" $$stream3 nl;
         
         /*---------------------------------------------------------------eric-*/
         /*-- set the same stream to something else.  It's like starting over.--*/
         /*------------------------------------------------------------12Mar02-*/
         set $$stream3 "A completely new stream3"; 

         put "set stream3:" $$stream3 nl;

         /*------------------------------------------------------eric-*/
         /*-- Set a stream to it's self plus some more.             --*/
         /*---------------------------------------------------12Mar02-*/
         set $$stream3 $$stream3 " !!! even more stuff for stream3"; 

         put "setself stream3:" $$stream3 nl;

         /*------------------------------------------------------eric-*/
         /*-- Set the stream to itself with  stuff on each side.    --*/
         /*-- Set differs from put in that putting a stream to      --*/
         /*-- itself will set what the stream looked like before    --*/
         /*-- the set command.                                      --*/
         /*---------------------------------------------------12Mar02-*/
         set $$stream3 "*********" $$stream3 "%%%%%%%%%%"; 

         put "setself stream3:" $$stream3 nl;

         /*------------------------------------------------------eric-*/
         /*-- Append some text a newline and our stream to itself.  --*/
         /*-- Notice that the append of itself includes Everything  --*/
         /*-- up to the stream reference. Including the newline.    --*/
         /*---------------------------------------------------12Mar02-*/
         open stream3;
         put "!!! This gets duped too!!! " nl $$stream3 ;
         close;

         put "open/putself stream3:" $$stream3 nl ;
         
         putstream stream3;

         put nl;
         
         put "stream3:" $$stream3 nl;

         /*------------------------------------------------------eric-*/
         /*-- This is a syntax error.  you can't compare a stream.  --*/
         /*---------------------------------------------------12Mar02-*/
         /*put "hello" /if cmp('hello', $$junk4);*/
         
        /*-------------------------------------------------------eric-*/
        /*-- We can delete a stream with unset too.                 --*/
        /*----------------------------------------------------9Mar 02-*/
         unset $$stream2;
         put nl "put deleted stream2:" nl;
         put $$stream2;
         
        /*---------------------------------------------------------------eric-*/
        /*-- So let's see what's left of our streams.  we still have an     --*/
        /*-- empty stream called junk3.                                     --*/
        /*------------------------------------------------------------9Mar 02-*/
         put nl "Stream variables:" nl;
         putvars stream "<" _name_ ">" _value_ "</" _name_ ">" nl;

      end;    
  end;
run;


ods tagsets.streams file="streamtest.txt";
ods tagsets.streams close;

           
