clear all
set more off
set maxvar 20000 
global DataIN  "C:\Projects\cross_section\cross_section\data" // "parent" folder, which contains folders for each wave
cd "$DataIN" 
use NIDS-CRAM_12345.dta, clear

// Demographics

*** Age
    forvalues i = 1/5 {
	rename w`i'_nc_best_age_yrs w`i'_nc_age
	recode w`i'_nc_age (-9/-1=.)
	}

*** Gender
    forvalues i = 1/5 {
	rename w`i'_nc_gen w`i'_nc_gender
	recode w`i'_nc_gender (-9/-1=.)
	}
	
*** Race 
    forvalues i = 1/5 {
	rename w`i'_nc_best_race w`i'_nc_race
	recode w`i'_nc_race (-8/-1=.)
	}	

*** Area
    forvalues i = 1/5 {
	rename w`i'_nc_geo2011 w`i'_nc_geo
	recode w`i'_nc_geo (-8/-1=.)

	gen w`i'_nc_urban = 1 if w`i'_nc_geo==2
	replace w`i'_nc_urban = 0 if w`i'_nc_geo==1 | w`i'_nc_geo==3
	lab var w`i'_nc_urban "Urban dummy"
	}

*** Province
    forvalues i = 1/5 {
	rename w`i'_nc_prov2011 w`i'_nc_province
	recode w`i'_nc_province (-9/-1=.) (10=.)
	}

*** Type of dwelling
    forvalues i = 1/5 {
	rename w`i'_nc_dwltyp w`i'_nc_dwelling
	recode w`i'_nc_dwelling (-9/-1=.)
	}

*** Has access to piped/tap water in dwelling
    forvalues i = 1/5 {
	gen w`i'_nc_water = w`i'_nc_watsrc
	recode w`i'_nc_water (2=0) (-9/-1 = .)
	lab var w`i'_nc_water "Has access to piped/tap water in dwelling/house or in yard"
	}

*** Has access to electricity in dwelling
    forvalues i = 1/5 {
	gen w`i'_nc_elec = w`i'_nc_enrgelec
	recode w`i'_nc_elec (2=0) (-9/-1 = .)
	lab var w`i'_nc_elec "Has access to electricity in dwelling/house"
	}

*** HH composition
/* Note 1: w2_nc_nocld (no of residents between 18 and 60) -- many missing observations due to survey implementation issues
Note 2: intervals vary by wave, particularly for W3

* nopres // aggregate
* nou7res // < 7
* no7to17res // 7-17
* nocld // 18-60
* no60res // > 60 */

    gen w1_nc_hhsize = w1_nc_nopres // just use aggregate, but can use individual items, but the way questions are asked here is concerning...
	gen w2_nc_hhsize = w2_nc_nopres // there are a few options for W2, but be sure to check CRAM manual
	
	recode w3_nc_nopres w3_nc_nou7res w3_nc_no7to17res w3_nc_nocld w3_nc_no60res (-9/-1=.)
	egen w3_nc_hhsize = rowtotal(w3_nc_nou7res w3_nc_no7to17res w3_nc_nocld w3_nc_no60res), m
	replace w3_nc_hhsize = w3_nc_nopres if w3_nc_hhsize==. & w3_nc_nopres!=. // affected 3 obs; the remaining 10 have values for w3_nc_hhsize from sum function 
	
	recode w4_nc_nopres w4_nc_nou7res w4_nc_no7to17res w4_nc_nocld w4_nc_no60res (-9/-1=.)
	egen w4_nc_hhsize = rowtotal(w4_nc_nou7res w4_nc_no7to17res w4_nc_nocld w4_nc_no60res), m
	replace w4_nc_hhsize = w4_nc_nopres if w4_nc_hhsize==. & w4_nc_nopres!=.
	
	recode w5_nc_nopres w5_nc_nou7res w5_nc_no7to17res w5_nc_nocld w5_nc_no60res (-9/-1=.)
	egen w5_nc_hhsize = rowtotal(w5_nc_nou7res w5_nc_no7to17res w5_nc_nocld w5_nc_no60res), m
	replace w5_nc_hhsize = w5_nc_nopres if w5_nc_hhsize==. & w5_nc_nopres!=.

