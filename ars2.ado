/*assumes swimmodelsor2 has just been run*/
/*no longer necessary to include covars and specify model*/

capture program drop ars2
program define ars2
syntax namelist [if] [in] , swim(varlist)  [covar(varlist)] [byvars(string)]
marksample touse

local model=e(cmd)

tempvar xswim
tempvar xnoswim
tempvar xse
tempvar xnoswimse
tempvar xswimup
tempvar xnoswimup
tempvar xswimlo
tempvar xnoswimlo
capture drop pswimse
capture drop pnoswimse
capture drop pswim  
capture drop pswimup
capture drop pswimlo
capture drop pnoswim
capture drop pnoswimlo
capture drop pnoswimup
*capture drop ar
*capture drop arup
*capture drop arse
*capture drop arlo

if "`swim'"=="anycontact" {

local av=e(cmdline)
scalar l1=strpos("`av'", "waterexp")+length("waterexp")
scalar l2=strpos("`av'", "if")-l1

local avs=substr("`av'", l1,l2)

if "`model'"=="logit" {
quietly adjust `swim'=0 waterexp=0 `avs' if `touse', by(anycontact) se gen(`xnoswim' `xnoswimse') nokey noheader
quietly adjust `swim'=1 `avs' if `touse', by(`swim' waterexp) se gen(`xswim' `xse')  nokey noheader



gen `xswimup'=`xswim'+(1.96*`xse')
gen `xswimlo'=`xswim'-(1.96*`xse')

gen `xnoswimup'=`xnoswim'+(1.96*`xnoswimse')
gen `xnoswimlo'=`xnoswim'-(1.96*`xnoswimse')



gen pswim=(exp(`xswim'))/(1+(exp(`xswim')))
gen pswimse=pswim*(1-pswim)*`xse'
gen pnoswim=(exp(`xnoswim'))/(1+(exp(`xnoswim')))
gen pnoswimse=pnoswim*(1-pnoswim)*`xnoswimse'
gen pswimup=(exp(`xswimup'))/(1+(exp(`xswimup')))
gen pswimlo=(exp(`xswimlo'))/(1+(exp(`xswimlo')))
gen `namelist'=pswim-pnoswim if `swim'==1

gen pnoswimup=(exp(`xnoswimup'))/(1+(exp(`xnoswimup')))
gen pnoswimlo=(exp(`xnoswimlo'))/(1+(exp(`xnoswimlo')))



gen `namelist'se=sqrt(pswimse^2+pnoswimse^2)
gen `namelist'up=`namelist'+(1.96*`namelist'se)
gen `namelist'lo=`namelist'-(1.96*`namelist'se)

	}

if "`model'"=="glm" {
predictnl `namelist'=_b[`swim']*`swim'+_b[waterexp]*waterexp if `touse', ci(`namelist'lo `namelist'up) se(`namelist'se)
quietly adjust `swim'=0 waterexp=0 `avs' if `touse', by(anycontact) se gen(pnoswim pnoswimse) nokey noheader
quietly adjust `swim'=1 `avs' if `touse', by(`swim' waterexp) se gen(pswim pswimse)  nokey noheader

gen pswimup=pswim+(1.96*pswimse)
gen pswimlo=pswim-(1.96*pswimse)

gen pnoswimup=pnoswim+(1.96*pnoswimse)
gen pnoswimlo=pnoswim-(1.96*pnoswimse)

}

}

if "`swim'"!="anycontact" {


local av=e(cmdline)
scalar l1=strpos("`av'", "swimexp")+length("swimexp")
scalar l2=strpos("`av'", "if")-l1

local avs=substr("`av'", l1,l2)

if "`model'"=="logit" {

quietly adjust anycontact=0 `swim'=0 waterexp=0  swimexp=0 `avs' if `touse', by(anycontact `swim') se gen(`xnoswim' `xnoswimse') nokey noheader
quietly adjust anycontact=1 `swim'=1 `avs' if  `touse', by(anycontact `swim' waterexp swimexp) se gen(`xswim' `xse')  nokey noheader


gen `xswimup'=`xswim'+(1.96*`xse')
gen `xswimlo'=`xswim'-(1.96*`xse')

gen `xnoswimup'=`xnoswim'+(1.96*`xnoswimse')
gen `xnoswimlo'=`xnoswim'-(1.96*`xnoswimse')



gen pswim=(exp(`xswim'))/(1+(exp(`xswim')))
gen pswimse=pswim*(1-pswim)*`xse'
gen pnoswim=(exp(`xnoswim'))/(1+(exp(`xnoswim')))
gen pnoswimse=pnoswim*(1-pnoswim)*`xnoswimse'
gen pswimup=(exp(`xswimup'))/(1+(exp(`xswimup')))
gen pswimlo=(exp(`xswimlo'))/(1+(exp(`xswimlo')))

gen pnoswimup=(exp(`xnoswimup'))/(1+(exp(`xnoswimup')))
gen pnoswimlo=(exp(`xnoswimlo'))/(1+(exp(`xnoswimlo')))

gen `namelist'=pswim-pnoswim if `swim'==1

gen `namelist'se=sqrt(pswimse^2+pnoswimse^2)
gen `namelist'up=`namelist'+(1.96*`namelist'se)
gen `namelist'lo=`namelist'-(1.96*`namelist'se)

	}

if "`model'"=="glm" {
predictnl `namelist'=_b[anycontact]*anycontact+_b[`swim']*`swim'+_b[waterexp]*waterexp+_b[swimexp]*swimexp if `touse', ci(`namelist'lo `namelist'up) se(`namelist'se)
replace `namelist'=. if anycontact==1 & `swim'==0
replace `namelist'se=. if anycontact==1 & `swim'==0
replace `namelist'lo=. if anycontact==1 & `swim'==0
replace `namelist'up=. if anycontact==1 & `swim'==0
quietly adjust anycontact=0 `swim'=0 waterexp=0  swimexp=0 `avs' if `touse', by(anycontact `swim') se gen(pnoswim pnoswimse) nokey noheader
quietly adjust anycontact=1 `swim'=1 `avs' if  `touse', by(anycontact `swim' waterexp swimexp) se gen(pswim pswimse)  nokey noheader

gen pswimup=pswim+(1.96*pswimse)
gen pswimlo=pswim-(1.96*pswimse)

gen pnoswimup=pnoswim+(1.96*pnoswimse)
gen pnoswimlo=pnoswim-(1.96*pnoswimse)



	}

}
end

