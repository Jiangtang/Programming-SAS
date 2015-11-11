* --- IML code to create SASPairs definitions for phenotypic causality models with or 
      without latent variables;
PROC IML;

	* ---------------------------------------------------------------------------------
	* --- Modules;	
	START GetPattern (nmatrix, name, type, card);
		* --- get the pattern matrix;
		thisrow = concat('   PA ', name);
		Card = Card // thisrow;
		do i=1 to nrow(nmatrix);
			thisrow='   ';
			if type='U' then jend = ncol(nmatrix);
			else jend = i;
			do j=1 to jend;
				if nmatrix[i,j] = 0 then thisrow = concat(thisrow, ' 0');
				else thisrow = concat(thisrow, ' 1');
			end;
			card = card // thisrow;
		end;
	FINISH;

	START LambdaIt (Fixed, LamValue, Card);
		* --- pattern and MA for lambda matrix;
		thiscard = '   PA Lambda'; Card = Card // thiscard;
		do i=1 to nrow(fixed);
			thischr = trim(left(char(fixed[i])));
			thiscard = concat('    ', thischr); Card = Card // thiscard;
		end;
		thiscard = '   MA Lambda'; Card = Card // thiscard;
		do i=1 to nrow(fixed);
			thischr = trim(left(char(LamValue[i])));
			thiscard = concat('    ', thischr); Card = Card // thiscard;
		end;
	FINISH;

	* ---------------------------------------------------------------------------------
	* --- Baseline1: Vp = same for all relatives, relative covs all free;
	START matrices1 (Card, RelCov);
		thiscard = '   VP S &np'; Card = Card // thiscard; 
		thiscard = '   FU L'; Card = Card // thiscard; 
		do i=1 to nrow(RelCov);
			thiscard = concat('   ', RelCov[i], ' S &np'); Card = Card // thiscard;
		end;
	FINISH;

	START mx1 (Card);
		thiscard = '   CO FU'; Card = Card // thiscard;
		thiscard = '   FI VP'; Card = Card // thiscard;
	FINISH;

	START IML1 (Card, RelCov, Lambda);
		thiscard = '   if pair_number=1 then do;'; Card = Card // thiscard;
		thiscard = '      VP = FU * t(FU);'; Card = Card // thiscard;
		thiscard = '      P1 = VP;'; Card = Card // thiscard;
		if Lambda=1 then do;
			thiscard = '      temp = diag(P1);'; Card = Card // thisCard;
			thiscard = '      P1 = P1 - temp + temp*INV(Lambda);'; Card = Card // thiscard;
		end;
		thiscard = '      P2 = P1;'; Card = Card // thiscard;
		thiscard = '   end;'; Card = Card // thiscard;
		do i=1 to nrow(RelCov);
			chari = char(i);
			chari = trim(left(chari));
			if i=1 then
				tempcard = concat('   if pair_number=', chari, ' then R12 = ', RelCov[i], ';');
			else 
				tempcard = concat('   else if pair_number=', chari, ' then R12 = ', RelCov[i], ';');
			card = card // tempcard;
		end;
	FINISH;

	* ---------------------------------------------------------------------------------
	* --- Baseline2: P=f(B), free relative covariances;
	START matrices2 (Card, RelCov, NLatChr, NObsChr, NTotChr);
		thiscard = '   SU ';  Card = Card // thiscard;
		thiscard = concat('   VP S ', NTotChr, ' ', NTotChr); Card = Card // thiscard;
		thiscard = concat('   B U ', NTotChr, ' ', NTotChr); Card = Card // thiscard;
		thiscard = concat('   IMBInv U ', NTotChr, ' ', NTotChr); Card = Card // thiscard;
		thiscard = concat('   ResidCov S ', NObsChr, ' ', NobsChr); Card = Card // thiscard;
		if &NlatentP > 0 then do;
			thiscard = concat('   ResCov11 S ', NLatChr, ' ', NLatChr); Card = Card // thiscard;
			thiscard = concat('   ResCov12 U ', NLatChr, ' ', NObsChr); Card = Card // thiscard;
			thiscard = concat('   ResCov21 U ', NObsChr, ' ', NLatChr); Card = Card // thiscard;
			thiscard = concat('   ResCov22 S ', NObsChr, ' ', NObsChr); Card = Card // thiscard;
		end;
		do i=1 to nrow(RelCov);
			thiscard = concat('   ', RelCov[i], ' S ', NObsChr, ' ', NObsChr); Card = Card // thiscard;
		end;
	FINISH;

	START mx2 (Card, B, U);
		thiscard = '   CO SU'; Card = Card // thiscard;
		thiscard = '   FI VP IMBInv ResidCov'; Card = Card // thiscard;
		* --- B matrix: Covs among within-person residuals;
		CALL GetPattern (B, 'B', 'U', Card);
		* --- within-person covariance matrix:
		* --- first make the U matrix symmetric;
		do i=1 to nrow(U);
			do j=i+1 to nrow(U);
				u[i,j] = u[j,i];
			end;
		end;
		* --- now, fix the digonal elements;
		U = U - I(Nrow(U));
		* --- PA command for U;
		if &NLatentP=0 then
			call GetPattern (U, 'ResidCov', 'S', Card);
		else do;
			temp = u[1:&NLatentP, 1:&NLatentP];
			call GetPattern (temp, 'ResCov11', 'S', card);
			thiscard = '   FI 1.0 Diag(ResCov11)';
			card = card // thiscard;
			temp = u[1:&NLatentP, &NLatentP+1 : &NTotalP];
			call GetPattern (temp, 'ResCov12', 'U', card);
			temp = u[&NLatentP+1 : &NTotalP, 1:&NLatentP];
			call GetPattern (temp, 'ResCov21', 'U', card);
			temp = u[&NLatentP+1 : &NTotalP, &NLatentP+1 : &NTotalP];
			call GetPattern (temp, 'ResCov22', 'S', card);
		end;
	FINISH;

	START IML2 (Card, RelCov, NLatChr, NObsChr, NTotChr, NLatP1Chr, Lambda);
		thiscard = '   if pair_number=1 then do;'; Card = Card // thiscard;
		if &NLatentP=0 then
			thiscard = '      ResidCov = SU + ResidCov;';
		else
			thiscard = '      ResidCov = (ResCov11 || ResCov12) // (ResCov21 || (SU + ResCov22));';
		Card = Card // thiscard;
		thiscard = '      IMBInv = INV(I(nrow(B)) - B);'; Card = Card // thiscard;
		if &NlatentP=0 then do;
			thiscard = '      VP = IMBInv * ResidCov * t(IMBInv);'; Card = Card // thiscard;
			thiscard = '      P1 = VP;'; Card = Card // thiscard;
		end;
		else do;
			thiscard = '      VP = IMBInv * ResidCov * t(IMBInv);'; Card = Card // thiscard;
			thiscard = concat('      P1 = VP[', NLatP1Chr, ':',  NTotChr, ', ', NLatP1Chr, ':',  NTotChr, '];');
			Card = Card // thiscard;
		end;
		if Lambda=1 then do;
			thiscard = '      temp = diag(P1);'; Card = Card // thisCard;
			thiscard = '      P1 = P1 - temp + temp*INV(Lambda);'; Card = Card // thiscard;
		end;
		thiscard = '      P2 = P1;'; Card = Card // thiscard;
		thiscard = '   end;'; Card = Card // thiscard;
		do i=1 to nrow(RelCov);
			chari = char(i);
			chari = trim(left(chari));
			if i=1 then
				tempcard = concat('   if pair_number=', chari, ' then R12 = ', RelCov[i], ';');
			else 
				tempcard = concat('   else if pair_number=', chari, ' then R12 = ', RelCov[i], ';');
			card = card // tempcard;
		end;
	FINISH;

	* ---------------------------------------------------------------------------------
	* --- P=f(B), covariances;
	START matrices3 (Card, RelCov, NLatChr, NObsChr, NTotChr);
		thiscard = '   SU ';  Card = Card // thiscard;
		thiscard = concat('   VP S ', NTotChr, ' ', NTotChr); Card = Card // thiscard;
		thiscard = concat('   B U ', NTotChr, ' ', NTotChr); Card = Card // thiscard;
		thiscard = concat('   IMBInv U ', NTotChr, ' ', NTotChr); Card = Card // thiscard;
		thiscard = concat('   ResidCov S ', NObsChr, ' ', NobsChr); Card = Card // thiscard;
		if &NlatentP > 0 then do;
			thiscard = concat('   ResCov11 S ', NLatChr, ' ', NLatChr); Card = Card // thiscard;
			thiscard = concat('   ResCov12 U ', NLatChr, ' ', NObsChr); Card = Card // thiscard;
			thiscard = concat('   ResCov21 U ', NObsChr, ' ', NLatChr); Card = Card // thiscard;
			thiscard = concat('   ResCov22 S ', NObsChr, ' ', NObsChr); Card = Card // thiscard;
		end;
		do i=1 to nrow(RelCov);
			thiscard = concat('   ', RelCov[i], ' S ', NTotChr, ' ', NTotChr); Card = Card // thiscard;
		end;
	FINISH;

	START mx3 (Card, B, U, RelCov);
		CALL mx2 (Card, B, U);
		* --- Covs among relatives residuals;
		U = U + I(nrow(U));
		do i=1 to nrow(RelCov);
			call getPattern (U, RelCov[i], 'S', Card);
		end;
	FINISH;

	START IML3 (Card, RelCov, NLatChr, NObsChr, NTotChr, NLatP1Chr, Lambda);
		thiscard = '   if pair_number=1 then do;'; Card = Card // thiscard;
		if &NLatentP=0 then
			thiscard = '      ResidCov = SU + ResidCov;';
		else
			thiscard = '      ResidCov = (ResCov11 || ResCov12) // (ResCov21 || (SU + ResCov22));';
		Card = Card // thiscard;
		thiscard = '      IMBInv = INV(I(nrow(B)) - B);'; Card = Card // thiscard;
		if &NlatentP=0 then do;
			thiscard = '      VP = IMBInv * ResidCov * t(IMBInv);'; Card = Card // thiscard;
			thiscard = '      P1 = VP;'; Card = Card // thiscard;
		end;
		else do;
			thiscard = '      VP = IMBInv * ResidCov * t(IMBInv);'; Card = Card // thiscard;
			thiscard = concat('      P1 = VP[', NLatP1Chr, ':',  NTotChr, ', ', NLatP1Chr, ':',  NTotChr, '];');
			Card = Card // thiscard;
		end;
		if Lambda=1 then do;
			thiscard = '      temp = diag(P1);'; Card = Card // thisCard;
			thiscard = '      P1 = P1 - temp + temp*INV(Lambda);'; Card = Card // thiscard;
		end;
		thiscard = '      P2 = P1;'; Card = Card // thiscard;
		thiscard = '   end;'; Card = Card // thiscard;
		do i=1 to nrow(RelCov);
			chari = trim(left(char(i)));
			if i=1 then
				tempcard = concat('   if pair_number=', chari, ' then R12 = IMBInv * ', RelCov[i],
					  ' * t(IMBInv);');
			else 
				tempcard = concat('   else if pair_number=', chari, ' then R12 = IMBInv * ', RelCov[i],
					  ' * t(IMBInv);');
			card = card // tempcard;
		end;
		if &NLatentP > 0 then do;
			thiscard = concat('   R12 = R12[', NLatP1Chr, ':',  NTotChr, ', ', NLatP1Chr, ':',  NTotChr, '];');
			card = card // thiscard;
		end;

	FINISH;

	* ---------------------------------------------------------------------------------
	* --- P = f(B): Genetic Parameters;
	START matrices4 (Card, RelCov, NLatChr, NObsChr, NTotChr);
		thiscard = '   SU'; card = card // thiscard;
		thiscard = concat('   VP S ', NTotChr, ' ', NTotChr); Card = Card // thiscard;
		thiscard = concat('   B U ', NTotChr, ' ', NTotChr); Card = Card // thiscard;
		thiscard = concat('   IMBInv U ', NTotChr, ' ', NTotChr); Card = Card // thiscard;
		if &NlatentP=0 then do;
			thiscard = '   VA'; Card = Card // thiscard;
			thiscard = '   VD'; Card = Card // thiscard;
			thiscard = '   VC'; Card = Card // thiscard;
			thiscard = '   VU'; Card = Card // thiscard;
			thiscard = '   ResidCov S &np'; Card = Card // thiscard;
			thiscard = '   VUOffDiag S &np'; Card = Card // thiscard;
		end;
		else do;
			thiscard = concat('   BigVA S ', NtotChr, ' ', NTotChr); Card = Card // thiscard;
			thiscard = concat('   BigVD S ', NtotChr, ' ', NTotChr); Card = Card // thiscard;
			thiscard = concat('   BigVC S ', NtotChr, ' ', NTotChr); Card = Card // thiscard;
			thiscard = concat('   BigVU S ', NtotChr, ' ', NTotChr); Card = Card // thiscard;
			thiscard = concat('   ResidCov S ', NtotChr, ' ', NTotChr); Card = Card // thiscard;
			thiscard = concat('   VU11 S ', NLatChr, ' ', NLatChr); Card = Card // thiscard;
			thiscard = concat('   VU12 U ', NLatChr, ' ', NObsChr); Card = Card // thiscard;
			thiscard = concat('   VU21 U ', NObsChr, ' ', NLatChr); Card = Card // thiscard;
			thiscard = concat('   VU22 S ', NObsChr, ' ', NObsChr); Card = Card // thiscard;
		end;
	FINISH;

	START mx4 (Card, B, U);
		thiscard = '   CO SU'; Card = Card // thiscard;
		* --- B matrix: Covs among within-person residuals;
		CALL GetPattern (B, 'B', 'U', Card);
		* --- within-person covariance matrix:
		* --- first make the U matrix symmetric;
		do i=1 to nrow(U);
			do j=i+1 to nrow(U);
				u[i,j] = u[j,i];
			end;
		end;
		* --- PA command for U;
		if &NLatentP=0 then do;
			if index("&modType", 'VA') > 0 then
				call GetPattern (U, 'VA', 'S', Card);
			else do;
				thiscard = '   FI VA';
				Card = Card // thiscard;
			end;
			if index("&modType", 'VD') > 0 then
				call GetPattern (U, 'VD', 'S', Card);
			else do;
				thiscard = '   FI VD';
				Card = Card // thiscard;
			end;
			if index("&modType", 'VC') > 0 then
				call GetPattern (U, 'VC', 'S', Card);
			else do;
				thiscard = '   FI VC';
				Card = Card // thiscard;
			end;
			call GetPattern (U, 'VUOffDiag', 'S', Card);
			thiscard = '   FI VP IMBInv ResidCov VU Diag(VUOffDiag)'; card = card // thiscard;
		end;
		else do;
			if index("&modtype", 'VA') > 0 then
				call GetPattern (U, 'BigVA', 'S', Card);
			else do;
				thiscard = '   FI BigVA';
				Card = Card // thiscard;
			end;
			if index("&modtype", 'VD') > 0 then
				call GetPattern (U, 'BigVD', 'S', Card);
			else do;
				thiscard = '   FI BigVD';
				Card = Card // thiscard;
			end;
			if index("&modtype", 'VC') > 0 then
				call GetPattern (U, 'BigVC', 'S', Card);
			else do;
				thiscard = '   FI BigVC';
				Card = Card // thiscard;
			end;
			thiscard = '   FI VP IMBInv BigVU ResidCov'; card = card // thiscard;
			U = U - I(nrow(U));
			temp = u[1:&NLatentP, 1:&NLatentP];
			call GetPattern (temp, 'VU11', 'S', card);
			thiscard = '   FI 1.0 Diag(VU11)'; card = card // thiscard;
			temp = u[1:&NLatentP, &NLatentP+1 : &NTotalP];
			call GetPattern (temp, 'VU12', 'U', card);
			temp = u[&NLatentP+1 : &NTotalP, 1:&NLatentP];
			call GetPattern (temp, 'VU21', 'U', card);
			temp = u[&NLatentP+1 : &NTotalP, &NLatentP+1 : &NTotalP];
			call GetPattern (temp, 'VU22', 'S', card);
		end;
	FINISH;

	START IML4 (Card, RelCov, NLatChr, NObsChr, NTotChr, NLatP1Chr, Lambda);
		thiscard = '   if pair_number=1 then do;'; Card = Card // thiscard;
		if &NLatentP=0 then do;
			thiscard = '      IMBInv = INV(I(nrow(B)) - B);'; Card = Card // thiscard;
			thiscard = '      VU = SU + VUOffDiag;'; Card = Card // thiscard;
			thiscard = '      ResidCov = VA + VD + VC + VU;'; Card = Card // thiscard;
			thiscard = '      VP = IMBInv * ResidCov * t(IMBInv);'; Card = Card // thiscard;
			thiscard = '      P1 = VP;'; Card = Card // thiscard;
		end;
		else do;
			thiscard = '      BigVU = (VU11 || VU12) // (VU21 || (SU + VU22));'; Card = Card // thiscard;
			thiscard = '      IMBInv = INV(I(nrow(B)) - B);'; Card = Card // thiscard;
			thiscard = '      ResidCov = BigVA + BigVD + BigVC + BigVU;'; Card = Card // thiscard;
			thiscard = '      VP = IMBInv * ResidCov * t(IMBInv);'; Card = Card // thiscard;
			thiscard = concat('      P1 = VP[', NLatP1Chr, ':',  NTotChr, ', ', NLatP1Chr, ':',  NTotChr, '];');
			Card = Card // thiscard;
		end;
		if Lambda=1 then do;
			thiscard = '      temp = diag(P1);'; Card = Card // thisCard;
			thiscard = '      P1 = P1 - temp + temp*INV(Lambda);'; Card = Card // thiscard;
		end;
		thiscard = '      P2 = P1;'; Card = Card // thiscard;
		thiscard = '   end;'; Card = Card // thiscard;
		if &NLatentP=0 then do;
			thiscard = '   R12 = IMBInv*(gamma_A*VA + gamma_D*VD + gamma_C*VC)*t(IMBInv);';
			card = card // thiscard;
		end;
		else do;
			thiscard = '   R12 = IMBInv*(gamma_A*BigVA + gamma_D*BigVD + gamma_C*BigVC)*t(IMBInv);';
			card = card // thiscard;
			thiscard = concat('   R12 = R12[', NLatP1Chr, ':',  NTotChr, ', ', NLatP1Chr, ':',  NTotChr, '];');
			card = card // thiscard;
		end;
	FINISH;
	* ---------------------------------------------------------------------------------
	* --- end of modules;

	* ---------------------------------------------------------------------------------
	* --- Start of executable code;

	* --- type of model;
	pcmod = upcase("&PCModType");

	* --- open data sets if needed;
	Lambda=0;
	if pcmod ^= 'BASELINE1' then do;
		USE work._TMP_Bmatrix;
			READ ALL VAR {&phenos} INTO B;
		CLOSE work._TMP_Bmatrix;
		USE work._TMP_Umatrix;
			READ ALL VAR {&phenos} INTO U;
		CLOSE work._TMP_Umatrix;
		if exist('work._TMP_Lambda') then do;
			Lambda=1;
			USE work._tmp_lambda;
				READ ALL VAR {Fixed} into CFixed;
				READ ALL VAR {Value} into LamValue;
			CLOSE work._tmp_lambda;
			Fixed = j(max(nrow(CFixed), ncol(CFixed)), 1, 0);
			do i=1 to nrow(Cfixed);
				if upcase(left(CFixed[i])) ^= 'YES' then fixed[i]=1;
			end;
			if nrow(LamValue)=1 then LamValue=t(LamValue);
		end;
	end;

	* --- character representation of matrix dimensions;
	NLatChr = trim(left(char(&NLatentP)));
	NTotChr = trim(left(char(&NTotalP)));
	temp = &NtotalP - &NLatentP;
	NObsChr = trim(left(char(temp)));
	temp = &NlatentP + 1;
	NLatP1Chr = trim(left(char(temp)));

	* --- array for the various combinations of relatives;
	Rel1List = "&Rel1List";
	Rel2List = "&Rel2List";
	temp1='x';
	n=0;
	do until (temp1='');
		n=n+1;
		temp1 = scan(Rel1List, n, ' ');
		temp2 = scan(Rel2List, n, ' ');
		if temp1 ^= '' then RelCov= RelCov // concat('ReltvCov', temp1, temp2);
	end;

	* --- begin model;
	thiscard = concat('BEGIN MODEL ', "&ModTitle"); Card = Card // thiscard;

	* ---------------------------------------------------------------------------------
	* --- Matrix Definitions;
	thiscard = 'BEGIN MATRICES'; Card = Card // thiscard;
	if pcmod='BASELINE1' then call matrices1 (Card, RelCov);
	else if pcmod = 'BASELINE2' then call matrices2 (Card, RelCov, NLatChr, NObsChr, NTotChr);
	else if pcmod = 'PC1' then call matrices3 (Card, RelCov, NLatChr, NObsChr, NTotChr);
	else if pcmod = 'PC2' then call matrices4 (Card, RelCov, NLatChr, NObsChr, NTotChr);
 
	* --- lambda if needed;
	if lambda=1 then do;
		thiscard = '   Lambda D &np'; Card = Card // thiscard;
	end;

	thiscard = 'END MATRICES'; Card = Card // thiscard;

	* ---------------------------------------------------------------------------------
	* --- MX Definitions;
	thiscard = 'BEGIN MX'; Card = Card // thiscard;
	if pcmod='BASELINE1' then call mx1 (Card);
	else if pcmod = 'BASELINE2' then call mx2 (Card, B, U);
	else if pcmod = 'PC1' then call mx3 (Card, B, U, RelCov);
	else if pcmod = 'PC2' then call mx4 (Card, B, U);

	* --- lambda if needed;
	if lambda=1 then call LambdaIt (Fixed, LamValue, Card);

	thiscard = 'END MX'; Card = Card // thiscard;

	* -----------------------------------------------------------------------------------------------
	* --- SASPairs IML Code;
	thisCard = 'BEGIN IML'; Card = Card // thiscard;
	if pcmod='BASELINE1' then call iml1 (Card, RelCov, Lambda);
	else if pcmod = 'BASELINE2' then call iml2 (Card, RelCov, NLatChr, NObsChr, NTotChr, NLatP1Chr, Lambda);
	else if pcmod = 'PC1' then call iml3 (Card, RelCov, NLatChr, NObsChr, NTotChr, NLatP1Chr, Lambda);
	else if pcmod = 'PC2' then call iml4 (Card, RelCov, NLatChr, NObsChr, NTotChr, NLatP1Chr, Lambda);

	thiscard = 'END IML'; card = card // thiscard;
	thiscard = 'END MODEL'; card = card // thiscard;

	* -----------------------------------------------------------------------------------------------
	* --- output data set;
	CREATE _TMP_Cards from Card [colname='Card'];
	APPEND from Card;
QUIT;
