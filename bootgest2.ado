*calculates difference in coefficients, or risk difference 
*avoids saving and resaving files 
*capture program drop bootgest2
*modification: 7/18/13-added preserve restore to avoid losing data if command is halted
program bootgest2
version 11.0

preserve

syntax anything [if] [in], [breps(real 100)] [boptions(string)] [level0(real 0)] [level1(real 1)] [predopts(string)] [regopts(string)]
marksample touse
tokenize `anything'
local cmd `1'
local outcome `2'
local exposure `3'
mac shift 3
local covar `*'
tempfile fdat
save `fdat'
qui `cmd' `outcome' `exposure' `covar' if `touse', `regopts'
keep if e(sample) & `touse'
bootstrap diff=r(diff), reps(`breps') `boptions': gest2 `cmd' `outcome' `exposure' `covar' if `touse', regopts(`regopts') level1(`level1') level0(`level0') predopts(`predopts')
clear
use `fdat'

restore

end

*capture program drop gest2
/*
program gest2, rclass
version 11.0
syntax anything [if] [in], [level0(real 0)] [level1(real 1)] [predopts(string)] [regopts(string)]

tokenize `anything'
local cmd `1'
local outcome `2'
local exposure `3'

mac shift 3
local covar `*'

marksample touse
tempvar pex punex

local expname=subinstr("`exposure'", "i.", "", .)

tempvar tempexp
gen `tempexp'=`expname'

`cmd' `outcome' `exposure' `covar' if `touse', `regopts'
*est store fmod
*tempfile full
*tempvar id
*gen `id'=_n

*save "`full'", replace

*tempfile unex


replace `expname'=`level0'
predict `punex' if e(sample), `predopts'
*keep `id' `punex'
*save "`unex'", replace

*use "`full'", clear

*tempfile ex
replace `expname'=`level1'
predict `pex' if e(sample), `predopts'

*keep `id' `pex'
*save "`ex'", replace

*use "`full'", clear

*capture drop _merge

*merge 1:1 `id' using `unex'
*qui assert _merge==3
*drop _merge

*merge 1:1 `id' using `ex'
*qui assert _merge==3
*drop _merge

tempvar xdiff

gen `xdiff'=`pex'-`punex' if e(sample)
qui summ `xdiff', meanonly
return scalar diff=r(mean)

di r(diff)



return list

replace `expname'=`tempexp'

end
*/
