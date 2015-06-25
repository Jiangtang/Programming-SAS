Instruction for code testing (Note: The author performs the test with SAS9.1.3/R.2.11 and SAS 9.2.3/R.2.14):

Before testing any example code, Proc_R.sas program needs to be copied under C:\test or other directory where users have write access.

If you run SAS 9.1 or above on Windows 7 or Vista, follow SAS 9.2_9.3_Win7_Vista_workaround file to create a modified SAS shortcut on desktop. 
Initiate SAS interactive mode by double-clicking the shortcut. 

test for example 1: .open example1.sas with SAS program editor.
                    .replace the path (C:\test) to %proc_r source code with user specific path if it is different from c:\test
                    .submit the SAS code (F3)

test for example 2: .open example2.sas with SAS program editor.
                    .replace the path (C:\test) to %proc_r source code with user specific path if it is different from c:\test
                    .submit the SAS code (F3)

test for example 3: 
           . install caTools package on R (http://CRAN.R-project.org/package=caTools)
           . make sure the R code embeded in SAS code can run without error in a regular R GUI.
           . open example3.sas with SAS program editor
           . replace the path (C:\test) to %proc_r source code with user specific path if it is different from c:\test
           . submit the SAS code (F3)
                 

test for example 4: 
           . install IDPmisc package on R (http://CRAN.R-project.org/package=IDPmisc)
           . install SwissAir package on R (http://CRAN.R-project.org/package=SwissAir) 
           . make sure R code embeded in SAS code can run without error in a regular R GUI.
           . open example4.sas with SAS program editor 
           . replace the path (C:\test) to %proc_r source code with user specific path if it is different from c:\test
           . submit the SAS code (F3)

test for your own R script:
           .open the proc_R_interface.sas file
           .Install any required R packages under the R version which will be called in %proc_r macro. 
          . make sure R code to be embeded in SAS code can run without error in a regular R GUI.
           .enter your own R script
           .submit SAS code (F3)
                 
