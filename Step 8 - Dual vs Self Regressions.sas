/*******************************************************************************************************************
PROGRAM: STEP 8: DUAL HARM OUTCOMES - DUAL VS SELF REGRESSIONS (MIDLIFE OUTCOMES OF ADOLESCENTS WITH DUAL HARM RELATIVE TO SELF-HARM ONLY; TABLE 3 & SUPPLEMENTAL TABLE 2)
DATA ANALYST: Elizabeth Kolias
DATE CREATED: 3 February 2025
CHECKED BY: Kallisse Dent
STEPS:
1. Create an indicator that is a combination of those not missing information for the exposure and in the analytic cohort.
2. Perform baseline logistic regressions predicting midlife outcomes for dual vs. self group.
3. Perform adjusted logistic regressions predicting midlife outcomes for dual vs. self group.
4. Perform adjusted logistic regressions adjusting for each co-variate separately for the dual vs. self group.
 
********************************************************************************************************************/

*KD - new library for SRW; 
libname out 'P:\AddHealth\Contract\29042102-RichmondRakerd\Work\Elizabeth Kolias\Dual Harm Data' ; 

proc format;
	value harmf
	0 = 'neither harm'
	1 = 'other only'
	2 = 'self only'
	3 = 'dual harm';
run;

*Create a new indicator (analytic_vs_self) that includes participants in the general analytic cohort created in Step 5 who 
are not missing for the dual_vs_self indicator created in Step 2.;
data analytic; 
set out.dualharm_draft8_analyticcohort; 
analytic_vs_self = (analytic_cohort_indicator = 1 and dual_vs_self_indicator ne . ); 

*Create a specific indicator for employment variable analyses - limits to those who are in the labor force ; 
if w5_unemployed_new =. then analytic_labor =0 ; 
else analytic_labor=analytic_vs_neither;
run; *n = 12,057; *148 variables;

/**Table 3**/ 
*** BASELINE MODELS; 
*Create a MACRO for baseline logistic regressions predicting midlife outcomes.;
%MACRO logistic_dualvself(outcome);
proc surveylogistic data = analytic missing; 
class dual_vs_self_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport (ref='1') w1_ethnicity(ref='0') /param=ref; 
model &outcome. (event='1') = dual_vs_self_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses ; 
cluster PSUSCID ; 
strata Region ; 
weight GSW5 ; 
domain analytic_vs_self; 
run;
%MEND;

*Cannot run associations with suicidality due to low counts; 

*Run MACRO for baseline logistic regression predicting midlife depression.;
%logistic_dualvself(w5_mh_dep_indicator);
*odds ratio for dual versus self: 1.376 (95% CI: 0.764 2.477) df = 128 strata = 4 cluster = 132;

*Run MACRO for baseline logistic regression predicting midlife substance misuse.;
%logistic_dualvself(w5_mh_sub_indicator);
*odds ratio for dual vs self: 1.147 (95% CI: 0.579 2.271) df = 128 strata = 4 cluster = 132;

*Run MACRO for baseline logistic regression predicting midlife fair/poor self-rated health.;
%logistic_dualvself(w5_ph_genhlth_indicator);
*odds ratio for dual vs self: 1.363 (95% CI: 0.671 2.77) df = 128 strata = 4 cluster = 132;

*Run MACRO for baseline logistic regression predicting midlife presence of a chronic health condition.;
%logistic_dualvself(w5_ph_chron_indicator_noresp);
*odds ratio for dual vs self: 0.985 (95% CI: 0.42 2.312) df = 128 strata = 4 cluster = 132;

*Run MACRO for baseline logistic regression predicting midlife presence of a chronic health condition INCLUDING RESPIRATORY CONDITIONS.;
%logistic_dualvself(w5_ph_chron_indicator);

*Run MACRO for baseline logistic regression predicting midlife married/cohabitating.;
%logistic_dualvself(w5_soc_rel_indicator);
*odds ratio for dual vs self: 1.087 (95% CI: 0.575 2.057) df = 128 strata = 4 cluster = 132;

*Run MACRO for baseline logistic regression predicting midlife victimization.;
%logistic_dualvself(w5_soc_vict_indicator);
*odds ratio for dual vs self: 2.6 (95% CI: 0.984 6.868) df = 128 strata = 4 cluster = 132;

*Cannot run associations with unemployment due to low counts; 


