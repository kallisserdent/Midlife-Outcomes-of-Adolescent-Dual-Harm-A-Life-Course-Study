/*******************************************************************************************************************
PROGRAM: STEP 1: DUAL HARM OUTCOMES - DEVELOP ANALYTIC COHORT
DATA ANALYST: Elizabeth Kolias
DATE CREATED: 21 October 2024
CHECKED BY: Kallisse Dent
STEPS:
1. Bring in Wave I and II data.
2. Bring in Wave V data.
3. Bring in cross sectional weights from Wave V.
4. Bring in Wave III data.
5. Bring in SES variable (constructed social origins score).
6. Merge all datasets.

********************************************************************************************************************/

*SRW libname statement; 
libname out 'P:\AddHealth\Contract\29042102-RichmondRakerd\Work\Elizabeth Kolias\Dual Harm Data' ; 

*Bring in Wave I data with renamed desired variables.;
*SRW libname statement for Wave I data; 
libname wave1 xport 'P:\AddHealth\Contract\29042102-RichmondRakerd\Data\Core Files - Wave I\Wave I In Home Interview Data\allwave1.xpt' ; 

data wave1 ; 
set wave1.allwave1 (keep=aid AH_PVT BIO_SEX H1GI8 H1GI6A H1GI6B H1GI6C H1GI6D H1GI6E H1GI4 imonth iyear iday H1GI1M H1GI1Y H1FS5 H1ED15 H1ED16 H1ED17 H1PF34 H1SU2 H1DS5 H1DS6 H1DS11 H1FV8 H1FV7); 
rename AH_PVT = w1_verbal_intel BIO_SEX = w1_sex H1GI8 = w1_race_one H1GI6A = w1_race_white 
	   H1GI6B = w1_race_black H1GI6C = w1_race_amind H1GI6D = w1_race_asian H1GI6E = w1_race_other H1GI4 = w1_ethnicity
       H1GI1M = w1_birth_mo H1GI1Y = w1_birth_yr imonth=imonth1 iyear = iyear1 iday=iday1
	H1FS5 = w1_selfcon_mind H1ED15 = w1_selfcon_teacher H1ED16 = w1_selfcon_school H1ED17 = w1_selfcon_hw H1PF34 = w1_selfcon_justright
	H1SU2 = w1_dual_self H1DS5 = w1_dual_other_fight H1DS6 = w1_dual_other_hurt H1DS11 = w1_dual_other_weapon H1FV8 = w1_dual_other_shot H1FV7 = w1_dual_other_knife; 
proc sort ; by aid ; 
run; *n  =  20,745, 26 variables;


*Bring in Wave II data with renamed desired variables.;
*SRW libname statement; 
libname wave2 xport 'P:\AddHealth\Contract\29042102-RichmondRakerd\Data\Core Files - Wave II\Wave II In Home Interview Data\wave2.xpt' ; 

data wave2 ;
set wave2.wave2 (keep=aid H2SU2 H2FV16 H2FV22 H2DS9 H2FV7 H2FV6);
rename H2SU2 = w2_dual_self H2FV16 = w2_dual_other_fight H2FV22 = w2_dual_other_hurt H2DS9 = w2_dual_other_weapon H2FV7 = w2_dual_other_shot H2FV6 = w2_dual_other_knife;
proc sort ; by aid;
run; *n = 14,738, 7 variables;


*Bring in Wave V data with renamed desired variables.;
*SRW libname statement ; 
libname wave5 xport 'P:\AddHealth\Contract\29042102-RichmondRakerd\Data\Core Files - Wave V\Wave V Mixed-Mode Survey Data\wave5.xpt' ; 
data wave5 ;
set wave5.wave5 (keep=aid H5MN9 H5SS0A H5SS0B H5SS0C H5SS0D H5SS0E H5TO15 H5TO21 H5TO26A H5TO26B H5TO26C H5TO26D H5TO27A H5TO27B H5TO27C H5TO27D
	H5ID1 H5ID6A H5ID6D H5ID6E H5ID6O H5ID6M H5ID6P H5ID6Q H5ID6R H5ID6N H5ID6L H5ID6F
	H5TR4 H5TR5 H5CJ2C H5CJ2D H5CJ2E H5CJ2F H5EC1 H5EC2 H5HR3 H5LM5 H5LM27 H5EC8);
