proc template;
    define tagset tagsets.writefile;
        define event doc;
            putl "Twas Brillig and the slithy toves";
            putl "Did gyre and gimble in the wabe,";
            putl "All mimsy were the borogoves,";
            putl "and the mome raths outgrabe.";
        end;
    end;
run;

/*---------------------------------------------------------------eric-*/
/*-- Reading a file in using datastep functions.  This example      --*/
/*-- comes pretty much straight out of the online documentation     --*/
/*-- for fread().                                                   --*/
/*------------------------------------------------------------9Jun 03-*/

proc template;
    define tagset tagsets.readfile;

        mvar infile;
    
        define event doc;
            putlog "Infile is" " :" infile;

            /*---------------------------------------------------eric-*/
            /*-- we have a default input file of jabberwocky.txt    --*/
            /*------------------------------------------------13Jun03-*/
            do /if infile;
               set $filename infile;
            else;
               set $filename "Jabberwocky.txt" ;
            done;

            putlog "Reading in file: " $filename;

            trigger readfile;
        end;    


        define event readfile;

            /*---------------------------------------------------------------eric-*/
            /*-- Set up the file and open it.                                   --*/
            /*------------------------------------------------------------13Jun03-*/
        
            set $filrf "myfile";
            eval $rc filename($filrf, $filename);
            eval $fid fopen($filrf);

            /*---------------------------------------------------------------eric-*/
            /*-- datastep functions  will bind directly to the variable         --*/
            /*-- space as it exists.                                            --*/
            /*--                                                                --*/
            /*-- Tagset variables are not like datastep variables, but          --*/
            /*-- we can create a big one full of spaces and let the functions   --*/
            /*-- write to it.                                                   --*/
            /*--                                                                --*/
            /*-- This creates a variable that is 200 spaces so that the         --*/
            /*-- function can write directly to the memory location held        --*/
            /*-- by the variable. in VI, 200i<space>                            --*/
            /*------------------------------------------------------------9Jun 03-*/
            set $file_record  "                                                                                                                                                                                                        ";

            /*---------------------------------------------------eric-*/
            /*-- Loop over the records in the file                  --*/
            /*------------------------------------------------13Jun03-*/
            do /if $fid > 0 ;

                do /while fread($fid) = 0;

                    set $rc fget($fid,$file_record ,200);

                    /* trimn to get rid of the spaces at the end. */
                    put trimn($file_record ) nl;

                done;
            done;

           /*-----------------------------------------------------eric-*/
           /*-- close up the file.  set works fine for this.         --*/
           /*--------------------------------------------------13Jun03-*/
            
            set $rc close($fid);
            set $rc filename($filrf);

    end;
end;

run;


%let infile=junk.txt;

ods tagsets.writefile file="readfile_out1.txt";
ods tagsets.writefile close;

ods tagsets.readfile file="readfile_out2.txt";
ods tagsets.readfile close;
