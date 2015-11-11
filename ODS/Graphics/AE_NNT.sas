/*
http://blogs.sas.com/content/graphicallyspeaking/2015/10/31/adverse-events-graph-with-nnt/
*/


%let gpath='.';
%let dpi=200;

data final;
  input AEDECOD $1-20 PCT0 PCTR Risk LRisk URisk RiskCI $66-84 NNT;
  datalines;
Back pain            0.10227 0.057471 -0.044801 -0.13623 0.04663 -0.04 (-0.14, 0.05) -22.3207
Insomnia             0.04545 0.011494 -0.033960 -0.09434 0.02641 -0.03 (-0.09, 0.03) -29.4462
Headache             0.09091 0.057471 -0.033438 -0.12232 0.05545 -0.03 (-0.12, 0.06) -29.9063
Respiratory disorder 0.00000 0.022989  0.022989 -0.01993 0.06591 0.02 (-0.02, 0.07)   43.5000
Weight decrease      0.00000 0.022989  0.022989 -0.01993 0.06591 0.02 (-0.02, 0.07)   43.5000
Dyspepsia            0.01136 0.034483  0.023119 -0.03259 0.07883 0.02 (-0.03, 0.08)   43.2542
Vomiting             0.01136 0.034483  0.023119 -0.03259 0.07883 0.02 (-0.03, 0.08)   43.2542
Hematuria            0.02273 0.045977  0.023250 -0.04209 0.08859 0.02 (-0.04, 0.09)   43.0112
Nausea               0.00000 0.034483  0.034483 -0.01529 0.08425 0.03 (-0.02, 0.08)   29.0000
Arthralgia           0.02273 0.068966  0.046238 -0.02687 0.11935 0.05 (-0.03, 0.12)   21.6271
;
run;

ods html;
proc print data=final;
run;
ods html close;

*---------------*
| Plot the data |
*---------------*;
proc template;

/* Set up panel plot using GTL */
   define statgraph panel;
   begingraph;
      entrytitle "Treatment Emergent Adverse Events with Largest Risk Difference";
      entrytitle "(Safety Population)";
          entryfootnote halign=left "Number needed to treat = 1/riskdiff.";

          /* Specify a 2 column, 1 row layout with common y-axis */
      layout lattice / columns=2 columnweights=(0.4 0.6) rowdatarange=union;
        rowaxes;
             rowaxis / griddisplay=on gridattrs=(thickness=1 color=lightgray) display=(tickvalues) tickvalueattrs=(size=10);
            endrowaxes;

            /* Left cell with incidence values */
        layout overlay / xaxisopts=(label="Proportion" tickvalueattrs=(size=8) linearopts=(thresholdmax=0));
          scatterplot y=aedecod x=pct0 / markerattrs=(symbol=circlefilled color=bib size=12)
                                                name='drga'
                                                                            legendlabel='Drug A (N=90)';
          scatterplot y=aedecod x=pctr / markerattrs=(symbol=trianglefilled color=red size=12)
                                                            name='drgb'
                                                                            legendlabel='Drug B (N=90)';
        endlayout;
            /* Right cell with risk differences and NNT */
        layout overlay / xaxisopts=(label="Risk Difference with 95% CI" tickvalueattrs=(size=8) linearopts=(viewmin=-0.20 viewmax=0.35 tickvaluelist=(-0.20 -0.15 -0.1 -0.05 0 0.05 0.1 0.15)))
                           x2axisopts=(label="Number needed to treat" tickvalueattrs=(size=7) linearopts=(viewmin=-0.20 viewmax=0.35 tickvaluelist=(-0.20 -0.15 -0.1 -0.05 -0.025 0 0.025 0.05 0.1 0.15)
                                   tickdisplaylist=('-5' '-6.7' '-10' '-20' '-40' "(*ESC*){unicode '00B1'x}(*ESC*){unicode '221e'x}" '40' '20' '10' '6.7')
                                   tickvaluefitpolicy=none));

          scatterplot y=aedecod x=risk / markerattrs=(symbol=diamondfilled color=black size=10)
                                                    xerrorlower=lrisk
                                                                            xerrorupper=urisk;
                  scatterplot y=aedecod x=risk / xaxis=x2
                                        datatransparency=1;
                  axistable y=aedecod value=riskci / class=origin position=0.8 display=(label) labelposition=min labelattrs=(size=8);
              referenceline x=0 / lineattrs=(pattern=shortdash color=black);
        endlayout;

            /* Bottom-centered sidebar with legend */
        sidebar / align=bottom spacefill=false;
          discretelegend 'drga' 'drgb' ;
        endsidebar;
      endlayout;
    endgraph;
  end;
run;

ods _all_ close;
ods listing gpath=&gpath image_dpi=&dpi;
ods graphics on / reset height=4in width=8in imagename='AdverseEvents';

proc sgrender data=final template=panel;
run;

