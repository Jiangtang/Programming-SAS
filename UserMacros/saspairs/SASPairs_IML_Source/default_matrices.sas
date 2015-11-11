/* --- DEFAULT MATRICXES FOR SASPAIRS --- */
data spimlsrc.default_matrices;
	length matrix_name $3 matrix_type $1;
	infile datalines dlm='09'x;
	input matrix_name matrix_type default_rows default_cols must_be_present;
datalines;
VA	S	1	1	0
VAf	S	1	1	0
VAm	S	1	1	0
VC	S	1	1	0
VCf	S	1	1	0
VCm	S	1	1	0
VD	S	1	1	0
VDf	S	1	1	0
VDm	S	1	1	0
VU	S	1	1	0
VUf	S	1	1	0
VUm	S	1	1	0
VE	S	1	1	0
VEf	S	1	1	0
VEm	S	1	1	0
FA	?	1	0	0
FAf	?	1	1	0
FAm	?	1	0	0
RA	C	0	0	0
RAf	C	0	0	0
RAm	C	0	0	0
SA	D	1	1	0
SAf	D	1	1	0
SAm	D	1	1	0
FC	?	1	0	0
FCf	?	1	0	0
FCm	?	1	0	0
RC	C	0	0	0
RCf	C	0	0	0
RCm	C	0	0	0
SC	D	1	1	0
SCf	D	1	1	0
SCm	D	1	1	0
FD	?	1	0	0
FDf	?	1	0	0
FDm	?	1	0	0
RD	C	0	0	0
RDf	C	0	0	0
RDm	C	0	0	0
SD	D	1	1	0
SDf	D	1	1	0
SDm	D	1	1	0
FU	?	1	0	0
FUf	?	1	0	0
FUm	?	1	0	0
RU	C	0	0	0
RUf	C	0	0	0
RUm	C	0	0	0
SU	D	1	1	0
SUf	D	1	1	0
SUm	D	1	1	0
FE	?	1	0	0
FEf	?	1	0	0
FEm	?	1	0	0
RE	C	0	0	0
REf	C	0	0	0
REm	C	0	0	0
SE	D	1	1	0
SEf	D	1	1	0
SEm	D	1	1	0
run;
