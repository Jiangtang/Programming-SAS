
/*http://www.sas.com/industry/government/fda/index.html

http://www.sas.com/industry/government/fda/macro.html

This is a set of SAS macros that converts a directory of transport files 
to a directory of SAS data sets and format catalogs (and vice versa). 
To see how to invoke the macros, look at the test following the last macro. 
The macros make the assumption that transport files created 
from data sets have the extension .xpt, and transport files created 
from format catalogs have the extension .xpf.


%fromexp: from xpt to sas7bcat (dirdelim, getnames, impfmts, impdset )
%toexp: from sas7bcat to xpt   (dirdelim,           expfmts, expdset)


expfmts
expdset

impfmts
impdset

getnames
dirdelim


*/



/*----------------------------------------------------------------*/
/* This macro will convert an existing format catalog into a      */
/* CNTLOUT= data set in transport format. The parameters are:     */
/*                                                                */
/* %expfmts(fmtlib,outfile);                                      */
/*                                                                */
/* where                                                          */
/*                                                                */
/* fmtlib                Name of format catalog. If only one      */
/*                       level is given, it is assumed that this  */
/*                       is a libref and the catalog name is      */
/*                       FORMATS.                                 */
/* outfile               Filename that will contain the transport */
/*                       file.                                    */
/*                                                                */
/* Note that the macro will first create a temporary CNTLOUT=     */
/* data set, then examine it for variables that are not necessary */
/* for the final transport file. This is done to reduce the size  */
/* of the transport file.                                         */
/*----------------------------------------------------------------*/

%macro expfmts(fmtlib,outfile);

*-----first create the CNTLOUT= data set from the catalog------------*;
proc format library=&fmtlib cntlout=work.temp;
run;

*-----determine variables not needed for the final transport file----*;
data _null_; set temp end=eof;
	nend+(end^=start);                 * START/END must be different ;
	nfuzz+(fuzz^=1e-12 and fuzz^=.);   * FUZZ must be non-default    ;

	if type='P' then do;               * For PICTURE formats:        ;
	     nprefix+(prefix^=' ');          *   nonblank prefix           ;
	     nmult+(mult^=.);                *   multiplier specified      ;
	     nfill+(fill^=' ');              *   nonblank fill             ;
	     nnoedit+(noedit=1);             *   NOEDIT specified          ;
	end;

	nsexcl+(sexcl='Y');                * start exclusion specified   ;
	neexcl+(eexcl='Y');                * end exclusion specified     ;
	nhlo+(hlo^=' ');                   * high/low/other etc. specd   ;
	if eof;

	length todrop $200;

	*-----build a DROP= option for all pertinent variables----------*;
	if ^nend        then todrop=trim(todrop)||' '||'END';
	if ^nfuzz       then todrop=trim(todrop)||' '||'FUZZ';
	if ^nprefix     then todrop=trim(todrop)||' '||'PREFIX';
	if ^nmult       then todrop=trim(todrop)||' '||'MULT';
	if ^nfill       then todrop=trim(todrop)||' '||'FILL';
	if ^nnoedit     then todrop=trim(todrop)||' '||'NOEDIT';
	if ^nsexcl      then todrop=trim(todrop)||' '||'SEXCL';
	if ^neexcl      then todrop=trim(todrop)||' '||'EEXCL';
	if ^nhlo        then todrop=trim(todrop)||' '||'HLO';
	if todrop^=' '	then todrop='DROP='||todrop;

	*-----emit the requested DROP= option---------------------------*;
	call symput('dropopt',trim(todrop));
run;

*-----provide a LIBNAME statement for the specified file-------------*;
libname yyy xport "&outfile.";

*-----create the transport file, dropping appropriate variables------*;
data yyy.formats; 
	set temp(&dropopt.);
run;

*-----clear the libref now that the file is written------------------*;
libname yyy clear;

*-----ensure the temporary data set is deleted-----------------------*;
proc datasets dd=work; 
	delete temp; 
quit;

%mend expfmts;

