/*******************************************************************************************************************
PROGRAM: STEP 10: DUAL HARM OUTCOMES - DUAL VS OTHER REGRESSIONS (MIDLIFE OUTCOMES OF ADOLESCENTS WITH DUAL HARM RELATIVE TO OTHER-HARM ONLY; SUPPLEMENTAL TABLES 2 & 3)
DATA ANALYST: Elizabeth Kolias
DATE CREATED: 3 February 2025
CHECKED BY: Kallisse Dent
STEPS:
1. Create an indicator that is a combination of those not missing information for the exposure and in the analytic cohort.
2. Perform baseline logistic regressions predicting midlife outcomes for dual vs. other group.
3. Perform adjusted logistic regressions predicting midlife outcomes for dual vs. other group.
4. Perform adjusted logistic regressions adjusting for each co-variate separately for the dual vs. other group.;

********************************************************************************************************************/
*SRW libname; 
libname out 'P:\AddHealth\Contract\29042102-RichmondRakerd\Work\Elizabeth Kolias\Dual Harm Data';

proc format;
	value harmf
	0 = 'neither harm'
	1 = 'other only'
	2 = 'self only'
	3 = 'dual harm';
run;

*Create a new indicator (analytic_vs_other) that includes participants in the general analytic cohort created in Step 5 who 
are not missing for the dual_vs_other_indicator created in Step 2.;
data analytic; 
set out.dualharm_draft8_analyticcohort; 
analytic_vs_other = (analytic_cohort_indicator = 1 and dual_vs_other_indicator ne . ); 
run; *n = 12,057; *148 variables;
 
/*** SUPPLEMENTAL TABLE 3 OUTPUT ***/ 

*Create a MACRO for baseline logistic regressions predicting midlife outcomes.;
%MACRO logistic_dualvother(outcome);
proc surveylogistic data = analytic missing; 
class dual_vs_other_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport (ref='1') w1_ethnicity(ref='0') /param=ref; 
model &outcome. (event='1') = dual_vs_other_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses ; 
cluster PSUSCID ; 
strata Region ; 
weight GSW5 ; 
domain analytic_vs_other; 
run;
%MEND;

*Cannot run associations with suicidality due to low counts; 

*Run MACRO for baseline logistic regression predicting midlife depression.;
%logistic_dualvother(w5_mh_dep_indicator);

*Run MACRO for baseline logistic regression predicting midlife substance misuse.;
%logistic_dualvother(w5_mh_sub_indicator);

*Run MACRO for baseline logistic regression predicting midlife fair/poor self-rated health.;
%logistic_dualvother(w5_ph_genhlth_indicator);

*Run MACRO for baseline logistic regression predicting midlife presence of a chronic health condition.;
%logistic_dualvother(w5_ph_chron_indicator_noresp);

*Run MACRO for baseline logistic regression predicting midlife presence of a chronic health condition INCLUDING RESPIRATORY CONDITIONS.;
%logistic_dualvother(w5_ph_chron_indicator);

*Run MACRO for baseline logistic regression predicting midlife married/cohabitating.;
%logistic_dualvother(w5_soc_rel_indicator);

*Run MACRO for baseline logistic regression predicting midlife victimization.;
%logistic_dualvother(w5_soc_vict_indicator);

*Cannot run associations with employment due to low cell counts; 

*Run MACRO for baseline logistic regression predicting below the federal poverty line in midlife.;
%logistic_dualvother(w5_se_poverty_indicator);

*Run MACRO for baseline logistic regression predicting loss of property in midlife.;
%logistic_dualvother(w5_se_property);

*Adjusted analyses; 
%MACRO adjusted_dualvother(outcome);
proc surveylogistic data = analytic missing; 
class dual_vs_other_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport (ref='1') w1_ethnicity(ref='0')  w3_cm_indicator(ref='0') /param=ref; 
model &outcome. (event='1') = dual_vs_other_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses w1_selfcon_sum_prorate w3_cm_indicator w1_verbal_intel; 
cluster PSUSCID ; 
strata Region ; 
weight GSW5 ; 
domain analytic_vs_other; 
run;
%MEND;

%adjusted_dualvother(w5_mh_dep_indicator); 
%adjusted_dualvother(w5_mh_sub_indicator); 
%adjusted_dualvother(w5_ph_genhlth_indicator); 
%adjusted_dualvother(w5_ph_chron_indicator_noresp); 
%adjusted_dualvother(w5_ph_chron_indicator); 
%adjusted_dualvother(w5_soc_rel_indicator); 
%adjusted_dualvother(w5_soc_vict_indicator); 
%adjusted_dualvother(w5_se_poverty_indicator); 
%adjusted_dualvother(w5_se_property);

/**SUPPLEMENTAL TABLE 2 OUTPUT**/ 

**Run logistic regressions predicting suicidality at midlife adjusting for adolescent self-control, childhood maltreatment, and adolescent cognitive ability separately.;
*Adjusting for self-control only; 
%MACRO adjcontrolonly_dualvother(outcome);
proc surveylogistic data = analytic missing; 
class dual_vs_other_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport (ref='1') w1_ethnicity(ref='0')   /param=ref; 
model &outcome. (event='1') = dual_vs_other_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses w1_selfcon_sum_prorate ; 
cluster PSUSCID ; 
strata Region ; 
weight GSW5 ; 
domain analytic_vs_other; 
run;
%MEND;
%adjcontrolonly_dualvother(w5_mh_dep_indicator); 
%adjcontrolonly_dualvother(w5_se_poverty_indicator); 

*adjusting for child maltreatment only ; 
%MACRO adjcmonly_dualvother(outcome);
proc surveylogistic data = analytic missing; 
class dual_vs_other_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport (ref='1') w1_ethnicity(ref='0')  w3_cm_indicator(ref='0')  /param=ref; 
model &outcome. (event='1') = dual_vs_other_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses w3_cm_indicator  ; 
cluster PSUSCID ; 
strata Region ; 
weight GSW5 ; 
domain analytic_vs_other; 
run;
%MEND; 
%adjcmonly_dualvother(w5_mh_dep_indicator); 
%adjcmonly_dualvother(w5_se_poverty_indicator); 

*adjusting for cognitive ability only ; 
%MACRO adjcogonly_dualvother(outcome);
proc surveylogistic data = analytic missing; 
class dual_vs_other_indicator (ref='0') w1_sex(ref='2') w1_race_selfreport (ref='1') w1_ethnicity(ref='0')   /param=ref; 
model &outcome. (event='1') = dual_vs_other_indicator w1_sex w1_race_selfreport w1_ethnicity w1_age w1_ses w1_verbal_intel ; 
cluster PSUSCID ; 
strata Region ; 
weight GSW5 ; 
domain analytic_vs_other; 
run;
%MEND;
%adjcogonly_dualvother(w5_mh_dep_indicator); 
%adjcogonly_dualvother(w5_se_poverty_indicator); 

