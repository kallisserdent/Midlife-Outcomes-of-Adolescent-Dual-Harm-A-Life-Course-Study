/*******************************************************************************************************************
PROGRAM: STEP 9: DUAL HARM OUTCOMES - SELF VS NEITHER REGRESSIONS (MIDLIFE OUTCOMES OF ADOLESCENTS WITH SELF-HARM ONLY RELATIVE TO NEITHER HARM; TABLE 3 & SUPPLEMENTAL TABLE 2)
DATA ANALYST: Elizabeth Kolias
DATE CREATED: 21 February 2025
CHECKED BY: Kallisse Dent
STEPS:
1. Create an indicator that is a combination of those not missing information for the exposure and in the analytic cohort.
2. Perform baseline logistic regressions predicting midlife outcomes for self vs. neither group.
3. Perform adjusted logistic regressions predicting midlife outcomes for self vs. neither group.
4. Perform adjusted logistic regressions adjusting for each co-variate separately for the self vs. neither group.

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

*Create a new indicator (analytic_self_vs_neither) that includes participants in the general analytic cohort created in Step 5 who 
are not missing for the self_vs_neither_indicator created in Step 2.;
data analytic;
set out.dualharm_draft8_analyticcohort;
analytic_self_vs_neither = (analytic_cohort_indicator = 1 and self_vs_neither_indicator ne .);

*Create a specific indicator for employment variable analyses - limits to those who are in the labor force ; 
if w5_unemployed_new =. then analytic_labor =0 ; 
else analytic_labor=analytic_vs_neither;

run; *n = 12,057; *148 variables;


/***Table 3***/ 
*** BASELINE MODELS ; 
*Create a MACRO for baseline logistic regressions predicting midlife outcomes.;
%MACRO logistic_selfvneither(outcome);
proc surveylogistic data = analytic missing;
class self_vs_neither_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport(ref='1') w1_ethnicity(ref='0') /param=ref;
model &outcome. (event='1') = self_vs_neither_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses;
cluster PSUSCID;
strata Region;
weight GSW5;
domain analytic_self_vs_neither;
run;
%MEND;

*Run MACRO for baseline logistic regression predicting midlife suicidality.;
%logistic_selfvneither(w5_mh_suicidality_indicator);

*Run MACRO for baseline logistic regression predicting midlife upper quintile depressive symptoms.;
%logistic_selfvneither(w5_mh_dep_indicator);

*Run MACRO for baseline logistic regression predicting midlife substance misuse.;
%logistic_selfvneither(w5_mh_sub_indicator);

*Run MACRO for baseline logistic regression predicting fair/poor self-rated health.;
%logistic_selfvneither(w5_ph_genhlth_indicator);

*Run MACRO for baseline logistic regression predicting presence of a chronic disease.;
%logistic_selfvneither(w5_ph_chron_indicator_noresp);

*SENSITIVITY ANALYSIS: Run MACRO for baseline logistic regression predicting presence of a chronic disease INCLUDING RESPIRATORY CONDITIONS.;
%logistic_selfvneither(w5_ph_chron_indicator);

*Run MACRO for baseline logistic regression predicting married/cohabitating.;
%logistic_selfvneither(w5_soc_rel_indicator);

*Run MACRO for baseline logistic regression predicting victimization.;
%logistic_selfvneither(w5_soc_vict_indicator);

*Run MACRO for baseline logistic regression predicting UPDATED unemployment.;
*NOTE: we need to take this out of the macro since there is a different analytic indicator for this version due 
to analyses only being run among those in the labor force; 
proc surveylogistic data = analytic missing;
class self_vs_neither_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport(ref='1') w1_ethnicity(ref='0') /param=ref;
model w5_unemployed_new (event='1') = self_vs_neither_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses;
cluster PSUSCID;
strata Region;
weight GSW5;
domain analytic_labor;
run; 

*Run MACRO for baseline logistic regression predicting below the federal poverty threshold.;
%logistic_selfvneither(w5_se_poverty_indicator);

*Run MACRO for baseline logistic regression predicting loss of property.;
%logistic_selfvneither(w5_se_property);

***ADJUSTED MODELS;
 
%MACRO adjusted_selfvneither(outcome);
proc surveylogistic data = analytic missing;
class self_vs_neither_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport(ref='1') w1_ethnicity(ref='0') w3_cm_indicator(ref='0')/param=ref;
model &outcome. (event='1') = self_vs_neither_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses w1_selfcon_sum_prorate w3_cm_indicator w1_verbal_intel;
cluster PSUSCID;
strata Region;
weight GSW5;
domain analytic_self_vs_neither;
run;
%MEND;

