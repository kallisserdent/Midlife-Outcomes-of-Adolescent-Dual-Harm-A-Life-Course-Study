/*******************************************************************************************************************
PROGRAM: STEP 3: DUAL HARM OUTCOMES - MIDLIFE OUTCOMES
DATA ANALYST: Elizabeth Kolias
DATE CREATED: 1 NOVEMBER 2024
CHECKED BY: Kallisse Dent
STEPS:
1. Create indicators for Wave V binary outcomes.
**See new unemployment indicator added on 5/15/2025, was also updated again on 1/21/2026 during 
final preparation of manuscript to correct a mistake and align with approaches used by others 
on the research team**
2. Create an indicator for upper quintile depressive symptoms at Wave V.
********************************************************************************************************************/
*SRW libname statement; 
libname out 'P:\AddHealth\Contract\29042102-RichmondRakerd\Work\Elizabeth Kolias\Dual Harm Data' ; 

*Load harmf format;
proc format;
	value harmf
	0 = 'neither harm'
	1 = 'other only'
	2 = 'self only'
	3 = 'dual harm';
run;

data dualharm_draft6_midlifeoutcomes;
set out.dualharm_draft5_dualharmgroups;

*Create an indicator for suicidality that includes 1+ past-year suicide attempt.;
	w5_mh_suicidality_indicator = (w5_mh_suicidality > 1); if w5_mh_suicidality = . then w5_mh_suicidality_indicator = .;

**Prep of CES-D 5 information; 
*Reverse code the happiness item of the CES-D-5 scale.;
	w5_mh_dep_happy_recod = 5 - w5_mh_dep_happy; if w5_mh_dep_happy = . then w5_mh_dep_happy_recod = .;
*Create a sum score for depressive symptoms using all items from the CES-D-5 scale. Note that this sum will treat missing values as 0.;
	w5_mh_dep_sum = sum(w5_mh_dep_blues, w5_mh_dep_depressed, w5_mh_dep_happy_recod, w5_mh_dep_sad, w5_mh_dep_life);
*Create a variable that counts the number of items with missing responses on the CES-D-5 scale. Then exclude participants with over 50% of items missing.;
	depression_Nmiss = nmiss(w5_mh_dep_blues, w5_mh_dep_depressed, w5_mh_dep_happy_recod, w5_mh_dep_sad, w5_mh_dep_life);
	w5_mh_dep_sum_exc = w5_mh_dep_sum;
	if depression_Nmiss > 2 then w5_mh_dep_sum_exc = .;
*Pro-rate the depression sum scores.;
	depression_Nrespond = 5 - depression_Nmiss;
	w5_mh_dep_sum_prorate = (5/depression_Nrespond)*w5_mh_dep_sum_exc;
	if w5_mh_dep_sum_exc = . then w5_dep_sum_prorate = .;
*Will create an indicator for upper quintile depressive symptoms in the next code chunk.;

**Creating other W5 indicator variables; 
*Create an indicator for binge drinking that includes drinking heavily 3+ days per week in the past year.;
	w5_mh_sub_binge_indicator = (w5_mh_sub_binge in (5,6)); if w5_mh_sub_binge = . then w5_mh_sub_binge_indicator = .;
*Create an indicator for heavy marijuana use that includes marijuana use every day or nearly every day.;
	w5_mh_sub_marijuana_indicator = (w5_mh_sub_marijuana=6); if w5_mh_sub_marijuana = . then w5_mh_sub_marijuana_indicator = .;
*Create an indicator for any substance misuse that includes any binge drinking, heavy marijuana use, prescription misuse (sedatives, 
	tranquilizers, or stimulants), opioid misuse, or illicit drug use (cocaine, meth, heroin, or other).
	All variables other than marijuana and binge drinking are any illicit use or presrciption misuse in the past 30 days (1=any);
	w5_mh_sub_indicator = (w5_mh_sub_binge_indicator = 1 or w5_mh_sub_marijuana_indicator = 1 or w5_mh_sub_pres_sedatives = 1 or 
	w5_mh_sub_pres_tranquilizers = 1 or w5_mh_sub_pres_stimulants = 1 or w5_mh_sub_opioids = 1 or w5_mh_sub_cocaine = 1 or 
	w5_mh_sub_meth = 1 or w5_mh_sub_heroin = 1 or w5_mh_sub_otherillegal = 1);
	*Similar approach as earlier for coding missing - those coded as not having substance use but with one or more variables as missing
	are coded as missing due to likely reporting bias. ; 
	if w5_mh_sub_indicator = 0 and (w5_mh_sub_binge_indicator = . or w5_mh_sub_marijuana_indicator = . or w5_mh_sub_pres_sedatives = . or 
	w5_mh_sub_pres_tranquilizers = . or w5_mh_sub_pres_stimulants = . or w5_mh_sub_opioids = . or w5_mh_sub_cocaine = . or 
	w5_mh_sub_meth = . or w5_mh_sub_heroin = . or w5_mh_sub_otherillegal = .) then w5_mh_sub_indicator = .;

