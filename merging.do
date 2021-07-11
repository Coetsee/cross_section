*! version 4.0
* 30 May 2021
* NIDS-CRAM
* Merging all waves datasets together.

/*  
NOTE TO USER
This do file merges all the NIDS-CRAM datasets from all waves. 

* NB
This do file does not create a balanced panel dataset and as such the interview 
outcomes need to be taken into account when performing analysis.

This do file assumes a parent folder (defined as global DataIN below) that 
contains separate subfolders for each wave, with the sub-folders being named 
"Wave `i'" where `i' is the wave number; E.g. "Wave 1"

*/
 
*===========================================================================================================================================
* GLOBALS FOR DATA FILES AND VERSION SUFFIXES

global DataIN "C:\Projects\cross_section\cross_section\data" 		//File path to where data is located. Change this path according to where your data folder is located on your computer.

cd "$DataIN"

global num_waves = 5								// This is the number of waves in the panel

*===========================================================================================================================================

clear all
set more off
set maxvar 20000 

// Merging datasets together per wave

forvalues i = 1/$num_waves {

	global VersionIN: dir "$DataIN\Wave `i'" files "NIDS-CRAM*.dta", respectcase
	global VersionIN: subinstr global VersionIN ".dta" "",all
	global VersionIN: subinstr global VersionIN "NIDS-CRAM_" "",all
	global VersionIN: subinstr global VersionIN `"""' "",all
	use "$DataIN\Wave `i'\NIDS-CRAM_$VersionIN.dta", clear
	merge 1:1 pid using "$DataIN\Wave `i'\derived_NIDS-CRAM_$VersionIN.dta"
	drop if _merge!=3
	drop _merge
	drop w`i'_nc_outcome
	save wave`i'_merged_nc, replace
}

* Merging waves to the Link    
use "$DataIN\Wave $num_waves\Link_File_NIDS-CRAM_$VersionIN.dta", clear

local save_name = "NIDS-CRAM"

forvalues i = 1/$num_waves {

	merge 1:1 pid using wave`i'_merged_nc
	drop _merge

	local save_name = "`save_name'" + "_" + "`i'"

}

save `save_name'.dta, replace

*===========================================================================================================================================
forvalues i = 1/$num_waves {
	erase wave`i'_merged_nc.dta
}

*===========================================================================================================================================
*THE END
