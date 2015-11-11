/*<pre><b>
/ Program   : fixnames.sas
/ Version   : 1.0
/ Author    : Roland Rashleigh-Berry
/ Date      : 04-May-2011
/ Purpose   : In-datastep macro to fix UTF-8 characters in a person's name by
/             converting the UTF-8 character pairs back to ascii.
/ SubMacros : none
/ Notes     : This is only intended to work on people's names and is only
/             intended for the spelling of European and Scandinavian names. It
/             should also work for South American names. You should use it when
/             you have received data from a UTF-8 system and you are working on
/             an ascii system and you notice that one or more dataset variables
/             contain corruptions to peoples names due to UTF-8 characters. This
/             macro is used in a data step to convert these UTF-8 character
/             pairs back into a single ascii character. This is a problem
/             sometimes encountered with investigator names for multinational,
/             multi-centre clinical trials. You should be warned that if a
/             genuine name contains a capital "A" topped with a tilde then this
/             macro will likely corrupt that name.
/ Usage     : data newpatinfo;
/               set patinfo;
/               %fixnames(invname)
/             run;
/===============================================================================
/ PARAMETERS:
/-------name------- -------------------------description------------------------
/ namevar           (pos) Name of the variable containing possibly corrupted
/                   names.
/===============================================================================
/ AMENDMENT HISTORY:
/ init --date-- mod-id ----------------------description------------------------
/ rrb  04May11         Code tidy
/===============================================================================
/ This is public domain software. No guarantee as to suitability or accuracy is
/ given or implied. User uses this code entirely at their own risk.
/=============================================================================*/

%put MACRO CALLED: fixnames v1.0;

