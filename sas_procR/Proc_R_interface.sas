%include "C:\test\Proc_R.sas";      **configure base SAS for R analysis        ***;
%Proc_R ( SAS2R=, R2SAS= );    ***execution of the first part of %Proc_R  ***;
Cards4;                        **Mark for the start of customized R script***;

******************************
***Please Enter R Code Here***
******************************

;;;;                           **Mark for the end of customized R script ***;
%Quit;                         **execution of the rest of %Proc_R        ***;
