/*<pre><b>
/ Program name   : test(progname.sas)
/ Program tested : (progname.sas)
/ Program version tested : v1.0
/ Template design date : 16-Aug-2007 (do not change this date)
/========================== TRIPLE TEST PACK VALIDATION ========================
/ Notes : This test pack is for testing the functionality of the program stated
/         above with a view to providing documented evidence that it works
/         correctly according to its stated purpose within the scope of its
/         intended use. This sort of testing is aimed at simple programs.
/         Testers are encouraged to use the (EQual, Not Equal) macros %eqnemac
/         (for macro value testing) and %eqnevar (for variable value testing)
/         when testing an expected result against an actual result so that a
/         clear and consistent message is written to the log if two items are
/         equal or not equal. Avoid deliberate "not equal" situations as this
/         could be interpreted as a program malfunction. You should ensure that
/         the sasautos=() statement at the start of the code explicitly points
/         to the macro library whose macros are being tested with no other macro
/         libraries assigned to the sasautos declaration.
/============================ Program author testing ===========================
/ Program author :
/ SAS version used for testing :
/ Notes in this section read : No
/ All parameters tested : No
/ All tests working OK : No
/ Author validation date : dd-mmm-yyyy
/ Notes : For macros, all parameters must be used at least once in the supplied
/         tests unless they are numbered parameters doing the same thing
/         (e.g. target1-target30) in which case the first two only need be used.
/         You do not have to test parameters that are for debugging purposes.
/         A validation date entered indicates that the validation in this
/         section is complete. This should only be filled in if the testing is
/         complete, all other fields in this section entered and there are no
/         "No" answers in this section.
/======================== Independent programmer testing =======================
/ Tester :
/ SAS version used for testing :
/ Program version tested : v1.0
/ Notes in this section read : No
/ Purpose clearly stated in program header : No
/ Author tests reflect stated program purpose : No
/ All parameters (if any) documented in program header : No
/ Author has tested all parameters (if any) : No
/ Author tests OK : No
/ Extra tests added : 1
/ Extra tests working OK : No
/ Tester validation date : dd-mmm-yyyy
/ Notes : At least one test must be added in this section. Try to think of 
/         something the author might have missed in their testing or some tricky
/         case still within the expected bounds of the parameter values. If a
/         program header is not available then questions related to it are
/         assumed to apply to the author-supplied documentation for the program
/         being tested. You should check that all parameters are at least
/         briefly described in the header or lacking that, the documentation,
/         although it is OK for the programmer to describe blocks of parameters
/         together such as numbered parameters (e.g. parm1-parm9). You should
/         check that the author has used all the documented parameters in their
/         test although the author only has to use the first two of a block
/         of paramters (e.g. parm1-parm9 needs only parm1 and parm2 tested).
/         Parameters there for debugging purposes do not need to be tested.
/         A validation date entered indicates that the validation in this
/         section is complete. This should only be filled in if the testing is
/         complete, all other fields in this section entered and there are no
/         "No" answers in this section.
/========================== User acceptance checking ===========================
/ Checker :
/ SAS version used for checking :
/ Notes in this section read : No
/ Programmer tests OK : No
/ Independent programmer tests OK : No
/ Extra tests added : 0
/ Extra tests working : N/A
/ Author documentation reviewed for stated program limitations : No
/ Program suitable for use : No
/ User validation date : dd-mmm-yyyy
/ Notes : You do not have to add extra tests in this section, unless your
/         in-house SOPs say otherwise, but you should rerun this code and review
/         the programmer tests and the independent programmer tests. The effort
/         put into checking the tests will likely be governed by your in-house
/         SOPs which might allow for a mere cursory check of this. You should
/         check that the way in which the macro will be used at your site is
/         reflected in the testing done and if not, add your own tests. Even if
/         all tests are OK you have to indicate whether the program is suitable
/         for use in the way it is intended to be used at your site. If there
/         are limitations to the way the program should be used that you are
/         aware of and the usage at your site might exceed these limitations
/         then this needs to be documented and passed on to the end users if it
/         is decided that the program is still fit for the purpose.
/         The most important thing in this section is deciding whether the
/         program is suitable for use at your site by the expected end users.
/         A validation date entered indicates that the validation in this
/         section is complete. This should only be filled in if the checking is
/         complete, all other fields in this section entered and there are no
/         "No" answers in this section. This test pack and the resulting sas log
/         should be stored in a safe place with read-only permissions as proof
/         of checking done.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ 
/=============================================================================*/

*- sasautos should point to the macro library under test and no others -;
options sasautos=("explicit-path-name-of-macro-library");


************************* program author testing start ************************;

************************** program author testing end *************************;


********************* independent programmer testing start ********************;

********************** independent programmer testing end *********************;


******************* (optional) user acceptance testing start ******************;

******************** (optional) user acceptance testing end *******************;


***************************** END OF TEST PROGRAM *****************************;
