/*******************************************************************************************************************
PROGRAM: STEP 2: DUAL HARM OUTCOMES - DUAL HARM GROUPS
DATA ANALYST: Elizabeth Kolias
DATE CREATED: 2 DECEMBER 2024
CHECKED BY: Kallisse Dent
STEPS:
1. Create an indicator for any self-harm at Wave I
2. Create an indicator for any self-harm at Wave II.
3. Create an indicator for any self-harm at either Wave I or II.
4. Create an indicator for any harm toward others at Wave I.
5. Create an indicator for any harm toward others at Wave II.
6. Create an indicator for harm toward others at either Wave I or II.
7. Create an indicator for dual harm.
8. Create a categorical variable for type of harm (dual harm, self-harm only, harm toward others only, and neither).
9. Create a categorical variable for type of harm excluding harm toward others only.
10. Create indicators for dual harm vs self-only, dual harm vs neither harm, dual harm vs other-only, self-only vs neither harm, and other-only vs neither harm.

********************************************************************************************************************/
*SRW libname statement; 
libname out 'P:\AddHealth\Contract\29042102-RichmondRakerd\Work\Elizabeth Kolias\Dual Harm Data' ; 


data dualharm_draft5_dualharmgroups;
set out.dualharm_draft4;

*Create an indicator for any self-harm at Wave I. A legitimate skip (7) means the participant did not have suicidal thoughts, so is therefore coded as 0.;
w1_dual_self_indicator = (w1_dual_self > 0);
if w1_dual_self = 7 then w1_dual_self_indicator = 0;
if w1_dual_self in(6, 8) then w1_dual_self_indicator = .;

*Create an indicator for any self-harm at Wave II. A legitimate skip (7) means the participant did not have suicidal thoughts, so is therefore coded as 0.;
w2_dual_self_indicator = (w2_dual_self > 0);
if w2_dual_self = 7 then w2_dual_self_indicator = 0;
if w2_dual_self in(.,6, 8) then w2_dual_self_indicator = .;

*Create an indicator for any self-harm at either Wave I or II.;
dual_self_indicator = (w1_dual_self_indicator = 1 or w2_dual_self_indicator = 1);
if w1_dual_self_indicator = . and w2_dual_self_indicator = . then dual_self_indicator = .;

*Create an indicator for any harm toward others at Wave I.;
w1_dual_other_hurt_indicator = (w1_dual_other_fight in(1,2,3) and w1_dual_other_hurt > 0); if w1_dual_other_hurt in(6,8,9) then w1_dual_other_hurt_indicator = .;
w1_dual_other_weapon_indicator = (w1_dual_other_weapon > 0); if w1_dual_other_weapon in(6,8,9) then w1_dual_other_weapon_indicator = .;
w1_dual_other_shot_indicator = (w1_dual_other_shot > 0); if w1_dual_other_shot in(6,8,9) then w1_dual_other_shot_indicator = .;
w1_dual_other_knife_indicator = (w1_dual_other_knife > 0); if w1_dual_other_knife in (6,8,9) then w1_dual_other_knife_indicator = .;

w1_dual_other_indicator = (w1_dual_other_hurt_indicator = 1 or w1_dual_other_weapon_indicator = 1 or 
w1_dual_other_shot_indicator = 1 or w1_dual_other_knife_indicator = 1);
*For those with no indication of dual harm across all variables, if any of the contributing variables were missing 
we are coding the overall variable as missing since lack of response may indicate response bias (which is less likely in 
those who have already indicated some harm towards others) ; 
if w1_dual_other_indicator = 0 and (w1_dual_other_hurt_indicator = . or w1_dual_other_weapon_indicator = . 
or w1_dual_other_shot_indicator = . or w1_dual_other_knife_indicator = .) then w1_dual_other_indicator = .;