*** Education
    lab def educ_bins 1 "Up to Primary" 2 "Up to Secondary" 3 "Matric" 4 "Tertiary", modify

    forvalues i = 1/5 {
	gen w`i'_nc_educ_bin = .
	replace w`i'_nc_educ_bin = 1 if inrange(w`i'_nc_edschgrd, 0, 7) |  w`i'_nc_edschgrd==19
	replace w`i'_nc_educ_bin = 2 if inrange(w`i'_nc_edschgrd, 8, 11) | inlist(w`i'_nc_edschgrd, 13,14,16,17)
	replace w`i'_nc_educ_bin = 3 if inlist(w`i'_nc_edschgrd, 12,15,18)
	replace w`i'_nc_educ_bin = 4 if w`i'_nc_edter== 1 & inlist(w`i'_nc_edschgrd, 12,15,18) 
	
	lab val w`i'_nc_educ_bin educ_bins
	lab var w`i'_nc_educ_bin "Highest education bin"
	}

*** Employment (just for Feb 2020; we have for April, June, and Oct 2020 and Jan and Mar 2020)
	
	gen w1_nc_empl_stat_feb = .
	replace w1_nc_empl_stat_feb =-9 if w1_nc_em_feb ==-9 | w1_nc_ems_feb==-9 | w1_nc_emany_feb==-9
	replace w1_nc_empl_stat_feb =-8 if w1_nc_em_feb ==-8 | w1_nc_ems_feb==-8 | w1_nc_emany_feb==-8
	
	replace w1_nc_empl_stat_feb=0 if w1_nc_emany_feb ==2 | w1_nc_ems_feb==3 | w1_nc_em_feb==2 | w1_nc_em_feb==3 
	replace w1_nc_empl_stat_feb=3 if w1_nc_emany_feb ==1 | w1_nc_ems_feb==1 | w1_nc_ems_feb==2 | w1_nc_em_feb==1
	
    lab var w1_nc_empl_stat_feb "Employed in February"
	lab def w1_nc_empl_feb 3 "Employed" 0 "Not employed: i.e. Unemployed or NEA" -8 "Refused" -9 "Don't Know", add
	cap lab val w1_nc_empl_stat_feb w1_nc_empl_feb 
	
	forvalues i=1/5 {
	recode w`i'_nc_empl_stat (-9/-1 = .)
	}
	
*** Occupation (usual occupation)
	forvalues i = 1/5 {
	recode w`i'_nc_emwrk_isco_c w`i'_nc_emswrk_isco_c w`i'_nc_unemwrk_isco_c (-9/-1 = .)
	gen w`i'_nc_occu = .
	replace w`i'_nc_occu = w`i'_nc_emwrk_isco_c 
	replace w`i'_nc_occu = w`i'_nc_emswrk_isco_c if mi(w`i'_nc_occu)
	replace w`i'_nc_occu = w`i'_nc_unemwrk_isco_c if mi(w`i'_nc_occu)
	lab val w`i'_nc_occu w`i'_nc_occ_code
	lab var w`i'_nc_occu "1 digit main occupation"
	}

*** Industry (only from W2 onwards)
    forvalues i = 2/5 {
	recode w`i'_nc_emsect_c w`i'_nc_emssect w`i'_nc_unemsect_c (-9/-1 = .)
	gen w`i'_nc_industry = .
	replace w`i'_nc_industry = w`i'_nc_emsect_c
	replace w`i'_nc_industry = w`i'_nc_emssect if mi(w`i'_nc_industry)
	replace w`i'_nc_industry = w`i'_nc_unemsect_c if mi(w`i'_nc_industry)
	recode w`i'_nc_industry (10 = 0)
	lab val w`i'_nc_industry w2_nc_sec_code
	lab var w`i'_nc_industry "1 digit main industry"
	}
	
	gen w1_nc_industry = w2_nc_industry 
	lab val w1_nc_industry w2_nc_sec_code

*** Food security ("In x month, did your HH run out of money to buy food?" or "In last 7 days, has anyone in HH gone hungry?")
    forvalues i = 1/5 {
	recode w`i'_nc_hhfdyn (-9/-1 = .) 
	gen w`i'_nc_no_food = (w`i'_nc_hhfdyn == 1)
	replace w`i'_nc_no_food = . if w`i'_nc_hhfdyn == .
	lab var w`i'_nc_no_food "HH ran out of money for food in ref month"
	}
	
    forvalues i = 1/5 {
	recode w`i'_nc_fdayn (-9/-1 = .) 
	gen w`i'_nc_hunger = (w`i'_nc_fdayn == 1)
	replace w`i'_nc_hunger = . if w`i'_nc_fdayn == .
	lab var w`i'_nc_hunger "In last 7 days, anyone in HH gone hungry"
	}
	
*** Marital status (only from W2 onwards)
    forvalues i = 2/5 {
	recode w`i'_nc_mar (-9/-1=.)
	gen w`i'_nc_married = (w`i'_nc_mar==1)
	lab var w`i'_nc_married "Married (or have partner) dummy"
	}
	
	gen w1_nc_married = w2_nc_married // assumption
	
*** Work from home (only from W2 onwards)
    forvalues i = 2/5 {
	gen w`i'_nc_work_from_home = .
	replace w`i'_nc_work_from_home = 1 if w`i'_nc_emwrkhm == 3 // No - None of the time
	replace w`i'_nc_work_from_home = 2 if w`i'_nc_emwrkhm == 2 // Yes - Some of the time
	replace w`i'_nc_work_from_home = 3 if w`i'_nc_emwrkhm == 1 // Yes - Most of the time
	replace w`i'_nc_work_from_home = . if w`i'_nc_emwrkhm == .
	replace w`i'_nc_work_from_home = . if w`i'_nc_emwrkhm == -9 // don't know
	replace w`i'_nc_work_from_home = . if w`i'_nc_emwrkhm == -8 // refused 
	lab var w`i'_nc_work_from_home "Able to work from home during lockdown"
	}

*** Received UIF TERS (2 questions, 1 for self-employed and employers, other for everyone else)

    ren w2_nc_emsteers_june w2_nc_emsteers // this one for self-employed + employers
	ren w3_nc_emsteers_oct w3_nc_emsteers
	ren w4_nc_emsteers_jan w4_nc_emsteers
	ren w5_nc_emsteers_mar w5_nc_emsteers
	
	gen w1_nc_emsteers = . // just to make loop below easier
	
    forvalues i = 1/5 {
	gen w`i'_nc_ters = 1 if w`i'_nc_eminc_ters==1 | w`i'_nc_emsteers==1 // yes
	replace w`i'_nc_ters = 0 if inrange(w`i'_nc_eminc_ters,2,3) | inrange(w`i'_nc_emsteers,2,6) // no's
	recode w`i'_nc_ters (-9/-1=.) // don't know or refuse
	lab var w`i'_nc_ters "TERS receipt dummy"
	}
	
*** Grant receipt

    // Personal receipt of any grant
	ren w2_nc_incgov_june w2_nc_incgov
	ren w3_nc_incgov_oct w3_nc_incgov
	ren w4_nc_incgov_jan w4_nc_incgov
	ren w5_nc_incgov_mar w5_nc_incgov
	
	forvalues i = 1/5 {
	gen w`i'_nc_grant = .
	replace w`i'_nc_grant = 1 if w`i'_nc_incgov==1 
	replace w`i'_nc_grant = 0 if w`i'_nc_incgov==2
	lab var w`i'_nc_grant "Personally receives a social grant"
	}
	
	// Personal receipt of CSG
	forvalues i = 1/5 {
	gen w`i'_nc_csg = .
	replace w`i'_nc_csg = 1 if w`i'_nc_incgov==1 & w`i'_nc_incgovtyp1==1  | w`i'_nc_incgov==1 & w`i'_nc_incgovtyp2==1  | w`i'_nc_incgov==1 & w`i'_nc_incgovtyp3==1 
	replace w`i'_nc_csg = 0 if w`i'_nc_incgov==1 & w`i'_nc_incgovtyp1!=1 & w`i'_nc_incgovtyp2!=1 & w`i'_nc_incgovtyp3!=1  | w`i'_nc_incgov==2
	lab var w`i'_nc_csg "Personally receives CSG"
	}
	
	// Personal receipt of OAP
	forvalues i = 1/5 {
	gen w`i'_nc_oap = .
	replace w`i'_nc_oap = 1 if w`i'_nc_incgov==1 & w`i'_nc_incgovtyp1==2  | w`i'_nc_incgov==1 & w`i'_nc_incgovtyp2==2  | w`i'_nc_incgov==1 & w`i'_nc_incgovtyp3==2 
	replace w`i'_nc_oap = 0 if w`i'_nc_incgov==1 & w`i'_nc_incgovtyp1!=2 & w`i'_nc_incgovtyp2!=1 & w`i'_nc_incgovtyp3!=2  | w`i'_nc_incgov==2
	lab var w`i'_nc_oap "Personally receives Old Age Pension"
	}
	
	// Personal receipt of COVID-19 SRD grant
	gen w1_nc_incgovtyp4 = . // just for loop
	gen w4_nc_incgovtyp4 = .
	gen w5_nc_incgovtyp4 = .
	
	forvalues i = 1/5 {
	gen w`i'_nc_c19grant = .
	replace w`i'_nc_c19grant = 1 if w`i'_nc_incgov==1 & w`i'_nc_incgovtyp1==8  | w`i'_nc_incgov==1 & w`i'_nc_incgovtyp2==8  | w`i'_nc_incgov==1 & w`i'_nc_incgovtyp3==8 | w`i'_nc_incgov==1 & w`i'_nc_incgovtyp4==8  
	replace w`i'_nc_c19grant = 0 if w`i'_nc_incgov==1 & w`i'_nc_incgovtyp1!=8 & w`i'_nc_incgovtyp2!=1 & w`i'_nc_incgovtyp3!=8 & w`i'_nc_incgovtyp4!=8 | w`i'_nc_incgov==2
	lab var w`i'_nc_c19grant "Personally receives C19 grant"
	}

    // HH-level CSG receipt
    forvalues i = 1/5 {
	gen w`i'_nc_csg_hh = .
	replace w`i'_nc_csg_hh = 1 if w`i'_nc_hhincchld>0 & w`i'_nc_outcome==1 | w`i'_nc_incchld==1 & w`i'_nc_outcome==1
	replace w`i'_nc_csg_hh = 0 if w`i'_nc_incchld==2 & w`i'_nc_outcome==1 | w`i'_nc_hhincchld==0 & w`i'_nc_outcome==1
	lab var w`i'_nc_csg_hh "Lives in HH that receives CSG"
	}

    // HH-level OAP receipt
    forvalues i = 1/5 {
	gen w`i'_nc_oap_hh = 1 if w`i'_nc_incgovpen==1 & w`i'_nc_outcome==1 | w`i'_nc_hhincgovpen>0 & w`i'_nc_outcome==1
	replace w`i'_nc_oap_hh = 0 if w`i'_nc_incgovpen==2 & w`i'_nc_outcome==1 | w`i'_nc_hhincgovpen==0 & w`i'_nc_outcome==1
	lab var w`i'_nc_oap_hh "Lives in HH that receives Old Age Pension"
	}
	
    // HH-level C19 grant receipt (only for W2 onwards)
	ren w2_nc_hhinccv_june w2_nc_hhinccv
	ren w3_nc_hhinccv_oct w3_nc_hhinccv
	ren w4_nc_hhinccv_jan w4_nc_hhinccv
	ren w5_nc_hhinccv_mar w5_nc_hhinccv
	
    forvalues i = 2/5 {
	gen w`i'_nc_c19grant_hh = 1 if w`i'_nc_hhinccv>0 & w`i'_nc_outcome==1 | w`i'_nc_hhinccv==-7 & w`i'_nc_outcome==1 // lives in HH that receives C19 grant or not if report positive number of HH members receiving grant (note, "-7' code is for "dont know number, but at least 1")
	replace w`i'_nc_c19grant_hh = 0 if w`i'_nc_hhinccv==0 & w`i'_nc_outcome==1 
	lab var w`i'_nc_c19grant_hh "Lives in HH that receives C19 Grant"
	}

*** Main/biggest source of HH income
    // note: not explicitly asked in W1, where respondents instead listed up to 3 sources; we assume here that 1st listed item = main source
	gen w1_nc_hhinc_main = .
	replace w1_nc_hhinc_main = w1_nc_hhincsrc1
	lab val w1_nc_hhinc_main w1_nc_hhincsrc
	
	forvalues i = 2/5 {
	recode w`i'_nc_hhincmain (-9/-1 = .)
	ren w`i'_nc_hhincmain w`i'_nc_hhinc_main
	}

