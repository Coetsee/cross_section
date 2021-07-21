// Setup
// Data folder
global DataIN  "C:\Projects\cross_section\cross_section\data" // "parent" folder, which contains folders for each wave
cd "$DataIN" 
global output "C:\Projects\cross_section\cross_section\results" // Output folder
clear all
set more off
set maxvar 20000 
use NIDS-CRAM_12345_clean.dta, clear



// variable of interest: w@_nc_hunger, want to look at effect of covid-19 grant on hunger - so following indivs over time who got the grant


// other vars needed: Employment status - receives other grants in HH (these should not be NB due to targeting of SRD)

//things that dont change over time - race, gender, education (?)

// w*_nc_c19grant - personally received c19 grant
// w2 w2_nc_hhinccv - number of hh residents who have received c19 grant 
// w*_nc_c19grant_hh - someone in HH received c19 grant
// w*_nc_incgov - do you personally receive any gov grant?
// w1_nc_incgovtyp1 - if so, which type? 


//reshape long

preserve
keep pid w*_nc_pweight_s  w*_nc_pweight_extu_s w*_nc_hunger w*_nc_hhinccv w*_nc_hhinc w*_nc_no_food w*_nc_fdcyn w*_nc_c19grant w*_nc_c19grant_hh w*_nc_incgov w*_nc_incgovtyp1 w*_nc_race w*_nc_gender w*_nc_prov w*_nc_urban w*_nc_age w*_nc_educ_bin w*_nc_hhsize stratum cluster 
reshape long w@_nc_pweight_s w@_nc_pweight_extu_s w@_nc_hunger w@_nc_hhinccv w@_nc_hhinc w@_nc_no_food w@_nc_fdcyn w@_nc_c19grant w@_nc_c19grant_hh w@_nc_incgov w@_nc_incgovtyp1 w@_nc_race w@_nc_gender w@_nc_prov w@_nc_urban w@_nc_age w@_nc_educ_bin w@_nc_hhsize, i(pid) j(wave)

save "NIDS-CRAM_clean_long.dta", replace

use "NIDS-CRAM_clean_long.dta"

svyset cluster [w=w_nc_pweight_extu_s], strata(stratum)

drop if w_nc_hunger == . 
//drop if w_nc_c19grant_hh == . 
//drop if w_nc_fdcyn == .

ren w_nc_hunger hunger
ren w_nc_c19grant_hh c19grant
ren w_nc_fdcyn childhunger

tabstat hunger c19grant

// declare as panel

xtset pid wave
sort pid wave

//first POLS - baseline


// what else to add? Maybe other grants? need hh size as well

xi: regress hunger c19grant [aw = w_nc_pweight_s], cluster(pid)
estimates store m1   

xi: regress hunger c19grant w_nc_hhsize w_nc_incgov w_nc_race w_nc_gender w_nc_hhinc w_nc_prov w_nc_urban w_nc_age w_nc_educ_bin [aw = w_nc_pweight_s], cluster(pid)
estimates store m2

xi: regress hunger c19grant w_nc_hhsize w_nc_incgov  w_nc_hhinc i.wave [aw = w_nc_pweight_s], cluster(pid)
estimates store m3

svyset cluster [w=w_nc_pweight_extu_s], strata(stratum)

* Fixed Effects 
xtreg hunger c19grant , fe  
estimates store m4

* First Differences  
reg   D.hunger D.c19grant   
estimates store m5

* Random Effects 

xtreg hunger c19grant w_nc_hhsize w_nc_incgov w_nc_race w_nc_gender w_nc_hhinc w_nc_prov w_nc_urban w_nc_age w_nc_educ_bin, re 
estimates store m6  
hausman m4  

esttab m1 m2 m3 m4 m5 m6  , b(a6) p(4) r2(4)    cells(b(star fmt(%9.3f))) 

// seems like insignificant effects across all specifications

// Now looking at childhunger:

xi: regress childhunger c19grant [aw = w_nc_pweight_s], cluster(pid)
estimates store m7   

xi: regress childhunger c19grant w_nc_hhsize w_nc_incgov w_nc_race w_nc_gender w_nc_hhinc w_nc_prov w_nc_urban w_nc_age w_nc_educ_bin [aw = w_nc_pweight_s], cluster(pid)
estimates store m8

xi: regress childhunger c19grant w_nc_hhsize w_nc_incgov  w_nc_hhinc i.wave [aw = w_nc_pweight_s], cluster(pid)
estimates store m9

svyset cluster [w=w_nc_pweight_extu_s], strata(stratum)

* Fixed Effects 
xtreg childhunger c19grant , fe  
estimates store m10

* First Differences  
reg   D.childhunger D.c19grant   
estimates store m11

* Random Effects 

xtreg childhunger c19grant w_nc_hhsize w_nc_incgov w_nc_race w_nc_gender w_nc_hhinc w_nc_prov w_nc_urban w_nc_age w_nc_educ_bin, re 
estimates store m12  
hausman m10  

esttab m7 m8 m9 m10 m11 m12  , b(a6 ) p(4) r2(4)    cells(b(star fmt(%9.3f))) 

// then for money for food:w_nc_no_food


xi: regress w_nc_no_food c19grant [aw = w_nc_pweight_s], cluster(pid)
estimates store m13   

xi: regress w_nc_no_food c19grant w_nc_hhsize w_nc_incgov w_nc_race w_nc_gender w_nc_hhinc w_nc_prov w_nc_urban w_nc_age w_nc_educ_bin [aw = w_nc_pweight_s], cluster(pid)
estimates store m14

xi: regress w_nc_no_food c19grant w_nc_hhsize w_nc_incgov  w_nc_hhinc i.wave [aw = w_nc_pweight_s], cluster(pid)
estimates store m15

svyset cluster [w=w_nc_pweight_extu_s], strata(stratum)

* Fixed Effects 
xtreg w_nc_no_food c19grant , fe  
estimates store m16

* First Differences  
reg   D.w_nc_no_food D.c19grant   
estimates store m17

* Random Effects 

xtreg w_nc_no_food c19grant w_nc_hhsize w_nc_incgov w_nc_race w_nc_gender w_nc_hhinc w_nc_prov w_nc_urban w_nc_age w_nc_educ_bin, re 
estimates store m18  
hausman m16  


esttab m13 m14 m15 m16 m17 m18  , b(a6 ) p(4) r2(4)    cells(b(star fmt(%9.3f))) 