*Create an indicator for fair/poor health;
	w5_ph_genhlth_indicator = (w5_ph_general = 4 or w5_ph_general = 5);
	if w5_ph_general = . then w5_ph_genhlth_indicator = .;

*Create an indicator for the presence of any chronic disease, including cancer, diabetes, heart disease, heart failure, blood clot, 
	atrial fibrillation, aortic aneurysm, arterial disease, stroke, kidney disease, and respiratory disease. We excluded those with 
	missing responses for all indicators. (This indicator will be used in sensitivity analyses);
	w5_ph_chron_indicator = (w5_ph_chron_cancer = 1 or w5_ph_chron_diabetes = 1 or w5_ph_chron_heart_disease = 1 or w5_ph_chron_heart_failure = 1 or 
	w5_ph_chron_heart_clot = 1 or w5_ph_chron_heart_afib = 1 or w5_ph_chron_heart_aneur = 1 or w5_ph_chron_heart_arterial = 1 or w5_ph_chron_stroke = 1 or 
	w5_ph_chron_kidney = 1 or w5_ph_chron_respiratory = 1);
 
	if w5_ph_chron_cancer = . and w5_ph_chron_diabetes = . and w5_ph_chron_heart_disease = . and w5_ph_chron_heart_failure = . and 
	w5_ph_chron_heart_clot = . and w5_ph_chron_heart_afib = . and w5_ph_chron_heart_aneur = . and w5_ph_chron_heart_arterial = . and 
	w5_ph_chron_stroke = . and w5_ph_chron_kidney = . and w5_ph_chron_respiratory = . then w5_ph_chron_indicator = .;
*Create an indicator for the presence of any chronic disease listed above excluding respiratory disease (this is the primary indicator that 
	we will use);
	w5_ph_chron_indicator_noresp = (w5_ph_chron_cancer = 1 or w5_ph_chron_diabetes = 1 or w5_ph_chron_heart_disease = 1 or w5_ph_chron_heart_failure = 1 or 
	w5_ph_chron_heart_clot = 1 or w5_ph_chron_heart_afib = 1 or w5_ph_chron_heart_aneur = 1 or w5_ph_chron_heart_arterial = 1 or w5_ph_chron_stroke = 1 or 
	w5_ph_chron_kidney = 1);
	if w5_ph_chron_cancer = . and w5_ph_chron_diabetes = . and w5_ph_chron_heart_disease = . and w5_ph_chron_heart_failure = . and 
	w5_ph_chron_heart_clot = . and w5_ph_chron_heart_afib = . and w5_ph_chron_heart_aneur = . and w5_ph_chron_heart_arterial = . and 
	w5_ph_chron_stroke = . and w5_ph_chron_kidney = . then w5_ph_chron_indicator = .;

*Create an indicator for relationship status that includes individuals who are married or cohabiting with a partner.;
	w5_soc_rel_indicator = (w5_soc_rel_married = 1 or w5_soc_rel_cohabit = 1);
	if w5_soc_rel_married = . and w5_soc_rel_cohabit in(.,97) then w5_soc_rel_indicator = .;

*Create an indicator for any victimization that includes someone pulling a knife/gun on you, being shot/stabbed, being slapped/hit/choked/kicked, 
	or being beaten up. Among those who do not endorse viticmization code missing if any variables are missing ;
	w5_soc_vict_indicator = (w5_soc_vict_knife = 1 or w5_soc_vict_shot = 1 or w5_soc_vict_slap = 1 or w5_soc_vict_beat = 1);
	if w5_soc_vict_indicator = 0 and (w5_soc_vict_knife = . or w5_soc_vict_shot = . or w5_soc_vict_slap = . or w5_soc_vict_beat = .) 
	then w5_soc_vict_indicator = .;

*Recode household income. If household income is legitimately skipped (997), the participant resides on their own. Use individual income instead.;
	w5_se_householdincome = w5_se_houseincome;
	if w5_se_houseincome in(., 998) then w5_se_householdincome = .;
	if w5_se_houseincome = 997 then w5_se_householdincome = w5_se_income;
