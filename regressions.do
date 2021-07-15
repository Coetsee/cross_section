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
keep pid w*_nc_pweight_s w*_nc_hunger w*_nc_hhinccv w*_nc_no_food w*_nc_fdcyn w*_nc_c19grant_hh w*_nc_incgov w*_nc_incgovtyp1 w*_nc_race w*_nc_gender w*_nc_prov w*_nc_urban w*_nc_age w*_nc_educ_bin stratum cluster 
reshape long w@_nc_pweight_s w@_nc_hunger w@_nc_hhinccv w@_nc_no_food w@_nc_fdcyn w@_nc_c19grant w@_nc_c19grant_hh w@_nc_incgov w@_nc_incgovtyp1 w@_nc_race w@_nc_gender w@_nc_prov w@_nc_urban w@_nc_age w@_nc_educ_bin, i(pid) j(wave)

save "NIDS-CRAM_clean_long.dta", replace

svyset cluster [w=w_nc_pweight_s], strata(stratum)
// declare as panel

xtset pid wave

save "NIDS-CRAM_clean_long.dta", replace

//first POLS

xi: regress w_nc_hunger  