rename H5MN9 = w5_mh_suicidality H5SS0A = w5_mh_dep_blues H5SS0B = w5_mh_dep_depressed H5SS0C = w5_mh_dep_happy H5SS0D = w5_mh_dep_sad H5SS0E = w5_mh_dep_life
	H5TO15 = w5_mh_sub_binge H5TO21 = w5_mh_sub_marijuana H5TO26A = w5_mh_sub_pres_sedatives H5TO26B = w5_mh_sub_pres_tranquilizers H5TO26C = w5_mh_sub_pres_stimulants H5TO26D = w5_mh_sub_opioids
	H5TO27A = w5_mh_sub_cocaine H5TO27B = w5_mh_sub_meth H5TO27C = w5_mh_sub_heroin H5TO27D = w5_mh_sub_otherillegal
	H5ID1 = w5_ph_general H5ID6A = w5_ph_chron_cancer H5ID6D = w5_ph_chron_diabetes H5ID6E = w5_ph_chron_heart_disease H5ID6O = w5_ph_chron_heart_failure H5ID6M = w5_ph_chron_heart_clot
	H5ID6P = w5_ph_chron_heart_afib H5ID6Q = w5_ph_chron_heart_aneur H5ID6R = w5_ph_chron_heart_arterial H5ID6N = w5_ph_chron_stroke H5ID6L = w5_ph_chron_stroke
	H5ID6L = w5_ph_chron_kidney H5ID6F = w5_ph_chron_respiratory H5TR4 = w5_soc_rel_married H5TR5 = w5_soc_rel_cohabit H5CJ2C = w5_soc_vict_knife H5CJ2D = w5_soc_vict_shot H5CJ2E = w5_soc_vict_slap H5CJ2F = w5_soc_vict_beat
	H5EC1 = w5_se_income H5EC2 = w5_se_houseincome H5HR3 = w5_se_householdsize H5LM5 = w5_se_employment H5LM27 = w5_se_workstatus H5EC8 = w5_se_property;
proc sort ; by aid;
run; *n = 12,300, 41 variables;


*Bring in cross-sectional weights from Wave 5;
*SRW libname statement ; 
libname weights xport 'P:\AddHealth\Contract\29042102-RichmondRakerd\Data\Core Files - Wave V\Wave V Mixed-Mode Survey Weights\weights5.xpt'; 
data weights5 ;
set weights.weights5 (keep=aid GSW5 PSUSCID REGION);
proc sort; by aid;
run; *n=12,300, 4 variables;


*Bring in Wave III data with renamed desired variables.;
*SRW libname statement ; 
libname wave3 xport 'P:\AddHealth\Contract\29042102-RichmondRakerd\Data\Core Files - Wave III\Wave III In Home Interview Data\wave3\wave3.xpt' ; 

data wave3 ;
set wave3.wave3 (keep=aid H3MA1 H3MA2 H3MA3 H3MA4);
rename H3MA1 = w3_cm_neglect_supervisory H3MA2 = w3_cm_neglect_physical H3MA3 = w3_cm_abuse_physical H3MA4 = w3_cm_abuse_sexual;
proc sort ; by aid;
run; *n = 15,197, 5 variables;


*Bring in Wave I SES data and convert aid to a numeric variable.;
*SRW libname statement ; 
libname ses xport 'P:\AddHealth\Contract\29042102-RichmondRakerd\Data\Constructed Files\Constructed SES Variables\conses.xpt' ; 
data wave1_ses ; 
set ses.conses (keep = aid sespc_al);
aid2 = put(aid, 8.);
drop aid; 
rename aid2 = aid sespc_al = w1_ses;
proc sort ; by aid ; 
run; *n = 20,745, 2 variables.;


*Merge Wave I, Wave II, Wave III, Wave V, cross-sectional weights for Wave V, and SES at Wave I datasets, keeping only participants that have data at Wave V.;
data fullcohort;
merge wave5(in=a) wave1 wave2 wave3 weights5 wave1_ses;
by aid;
if a; *wave 5 is out "base" analytic cohort; 
run; *n=12,300, 80 variables; 

*Save the merged dataset as a permanent file in my data folder.;
data out.dualharm_draft4;
set fullcohort;
run; *n = 12,300, 80 variables; 
