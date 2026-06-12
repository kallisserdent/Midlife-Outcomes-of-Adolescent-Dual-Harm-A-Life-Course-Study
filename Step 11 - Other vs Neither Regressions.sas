/*******************************************************************************************************************
PROGRAM: STEP 8: DUAL HARM OUTCOMES - DUAL VS NEITHER REGRESSIONS (TABLE 3 & SUPPLEMENTAL TABLE 2)
DATA ANALYST: Elizabeth Kolias
DATE CREATED: 21 February 2025
CHECKED BY: Kallisse Dent
STEPS:
1. Create an indicator that is a combination of those not missing information for the exposure and in the analytic cohort.
2. Perform baseline logistic regressions predicting midlife outcomes for other vs. neither group.
3. Perform adjusted logistic regressions predicting midlife outcomes for other vs. neither group.
4. Perform adjusted logistic regressions adjusting for each co-variate separately for the other vs. neither group.

********************************************************************************************************************/
*KD adding SRW libname ; 
libname out 'P:\AddHealth\Contract\29042102-RichmondRakerd\Work\Elizabeth Kolias\Dual Harm Data' ; 

proc format;
	value harmf
	0 = 'neither harm'
	1 = 'other only'
	2 = 'self only'
	3 = 'dual harm';
run;

*Create a new indicator (analytic_other_vs_neither) that includes participants in the general analytic cohort created in Step 5 who 
are not missing for the other_vs_neither_indicator created in Step 2.;
data analytic;
set out.dualharm_draft8_analyticcohort;
analytic_other_vs_neither = (analytic_cohort_indicator = 1 and other_vs_neither_indicator ne .);

*Create a specific indicator for employment variable analyses - limits to those who are in the labor force ; 
if w5_unemployed_new =. then analytic_labor =0 ; 
else analytic_labor=analytic_vs_neither;
run; *n = 12,057; *148 variables;


/*** SUPPLEMENTAL TABLE 3 OUTPUT**/ 

*Create a MACRO for baseline logistic regressions predicting midlife outcomes.;
%MACRO logistic_othervneither (outcome);
proc surveylogistic data = analytic missing;
class other_vs_neither_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport(ref='1') w1_ethnicity(ref='0') /param=ref;
model &outcome. (event='1') = other_vs_neither_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses;
cluster PSUSCID;
strata Region;
weight GSW5;
domain analytic_other_vs_neither;
run;
%MEND;

*Run MACRO for baseline logistic regression predicting midlife suicidality.;
%logistic_othervneither(w5_mh_suicidality_indicator);

*Run MACRO for baseline logistic regression predicting midlife depression.;
%logistic_othervneither(w5_mh_dep_indicator);

*Run MACRO for baseline logistic regression predicting midlife substance misuse.;
%logistic_othervneither(w5_mh_sub_indicator);

*Run MACRO for baseline logistic regression predicting fair/poor midlife health.;
%logistic_othervneither(w5_ph_genhlth_indicator);

*Run MACRO for baseline logistic regression predicting presence of a chronic disease at midlife.;
%logistic_othervneither(w5_ph_chron_indicator_noresp);

*Run MACRO for baseline logistic regression predicting presence of a chronic disease INCLUDING RESPIRATORY DISEASES at midlife.;
%logistic_othervneither(w5_ph_chron_indicator);

*Run MACRO for baseline logistic regression predicting married/cohabitating at midlife.;
%logistic_othervneither(w5_soc_rel_indicator);

*Run MACRO for baseline logistic regression predicting victimization at midlife.;
%logistic_othervneither(w5_soc_vict_indicator);


*Run MACRO for baseline logistic regression predicting  unemployment at midlife.;
*Need to run analysis outside of macro for employment variable b/c it is a diffent 
subpopulation = different domain statement variable - excluding those that are not in the labor force ; 
proc surveylogistic data = analytic missing;
class other_vs_neither_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport(ref='1') w1_ethnicity(ref='0') /param=ref;
model w5_unemployed_new (event='1') = other_vs_neither_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses;
cluster PSUSCID;
strata Region;
weight GSW5;
domain analytic_labor;
run;

*Run MACRO for baseline logistic regression predicting below the federal poverty threshold at midlife.;
%logistic_othervneither(w5_se_poverty_indicator);

*Run MACRO for baseline logistic regression predicting loss of property at midlife.;
%logistic_othervneither(w5_se_property);

**Adjusted analyses; 
%MACRO adjusted_othervneither (outcome);
proc surveylogistic data = analytic missing;
class other_vs_neither_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport(ref='1') w1_ethnicity(ref='0') w3_cm_indicator(ref='0') /param=ref;
model &outcome. (event='1') = other_vs_neither_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses w1_selfcon_sum_prorate w3_cm_indicator w1_verbal_intel;
cluster PSUSCID;
strata Region;
weight GSW5;
domain analytic_other_vs_neither;
run;
%MEND;
%adjusted_othervneither(w5_mh_suicidality_indicator); 
%adjusted_othervneither(w5_mh_dep_indicator); 
%adjusted_othervneither(w5_mh_sub_indicator); 
%adjusted_othervneither(w5_ph_genhlth_indicator); 
%adjusted_othervneither(w5_ph_chron_indicator_noresp); 
%adjusted_othervneither(w5_ph_chron_indicator); 
%adjusted_othervneither(w5_soc_rel_indicator); 
%adjusted_othervneither(w5_soc_vict_indicator); 
%adjusted_othervneither(w5_se_poverty_indicator); 
%adjusted_othervneither(w5_se_property);

