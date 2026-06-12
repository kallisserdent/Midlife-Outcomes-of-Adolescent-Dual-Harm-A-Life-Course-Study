/*******************************************************************************************************************
PROGRAM: STEP 13: DUAL HARM OUTCOMES - EXPLORING THE ASSOCIATION BETWEEN COGNITIVE ABILITY AND VICTIMIZATION
DATA ANALYST: Elizabeth Kolias
DATE CREATED: 15 July 2025
CHECKED BY: Kallisse Dent
STEPS:
1. Run associations between adolescent cognitive ability and midlife victimization, and between adolescent cognitive ability and adolescent dual harm
among those individuals who are included in the analysis of dual versus self only harm. 

These analyses were motivated by associations of dual versus self harm with victimization becoming 
statistically significant once cognitive ability was accounted for.

These results are presented only in the body of the manuscript under the results section for 
dual versus self harm.  
********************************************************************************************************************/
*libname for the SRW; 
libname out 'P:\AddHealth\Contract\29042102-RichmondRakerd\Work\Elizabeth Kolias\Dual Harm Data'; 

proc format;
	value harmf
	0 = 'neither harm'
	1 = 'other only'
	2 = 'self only'
	3 = 'dual harm';
run;

*Run logistic regression using adolescent cognitive ability to predict midlife victimization in the subset of participants who have engaged in self-harm or dual harm.;
data analytic; 
set out.dualharm_draft8_analyticcohort; 
analytic_vs_self = (analytic_cohort_indicator = 1 and dual_vs_self_indicator ne . ); 
run;


*Association of midlife victimization with cognitive ability among those who were in the 
subset of analyses used in the dual versus self-harm comparisons; 
proc surveyreg data = analytic missing ;
class w5_soc_vict_indicator (ref='0')  ; 
model w1_verbal_intel = w5_soc_vict_indicator /adjrsq solution clparm; /*adjusted r-squared takes into account weighting*/
cluster PSUSCID; 
strata Region;
weight GSW5;
domain analytic_vs_self;
*ODS OUTPUT PARAMETERESTIMATES=PARAMETER_EST FITSTATISTICS=FIT;
run;

*Association of dual harm (versus self-harm) with cognitive ability; 
proc surveyreg data = analytic missing ;
class dual_vs_self_indicator (ref='0')  ; 
model w1_verbal_intel = dual_vs_self_indicator /adjrsq solution clparm; /*adjusted r-squared takes into account weighting*/
cluster PSUSCID; 
strata Region;
weight GSW5;
domain analytic_vs_self;
*ODS OUTPUT PARAMETERESTIMATES=PARAMETER_EST FITSTATISTICS=FIT;
run;
 
