*--------------------------------------------------*
* Did USMCA Increase Mexico's Share of U.S. Imports?
* Lucia Mata | ECON 5372 | Spring 2026
*--------------------------------------------------*

*-------------Import Dataset-----------------------*
cd "C:\Users\lucia\Downloads"
import delimited "C:\Users\lucia\Downloads\TradeData_4_1_2026_10_4_14.csv", clear

*-------------Keep and rename variables------------*
keep year partnerdesc primaryvalue
rename partnerdesc country
rename primaryvalue imports

destring year, replace
destring imports, replace force
replace country = "Korea" if country == "Rep. of Korea"

*-----------Generate Log Imports-------------------*
gen log_imports = ln(imports)

*---------------Encode Country---------------------*
encode country, gen(country_id)

*-------------Declare the Panel--------------------*
xtset country_id year

*-----------Check Mexico's Country ID--------------*
* Expected order (alphabetical): Brazil=1 Chile=2 China=3 Colombia=4
*   Germany=5 Japan=6 Korea=7 Mexico=8 Viet Nam=9
tab country country_id

*---------------Install synth package--------------*
ssc install synth, replace

*------------------------------Run Synthetic Control (Mexico = trunit 8)-----*
synth log_imports log_imports(2015) log_imports(2016) log_imports(2017) ///
    log_imports(2018) log_imports(2019), trunit(8) trperiod(2020)

matrix Y_treated   = e(Y_treated)
matrix Y_synthetic = e(Y_synthetic)

*-----------Convert matrices to variables----------*
clear
svmat Y_treated,   name(real_mexico)
svmat Y_synthetic, name(synthetic_mexico)
gen year = 2014 + _n
keep if real_mexico1 != .

gen gap  = real_mexico1 - synthetic_mexico1
gen zero = 0
list year real_mexico1 synthetic_mexico1 gap

*-----------------------Pre-treatment fit graph----------------------------*
twoway ///
    (line real_mexico1      year if year <= 2019, lcolor(purple) lwidth(medium)) ///
    (line synthetic_mexico1 year if year <= 2019, lcolor(red) lpattern(dash) lwidth(medium)), ///
    legend(label(1 "US Imports from Mexico") label(2 "Synthetic Mexico")) ///
    title("Pre-Treatment Fit: Real vs Synthetic Mexico") ///
    subtitle("2015-2019") ///
    xtitle("Year") ytitle("Log of US Imports (USD)") ///
    xlabel(2015(1)2019)
graph export "C:\Users\lucia\Downloads\pretreatment_graph.png", replace

*-----------------Real vs Synthetic Mexico graph---------------------------*
twoway ///
    (line real_mexico1      year, lcolor(purple) lwidth(medium)) ///
    (line synthetic_mexico1 year, lcolor(red) lpattern(dash) lwidth(medium)), ///
    legend(label(1 "US Imports from Mexico") label(2 "Synthetic Mexico")) ///
    title("Effect of USMCA on US Imports from Mexico") ///
    xtitle("Year") ytitle("Log of US Imports (USD)") ///
    xline(2020, lpattern(dash) lcolor(gray)) ///
    xlabel(2015(1)2023)
graph export "C:\Users\lucia\Downloads\synth_main_graph.png", replace

*-----------------------Gap graph------------------------------------------*
twoway ///
    (line gap  year, lcolor(purple) lwidth(thick)) ///
    (line zero year, lcolor(black) lpattern(dash)), ///
    legend(label(1 "Treatment Effect") label(2 "Zero Reference")) ///
    title("Treatment Effect of USMCA on US Imports from Mexico") ///
    xline(2020, lpattern(dash) lcolor(gray)) ///
    yline(0, lcolor(black)) ///
    xtitle("Year") ytitle("Gap (Real - Synthetic)") ///
    xlabel(2015(1)2023)
graph export "C:\Users\lucia\Downloads\gap_graph.png", replace

*--------------------Placebo Tests and Graph-------------------------------*

*-------Reload Data for Placebos-------------------------------------------*
cd "C:\Users\lucia\Downloads"
import delimited "TradeData_4_1_2026_10_4_14.csv", clear
keep year partnerdesc primaryvalue
rename partnerdesc country
rename primaryvalue imports
destring year, replace
destring imports, replace force
replace country = "Korea" if country == "Rep. of Korea"
gen log_imports = ln(imports)
encode country, gen(country_id)
xtset country_id year

*-------Placebo - Brazil (trunit 1)----------------------------------------*
synth log_imports log_imports(2015) log_imports(2016) log_imports(2017) ///
    log_imports(2018) log_imports(2019), trunit(1) trperiod(2020)
matrix brazil_treated   = e(Y_treated)
matrix brazil_synthetic = e(Y_synthetic)
svmat brazil_treated,   name(brazil_t)
svmat brazil_synthetic, name(brazil_s)

*-------Placebo - Chile (trunit 2)------------------------------------------*
synth log_imports log_imports(2015) log_imports(2016) log_imports(2017) ///
    log_imports(2018) log_imports(2019), trunit(2) trperiod(2020)
matrix chile_treated   = e(Y_treated)
matrix chile_synthetic = e(Y_synthetic)
svmat chile_treated,   name(chile_t)
svmat chile_synthetic, name(chile_s)