/*----------------------------------------------------------------*/
/* This macro will convert an existing SAS data set into a        */
/* transport file. The parameters are:                            */
/*                                                                */
/* %expdset(dataset,outfile);                                     */
/*                                                                */
/* where                                                          */
/*                                                                */
/* dataset               Name of SAS data set (one- or two-level) */
/* outfile               Filename that will contain the transport */
/*                       file.                                    */
/*----------------------------------------------------------------*/

%macro expdset(dataset,outfile);
libname yyy xport "&outfile.";

data _null_;
      i=index("&dataset.",'.')+1;
      memname=scan(substr("&dataset.",i),1,' .');
      call execute('data yyy.'||memname||"; set &dataset.; run;");
run;

libname yyy clear;
%mend expdset;

/*----------------------------------------------------------------*/
/* This macro will convert a transport CNTLOUT data set into      */
/* a native format catalog. The parameters are:                   */
/*                                                                */
/* %impfmts(xpffile);                                             */
/*                                                                */
/* where                                                          */
/*                                                                */
/* xpffile               Name of transport CNTLOUT data set       */
/*                                                                */
/* The macro will create the formats in LIBRARY.FORMATS. It       */
/* assumes that the libref LIBRARY has already been defined.      */
/*----------------------------------------------------------------*/

%macro impfmts(xpffile);
libname xxx xport "&xpffile.";

proc format library=library.formats cntlin=xxx.formats;
run;

libname xxx clear;
%mend impfmts;

/*----------------------------------------------------------------*/
/* This macro will convert a transport data set into a native SAS */
/* data set. The parameters are:                                  */
/*                                                                */
/* %impdset(xptfile);                                             */
/*                                                                */
/* where                                                          */
/*                                                                */
/* xptfile               Name of transport data set               */
/*                                                                */
/* The macro will create the native SAS data set in the directory */
/* defined by the libref LIBRARY, which it assumes has already    */
/* been defined.                                                  */
/*----------------------------------------------------------------*/

%macro impdset(xptfile);
libname xxx xport "&xptfile.";

proc copy in=xxx out=library;
run;

libname xxx clear;

%mend impdset;

/*----------------------------------------------------------------*/
/* This macro will create a SAS data set consisting of a variable */
/* called FILENAME. There will be one observation for each file   */
/* in the specified directory with the specified extension. The   */
/* parameters are:                                                */
/*                                                                */
/* %getnames(dataset,directry,extensn);                           */
/*                                                                */
/* where                                                          */
/*                                                                */
/* dataset               Name of SAS data set to create           */
/* directry              Directory to find files                  */
/* extensn               Specified extension to look for          */
/*                                                                */
/*----------------------------------------------------------------*/

%macro getnames(dataset,directry,extensn);
filename xxx pipe "&dircmd. &directry.&delim.*.&extensn.";

data &dataset.;
  infile xxx length=l;
  length filename $200;
  input @;
  input @1 filename $varying200. l;
  if index(filename,"&delim.")=0
     then filename="&directry.&delim."||filename;
  keep filename;
run;

filename xxx clear;
%mend getnames;

/*----------------------------------------------------------------*/
/* This macro will determine the proper directory command and     */
/* delimiter. For UNIX, the command is ls -1, and the delimiter   */
/* is a forward slash. For PC, the command is dir/b, and the      */
/* delimiter is a backslash.                                      */
/*----------------------------------------------------------------*/

%macro dirdelim;
%global dircmd delim;

data _null_;
  *-----determine if we are on UNIX-----*;
  unix = "&sysscp" in ('RS6000  ', /* AIX */
               'SUN 4   ', /* Solaris I and II */
               'HP 800  ', /* HP-UX */
               'DEVHOST ', /* SAS Institute Internal */
               'ALXOSF  ', /* Digital UNIX */
               '386 ABI ', /* Intel ABI */
               'MIPS ABI'  /* MIPS ABI */
              );

  *-----determine if we are on a PC-----*;
  PCX = "&sysscp" in ('OS2','WIN','WIN_NTSV');

  *-----if on UNIX, use ls -1 and forward slash delimiter-----*;
  if unix then do;
     dircmd='ls -1';
     delim='/';
     end;

  *-----if on PC, use DIR/B and backslash delimiter-----*;
  else if pcx then do;
     dircmd='DIR/B';
     delim='\';
     end;

  *-----otherwise not supported-----*;
  else do;
     abort abend 999;
     end;

  *-----save macro variables for command and delimiter-----*;
  call symput('dircmd',trim(dircmd));
  call symput('delim',delim);
