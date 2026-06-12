/*******************************************************************************************************************
PROGRAM: STEP 12: DUAL HARM OUTCOMES - COMPARING ANALYTIC COHORT WITH NON-ANALYTIC COHORT (SAMPLE CHARACTERISTICS; SUPPLEMENTAL TABLE 1)
DATA ANALYST: Elizabeth Kolias
DATE CREATED: 14 February 2025
CHECKED BY: Kallisse Dent
STEPS:
1. Calculate the weighted prevalence of each categorical for both analytic cohort and non-analytic cohort. Run chi-square tests to determine if analytic cohort differs by each covariate.
2. Calculate the median/IQR of each continuous variable for both analytic cohort and non-analytic cohort. Run ANOVAs to determine if analytic cohort differs by each covariate.
**THIS IS OUTPUT FOR SUPPLEMENTAL TABLE 1 ; 
********************************************************************************************************************/
libname out 'P:\AddHealth\Contract\29042102-RichmondRakerd\Work\Elizabeth Kolias\Dual Harm Data' ; 

proc format;
	value harmf
	0 = 'neither harm'
	1 = 'other only'
	2 = 'self only'
	3 = 'dual harm';
run;

*NOTE: Cannot using the missing option here - will make it so that you cant get p-values. 
But confirmed that we do not drop strata or clusters -- so this will not bias our variances; 
*Calculate the weighted prevalence of male sex by inclusion/exclusion in analytic cohort.;
proc surveyfreq data = out.dualharm_draft8_analyticcohort;
tables analytic_cohort_indicator*w1_sex/row chisq; 
cluster PSUSCID; 
strata Region;
weight GSW5;
run;

*Calculate the weighted prevalence of each racial category by inclusion/exclusion in analytic cohort.;
proc surveyfreq data = out.dualharm_draft8_analyticcohort;  
tables analytic_cohort_indicator*w1_race_selfreport /row chisq; 
cluster PSUSCID;
strata Region; 
weight GSW5;
run;

*Calculate the weighted prevalence of Hispanic/Latino ethnicity by inclusion/exclusion in analytic cohort.;
proc surveyfreq data = out.dualharm_draft8_analyticcohort;  
tables analytic_cohort_indicator*w1_ethnicity /row chisq; 
cluster PSUSCID;
strata Region; 
weight GSW5;
run;

*Calculate the weighted prevalence of childhood maltreatment by inclusion/exclusion in analytic cohort.;
proc surveyfreq data = out.dualharm_draft8_analyticcohort;  
tables analytic_cohort_indicator*w3_cm_indicator /row chisq; 
cluster PSUSCID;
strata Region; 
weight GSW5;
run;

*Calculate the weighted prevalence in each harm group by inclusion/exclusion in analytic cohort.;
proc surveyfreq data = out.dualharm_draft8_analyticcohort;  
tables analytic_cohort_indicator*harm_type /row chisq; 
cluster PSUSCID;
strata Region; 
weight GSW5;
run;


*Calculate median/IQR of age by inclusion/exclusion in analytic cohort.;
proc surveymeans data = out.dualharm_draft8_analyticcohort median q1 q3;  
var w1_age ; 
cluster PSUSCID; 
strata Region; 
weight GSW5  ;
domain  analytic_cohort_indicator ;
run;


*Calculate median/IQR of SES by inclusion/exclusion in analytic cohort.;
proc surveymeans data = out.dualharm_draft8_analyticcohort median q1 q3;  
var w1_ses ; 
cluster PSUSCID; 
strata Region; 
weight GSW5  ;
domain  analytic_cohort_indicator ;
run;


*Calculate median/IQR of adolescent self-control by inclusion/exclusion in analytic cohort.;
proc surveymeans data = out.dualharm_draft8_analyticcohort median q1 q3;  
var w1_selfcon_sum_prorate ; 
cluster PSUSCID; 
strata Region; 
weight GSW5  ;
domain  analytic_cohort_indicator ;
run;

*Calculate median/IQR of adolescent cognitive ability by inclusion/exclusion in analytic cohort.;
proc surveymeans data = out.dualharm_draft8_analyticcohort median q1 q3;  
var w1_verbal_intel ; 
cluster PSUSCID; 
strata Region; 
weight GSW5  ;
domain  analytic_cohort_indicator ;
run;

*Run ANOVA to see if continuous variables differ by inclusion in analytic cohort; 
%MACRO cont_test_analytic(var);  
proc surveyreg data = out.dualharm_draft8_analyticcohort ;
class analytic_cohort_indicator (ref=0) / param=ref ;
model &var. = analytic_cohort_indicator;
cluster PSUSCID; 
strata Region; 
weight GSW5; 
run;
%MEND ; 
%cont_test_analytic(w1_age) ; 
%cont_test_analytic(w1_ses) ; 
%cont_test_analytic(w1_selfcon_sum_prorate); 
%cont_test_analytic(w1_verbal_intel);