*Create an indicator for any harm toward others at Wave II.;
w2_dual_other_hurt_indicator = (w2_dual_other_hurt > 0); if w2_dual_other_hurt in(.,6,8) then w2_dual_other_hurt_indicator = .; if w2_dual_other_hurt = 7 then w2_dual_other_hurt_indicator = 0;
w2_dual_other_weapon_indicator = (w2_dual_other_weapon > 0); if w2_dual_other_weapon in(.,6,8) then w2_dual_other_weapon_indicator = .;
w2_dual_other_shot_indicator = (w2_dual_other_shot > 0); if w2_dual_other_shot in(.,6,8) then w2_dual_other_shot_indicator = .;
w2_dual_other_knife_indicator = (w2_dual_other_knife > 0); if w2_dual_other_knife in(.,6,8) then w2_dual_other_knife_indicator = .;

w2_dual_other_indicator = (w2_dual_other_hurt_indicator = 1 or w2_dual_other_weapon_indicator = 1 or 
w2_dual_other_shot_indicator = 1 or w2_dual_other_knife_indicator = 1);
*Same approach for handling missingness as in Wave I.; 
if w2_dual_other_indicator = 0 and (w2_dual_other_hurt_indicator = . or w2_dual_other_weapon_indicator = . 
or w2_dual_other_shot_indicator = . or w2_dual_other_knife_indicator = .) then w2_dual_other_indicator = .;

*Create an indicator for any harm toward others at either Wave I or II.;
dual_other_indicator = (w1_dual_other_indicator = 1 or w2_dual_other_indicator = 1);
if w1_dual_other_indicator = . and w2_dual_other_indicator = . then dual_other_indicator = .;

*Create an indicator for dual harm.;
dual_indicator = (dual_self_indicator = 1 and dual_other_indicator = 1);
if dual_self_indicator = . or dual_other_indicator = . then dual_indicator = .;

*Create a categorical variable for type of harm.;
if dual_self_indicator = 1 and dual_other_indicator = 1 then harm_type = 3;
else if dual_self_indicator = 1 and dual_other_indicator = 0 then harm_type = 2;
else if dual_self_indicator = 0 and dual_other_indicator = 1 then harm_type = 1;
else if dual_self_indicator = 0 and dual_other_indicator = 0 then harm_type = 0;
else harm_type = .;

*Create a categorical variable for type of harm excluding harm toward others only.;
if dual_self_indicator = 1 and dual_other_indicator = 1 then harm_type_no_other = 3;
else if dual_self_indicator = 1 and dual_other_indicator = 0 then harm_type_no_other = 2;
else if dual_self_indicator = 0 and dual_other_indicator = 0 then harm_type_no_other = 0;
else harm_type_no_other = .;

*Create an indicator for dual harm vs self-harm-only.;
if dual_self_indicator = 1 then do;
dual_vs_self_indicator = (dual_other_indicator = 1);
if dual_other_indicator = . then dual_vs_self_indicator = .;
end;

*Create an indicator for dual harm vs neither harm.;
if dual_indicator = 1 then dual_vs_neither_indicator = 1;
else if dual_self_indicator = 0 and dual_other_indicator = 0 then dual_vs_neither_indicator = 0;
else dual_vs_neither_indicator = .;

*Create an indicator for dual harm vs harm toward others only.;
if dual_other_indicator = 1 then do;
dual_vs_other_indicator = (dual_self_indicator = 1);
if dual_self_indicator = . then dual_vs_other_indicator = .;
end;

*Create an indicator for self-harm vs neither harm.;
if dual_other_indicator = 0 then do;
self_vs_neither_indicator = (dual_self_indicator = 1);
if dual_self_indicator = . then self_vs_neither_indicator = .;
end;

*Create an indicator for harm toward others only vs neither harm.;
if dual_self_indicator = 0 then do;
other_vs_neither_indicator = (dual_other_indicator = 1);
if dual_other_indicator = . then other_vs_neither_indicator = .;
end;

run; *n=12,300; *102 variables;

*Create new labels for harm_type variable.;
proc format;
	value harmf
	0 = 'neither harm'
	1 = 'other only'
	2 = 'self only'
	3 = 'dual harm';
run; *n=12,300;

data dualharm_draft5_dualharmgroups;
set dualharm_draft5_dualharmgroups;
	format harm_type harm_type_no_other harmf.;
run; *n=12,300;

*Save a copy of this data set in library.;
data out.dualharm_draft5_dualharmgroups;
set dualharm_draft5_dualharmgroups;
run; *n = 12,300; *102 variables; 