*** Wages

***** (1) Clean + generate bracketweights *****

   // Feb
   * 1 source of income for Feb: w1_nc_eminc_feb, w1_nc_eminc_feb_brac
   gen w1_nc_totwage_feb = w1_nc_eminc_feb
   recode w1_nc_totwage_feb (-9/-1 = .)
   recode w1_nc_eminc_feb_brac (-9/-1 = .)
   
   * Assign brackets to those both gave Rand amounts and those who gave brackets
   	gen w1_nc_bracket_feb = w1_nc_eminc_feb_brac 
	replace w1_nc_bracket_feb = 1 if w1_nc_totwage_feb==0 | w1_nc_eminc_feb_brac==1
	replace w1_nc_bracket_feb = 2 if inrange(w1_nc_totwage_feb,1,3000) | w1_nc_eminc_feb_brac==2 
	replace w1_nc_bracket_feb = 3 if inrange(w1_nc_totwage_feb,3001,6000) | w1_nc_eminc_feb_brac==3 
	replace w1_nc_bracket_feb = 4 if inrange(w1_nc_totwage_feb,6001,12000) | w1_nc_eminc_feb_brac==4 
	replace w1_nc_bracket_feb = 5 if inrange(w1_nc_totwage_feb,12001,24000) | w1_nc_eminc_feb_brac==5 
	replace w1_nc_bracket_feb = 6 if w1_nc_totwage_feb>24000 & w1_nc_totwage_feb!=. | w1_nc_eminc_feb_brac==6
	
    lab val w1_nc_bracket_feb w1_nc_brac // 3 205 obs
	
   * For each bracket, calculate % of those who responded with Rand amount
    gen byte w1_nc_randinfo_feb = w1_nc_totwage_feb <. & w1_nc_bracket_feb <. 
   
    save "NIDS-CRAM_12345_clean.dta", replace 
   
    collapse (mean) w1_nc_pr_rand_feb = w1_nc_randinfo_feb if w1_nc_bracket_feb!=. [aw=w1_nc_pweight_s], by(w1_nc_bracket_feb)
    save "w1_nc_pr_rand_feb.dta", replace

    * Generate bracket weight for each bracket
    use "NIDS-CRAM_12345_clean.dta", clear
    merge m:1 w1_nc_bracket_feb using w1_nc_pr_rand_feb.dta // 3 205 merged, matches above, good!
    drop _m
   
    gen w1_nc_bracketweight_feb = w1_nc_pweight_s/w1_nc_pr_rand_feb
    lab var w1_nc_bracketweight_feb "Bracketweight"
    lab var w1_nc_pr_rand_feb "Within-bracket probability of reporting a Rand amt"
    lab var w1_nc_totwage_feb "Nominal total monthly wage"
   
    save "NIDS-CRAM_12345_clean.dta", replace