*Breaking out unemployed analyses; 
proc surveylogistic data = analytic missing;
class other_vs_neither_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport(ref='1') w1_ethnicity(ref='0') w3_cm_indicator(ref='0') /param=ref;
model w5_unemployed_new (event='1') = other_vs_neither_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses w1_selfcon_sum_prorate w3_cm_indicator w1_verbal_intel;
cluster PSUSCID;
strata Region;
weight GSW5;
domain analytic_labor;
run;


/**SUPPLEMENTAL TABLE 2**/ 
*Adjusting for self-control only - limiting analysis to outcomes that were statistically significant at baseline ;  
%MACRO adjselfcononly_othervneither (outcome);
proc surveylogistic data = analytic missing;
class other_vs_neither_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport(ref='1') w1_ethnicity(ref='0')  /param=ref;
model &outcome. (event='1') = other_vs_neither_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses w1_selfcon_sum_prorate;
cluster PSUSCID;
strata Region;
weight GSW5;
domain analytic_other_vs_neither;
run;
%MEND;
%adjselfcononly_othervneither(w5_mh_suicidality_indicator); 
%adjselfcononly_othervneither(w5_mh_dep_indicator); 
%adjselfcononly_othervneither(w5_mh_sub_indicator); 
%adjselfcononly_othervneither(w5_ph_genhlth_indicator); 
%adjselfcononly_othervneither(w5_soc_vict_indicator); 
%adjselfcononly_othervneither(w5_se_poverty_indicator); 
%adjselfcononly_othervneither(w5_se_property);
*Breaking out unemployed; 
proc surveylogistic data = analytic missing;
class other_vs_neither_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport(ref='1') w1_ethnicity(ref='0') /param=ref;
model w5_unemployed_new (event='1') = other_vs_neither_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses w1_selfcon_sum_prorate ;
cluster PSUSCID;
strata Region;
weight GSW5;
domain analytic_labor;
run;

**adjusting for childhood maltreatment only ; 
%MACRO adjcmonly_othervneither (outcome);
proc surveylogistic data = analytic missing;
class other_vs_neither_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport(ref='1') w1_ethnicity(ref='0') w3_cm_indicator(ref='0')  /param=ref;
model &outcome. (event='1') = other_vs_neither_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses w3_cm_indicator ;
cluster PSUSCID;
strata Region;
weight GSW5;
domain analytic_other_vs_neither;
run;
%MEND;
%adjcmonly_othervneither(w5_mh_suicidality_indicator); 
%adjcmonly_othervneither(w5_mh_dep_indicator); 
%adjcmonly_othervneither(w5_mh_sub_indicator); 
%adjcmonly_othervneither(w5_ph_genhlth_indicator); 
%adjcmonly_othervneither(w5_soc_vict_indicator); 
%adjcmonly_othervneither(w5_se_poverty_indicator); 
%adjcmonly_othervneither(w5_se_property);

*Breaking out unemployment; 
proc surveylogistic data = analytic missing;
class other_vs_neither_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport(ref='1') w1_ethnicity(ref='0') w3_cm_indicator(ref='0') /param=ref;
model w5_unemployed_new (event='1') = other_vs_neither_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses  w3_cm_indicator ;
cluster PSUSCID;
strata Region;
weight GSW5;
domain analytic_labor;
run;

*Macro for adjusting for cognitive ability only ; 
%MACRO adjintelonly_othervneither (outcome);
proc surveylogistic data = analytic missing;
class other_vs_neither_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport(ref='1') w1_ethnicity(ref='0')   /param=ref;
model &outcome. (event='1') = other_vs_neither_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses w1_verbal_intel ;
cluster PSUSCID;
strata Region;
weight GSW5;
domain analytic_other_vs_neither;
run;
%MEND;
%adjintelonly_othervneither(w5_mh_suicidality_indicator);
%adjintelonly_othervneither(w5_mh_dep_indicator); 
%adjintelonly_othervneither(w5_mh_sub_indicator); 
%adjintelonly_othervneither(w5_ph_genhlth_indicator); 
%adjintelonly_othervneither(w5_soc_vict_indicator); 
%adjintelonly_othervneither(w5_se_poverty_indicator); 
%adjintelonly_othervneither(w5_se_property);

*Breaking out unemployment; 
proc surveylogistic data = analytic missing;
class other_vs_neither_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport(ref='1') w1_ethnicity(ref='0') /param=ref;
model w5_unemployed_new (event='1') = other_vs_neither_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses  w1_verbal_intel;
cluster PSUSCID;
strata Region;
weight GSW5;
domain analytic_labor;
run;