*-------Placebo - China (trunit 3)------------------------------------------*
synth log_imports log_imports(2015) log_imports(2016) log_imports(2017) ///
    log_imports(2018) log_imports(2019), trunit(3) trperiod(2020)
matrix china_treated   = e(Y_treated)
matrix china_synthetic = e(Y_synthetic)
svmat china_treated,   name(china_t)
svmat china_synthetic, name(china_s)

*-------Placebo - Colombia (trunit 4)---------------------------------------*
synth log_imports log_imports(2015) log_imports(2016) log_imports(2017) ///
    log_imports(2018) log_imports(2019), trunit(4) trperiod(2020)
matrix colombia_treated   = e(Y_treated)
matrix colombia_synthetic = e(Y_synthetic)
svmat colombia_treated,   name(colombia_t)
svmat colombia_synthetic, name(colombia_s)

*-------Placebo - Germany (trunit 5)----------------------------------------*
synth log_imports log_imports(2015) log_imports(2016) log_imports(2017) ///
    log_imports(2018) log_imports(2019), trunit(5) trperiod(2020)
matrix germany_treated   = e(Y_treated)
matrix germany_synthetic = e(Y_synthetic)
svmat germany_treated,   name(germany_t)
svmat germany_synthetic, name(germany_s)

*-------Placebo - Japan (trunit 6)------------------------------------------*
synth log_imports log_imports(2015) log_imports(2016) log_imports(2017) ///
    log_imports(2018) log_imports(2019), trunit(6) trperiod(2020)
matrix japan_treated   = e(Y_treated)
matrix japan_synthetic = e(Y_synthetic)
svmat japan_treated,   name(japan_t)
svmat japan_synthetic, name(japan_s)

*-------Placebo - Korea (trunit 7)------------------------------------------*
synth log_imports log_imports(2015) log_imports(2016) log_imports(2017) ///
    log_imports(2018) log_imports(2019), trunit(7) trperiod(2020)
matrix korea_treated   = e(Y_treated)
matrix korea_synthetic = e(Y_synthetic)
svmat korea_treated,   name(korea_t)
svmat korea_synthetic, name(korea_s)

*-------Placebo - Viet Nam (trunit 9)---------------------------------------*
synth log_imports log_imports(2015) log_imports(2016) log_imports(2017) ///
    log_imports(2018) log_imports(2019), trunit(9) trperiod(2020)
matrix vietnam_treated   = e(Y_treated)
matrix vietnam_synthetic = e(Y_synthetic)
svmat vietnam_treated,   name(vietnam_t)
svmat vietnam_synthetic, name(vietnam_s)

*-------Placebo - Mexico (trunit 8, treatment unit)-------------------------*
synth log_imports log_imports(2015) log_imports(2016) log_imports(2017) ///
    log_imports(2018) log_imports(2019), trunit(8) trperiod(2020)
matrix mexico_treated   = e(Y_treated)
matrix mexico_synthetic = e(Y_synthetic)
svmat mexico_treated,   name(mexico_t)
svmat mexico_synthetic, name(mexico_s)

*-----------------------Generate gap variables------------------------------*
gen gap_brazil   = brazil_t1   - brazil_s1
gen gap_chile    = chile_t1    - chile_s1
gen gap_china    = china_t1    - china_s1
gen gap_colombia = colombia_t1 - colombia_s1
gen gap_germany  = germany_t1  - germany_s1
gen gap_japan    = japan_t1    - japan_s1
gen gap_korea    = korea_t1    - korea_s1
gen gap_vietnam  = vietnam_t1  - vietnam_s1
gen gap_mexico   = mexico_t1   - mexico_s1

*-----------Keep only the 9 time-period rows--------------------------------*
* svmat fills rows 1-9; those correspond to country_id=1 (Brazil) years 2015-2023
keep if brazil_t1 != .
list year gap_mexico gap_brazil in 1/9

*------------------------------Placebo graph--------------------------------*
twoway ///
    (line gap_brazil   year, lcolor(sienna)    lwidth(thin)) ///
    (line gap_chile    year, lcolor(orange)    lwidth(thin)) ///
    (line gap_china    year, lcolor(lavender)  lwidth(thin)) ///
    (line gap_colombia year, lcolor(midgreen)  lwidth(thin)) ///
    (line gap_germany  year, lcolor(purple)    lwidth(thin)) ///
    (line gap_japan    year, lcolor(cranberry) lwidth(thin)) ///
    (line gap_korea    year, lcolor(cyan)      lwidth(thin)) ///
    (line gap_vietnam  year, lcolor(gold)      lwidth(thin)) ///
    (line gap_mexico   year, lcolor(red)       lwidth(thick)), ///
    legend(label(9 "Mexico") label(1 "Donor Countries")) ///
    title("Placebo Test: Mexico vs Donor Countries") ///
    xline(2020, lpattern(dash) lcolor(gray)) ///
    yline(0, lcolor(black)) ///
    xtitle("Year") ytitle("Gap (Real - Synthetic)") ///
    xlabel(2015(1)2023)
graph export "C:\Users\lucia\Downloads\placebo_graph.png", replace

save "C:\Users\lucia\Downloads\Presentation_MataL.dta", replace
