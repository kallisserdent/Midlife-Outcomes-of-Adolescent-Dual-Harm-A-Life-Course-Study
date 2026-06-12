/*******************************************************************************************************************
PROGRAM: STEP 6: DUAL HARM OUTCOMES - DESCRIPTIVE STATISTICS (SAMPLE CHARACTERISTICS AND SOCIODEMOGRAPHIC CHARACTERISTICS BY HARM TYPE; TABLES 1 & 2)
DATA ANALYST: Elizabeth Kolias
DATE CREATED: 31 January 2025
CHECKED BY: Kallisse Dent
STEPS:
1. Calculate the weighted prevalence of each categorical variable by harm type and overall.
2. Calculate the median/IQR of each continous variable by harm type and overall.
3. Calculate the weighted prevalence of participants in each harm group.
4. Run ANOVAS/chi-square tests to determine if harm groups differ by covariates.

***Output corresponds to Table 1 and Table 2
********************************************************************************************************************/
*SRW libname statement; 
libname out 'P:\AddHealth\Contract\29042102-RichmondRakerd\Work\Elizabeth Kolias\Dual Harm Data' ; 


proc contents data = out.dualharm_draft8_analyticcohort; run; *n = 12,057; *147 variables;
proc format;
	value harmf
	0 = 'neither harm'
	1 = 'other only'
	2 = 'self only'
	3 = 'dual harm';
run;

***NOTE: The approach used below drops individuals from the "other harm only" group since the indicator harm_type_no_other 
is missing for those with other harm only. However, dropping these individuals does not change the number of cluster or 
strata and therefore does not change variances (p-values). Other approaches were used for checking and results aligned with 
the approach that is shown here. This approach was used for simplicity. Most of the checks are not shown here for ease of following 
this code but are available upon request. ;


**Need to create a special indicator for descriptive statistics for the employment variable since this variable is only 
defined for those in the labor force; 
data analytic_cohort_test_employ ; 
merge out.dualharm_draft8_analyticcohort;  ; 
if w5_unemployed_new =. then analytic_labor =0 ; 
else analytic_labor=analytic_cohort_indicator;
run; 

/***TABLE 1 OUPTUT***/ 

*Calculate the weighted prevalence of sex by harm type.;
proc surveyfreq data = out.dualharm_draft8_analyticcohort;  
tables analytic_cohort_indicator*harm_type_no_other*w1_sex /row chisq; 
cluster PSUSCID;
strata Region; 
weight GSW5;
run;


*Calculate the weighted prevalence of male sex overall;
proc surveyfreq data = out.dualharm_draft8_analyticcohort missing ;  
tables analytic_cohort_indicator*(w1_sex)/row chisq; 
cluster PSUSCID;
strata Region; 
weight GSW5;
run;


*Calculate the weighted prevalence of each racial category by harm type.;
proc surveyfreq data = out.dualharm_draft8_analyticcohort;  
tables analytic_cohort_indicator*harm_type_no_other*w1_race_selfreport /row chisq; 
cluster PSUSCID;
strata Region; 
weight GSW5;
run;

*Calculate the weighted prevalence of each racial category overall.;
proc surveyfreq data = out.dualharm_draft8_analyticcohort missing ;  
tables analytic_cohort_indicator*w1_race_selfreport /row chisq; 
cluster PSUSCID;
strata Region; 
weight GSW5;
run;
/*NOTE: N WHO ARE AMERICAN INDIAN ALASKAN NATIVE AND N FOR THOSE WHO ARE ASIAN OR PACIFIC ISLAND
AMONG THOSE WITH DUAL HARM AND AMONG THOSE WITH SELF HARM IS LESS THAN 10 - CANNOT REPORT THIS INFORMATION*/

*Calculate the weighted prevalence of Hispanic/Latino ethnicity by harm type.;
proc surveyfreq data = out.dualharm_draft8_analyticcohort;  
tables analytic_cohort_indicator*harm_type_no_other*w1_ethnicity /row chisq; 
cluster PSUSCID;
strata Region; 
weight GSW5;
run;

*Calculate the weighted prevalence of Hispanic/Latino ethnicity overall.;
proc surveyfreq data = out.dualharm_draft8_analyticcohort missing ;  
tables analytic_cohort_indicator*w1_ethnicity /row chisq; 
cluster PSUSCID;
strata Region; 
weight GSW5;
run;


