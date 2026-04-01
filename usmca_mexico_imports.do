*--------------------------------------------------*
* Did USMCA Increase Mexico's Share of U.S. Imports?
* Lucia Mata | ECON 5372 | Spring 2026
*--------------------------------------------------*

*-------------Import Dataset-----------------------*
cd "C:\Users\lucia\Downloads"
import delimited "TradeData_3_13_2026_17_37_16.csv", clear
*--------------------------------------------------*

keep refyear partnerdesc primaryvalue
rename refyear year
rename partnerdesc country
rename primaryvalue imports

destring year, replace
destring imports, replace force

*---------------Encode Country---------------------*
encode country, gen(country_id)

*-------------Declare the Panel--------------------*
xtset country_id year

numlabel _all, add
tab country_id

*---------------Install synth package--------------*
ssc install synth, replace

*-----------Generate Log Imports-------------------*
gen log_imports = ln(imports)

*-----------------Check Mexico's Country ID--------*
tab country country_id

*---------------Placebo Tests---------------------*
* trunit(5) is Mexico — run all donor countries

synth log_imports log_imports(2015) log_imports(2016) log_imports(2017) log_imports(2018) log_imports(2019), trunit(1) trperiod(2020)
matrix list e(Y_treated)
matrix list e(Y_synthetic)

synth log_imports log_imports(2015) log_imports(2016) log_imports(2017) log_imports(2018) log_imports(2019), trunit(2) trperiod(2020)
matrix list e(Y_treated)
matrix list e(Y_synthetic)

synth log_imports log_imports(2015) log_imports(2016) log_imports(2017) log_imports(2018) log_imports(2019), trunit(3) trperiod(2020)
matrix list e(Y_treated)
matrix list e(Y_synthetic)

synth log_imports log_imports(2015) log_imports(2016) log_imports(2017) log_imports(2018) log_imports(2019), trunit(4) trperiod(2020)
matrix list e(Y_treated)
matrix list e(Y_synthetic)

synth log_imports log_imports(2015) log_imports(2016) log_imports(2017) log_imports(2018) log_imports(2019), trunit(6) trperiod(2020)
matrix list e(Y_treated)
matrix list e(Y_synthetic)

synth log_imports log_imports(2015) log_imports(2016) log_imports(2017) log_imports(2018) log_imports(2019), trunit(7) trperiod(2020)
matrix list e(Y_treated)
matrix list e(Y_synthetic)

*---------------Placebo Graph----------------------*
clear
input year mexico china germany india japan korea vietnam
2015 -0.024  0.522  0.040  0.049 -0.008  0.036 -0.162
2016 -0.016  0.486 -0.018 -0.003  0.016  0.032 -0.087
2017 -0.043  0.510 -0.025 -0.033  0.000  0.007 -0.042
2018 -0.008  0.478 -0.006  0.024 -0.008 -0.048 -0.096
2019  0.108  0.268  0.006 -0.173  0.000 -0.040  0.147
2020  0.005  0.329 -0.066 -0.429 -0.169  0.047  0.440
2021 -0.017  0.332 -0.118 -0.323 -0.252  0.001  0.340
2022  0.057  0.226 -0.203 -0.379 -0.309  0.071  0.401
2023  0.329 -0.069 -0.066 -0.311 -0.238  0.051  0.310
end

twoway ///
    (line china    year, lcolor(orange) lwidth(thin)) ///
    (line germany  year, lcolor(pink)   lwidth(thin)) ///
    (line india    year, lcolor(red)    lwidth(thin)) ///
    (line japan    year, lcolor(green)  lwidth(thin)) ///
    (line korea    year, lcolor(dknavy) lwidth(thin)) ///
    (line vietnam  year, lcolor(lavender) lwidth(thin)) ///
    (line mexico   year, lcolor(magenta) lwidth(thick)), ///
    xline(2020, lpattern(dash) lcolor(gray)) ///
    yline(0, lcolor(black)) ///
    title("Placebo Test: Mexico vs Donor Countries") ///
    xtitle("Year") ytitle("Gap (Real - Synthetic)") ///
    xlabel(2015(1)2023)

graph export "C:\Users\lucia\Downloads\placebo_graph.png", replace

*---------------Main Synthetic Control-------------*
* Reload original dataset before running main synth
* (uncomment lines below if running from scratch)
* import delimited "TradeData_3_13_2026_17_37_16.csv", clear
* keep refyear partnerdesc primaryvalue
* rename refyear year
* rename partnerdesc country
* rename primaryvalue imports
* destring year, replace
* destring imports, replace force
* encode country, gen(country_id)
* xtset country_id year
* gen log_imports = ln(imports)

synth log_imports log_imports(2015) log_imports(2016) log_imports(2017) log_imports(2018) log_imports(2019), ///
    trunit(5) trperiod(2020) resultsperiod(2015(1)2023) keep(synth_results.dta) replace figure

*---------------Main Graph Data--------------------*
clear
input year real_mexico synthetic_mexico
2015 26.424316 26.447771
2016 26.414301 26.429757
2017 26.478165 26.520675
2018 26.578897 26.587214
2019 26.613033 26.505244
2020 26.518904 26.514393
2021 26.685192 26.702016
2022 26.852703 26.795844
2023 26.897158 26.568161
end

gen gap  = real_mexico - synthetic_mexico
gen zero = 0

*---------------Pre-Treatment Fit Graph------------*
twoway ///
    (line real_mexico      year if year <= 2019, lcolor(blue) lwidth(medium)) ///
    (line synthetic_mexico year if year <= 2019, lcolor(red)  lpattern(dash) lwidth(medium)), ///
    legend(label(1 "US Imports from Mexico") label(2 "Synthetic Mexico")) ///
    title("Pre-Treatment Fit: Real vs Synthetic Mexico") ///
    subtitle("2015-2019") ///
    xtitle("Year") ytitle("Log of US Imports (USD)") ///
    xlabel(2015(1)2019)

*---------------Full Period Main Graph-------------*
twoway ///
    (line real_mexico      year, lcolor(blue) lwidth(medium)) ///
    (line synthetic_mexico year, lcolor(red)  lpattern(dash) lwidth(medium)), ///
    xline(2020, lpattern(dash) lcolor(gray)) ///
    legend(label(1 "US Imports from Mexico") label(2 "Synthetic Mexico")) ///
    title("Effect of USMCA on US Imports from Mexico") ///
    xtitle("Year") ytitle("Log of US Imports (USD)") ///
    xlabel(2015(1)2023)

graph export "C:\Users\lucia\Downloads\synth_main_graph.png", replace

*---------------Gap Graph--------------------------*
twoway ///
    (line gap  year, lcolor(purple) lwidth(medium)) ///
    (line zero year, lcolor(black)  lpattern(dash)), ///
    xline(2020, lpattern(dash) lcolor(gray)) ///
    yline(0, lcolor(black)) ///
    title("Treatment Effect of USMCA on US Imports from Mexico") ///
    xtitle("Year") ytitle("Gap (Real - Synthetic)") ///
    xlabel(2015(1)2023)

graph export "C:\Users\lucia\Downloads\gap_graph.png", replace
