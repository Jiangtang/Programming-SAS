%macro Grue / des="Copyright Infocom";

    %let typed=;

    %window grue color=black
        #2 @10 "It is pitch black." color=white
        #4 @10 "You are likely to be eaten by a grue." color=white
        #40 @10 typed 50 color=gray attr=rev_video
        ;

    %window grue2 color=black
        #2 @10 "It is pitch black." color=white
        #4 @10 "You are likely to be eaten by a grue." color=white
        #7 @10 "The grue is a sinister, lurking presence in the dark places of the earth." color=white
        #8 @10 "Its favorite diet is adventurers, but its insatiable appetite is tempered" color=white
        #9 @10 "by its fear of light. No grue has ever been seen by the light of day, and" color=white
        #10 @10 "few have survived its fearsome jaws to tell the tale." color=white
        #12 @75 "- ZORK I" color=white
        ;

    %display grue;

    %if "&typed" ne "" %then %do;

        %if %lowcase(%substr(%sysfunc(compbl(&typed)),1,14))=what is a grue %then %do;
    
            %display grue2;

        %end;

    %end;

%mend Grue;