*Calculate the weighted prevalence of childhood maltreatment by harm type.;
proc surveyfreq data = out.dualharm_draft8_analyticcohort;  
tables analytic_cohort_indicator*harm_type_no_other*w3_cm_indicator /row chisq; 
cluster PSUSCID;
strata Region; 
weight GSW5;
run;

*Calculate the weighted prevalence of childhood maltreatment overall.;
proc surveyfreq data = out.dualharm_draft8_analyticcohort missing ;  
tables analytic_cohort_indicator*w3_cm_indicator /row chisq; 
cluster PSUSCID;
strata Region; 
weight GSW5;
run;


*Run ANOVAs to see if continous variables differ by harm type.;

*Create a new analytic indicator so that those in the other harm group are not included in analytic cohort; 
data anova_cohort; 
set out.dualharm_draft8_analyticcohort;
if harm_type_no_other = . then analytic_indic_noother = 0 ; else analytic_indic_noother= analytic_cohort_indicator ; 
run; 


*Run ANOVA to see if harm groups differ by age.;
proc surveyreg data = anova_cohort missing;
class harm_type_no_other param=ref  (ref='neither harm');
model w1_age = harm_type_no_other;
cluster PSUSCID; 
strata Region; 
weight GSW5; 
domain analytic_indic_noother;
run;

*Run ANOVA to see if harm groups differ by SES.;
proc surveyreg data = anova_cohort missing;
class harm_type_no_other (ref='neither harm');
model w1_ses = harm_type_no_other;
cluster PSUSCID; 
strata Region; 
weight GSW5; 
domain analytic_indic_noother;
run;

*Run ANOVA to see if harm groups differ by adolescent self-control.;
proc surveyreg data = anova_cohort missing;
class harm_type_no_other (ref='neither harm');
model w1_selfcon_sum_prorate = harm_type_no_other;
cluster PSUSCID; 
strata Region; 
weight GSW5; 
domain analytic_indic_noother;
run;

*Run ANOVA to see if harm groups differ by adolescent cognitive ability.;
proc surveyreg data = anova_cohort missing;
class harm_type_no_other (ref='neither harm');
model w1_verbal_intel = harm_type_no_other;
cluster PSUSCID; 
strata Region; 
weight GSW5; 
domain analytic_indic_noother;
run;

/***TABLE 2 OUTPUT***/ 

*Calculate the weighted prevalence of suicidality by harm type.;
proc surveyfreq data = out.dualharm_draft8_analyticcohort missing  ;  
tables analytic_cohort_indicator*harm_type*w5_mh_suicidality_indicator /row chisq; 
cluster PSUSCID;
strata Region; 
weight GSW5;
run;
/*NOTE: N SUICIDES AMONG THOSE WITH DUAL HARM IS LESS THAN 10 - CANNOT REPORT THIS INFORMATION OR INFORMATION FOR ASSOCIATIONS 
WITH SUCIDALITY WITH COMPARISONS INCLUDING DUAL HARM*/ 

*Calculate the weighted prevalence of depression by harm type.; 
proc surveyfreq data = out.dualharm_draft8_analyticcohort missing ;  
tables analytic_cohort_indicator*harm_type*w5_mh_dep_indicator /row chisq; 
cluster PSUSCID;
strata Region; 
weight GSW5;
run;

*Calculate the weighted prevalence of substance misuse by harm type.;
proc surveyfreq data = out.dualharm_draft8_analyticcohort missing ;  
tables analytic_cohort_indicator*harm_type*w5_mh_sub_indicator /row chisq; 
cluster PSUSCID;
strata Region; 
weight GSW5;
run;

*Calculate the weighted prevalence of fair/poor self-rated general health by harm type.;
proc surveyfreq data = out.dualharm_draft8_analyticcohort missing ;  
tables analytic_cohort_indicator*harm_type*w5_ph_genhlth_indicator /row chisq; 
cluster PSUSCID;
strata Region; 
weight GSW5;
run;


