/*<pre><b>
/ Program   : lslist2sas.sas
/ Version   : 1.1
/ Author    : Roland Rashleigh-Berry
/ Date      : 20-Mar-2014
/ Purpose   : To read the output of the "ls -l" command into a sas dataset
/ SubMacros : none
/ Notes     : The "ls -l" command produces a listing that can be saved to a file
/             but gives problems in that the position of the fields depends on
/             the length of the fields and as such is unpredictable. The fields
/             "group" and "size" might have no gap between them if they are
/             both long so "scanning" for this can give the wrong result.
/             The file name might contains spaces so this should not be scanned
/             for and instead "call scan" needs to be used to find out the
/             position of the date (or time) that precedes the final file name
/             so that the file name can be read using substr() to the end. There
/             may be other instances of when adjacent columns have no gap
/             between them that will need to be catered for.
/
/             The listing is expected to have the following "ls -l" style:
/
/                /dir1/dir2/dir3:
/                total 111
/                drwxr-xr-x   2 root       root          1024 Jan 21  2000 xx_yy
/
/             Variables in the output dataset are, in this order: path, total,
/             permiss, links, owner, group, size, month, day, year, time, date,
/             datetime, filename.
/
/ Usage     : lslist2sas(my-text-file); 
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ textfile          (pos) (no quotes) Enclose in %nrstr() if the file path 
/                   contains spaces or special characters.
/ dsout             (pos) Name of output dataset (defaults to "_lslist2sas")
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  15May13         New (v1.0)
/ rrb  04Jun13         Problem with dates in the future fixed (v1.1)
/ rrb  20Mar14         Default output dataset name now starts with an underscore
/                      (v2.0)
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: lslist2sas v2.0;


%macro lslist2sas(textfile,dsout);

  %if not %length(&dsout) %then %let dsout=_lslist2sas;

  *-- there is no system informat for months so create one --;
  proc format;
    invalue _mon
    "Jan"=1
    "Feb"=2
    "Mar"=3
    "Apr"=4
    "May"=5
    "Jun"=6
    "Jul"=7
    "Aug"=8
    "Sep"=9
    "Oct"=10
    "Nov"=11
    "Dec"=12
    ;
  run;


  data &dsout;
    length path $ 200 total 8 permiss $ 10 links 8 owner $ 8
           grpsize $ 30 group $ 11 size 8 month $ 3 day 8 yrtm $ 5 
           pos len year time date datetime 8 filename $ 200;
    retain path " " total .;
    infile "&textfile";
    *-- Do a straight "input" and then use _infile_ for      --;
    *-- scanning and sub-stringing to get the column values. --;
    input;
    *-- Note that an "output" is only done for a valid data --;
    *-- line that starts with a "permissions" string.       --;
    if _infile_ NE " " then do;
      if substr(_infile_,length(_infile_),1)=":" 
       then path=substr(_infile_,1,length(_infile_)-1);
      else if _infile_=:"total" then total=input(scan(_infile_,2," "),comma13.);
      else do;
        permiss=scan(_infile_,1," ");
        links=input(scan(_infile_,2," "),6.);
        owner=scan(_infile_,3," ");
        *-- group and size read as combined in case they have joined --;
        grpsize=scan(_infile_,4," ");
        if length(grpsize)>11 then do;
          *-- most likely group and size are joined --;
          group=substr(grpsize,1,prxmatch('/\d+ *$/',grpsize)-1);
          size=input(substr(grpsize,prxmatch('/\d+ *$/',grpsize)),12.);
          month=scan(_infile_,5," ");
          day=input(scan(_infile_,6," "),2.);
          *-- the next will either be a year or the time --;
          yrtm=scan(_infile_,7," ");
          if index(yrtm,':') then do;
            *-- we have a time so assume the year is the current year --;
            time=input(yrtm,time5.);
            year=year(date());
          end;
          else do;
            *-- this is a plain year so set the time to zero --;
            year=input(yrtm,4.);
            time=0;
          end;
          *-- The file name may have spaces in it so we can not --;
          *-- just scan for it so we need to use "call scan" to --;
          *-- tell us where we got the year/time from and skip  --;
          *-- to just after that to read the file name in.      --;
          pos=0;
          len=0;
          call scan(_infile_,7,pos,len," ");
          filename=left(substr(_infile_,pos+len));
        end;
        else do;
          *-- we have seperate group and size --;
          group=grpsize;
          size=input(scan(_infile_,5," "),12.);
          month=scan(_infile_,6," ");
          day=input(scan(_infile_,7," "),2.);
          *-- see above comments --;
          yrtm=scan(_infile_,8," ");
          if index(yrtm,':') then do;
            time=input(yrtm,time5.);
            year=year(date());
          end;
          else do;
            year=input(yrtm,4.);
            time=0;
          end;
          *-- see "call scan" comments above --;
          pos=0;
          len=0;
          call scan(_infile_,8,pos,len," ");
          filename=left(substr(_infile_,pos+len));
        end;
        *-- calculate date and datetime from what we already have --;
        date=mdy(input(month,_mon.),day,year);
        datetime=dhms(date,0,0,time);
        *-- fix the date if it is in the future --;
        if date>today() then do;
          year=year-1;
          date=mdy(input(month,_mon.),day,year);
          datetime=dhms(date,0,0,time);
        end;
        *-- HERE IS WHERE WE DO THE "OUTPUT" --;
        output;
      end;
    end;
    FORMAT date date9. time time5. datetime datetime22.;
    *-- drop working variables (maybe keep for debugging) --;
    DROP pos len grpsize yrtm;
  run;


%mend lslist2sas;
