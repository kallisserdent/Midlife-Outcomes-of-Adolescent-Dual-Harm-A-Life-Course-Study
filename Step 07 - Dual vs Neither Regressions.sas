/*******************************************************************************************************************
PROGRAM: STEP 7: DUAL HARM OUTCOMES - DUAL VS NEITHER REGRESSIONS (MIDLIFE OUTCOMES OF ADOLESCENTS WITH DUAL HARM RELATIVE TO NEITHER HARM; TABLE 3 & SUPPLEMENTAL TABLE 2)
DATA ANALYST: Elizabeth Kolias
DATE CREATED: 3 February 2025
CHECKED BY: Kallisse Dent
STEPS:
1. Create an indicator that is a combination of those not missing information for the exposure and in the analytic cohort.
2. Perform baseline logistic regressions predicting midlife outcomes for dual vs. neither group.
3. Perform adjusted logistic regressions predicting midlife outcomes for dual vs. neither group.
4. Perform adjusted logistic regressions adjusting for each co-variate separately for the dual vs. neither group.
********************************************************************************************************************/
libname out 'P:\AddHealth\Contract\29042102-RichmondRakerd\Work\Elizabeth Kolias\Dual Harm Data' ; 

proc format;
	value harmf
	0 = 'neither harm'
	1 = 'other only'
	2 = 'self only'
	3 = 'dual harm';
run;

*Create a new indicator(analytic_vs_neither) that includes participants in the general analytic cohort created in Step 5 who 
are not missing for the dual_vs_neither_indicator created in Step 2.;
data analytic; 
set out.dualharm_draft8_analyticcohort; 
analytic_vs_neither = (analytic_cohort_indicator = 1 and dual_vs_neither_indicator ne . ); 

*Create a specific indicator for employment variable analyses - limits to those who are in the labor force ; 
if w5_unemployed_new =. then analytic_labor =0 ; 
else analytic_labor=analytic_vs_neither;
run; *n = 12,057; *148 variables;

/***Table 3 OUTPUT ***/ 
***BASELINE MODELS; 
*Create a MACRO for baseline logistic regressions predicting midlife outcomes.;
%MACRO logistic_dualvneither(outcome);
proc surveylogistic data = analytic missing; 
class dual_vs_neither_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport (ref='1') w1_ethnicity(ref='0') /param=ref; 
model &outcome. (event='1') = dual_vs_neither_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses ; 
cluster PSUSCID ; 
strata Region ; 
weight GSW5 ; 
domain analytic_vs_neither; 
run;
%MEND;


*Run MACRO for baseline logistic regression predicting midlife suicidality.;
%logistic_dualvneither(w5_mh_suicidality_indicator);
*odds ratio for dual vs neither is 8.907 (95% CI: 3.126 25.377) df = 128 strata = 4 cluster = 132);

*NOTE: When running these analyses your get Odd Ratios for the missing category versus 0 (reference category). These 
odds ratios should be ignored. Also, checks confirmed that running analyses without those with missing information 
does not change our estimates of interest. The approach used is the best approach b/c it avoids dropping individuals 
with missing information which can lead to changes in variances. 

*Cannot run associations with suicide due to low counts ; 

*Run MACRO for baseline logistic regression predicting midlife depression.;
%logistic_dualvneither(w5_mh_dep_indicator);
*odds ratio for dual vs neither is 3.081 (95% CI: 2.073 4.58) df = 128 strata = 4 cluster = 132);

*Run MACRO for baseline logistic regression predicting midlife substance misuse.;
%logistic_dualvneither(w5_mh_sub_indicator);
*odds ratio for dual vs neither is 1.892 (95% CI: 1.097 3.264) df = 128 strata = 4 cluster = 132;

*Run MACRO for baseline logistic regression predicting fair/poor self-rated midlife health.;
%logistic_dualvneither(w5_ph_genhlth_indicator);
*odds ratio for dual vs neither is 2.32 (95% CI: 1.375 3.912) df = 128 strata = 4 cluster = 132;

*Run MACRO for baseline logistic regression predicting presence of chronic health condition at midlife.;
%logistic_dualvneither(w5_ph_chron_indicator_noresp);
*odds ratio for dual vs neither is 1.115 (95% CI: 0.6 2.07) df = 128 strata = 4 cluster = 132;

*SENSITIVITY ANALYSIS: Run MACRO for baseline logistic regression predicting presence of a chronic health condition INCLUDING RESPIRATORY CONDITIONS at midlife.;
%logistic_dualvneither(w5_ph_chron_indicator);
*odds ratio for dual vs neither is 1.478 (95% CI: 0.92 2.376) df = 128 strata = 4 cluster = 132;