*Calculate the weighted prevalence of presence of a chronic health condition by harm type.;
proc surveyfreq data = out.dualharm_draft8_analyticcohort missing ;  
tables analytic_cohort_indicator*harm_type*w5_ph_chron_indicator_noresp /row chisq;
cluster PSUSCID;
strata Region;
weight GSW5;
run;

*SENSITIVITY ANALYSIS: Calculate the weighted prevalence of presence of a chronic health condition INCLUDING RESPIRATORY CONDITIONS by harm type.;
   *NOTE: These numbers are not presented in the mansucript but are referenced in a foot note. ;
proc surveyfreq data = out.dualharm_draft8_analyticcohort missing ;  
tables analytic_cohort_indicator*harm_type*w5_ph_chron_indicator /row chisq;
cluster PSUSCID;
strata Region;
weight GSW5;
run;
 

*Calculate the weighted prevalence of being in a relationship by harm type.;
proc surveyfreq data = out.dualharm_draft8_analyticcohort missing ;  
tables analytic_cohort_indicator*harm_type*w5_soc_rel_indicator /row chisq;
cluster PSUSCID;
strata Region;
weight GSW5;
run;

*Calculate the weighted prevalence of any victimization by harm type.;
proc surveyfreq data = out.dualharm_draft8_analyticcohort missing ;  
tables analytic_cohort_indicator*harm_type*w5_soc_vict_indicator /row chisq;
cluster PSUSCID;
strata Region;
weight GSW5;
run;


*Calculate the weighted prevalence of any victimization by harm type.;
*Need to use the special analytic indicator for in the labor force, since this variable is only defined for those 
who are in the labor force; 
proc surveyfreq data = analytic_cohort_test_employ/*missing*/ ;
tables analytic_labor*harm_type*w5_unemployed_new /row chisq;
cluster PSUSCID;
strata Region;
weight GSW5;
run;
 

*Calculate the weighted prevalence of below the federal poverty threshold by harm type.;
proc surveyfreq data = out.dualharm_draft8_analyticcohort missing ;  
tables analytic_cohort_indicator*harm_type*w5_se_poverty_indicator /row chisq;
cluster PSUSCID;
strata Region;
weight GSW5;
run;

*Calculate the weighted prevalence of loss of property by harm type.;
proc surveyfreq data = out.dualharm_draft8_analyticcohort missing ;  
tables analytic_cohort_indicator*harm_type*w5_se_property /row chisq;
cluster PSUSCID;
strata Region;
weight GSW5;
run;

*Calculate the median/IQR of each continuous variable by harm type and overall.;

*Sort by harm type.;
proc sort data = out.dualharm_draft8_analyticcohort out = sorted; by harm_type; run;

*Calculate the median/IQR age by harm type.;
proc surveymeans data = sorted median q1 q3; 
domain analytic_cohort_indicator ; 
var w1_age ; 
cluster PSUSCID; 
strata Region; 
weight GSW5  ;
by  harm_type ;
run;

*Calculate the median/IQR age overall.;
proc surveymeans data = sorted median min max q1 q3; 
domain analytic_cohort_indicator ; 
var w1_age ; 
cluster PSUSCID; 
strata Region; 
weight GSW5  ;
run;

*Calculate the median/IQR SES by harm type.;
proc surveymeans data = sorted median q1 q3; 
domain analytic_cohort_indicator ; 
var w1_ses; 
cluster PSUSCID; 
strata Region; 
weight GSW5  ;
by  harm_type ;
run;



*Calculate the median/IQR self-control level by harm type.;
proc surveymeans data = sorted median q1 q3; 
domain analytic_cohort_indicator ; 
var w1_selfcon_sum_prorate; 
cluster PSUSCID; 
strata Region; 
weight GSW5  ;
by harm_type;
run;

 

*Calculate the median/IQR cognitive ability by harm type.;
proc surveymeans data = sorted median q1 q3; 
domain analytic_cohort_indicator ; 
var w1_verbal_intel; 
cluster PSUSCID; 
strata Region; 
weight GSW5  ;
by harm_type;
run;



*Calculate the weighted prevalence of each harm type.;
proc surveyfreq data = out.dualharm_draft8_analyticcohort missing  ;  
tables analytic_cohort_indicator*harm_type /row chisq;
cluster PSUSCID;
strata Region;
weight GSW5;
run;