*Create a measure of total household size. w5_se_householdsize measures the number of co-residents, so we need to add 1 to get the total household 
	size that includes the respondent. 997 means that the respondent is homeless or lives in group housing, so their total household size will be coded as 1.;
	w5_se_totalhouseholdsize = w5_se_householdsize + 1;
	if w5_se_householdsize = 997 then w5_se_totalhouseholdsize = 1;
	if w5_se_householdsize = . then w5_se_totalhouseholdsize = .;
*Create an indicator for earning below the federal poverty threshold of the 48 contiguous states in 2018 based on household size.;
	if w5_se_totalhouseholdsize = 1 and w5_se_householdincome < 4 and w5_se_householdincome ne . then w5_se_poverty_indicator = 1;
	else if w5_se_totalhouseholdsize = 2 and w5_se_householdincome < 5 and w5_se_householdincome ne . then w5_se_poverty_indicator = 1;
	else if w5_se_totalhouseholdsize = 3 and w5_se_householdincome < 6 and w5_se_householdincome ne . then w5_se_poverty_indicator = 1;
	else if w5_se_totalhouseholdsize in(4,5) and w5_se_householdincome < 7 and w5_se_householdincome ne . then w5_se_poverty_indicator = 1;
	else if w5_se_totalhouseholdsize in(6,7) and w5_se_householdincome < 8 and w5_se_householdincome ne . then w5_se_poverty_indicator = 1;
	else if w5_se_totalhouseholdsize in(8,9) and w5_se_householdincome < 9 and w5_se_householdincome ne . then w5_se_poverty_indicator = 1;
	else if w5_se_totalhouseholdsize > 9 and w5_se_householdincome < 10 and w5_se_householdincome ne . then w5_se_poverty_indicator = 1;
	else if w5_se_totalhouseholdsize = . or w5_se_householdincome = . then w5_se_poverty_indicator = .;
	else w5_se_poverty_indicator = 0;

*Create an indicator for unemployed, which includes those who are only temporarily laid off or unemployed and looking for work. The federal 
	definition of unemployment only includes those who are in the labor force. Therefore this indicator will be missing and we will 
	run sub-analyses only among those who are in the labor force;
	/*NOTE: 1/20/26: re-working to continue using w5_se_workstatus, but drop out 
		    individuals who aren't in the labor force (by setting unemployment to missing
		    and creating a subpopulation specific to this analysis that excludes them). 
		    This will affect individuals with w5_se_workstatus = 4, 6, 7, 8, 9, 10 - that is, 
		    permanently disabled, unemployed+not looking for work,student, keeping house,
		    retired, and other. */ 

	if w5_se_employment=1 then w5_notworkpay=0; 
		else if w5_se_employment in(2,3) then w5_notworkpay=1; 
		else w5_notworkpay=.; /* keeping just for QA */ 

	/* Create variable to be used in analysis - !!! NOTE REVISION 1/20/26 !!!
			Previouslty we treated all leg-skip as employed, but some individuals who were 
			missing for w5_se_employment were treated as leg-skip for w5_se_workstatus for unknown reasons. We 
			want to treat them as MISSING rather than unemployed=0. So revising 2nd line
		    below to do that. */ 

	if w5_se_workstatus in(1,5) then w5_unemployed_new=1; /* 1=laid off, 5=unemployed and looking for work*/ 
	 	else if w5_se_workstatus in(4,6,7,8,9,10) or w5_se_workstatus=. or w5_se_employment=. then w5_unemployed_new=.; /* not in work force */ 
	 	else w5_unemployed_new =0; /* OTHERWISE, enforce that leg-skip, temporarily disabled/sick leave, 
								  and maternity/paternity all have unemployed = 0 = we are counting them as employed  */ 


*Loss of property does not need to be re-coded.;

run; *n = 12,300; *122 variables;

*Save a copy of the dataset created in library.;
data out.dualharm_draft6_midlifeoutcomes;
set dualharm_draft6_midlifeoutcomes;
run; *n = 12,300; *123 variables; *Looks good;

*Create an indicator for upper quintile of depressive symptoms. First, divide depressive symptom scores into quintiles.;
proc rank data = out.dualharm_draft6_midlifeoutcomes
out = analytic_quantiles
groups = 5;
var w5_mh_dep_sum_prorate;
ranks dep_quintile;
run;

*Second, create the indicator for upper quintile depressive symptoms.;
data analytic_quantiles2;
set analytic_quantiles;
w5_mh_dep_indicator = (dep_quintile = 4);
if dep_quintile = . then w5_mh_dep_indicator = .;
run; *n = 12,300;

*Save a copy of the updated dataset in library.;
data out.dualharm_draft6_midlifeoutcomes;
set analytic_quantiles2;
run; *n = 12,300; *124 variables; *Looks good;