*Run MACRO for baseline logistic regression predicting midlife below federal poverty threshold.;
%logistic_dualvself(w5_se_poverty_indicator);
*odds ratio for dual vs self: 1.639 (95% CI: 0.745 3.605) df = 128 strata = 4 cluster = 132;

*Run MACRO for baseline logistic regression predicting midlife loss of property.;
%logistic_dualvself(w5_se_property);
*odds ratio for dual vs self: 1.859 (95% CI: 1.016 3.404) df = 128 strata = 4 cluster = 132;


/**Table 3**/ 
*** ADJUSTED MODELS; 

%MACRO adjusted_dualvself(outcome);
proc surveylogistic data = analytic missing; 
class dual_vs_self_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport (ref='1') w1_ethnicity(ref='0') w3_cm_indicator(ref='0')/param=ref; 
model &outcome. (event='1') = dual_vs_self_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses w1_selfcon_sum_prorate w3_cm_indicator w1_verbal_intel; 
cluster PSUSCID ; 
strata Region ; 
weight GSW5 ; 
domain analytic_vs_self; 
run;
%MEND;

%adjusted_dualvself(w5_mh_dep_indicator); 
%adjusted_dualvself(w5_mh_sub_indicator); 
%adjusted_dualvself(w5_ph_genhlth_indicator); 
%adjusted_dualvself(w5_ph_chron_indicator_noresp); 
%adjusted_dualvself(w5_ph_chron_indicator); 
%adjusted_dualvself(w5_soc_rel_indicator); 
%adjusted_dualvself(w5_soc_vict_indicator); 
%adjusted_dualvself(w5_se_poverty_indicator); 
%adjusted_dualvself(w5_se_property); 


/**Supplemental Table 2 **/ 

*Run logistic regressions predicting victimization at midlife adjusting for adolescent self-control, childhood maltreatment, and adolescent cognitive ability separately.;
**Social victimization outcome; 
*only self-control; 
proc surveylogistic data = analytic missing; 
class dual_vs_self_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport (ref='1') w1_ethnicity(ref='0') /param=ref; 
model w5_soc_vict_indicator (event='1') = dual_vs_self_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses w1_selfcon_sum_prorate; 
cluster PSUSCID ; 
strata Region ; 
weight GSW5 ; 
domain analytic_vs_self; 
run;
*adjust for child maltreatment only ; 
proc surveylogistic data = analytic missing; 
class dual_vs_self_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport (ref='1') w1_ethnicity(ref='0') w3_cm_indicator(ref='0') /param=ref; 
model w5_soc_vict_indicator (event='1') = dual_vs_self_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses w3_cm_indicator; 
cluster PSUSCID ; 
strata Region ; 
weight GSW5 ; 
domain analytic_vs_self; 
run;
*adjust for cognitive ability only ; 
proc surveylogistic data = analytic missing; 
class dual_vs_self_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport (ref='1') w1_ethnicity(ref='0') /param=ref; 
model w5_soc_vict_indicator (event='1') = dual_vs_self_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses w1_verbal_intel; 
cluster PSUSCID ; 
strata Region ; 
weight GSW5 ; 
domain analytic_vs_self; 
run;

*Outcome= loss of property; 
*Run logistic regressions predicting loss of property at midlife adjusting for adolescent self-control, childhood maltreatment, and adolescent cognitive ability separately.;
*adjusting only for self-control; 
proc surveylogistic data = analytic missing; 
class dual_vs_self_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport (ref='1') w1_ethnicity(ref='0') /param=ref; 
model w5_se_property (event='1') = dual_vs_self_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses w1_selfcon_sum_prorate; 
cluster PSUSCID ; 
strata Region ; 
weight GSW5 ; 
domain analytic_vs_self; 
run;
*adjust for childhood maltreatment only; 
proc surveylogistic data = analytic missing; 
class dual_vs_self_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport (ref='1') w1_ethnicity(ref='0') w3_cm_indicator(ref='0') /param=ref; 
model w5_se_property (event='1') = dual_vs_self_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses w3_cm_indicator; 
cluster PSUSCID ; 
strata Region ; 
weight GSW5 ; 
domain analytic_vs_self; 
run;
*adjust for cognitive ability only; 
proc surveylogistic data = analytic missing; 
class dual_vs_self_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport (ref='1') w1_ethnicity(ref='0') /param=ref; 
model w5_se_property (event='1') = dual_vs_self_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses w1_verbal_intel; 
cluster PSUSCID ; 
strata Region ; 
weight GSW5 ; 
domain analytic_vs_self; 
run;