*Run MACRO for baseline logistic regression predicting married/cohabitating at midlife.;
%logistic_dualvneither(w5_soc_rel_indicator);
*odds ratio for dual vs neither is 0.732 (95% CI: 0.442 1.213) df = 128 strata = 4 cluster = 132;

*Run MACRO for baseline logistic regression predicting any self-reported victimization at midlife.;
%logistic_dualvneither(w5_soc_vict_indicator);
*odds ratio for dual vs neither is 3.689 (95% CI: 1.893 7.189) df = 128 strata = 4 cluster = 132;
*NOTE: All analyses with victimization as the outcome will result in a convergence warning due to low cell counts. 
Checks were performed to determine the source of this error, which ultimately was due to low cell counts in the 
racial categories across victimization outcomes. A check was run with a collapsed version of the racial category - this 
got rid of the warning message - estimates changed slightly but did not change statistical significance. We concluded that 
the warning was not leading to biases in estimates and chose to retain more granular racial categories to be consistent 
with other analyses. 

*Cannot run associations for employment due to low counts. 

*Run MACRO for baseline logistic regression predicting below federal poverty threshold at midlife.;
%logistic_dualvneither(w5_se_poverty_indicator);
*odds ratio for dual vs neither is 3.356 (95% CI: 1.989 5.663) df = 128 strata = 4 cluster = 132;

*Run MACRO for baseline logistic regression predicting loss of property at midlife.;
%logistic_dualvneither(w5_se_property);
*odds ratio for dual vs neither is 2.168 (95% CI: 1.388 3.385) df = 128 strata = 4 cluster = 132;


***ADJUSTED MODELS; 
*Cannot run associations with suicidality ; 

*Run adjusted logistic regression predicting upper quintile of depressive symptoms at midlife.;
proc surveylogistic data = analytic missing; 
class dual_vs_neither_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport (ref='1') w1_ethnicity(ref='0') w3_cm_indicator(ref='0') /param=ref; 
model w5_mh_dep_indicator (event='1') = dual_vs_neither_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses w1_selfcon_sum_prorate w3_cm_indicator w1_verbal_intel; 
cluster PSUSCID ; 
strata Region ; 
weight GSW5 ; 
domain analytic_vs_neither; 
run;

*Run adjusted logistic regression predicting substance misuse at midlife.;
proc surveylogistic data = analytic missing; 
class dual_vs_neither_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport (ref='1') w1_ethnicity(ref='0') w3_cm_indicator(ref='0') /param=ref; 
model w5_mh_sub_indicator (event='1') = dual_vs_neither_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses w1_selfcon_sum_prorate w3_cm_indicator w1_verbal_intel; 
cluster PSUSCID ; 
strata Region ; 
weight GSW5 ; 
domain analytic_vs_neither; 
run;

*Run adjusted logistic regression predicting fair/poor health at midlife.;
proc surveylogistic data = analytic missing; 
class dual_vs_neither_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport (ref='1') w1_ethnicity(ref='0') w3_cm_indicator(ref='0') /param=ref; 
model w5_ph_genhlth_indicator (event='1') = dual_vs_neither_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses w1_selfcon_sum_prorate w3_cm_indicator w1_verbal_intel; 
cluster PSUSCID ; 
strata Region ; 
weight GSW5 ; 
domain analytic_vs_neither; 
run;

*Run adjusted logistic regression predicting presence of a chronic health condition at midlife.;
proc surveylogistic data = analytic missing; 
class dual_vs_neither_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport (ref='1') w1_ethnicity(ref='0') w3_cm_indicator(ref='0') /param=ref; 
model w5_ph_chron_indicator_noresp (event='1') = dual_vs_neither_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses w1_selfcon_sum_prorate w3_cm_indicator w1_verbal_intel; 
cluster PSUSCID ; 
strata Region ; 
weight GSW5 ; 
domain analytic_vs_neither; 
run;

*Run adjusted logistic regression predicting presence of a chronic health condition INCLUDING RESPIRATORY CONDITIONS at midlife.;
proc surveylogistic data = analytic missing; 
class dual_vs_neither_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport (ref='1') w1_ethnicity(ref='0') w3_cm_indicator(ref='0') /param=ref; 
model w5_ph_chron_indicator (event='1') = dual_vs_neither_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses w1_selfcon_sum_prorate w3_cm_indicator w1_verbal_intel; 
cluster PSUSCID ; 
strata Region ; 
weight GSW5 ; 
domain analytic_vs_neither; 
run;

*Run adjusted logistic regression predicting married/cohabitating at midlife.;
proc surveylogistic data = analytic missing; 
class dual_vs_neither_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport (ref='1') w1_ethnicity(ref='0') w3_cm_indicator(ref='0') /param=ref; 
model w5_soc_rel_indicator (event='1') = dual_vs_neither_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses w1_selfcon_sum_prorate w3_cm_indicator w1_verbal_intel; 
cluster PSUSCID ; 
strata Region ; 
weight GSW5 ; 
domain analytic_vs_neither; 
run;

