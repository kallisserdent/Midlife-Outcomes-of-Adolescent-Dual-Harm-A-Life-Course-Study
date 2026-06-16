/*******************************************************************************************************************
PROGRAM: STEP 4: DUAL HARM OUTCOMES - COVARIATES
DATA ANALYST: Elizabeth Kolias
DATE CREATED: 11 NOVEMBER 2024
CHECKED BY: Kallisse Dent
STEPS:
1. Create indicators for adolescent self-control and childhood maltreatment.
2. Create age, sex, race, and ethnicity indicators.


********************************************************************************************************************/
*SRW libname statement; 
libname out 'P:\AddHealth\Contract\29042102-RichmondRakerd\Work\Elizabeth Kolias\Dual Harm Data' ; 

proc format;
	value harmf
	0 = 'neither harm'
	1 = 'other only'
	2 = 'self only'
	3 = 'dual harm';
run;

data dualharm_draft7_covariates;
set out.dualharm_draft6_midlifeoutcomes;

*Rescale items on the self-control scale so that each ranges from 0 to 1.;
w1_selfcon_mind_recod = w1_selfcon_mind / 3; if w1_selfcon_mind in(6, 8) then w1_selfcon_mind_recod = .;
w1_selfcon_teacher_recod = w1_selfcon_teacher / 4; if w1_selfcon_teacher in(6, 7, 8) then w1_selfcon_teacher_recod = .;
w1_selfcon_school_recod = w1_selfcon_school / 4; if w1_selfcon_school in(6, 7, 8) then w1_selfcon_school_recod = .;
w1_selfcon_hw_recod = w1_selfcon_hw / 4; if w1_selfcon_hw in(6, 7, 8) then w1_selfcon_hw_recod = .;
*This indicator for doing things just right = need to rescale so that responses start at 0 instead of 1 to align with other indicators 
**Note: This question is asked about good self control rather than poor self-control, however, the responses are also in the reverse order 
so reverse coding is not needed -> higher scores correspond to poorer self-control; 
w1_selfcon_justright_rescal = w1_selfcon_justright - 1; if w1_selfcon_justright in(6, 8) then w1_selfcon_justright_rescal = .;
w1_selfcon_justright_recod = w1_selfcon_justright_rescal / 4; if w1_selfcon_justright_rescal = . then w1_selfcon_justright_recod = .;

*Create a sum of the self-control items. Use of the sum function means that sum scores will be taken even if some items are missing.;
w1_selfcon_sum = sum(w1_selfcon_mind_recod, w1_selfcon_teacher_recod, w1_selfcon_school_recod, w1_selfcon_hw_recod, w1_selfcon_justright_recod);

*Create a variable that counts the number of items with missing responses on the self-control scale. Then exclude participants with over 3 items missing.;
selfcon_Nmiss = nmiss(w1_selfcon_mind_recod, w1_selfcon_teacher_recod, w1_selfcon_school_recod, w1_selfcon_hw_recod, w1_selfcon_justright_recod);
w1_selfcon_sum_exc = w1_selfcon_sum;
if selfcon_Nmiss >3 then w1_selfcon_sum_exc = .;

*Pro-rate the self-control variable;
selfcon_Nrespond = 5 - selfcon_Nmiss;
	w1_selfcon_sum_prorate = (5/selfcon_Nrespond)*w1_selfcon_sum_exc;
	if w1_selfcon_sum_exc = . then w1_selfcon_sum_prorate = .;

*Create an indicator for childhood maltreatment.;
  *Indicator for physical abuse 0 adult caregivers slapped, hit or kicked you 3 or more times; 
w3_cm_abuse_physical_indicator = (w3_cm_abuse_physical in(3,4,5)); if w3_cm_abuse_physical in(., 96, 98, 99) then w3_cm_abuse_physical_indicator = .;
  *Indicator for sexual abuse = any sexual abuse; 
w3_cm_abuse_sexual_indicator = (w3_cm_abuse_sexual in(1,2,3,4,5)); if w3_cm_abuse_sexual in(., 96, 98, 99) then w3_cm_abuse_sexual_indicator = .;
w3_cm_indicator = (w3_cm_abuse_physical_indicator = 1 or w3_cm_abuse_sexual_indicator = 1);
  *Coding as missing if no indication of abuse currently and any of the indicators are missing ; 
if w3_cm_indicator = 0 and (w3_cm_abuse_physical_indicator = . or w3_cm_abuse_sexual_indicator = .) then w3_cm_indicator = .;

*Adolescent cognitive ability (w1_verbal_intel) does not need to be recoded.;

*Calculate age at Wave I. Estimate the DOB as the 15th of the birth month.;
w1_intvw_date = mdy(imonth1, iday1, iyear1);
w1_bdate = mdy(w1_birth_mo, 15, w1_birth_yr);
w1_age = floor((w1_intvw_date - w1_bdate) / 365.25);

*Recode sex.;
if w1_sex in(6,8) then w1_sex = .;

*Recode race. Participants are coded as either White, Black, American Indian/Alaska Native, Asian, Other, or Multiracial.;
array race {5} w1_race_white w1_race_black w1_race_amind w1_race_asian w1_race_other;
do i = 1 to 5;
if race[i] in (6, 8, 9) then race[i] = .;
end;
race_sum = sum(w1_race_white, w1_race_black, w1_race_amind, w1_race_asian, w1_race_other);
if race_sum > 1 then w1_race_selfreport = 6;
else if race_sum = 1 then do;
if w1_race_white = 1 then w1_race_selfreport = 1;
if w1_race_black = 1 then w1_race_selfreport = 2;
if w1_race_amind = 1 then w1_race_selfreport = 3;
if w1_race_asian = 1 then w1_race_selfreport = 4;
if w1_race_other = 1 then w1_race_selfreport = 5;
end;
else w1_race_selfreport = .;

*Recode ethnicity.;
if w1_ethnicity in(6,8) then w1_ethnicity = .;

*Adolescent SES (w1_ses) does not need to be recoded.;

run; *n = 12,300; *144 variables;

*Save a copy of the dataset in library.;
data out.dualharm_draft7_covariates;
set dualharm_draft7_covariates;
run;

