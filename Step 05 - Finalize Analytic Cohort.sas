/*******************************************************************************************************************
PROGRAM: STEP 5: DUAL HARM OUTCOMES - FINALIZE ANALYTIC COHORT
DATA ANALYST: Elizabeth Kolias
DATE CREATED: 17 January 2025
CHECKED BY: Kallisse Dent
STEPS:
1. Make a list of all the variables I will use in the fully adjusted model.
2. Exclude participants missing data on sampling weight/cluster variables.
3. Exclude participants missing data on demographic variables.
4. Exclude participants missing data on covariates.
5. Exclude participants missing data on predictors.
6. Exclude participants missing data on outcomes.
7. Create final analytic cohort inclusion/exclusion variable. 
********************************************************************************************************************/
*SRW libname statement; 
libname out 'P:\AddHealth\Contract\29042102-RichmondRakerd\Work\Elizabeth Kolias\Dual Harm Data' ; 
proc contents data = out.dualharm_draft7_covariates; run; *n = 12,300; *144 variables;

/*Make a list of all the variables I will use in the fully adjusted model.

aid
GSW5
PSUSCID
REGION

w1_age
w1_sex
w1_race_selfreport
w1_ethnicity
w1_ses

w1_selfcon_sum_prorate
w3_cm_indicator
w1_verbal_intel

dual_self_indicator
dual_other_indicator

w5_mh_suicidality_indicator
w5_mh_dep_indicator
w5_mh_sub_indicator

w5_ph_genhlth_indicator
w5_ph_chron_indicator_noresp

w5_soc_rel_indicator
w5_soc_vict_indicator

w5_se_poverty_indicator
w5_se_unemployment_indicator
w5_se_property*/

*Run format.;
proc format;
	value harmf
	0 = 'neither harm'
	1 = 'other only'
	2 = 'self only'
	3 = 'dual harm';
run;

**Information from the following code was used to generate information found in SUPPLEMENTAL 
FIGURE 1 ;


*Exclude participants missing data on sampling weight/cluster variables.;
data dualharm_draft8a_missing_wts;
set out.dualharm_draft7_covariates;
if aid = '' or GSW5 = . or PSUSCID = '' or REGION = . then analytic_cohort_indicator1 = 0;
else analytic_cohort_indicator1 = 1;
run; *n = 12,300;

proc freq data = dualharm_draft8a_missing_wts; tables analytic_cohort_indicator1; run; *243 excluded;

data dualharm_draft8a_missing_wts;
set dualharm_draft8a_missing_wts;
where analytic_cohort_indicator1 = 1;
run; *n = 12,057;

*Exclude participants missing data on demographic variables.;
data dualharm_draft8b_missing_dems;
set dualharm_draft8a_missing_wts;
if w1_age = . or w1_sex = . or w1_race_selfreport = . or w1_ethnicity = . or w1_ses = . then analytic_cohort_indicator2 = 0;
else analytic_cohort_indicator2 = 1;
run;

proc freq data = dualharm_draft8b_missing_dems; tables analytic_cohort_indicator1 analytic_cohort_indicator2; run; *730 excluded;

data dualharm_draft8b_missing_dems;
set dualharm_draft8b_missing_dems;
where analytic_cohort_indicator2 = 1;
run; *n = 11,327;

*Exclude participants missing data on predictors.;
data dualharm_draft8c_missing_pred;
set dualharm_draft8b_missing_dems;
if dual_self_indicator = . or dual_other_indicator = . then analytic_cohort_indicator3 = 0;
else analytic_cohort_indicator3 = 1;
run;

proc freq data = dualharm_draft8c_missing_pred; tables analytic_cohort_indicator1 analytic_cohort_indicator2 analytic_cohort_indicator3; run; *18 excluded;

data dualharm_draft8c_missing_pred;
set dualharm_draft8c_missing_pred;
where analytic_cohort_indicator3 = 1;
run; *n = 11,309;

*Exclude participants missing data on covariates.;
data dualharm_draft8d_missing_cov;
set dualharm_draft8c_missing_pred;
if w1_selfcon_sum_prorate = . or w3_cm_indicator = . or w1_verbal_intel = . then analytic_cohort_indicator4 = 0;
else analytic_cohort_indicator4 = 1;
run;

proc freq data = dualharm_draft8d_missing_cov; tables analytic_cohort_indicator1 analytic_cohort_indicator2 analytic_cohort_indicator3 analytic_cohort_indicator4; run; *2,703 excluded;

data dualharm_draft8d_missing_cov;
set dualharm_draft8d_missing_cov;
where analytic_cohort_indicator4 = 1;
run; *n = 8,606;

*Exclude participants missing data on outcomes.;
data dualharm_draft8e_missing_outcome;
set dualharm_draft8d_missing_cov;
if w5_mh_suicidality_indicator = . or w5_mh_dep_indicator = . or w5_mh_sub_indicator = . or 
w5_ph_genhlth_indicator = . or w5_ph_chron_indicator_noresp = . or 
w5_soc_rel_indicator = . or w5_soc_vict_indicator = . or 
w5_se_poverty_indicator = . or w5_se_unemployment_indicator = . or w5_se_property = . 
then analytic_cohort_indicator5 = 0;
else analytic_cohort_indicator5 = 1;
run;

proc freq data = dualharm_draft8e_missing_outcome; tables analytic_cohort_indicator1 analytic_cohort_indicator2 analytic_cohort_indicator3 analytic_cohort_indicator4 analytic_cohort_indicator5; run; *1,016 excluded;

data dualharm_draft8e_missing_outcome;
set dualharm_draft8e_missing_outcome;
where analytic_cohort_indicator5 = 1;
run; *n = 7,590;

*Create a new permanent dataset that excludes participants without data on complex survey design variables.;
data out.dualharm_draft8_csdmissing;
set out.dualharm_draft7_covariates;
if aid = '' or GSW5 = . or PSUSCID = '' or REGION = . then csd = 0;
else csd = 1;
run;*n = 12,300;

proc freq data = out.dualharm_draft8_csdmissing; tables csd; run; *243 excluded.;

data out.dualharm_draft8_csdmissing;
set out.dualharm_draft8_csdmissing;
where csd = 1;
run; *n = 12,057; *145 variables.;

*Create final analytic cohort with inclusion/exclusion variable.;
data out.dualharm_draft8_analyticcohort;
set out.dualharm_draft8_csdmissing;
if w1_age = . or w1_sex = . or w1_race_selfreport = . or w1_ethnicity = . or w1_ses = . or 
w1_selfcon_sum_prorate = . or w3_cm_indicator = . or w1_verbal_intel = . or dual_self_indicator = . or dual_other_indicator = . or 
w5_mh_suicidality_indicator = . or w5_mh_dep_indicator = . or w5_mh_sub_indicator = . or 
w5_ph_genhlth_indicator = . or w5_ph_chron_indicator_noresp = . or 
w5_soc_rel_indicator = . or w5_soc_vict_indicator = . or 
w5_se_poverty_indicator = . or w5_se_unemployment_indicator = . or w5_se_property = . 
then analytic_cohort_indicator = 0;
else analytic_cohort_indicator = 1;
run; *n = 12,057; *146 variables;

proc freq data = out.dualharm_draft8_analyticcohort; tables analytic_cohort_indicator; run; *n = 7,590 included in analytic cohort.;