*Run adjusted logistic regression predicting victimization at midlife.;
proc surveylogistic data = analytic missing; 
class dual_vs_neither_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport (ref='1') w1_ethnicity(ref='0') w3_cm_indicator(ref='0') /param=ref; 
model w5_soc_vict_indicator (event='1') = dual_vs_neither_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses w1_selfcon_sum_prorate w3_cm_indicator w1_verbal_intel; 
cluster PSUSCID ; 
strata Region ; 
weight GSW5 ; 
domain analytic_vs_neither; 
run;

*Cannot run associations with employment due to low cell counts; 

*Run adjusted logistic regression predicting below federal poverty threshold at midlife.;
proc surveylogistic data = analytic missing; 
class dual_vs_neither_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport (ref='1') w1_ethnicity(ref='0') w3_cm_indicator(ref='0') /param=ref; 
model w5_se_poverty_indicator (event='1') = dual_vs_neither_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses w1_selfcon_sum_prorate w3_cm_indicator w1_verbal_intel; 
cluster PSUSCID ; 
strata Region ; 
weight GSW5 ; 
domain analytic_vs_neither; 
run;

*Run adjusted logistic regression predicting loss of property at midlife.;
proc surveylogistic data = analytic missing; 
class dual_vs_neither_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport (ref='1') w1_ethnicity(ref='0') w3_cm_indicator(ref='0') /param=ref; 
model w5_se_property (event='1') = dual_vs_neither_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses w1_selfcon_sum_prorate w3_cm_indicator w1_verbal_intel; 
cluster PSUSCID ; 
strata Region ; 
weight GSW5 ; 
domain analytic_vs_neither; 
run;

/**Supplemental Table 2**/ 

***First we will run analyses that only adjust for self-control; 
*NOTE: These analyses are only run for those associations that were statistically significant at baseline; 
%MACRO adjselfcononly_dualvneither(outcome);
proc surveylogistic data = analytic missing; 
class dual_vs_neither_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport (ref='1') w1_ethnicity(ref='0') /param=ref; 
model &outcome. (event='1') = dual_vs_neither_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses w1_selfcon_sum_prorate; 
cluster PSUSCID ; 
strata Region ; 
weight GSW5 ; 
domain analytic_vs_neither; 
run;
%MEND;
%adjselfcononly_dualvneither(w5_mh_dep_indicator);
%adjselfcononly_dualvneither(w5_mh_sub_indicator);
%adjselfcononly_dualvneither(w5_ph_genhlth_indicator);
%adjselfcononly_dualvneither(w5_soc_vict_indicator);
%adjselfcononly_dualvneither(w5_se_poverty_indicator);
%adjselfcononly_dualvneither(w5_se_property);

*Now adjusting for childhood maltreatment only ; 
%MACRO adjcmonly_dualvneither(outcome);
proc surveylogistic data = analytic missing; 
class dual_vs_neither_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport (ref='1') w1_ethnicity(ref='0') w3_cm_indicator(ref='0')/param=ref; 
model &outcome. (event='1') = dual_vs_neither_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses w3_cm_indicator ; 
cluster PSUSCID ; 
strata Region ; 
weight GSW5 ; 
domain analytic_vs_neither; 
run;
%MEND;
%adjcmonly_dualvneither(w5_mh_dep_indicator);
%adjcmonly_dualvneither(w5_mh_sub_indicator);
%adjcmonly_dualvneither(w5_ph_genhlth_indicator);
%adjcmonly_dualvneither(w5_soc_vict_indicator);
%adjcmonly_dualvneither(w5_se_poverty_indicator);
%adjcmonly_dualvneither(w5_se_property);

*Now adjusting for cognitive ability only; 
%MACRO adjcogonly_dualvneither(outcome);
proc surveylogistic data = analytic missing; 
class dual_vs_neither_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport (ref='1') w1_ethnicity(ref='0') /param=ref; 
model &outcome. (event='1') = dual_vs_neither_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses w1_verbal_intel ; 
cluster PSUSCID ; 
strata Region ; 
weight GSW5 ; 
domain analytic_vs_neither; 
run;
%MEND;
%adjcogonly_dualvneither(w5_mh_dep_indicator);
%adjcogonly_dualvneither(w5_mh_sub_indicator);
%adjcogonly_dualvneither(w5_ph_genhlth_indicator);
%adjcogonly_dualvneither(w5_soc_vict_indicator);
%adjcogonly_dualvneither(w5_se_poverty_indicator);
%adjcogonly_dualvneither(w5_se_property);
