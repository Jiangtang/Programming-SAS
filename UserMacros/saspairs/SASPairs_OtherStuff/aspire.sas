data spothstf.aspire(type=corr);
	infile "&infilename";
	length _type_ _name_ $4;
	input relative1 relative2 _type_ _name_ riq rpa rses roa rea fiq fpa fses foa fea;
    label riq='Respondent: Intelligence'
          rpa='Respondent: Parental Aspiration'
          rses='Respondent: Family SES'
          roa='Respondent: Occupational Aspiration'
          rea='Respondent: Educational Aspiration'
          fiq='Friend: Intelligence'
          fpa='Friend: Parental Aspiration'
          fses='Friend: Family SES'
          foa='Friend: Occupational Aspiration'
          fea='Friend: Educational Aspiration';
run;
