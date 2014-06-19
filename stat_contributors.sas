%let name=%nrstr(Alan Agresti, University of Florida; Paul Allison, University of Pennsylvania; Douglas Bates, University of Wisconsin; John Barnard Jr., Cleveland Clinic Foundation; David Binder (deceased), formerly of David Binder Research; Suzette Blanchard, Frontier Science Technology Research Foundation; Mary Butler Moore, formerly of University of Florida at Gainesville; Wilbert P. Byrd, Clemson University; Vincent Carey, Harvard University; Sally Carson, RAND; Love Casanova, CSC-FSG; Helene Cavior, Abacus Concepts; Rao Chaganty, Old Dominion University; George Chao, DuPont Merek Pharmaceutical Company; Colin Chen, Fannie Mae; Daniel M. Chilko, West Virginia University; Marc Cohen, Fair Isaac Corporation; Jan de Leeuw, University of California, Los Angeles; Dave DeLong, Duke University; Alex Dmitrienko, Eli Lilly; Sandra Donaghy, North Carolina State University; David B. Duncan, Johns Hopkins University; Paul Eilers, Leiden University; Scott Emerson, University of Washington; Michael Farrell, Oak Ridge National Laboratory; Stewart Fossceco, SLF Consulting; Michael Friendly, York University; Rudolf J. Freund, Texas A&M University; Wayne Fuller, Iowa State University; Andrzej Galecki, University of Michigan; A. Ronald Gallant, Duke University; Joseph Gardiner, Michigan State University; Charles Gates, Texas A&M University; Thomas M. Gerig, North Carolina State University; Francis Giesbrecht, North Carolina State University; Harvey J. Gold, North Carolina State University; Kenneth Goldberg, Centocor Inc; Robert J. Gray, Harvard University; Donald Guthrie, University of California, Los Angeles; Gerald Hajian, Schering Plough Research Institute; Bob Hamer, University of North Carolina at Chapel Hill; Frank E. Harrell Jr., Vanderbilt University; Wolfgang M. Hartmann; Walter Harvey, Ohio State University; Douglas Hawkins, University of Minnesota; Xuming He, University of Illinois at Urbana-Champaign; Ronald W. Helms, Rho, Inc.; Joseph Hilbe, Arizona State University; Gerry Hobbs, West Virginia University; Ronald R. Hocking, Texas A & M University; Nick Horton, Smith College; Julian Horwich, Camp Conference Company; Jason C. Hsu, Ohio State University; David Hurst, University of Alabama at Birmingham; Joseph G. Ibrahim, University of North Carolina at Chapel Hill; Emilio A. Icaza, Louisiana State University; Jun Jie, Purdue University; Joerg Kaufman, Bayer Schering Pharma AG; William Kennedy, Iowa State University; Gary Koch, University of North Carolina at Chapel Hill; Roger Koenker, University of Illinois at Urbana-Champaign; Alexander Kolovos, SpaceTimeWorks LLC; Kenneth L. Koonce, Louisiana State University; Rich La Valley, Strategic Technology Solutions; Russell V. Lenth, University of Iowa; Charles Lin, U.S. Census Bureau; Danyu Lin, University of North Carolina; Ardell C. Linnerud, North Carolina State University; Ramon C. Littel, University of Florida; George MacKenzie, University of Oregon; Brian Marx, Louisiana State University; J. Jack McArdle, University of Southern California; Roderick P. McDonald, Macquarie University; Alfio Marazzi, University of Lausanne; J. Philip Miller, Washington University Medical School; George Milliken, Kansas State University; Robert J. Monroe, North Carolina State University; Robert D. Morrison, Oklahoma State University; Keith Muller, University of Florida; Anupama Narayanan, Procter & Gamble Co; Meltem Narter; Ralph G. O’Brien, Cleveland Clinic Foundation; Kenneth Offord, Mayo Clinic; Christopher R. Olinger, d-Wise Technologies; Christopher J. Paciorek, Harvard University; Robert Parks, Washington University; Richard M. Patterson, Auburn University; Virginia Patterson, University of Tennessee; Cliff Pereira, Oregon State University; Hans-Peter Piepho, Universität Hohenheim; Edward Pollak, Iowa State University; Stephen Portnoy, University of Illinois; John Preisser, University of North Carolina at Chapel Hill; C. H. Proctor, North Carolina State University; Bahjat Qaqish, University of North Carolina at Chapel Hill; Dana Quade, University of North Carolina at Chapel Hill; Bill Raynor, Kimberly Clark; Georgia Roberts, Statistics Canada; James Roger, GlaxoSmithKline (retired); Peter Rousseeuw, University of Antwerp; Donald Rubin, Harvard University; Joseph L. Schafer, Pennsylvania State University; Robert Schechter, AstraZeneca; Shayle Searle, Cornell University; Pat Hermes Smith, formerly of Ciba-Geigy; Roger Smith, formerly of USDA; Phil Spector, University of California, Berkeley; Michael Speed, Texas A&M University at College Station; William Stanish, Statistical Insight; Rodney Strand, Orion Enterprises, LLC; Walter Stroup, University of Nebraska; Robert Teichman, ICI Americas Inc.; Terry M. Therneau, Mayo Clinic; Edward Vonesh, Northwestern University; Grace Wahba, University of Wisconsin at Madison; Glenn Ware, University of Georgia; Peter H. Westfall, Texas Tech University; Edward W. Whitehorne, CI Partners, LLC; William Wigton, USDA; William Wilson, University of North Florida; Philip Whittall, Unilever (retired); Dong Xiang; Victor Yohai, University of Buenos Aires; Forrest W. Young (deceased), formerly of University of North Carolina at Chapel Hill; Ke-Hai Yuan, University of Notre Dame; Ruben Zamar, University of British Columbia; Scott Zeger, Johns Hopkins University );

%put &name;


%macro words(str,delim=%str( ));
  %local i;
  %let i=1;
  %do %while(%length(%qscan(&str,&i,&delim)) GT 0);
    %let i=%eval(&i + 1);
  %end;
%eval(&i - 1)
%mend words;


%let num_tokens= %words(%NRQUOTE(&name), delim=%str(;));
%put &num_tokens;

%macro doit(delim=%str(;));
data a;
	length a $100.;
	%do i=1 %to &num_tokens;
		a="%qscan(%SUPERQ(name),&i,&delim)";
		output;
	%end;
run;	
%mend;
%doit;


data b;
	set a;
	name=scan(a,1,",");
	institute=substr(a,length(name)+2);
	drop a;
run;