%adjusted_selfvneither(w5_mh_suicidality_indicator); 
%adjusted_selfvneither(w5_mh_dep_indicator); 
%adjusted_selfvneither(w5_mh_sub_indicator); 
%adjusted_selfvneither(w5_ph_genhlth_indicator); 
%adjusted_selfvneither(w5_ph_chron_indicator_noresp); 
%adjusted_selfvneither(w5_ph_chron_indicator); 
%adjusted_selfvneither(w5_soc_rel_indicator); 
%adjusted_selfvneither(w5_soc_vict_indicator); 
%adjusted_selfvneither(w5_se_poverty_indicator); 
%adjusted_selfvneither(w5_se_property);

*Need to complete employment analysis outside of macro due to different
analytic indicator -- excludes those not in the labor force ; 
proc surveylogistic data = analytic missing;
class self_vs_neither_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport(ref='1') w1_ethnicity(ref='0') w3_cm_indicator(ref='0')/param=ref;
model w5_unemployed_new (event='1') = self_vs_neither_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses w1_selfcon_sum_prorate w3_cm_indicator w1_verbal_intel;
cluster PSUSCID;
strata Region;
weight GSW5;
domain analytic_labor;
run;


/***SUPPLEMENTAL TABLE 2***/ 

/**KD Creating macros for controlloing for each covariate separately**/ 
**Controlling only for self-control;  
%MACRO adjselfcononly_selfvneither(outcome);
proc surveylogistic data = analytic missing;
class self_vs_neither_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport(ref='1') w1_ethnicity(ref='0') /param=ref;
model &outcome. (event='1') = self_vs_neither_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses w1_selfcon_sum_prorate ;
cluster PSUSCID;
strata Region;
weight GSW5;
domain analytic_self_vs_neither;
run;
%MEND;
%adjselfcononly_selfvneither(w5_mh_suicidality_indicator); 
%adjselfcononly_selfvneither(w5_mh_dep_indicator); 
%adjselfcononly_selfvneither(w5_mh_sub_indicator); 
%adjselfcononly_selfvneither(w5_ph_genhlth_indicator); 
%adjselfcononly_selfvneither(w5_se_poverty_indicator); 

*Pulling out unemployement analysis; 
proc surveylogistic data = analytic missing;
class self_vs_neither_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport(ref='1') w1_ethnicity(ref='0') /param=ref;
model w5_unemployed_new (event='1') = self_vs_neither_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses w1_selfcon_sum_prorate ;
cluster PSUSCID;
strata Region;
weight GSW5;
domain analytic_labor;
run;

*Adjusting for childhood maltreatment only; 
%MACRO adjcmonly_selfvneither(outcome);
proc surveylogistic data = analytic missing;
class self_vs_neither_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport(ref='1') w1_ethnicity(ref='0')  w3_cm_indicator(ref='0')/param=ref;
model &outcome. (event='1') = self_vs_neither_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses  w3_cm_indicator ;
cluster PSUSCID;
strata Region;
weight GSW5;
domain analytic_self_vs_neither;
run;
%MEND;
%adjcmonly_selfvneither(w5_mh_suicidality_indicator); 
%adjcmonly_selfvneither(w5_mh_dep_indicator); 
%adjcmonly_selfvneither(w5_mh_sub_indicator); 
%adjcmonly_selfvneither(w5_ph_genhlth_indicator); 
%adjcmonly_selfvneither(w5_se_poverty_indicator); 

*pulling out unemployment analysis; 
proc surveylogistic data = analytic missing;
class self_vs_neither_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport(ref='1') w1_ethnicity(ref='0') w3_cm_indicator(ref='0')/param=ref;
model w5_unemployed_new (event='1') = self_vs_neither_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses  w3_cm_indicator ;
cluster PSUSCID;
strata Region;
weight GSW5;
domain analytic_labor;
run;

*Adjusting for cognitive ability only ; 
%MACRO adjcogonly_selfvneither(outcome);
proc surveylogistic data = analytic missing;
class self_vs_neither_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport(ref='1') w1_ethnicity(ref='0')  /param=ref;
model &outcome. (event='1') = self_vs_neither_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses  w1_verbal_intel ;
cluster PSUSCID;
strata Region;
weight GSW5;
domain analytic_self_vs_neither;
run;
%MEND;
%adjcogonly_selfvneither(w5_mh_suicidality_indicator); 
%adjcogonly_selfvneither(w5_mh_dep_indicator); 
%adjcogonly_selfvneither(w5_mh_sub_indicator); 
%adjcogonly_selfvneither(w5_ph_genhlth_indicator); 
%adjcogonly_selfvneither(w5_se_poverty_indicator); 

*pulling out unemployment variable; 
proc surveylogistic data = analytic missing;
class self_vs_neither_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport(ref='1') w1_ethnicity(ref='0') /param=ref;
model w5_unemployed_new (event='1') = self_vs_neither_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses w1_verbal_intel;
cluster PSUSCID;
strata Region;
weight GSW5;
domain analytic_labor;
run;