run;

%mend dirdelim;

/*----------------------------------------------------------------*/
/* This macro will create native SAS data sets in the specified   */
/* directory, using transport files from another directory. The   */
/* transport files include those with .xpf extensions and .xpt    */
/* extensions. .xpf files are transport versions of CNTLOUT= data */
/* sets from PROC FORMAT. These will be read into PROC FORMAT via */
/* the CNTLIN= option. The .xpt files are regular transport data  */
/* sets that may refer to formats in the .xpf files. Therefore, we*/
/* use the LIBRARY libref and use LIBRARY.FORMATS as the format   */
/* catalog to ensure that the catalog is searched. (The FMTSEARCH=*/
/* option, by default, references LIBRARY.FORMATS as a catalog to */
/* search in). The parameters are:                                */
/*                                                                */
/* %fromexp(indir,outdir);                                        */
/*                                                                */
/* where                                                          */
/*                                                                */
/* indir                 directory containing transport files     */
/* outdir                directory to contain SAS data sets       */
/*----------------------------------------------------------------*/

%macro fromexp(indir,outdir);

%dirdelim;

*-----establish LIBRARY libref for output directory-----*;
libname library "&outdir.";

*-----obtain the names of the transport files for data sets-----*;
%getnames(xptfiles,&indir,xpt);

*-----obtain the names of the transport files for formats-----*;
%getnames(formats,&indir,xpf);

*-----invoke the %impfmts macro for each format transport file-----*;
data _null_; set formats;
  call execute('%impfmts('||trim(filename)||');');
run;

*-----invoke the %impdset macro for each data set transport file---*;
data _null_; set xptfiles;
  call execute('%impdset('||trim(filename)||');');
run;

*-----clear LIBRARY libref now that we are done-----*;
libname library clear;
%mend fromexp;

/*----------------------------------------------------------------*/
/* This macro will create transport files in the specified        */
/* directory, using native SAS data sets from another directory.  */
/* Regular SAS data sets will be converted to transport files     */
/* with the .xpt extension, and format catalogs will be converted */
/* to transport data set representations of their corresponding   */
/* CNTLOUT= data sets, using the .xpf extension.                  */
/*                                                                */
/* %fromexp(indir,outdir);                                        */
/*                                                                */
/* where                                                          */
/*                                                                */
/* indir                 directory containing SAS data sets       */
/*                         and format catalogs                    */
/* outdir                directory to contain transport files     */
/*----------------------------------------------------------------*/

%macro toexp(indir,outdir);

*-----use dictionary.members to get all member names---------------*;
libname library "&indir.";
proc sql;
	create table names as
	 select memname, memtype
	 from   dictionary.members
	 where  libname = 'LIBRARY';
quit;

%dirdelim;

*-----generate %expfmts or %expdset calls for proper members-------*;
data _null_; set names;
  if memtype='CATALOG' then do;
     macro='%expfmts';
     ext='xpf';
     end;
  else do;
     macro='%expdset';
     ext='xpt';
     end;
  call execute(macro||'(LIBRARY.'||trim(memname)||','||
       "&outdir.&delim."||trim(memname)||'.'||ext||');');
run;

*-----delete WORK.NAMES now that we are done-----------------------*;
proc datasets dd=work; 
	delete names; 
quit;

*-----clear the libref now that we are done------------------------*;
libname library clear;

%mend toexp;

*==================END OF MACRO SET================================*;

/*test

%toexp(A:\test\sas7bcat,A:\test\xpt)

%fromexp(A:\test\xpt,A:\test\sas7bcat)

test end*/
