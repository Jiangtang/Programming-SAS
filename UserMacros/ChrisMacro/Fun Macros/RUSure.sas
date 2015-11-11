%macro RUSure / des="Really?";

    %local user_mprint;
    %let user_mprint=%sysfunc(getoption(mprint));
    options nomprint;

    %window rusure1
        #1  @20 "Welcome!"
        #3  @20 "You are about to submit a program."
        //  @20 "Hit ENTER to continue.";
    %display rusure1 delete;

    %let rusure=;

    %window rusure2
        //  @20 "Are you sure you would like to submit the program?"
        //  @20 rusure 1 attr=rev_video required=yes
        //  @20 "Enter Y for Yes or N for No, then hit ENTER to continue.";
    %display rusure2 delete;

    %let rusure=;

    %window rusure3
        //  @20 "You're absolutely certain about your decision?"
        //  @20 rusure 1 attr=rev_video required=yes
        //  @20 "Enter Y for Yes or N for No, then hit ENTER to continue.";
    %display rusure3 delete;

    %let rusure=;

    %window rusure4
        //  @20 "I couldn't convince you otherwise?"
        //  @20 rusure 1 attr=rev_video required=yes
        //  @20 "Enter Y for Yes or N for No, then hit ENTER to continue.";
    %display rusure4 delete;

    %let rusure=;

    %window rusure5
        //  @20 "Wouldn't you rather run a different program?"
        //  @20 rusure 1 attr=rev_video required=yes
        //  @20 "Enter Y for Yes or N for No, then hit ENTER to continue.";
    %display rusure5 delete;

    %let rusure=;

    %window rusure6
        //  @20 "For example, the following program is a very nice program:"
         /  @20 "'S:\SAS\SASFoundation\9.2\sastest\sasiq.sas'"
        //  @20 "Hit ENTER to continue.";
    %display rusure6 delete;

    %let rusure=;

    %window rusure7
        //  @20 "What's wrong with that program? Do you have a problem with it?"
        //  @20 rusure 1 attr=rev_video required=yes
        //  @20 "Enter Y for Yes or N for No, then hit ENTER to continue.";
    %display rusure7 delete;

    %let rusure=;

    %window rusure8
        //  @20 "Fine! If you want to run your program then go ahead."
        //  @20 "Hit ENTER to continue."
       ///  @20 "See if I care. I'm just a computer. Nobody cares about MY needs. [Sobs]";
    %display rusure8 delete;

    options &user_mprint;

%mend RUSure;