%macro fixnames(namevar);
  &namevar=tranwrd(&namevar,"C380"x,"C0"x); *- large a grave -;
  &namevar=tranwrd(&namevar,"C381"x,"C1"x); *- large a acute -;
  &namevar=tranwrd(&namevar,"C382"x,"C2"x); *- large a circumflex -;
  &namevar=tranwrd(&namevar,"C383"x,"C3"x); *- large a tilde -;
  &namevar=tranwrd(&namevar,"C384"x,"C4"x); *- large a diaeresis -;
  &namevar=tranwrd(&namevar,"C385"x,"C5"x); *- large a ring -;
  &namevar=tranwrd(&namevar,"C386"x,"C6"x); *- large ae -;
  &namevar=tranwrd(&namevar,"C387"x,"C7"x); *- large c cedilla -;
  &namevar=tranwrd(&namevar,"C388"x,"C8"x); *- large e grave -;
  &namevar=tranwrd(&namevar,"C389"x,"C9"x); *- large e acute -;
  &namevar=tranwrd(&namevar,"C38A"x,"CA"x); *- large e circumflex -;
  &namevar=tranwrd(&namevar,"C38B"x,"CB"x); *- large e diaeresis -;
  &namevar=tranwrd(&namevar,"C38C"x,"CC"x); *- large i grave -;
  &namevar=tranwrd(&namevar,"C38D"x,"CD"x); *- large i acute -;
  &namevar=tranwrd(&namevar,"C38E"x,"CE"x); *- large i circumflex -;
  &namevar=tranwrd(&namevar,"C38F"x,"CF"x); *- large i diaeresis -;
  &namevar=tranwrd(&namevar,"C390"x,"D0"x); *- large eth -;
  &namevar=tranwrd(&namevar,"C391"x,"D1"x); *- large n tilde -;
  &namevar=tranwrd(&namevar,"C392"x,"D2"x); *- large o grave -;
  &namevar=tranwrd(&namevar,"C393"x,"D3"x); *- large o acute -;
  &namevar=tranwrd(&namevar,"C394"x,"D4"x); *- large o circumflex -;
  &namevar=tranwrd(&namevar,"C395"x,"D5"x); *- large o tilde -;
  &namevar=tranwrd(&namevar,"C396"x,"D6"x); *- large o diaeresis -;
  &namevar=tranwrd(&namevar,"C398"x,"D8"x); *- large o stroke -;
  &namevar=tranwrd(&namevar,"C399"x,"D9"x); *- large u grave -;
  &namevar=tranwrd(&namevar,"C39A"x,"DA"x); *- large u acute -;
  &namevar=tranwrd(&namevar,"C39B"x,"DB"x); *- large u circumflex -;
  &namevar=tranwrd(&namevar,"C39C"x,"DC"x); *- large u diaeresis -;
  &namevar=tranwrd(&namevar,"C39D"x,"DD"x); *- large y acute -;
  &namevar=tranwrd(&namevar,"C39E"x,"DE"x); *- large thorn -;
  &namevar=tranwrd(&namevar,"C39F"x,"DF"x); *- sharp s -;
  &namevar=tranwrd(&namevar,"C3A1"x,"E1"x); *- small a acute -;
  &namevar=tranwrd(&namevar,"C3A2"x,"E2"x); *- small a circumflex -;
  &namevar=tranwrd(&namevar,"C3A3"x,"E3"x); *- small a tilde -;
  &namevar=tranwrd(&namevar,"C3A4"x,"E4"x); *- small a diaeresis -;
  &namevar=tranwrd(&namevar,"C3A5"x,"E5"x); *- small a ring -;
  &namevar=tranwrd(&namevar,"C3A6"x,"E6"x); *- small ae -;
  &namevar=tranwrd(&namevar,"C3A7"x,"E7"x); *- small c cedilla -;
  &namevar=tranwrd(&namevar,"C3A8"x,"E8"x); *- small e grave -;
  &namevar=tranwrd(&namevar,"C3A9"x,"E9"x); *- small e acute -;
  &namevar=tranwrd(&namevar,"C3AA"x,"EA"x); *- small e circumflex -;
  &namevar=tranwrd(&namevar,"C3AB"x,"EB"x); *- small e diaeresis -;
  &namevar=tranwrd(&namevar,"C3AC"x,"EC"x); *- small i grave -;
  &namevar=tranwrd(&namevar,"C3AD"x,"ED"x); *- small i acute -;
  &namevar=tranwrd(&namevar,"C3AE"x,"EE"x); *- small i circumflex -;
  &namevar=tranwrd(&namevar,"C3AF"x,"EF"x); *- small i diaeresis -;
  &namevar=tranwrd(&namevar,"C3B0"x,"F0"x); *- small eth -;
  &namevar=tranwrd(&namevar,"C3B1"x,"F1"x); *- small n tilde -;
  &namevar=tranwrd(&namevar,"C3B2"x,"F2"x); *- small o grave -;
  &namevar=tranwrd(&namevar,"C3B3"x,"F3"x); *- small o acute -;
  &namevar=tranwrd(&namevar,"C3B4"x,"F4"x); *- small o circumflex -;
  &namevar=tranwrd(&namevar,"C3B5"x,"F5"x); *- small o tilde -;
  &namevar=tranwrd(&namevar,"C3B6"x,"F6"x); *- small o diaeresis -;
  &namevar=tranwrd(&namevar,"C3B8"x,"F8"x); *- small o stroke -;
  &namevar=tranwrd(&namevar,"C3B9"x,"F9"x); *- small u grave -;
  &namevar=tranwrd(&namevar,"C3BA"x,"FA"x); *- small u acute -;
  &namevar=tranwrd(&namevar,"C3BB"x,"FB"x); *- small u circumflex -;
  &namevar=tranwrd(&namevar,"C3BC"x,"FC"x); *- small u diaeresis -;
  &namevar=tranwrd(&namevar,"C3BD"x,"FD"x); *- small y acute -;
  &namevar=tranwrd(&namevar,"C3BE"x,"FE"x); *- small thorn -;
  &namevar=tranwrd(&namevar,"C3BF"x,"FF"x); *- small y diaeresis -;
%mend fixnames;
