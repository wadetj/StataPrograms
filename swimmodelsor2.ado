/*NOTE THIS IS THE CURRENT VRSION OF THIS PROGRAM, ALL OTHERS SHOULD BE REPLACED BY THIS*/

capture program drop swimmodelsor2
program swimmodelsor2
syntax [if] [in], outcome(varlist) model(string) swim(varlist) exposure(varlist)  [clustervar(varlist)] [covar(string)] [unit(real 1)] [predictvar(string)]  

capture drop waterexp 
capture drop swimexp
 
marksample touse
display in white "`outcome' `exposure' `swim'"

set more off
tempvar hhnum
capture gen `hhnum'=real(hh)
if "`swim'"=="anycontact"{

*tempvar waterexp
gen waterexp=`swim'*`exposure' if `touse'

if "`clustervar'"=="" { 
if "`model'"=="logit" {
xi: logit `outcome' `swim' waterexp `covar' if `touse'
lincom `swim'+ `unit'*waterexp
lincom waterexp
lincom `swim'+ `unit'*waterexp, or
lincom `unit'*waterexp, or
}

if "`model'"=="glm" {
xi: glm `outcome' `swim' waterexp `covar' if `touse', family(binomial) link(identity) 
lincom anycontact+`unit'*waterexp
}

if "`model'"=="glmRR" {
xi: glm `outcome' `swim' waterexp `covar' if `touse', family(binomial) link(log) 
lincom `swim'+ `unit'*waterexp
lincom waterexp
lincom `swim'+ `unit'*waterexp, rr
lincom `unit'*waterexp, rr
}


*adjust `swim'=0 waterexp=0 `covar' if `swim'==0, by(`swim') pr gen(pnoswim)
*adjust "`swim'"=1  "`covar'" if `swim'==1, by(`swim' `waterexp') pr gen(pswim)	

	}

else if "`clustervar'"~="" {
if "`model'"=="logit" {
xi: logit `outcome' `swim' waterexp `covar' if `touse', cluster(`clustervar')
lincom `swim'+ `unit'*waterexp
lincom `unit'*waterexp
lincom `swim'+`unit'*waterexp, or
lincom `unit'*waterexp, or

}



if "`model'"=="glmRR" {
xi: glm `outcome' `swim' waterexp `covar' if `touse', family(binomial) link(log) cluster(`clustervar')
lincom `swim'+ `unit'*waterexp
lincom `unit'*waterexp
lincom `swim'+`unit'*waterexp, rr
lincom `unit'*waterexp, rr
}



if "`model'"=="gmlogit" {
	
xi: xtgee `outcome' `swim' waterexp `covar' if `touse',  family(binomial) link(logit) robust i(`clustervar')
lincom `swim'+ `unit'*waterexp
lincom `unit'*waterexp
lincom `swim'+`unit'*waterexp, or
lincom `unit'*waterexp, or

}

if "`model'"=="gmlinear" {

xi: xtgee `outcome' `swim' waterexp `covar' if `touse', family(binomial) link(identity) robust i(`clustervar')
lincom `unit'*waterexp
lincom anycontact+`unit'*waterexp

}


if "`model'"=="glm" {
xi: glm `outcome' `swim' waterexp `covar' if `touse', family(binomial) link(identity) cluster(`clustervar') 
lincom `unit'*waterexp
lincom anycontact+`unit'*waterexp
		}
	}
}

else if "`swim'"~="anycontact" {
*tempvar waterexp
*tempvar swimexp

gen waterexp=anycontact*`exposure'
gen swimexp=`swim'*`exposure'

if "`clustervar'"=="" {
if "`model'"=="logit" { 
xi: logit `outcome' anycontact waterexp `swim' swimexp `covar' if `touse'
lincom anycontact+`swim'+`unit'*waterexp+`unit'*swimexp
lincom `unit'*waterexp+`unit'*swimexp
lincom anycontact+`swim'+`unit'*waterexp+`unit'*swimexp, or
lincom `unit'*waterexp+`unit'*swimexp, or
}
if "`model'"=="glm" {
xi: glm `outcome' anycontact `swim' waterexp swimexp `covar' if `touse', family(binomial) link(identity)
lincom `unit'*waterexp+`unit'*swimexp
lincom anycontact+`unit'*waterexp+`swim'+`unit'*swimexp
}


if "`model'"=="glmRR" {
xi: glm `outcome' anycontact `swim' waterexp swimexp `covar' if `touse', family(binomial) link(log)
lincom `unit'*waterexp+`unit'*swimexp
lincom anycontact+`swim'+`unit'*waterexp+`unit'*swimexp, rr
lincom `unit'*waterexp+`unit'*swimexp, rr
}

	}

		
else if "`clustervar'"~="" {
if "`model'"=="logit" {
xi: logit `outcome' anycontact waterexp `swim' swimexp `covar' if `touse', cluster(`clustervar') 
lincom anycontact+`swim'+`unit'*waterexp+`unit'*swimexp
lincom `unit'*waterexp+`unit'*swimexp
lincom anycontact+`swim'+`unit'*waterexp+`unit'*swimexp, or
lincom `unit'*waterexp+`unit'*swimexp, or
}

if "`model'"=="gmlogit" {
	
xi: xtgee `outcome' anycontact waterexp `swim' swimexp `covar' if `touse',  family(binomial) link(logit) robust i(`clustervar')
lincom anycontact+`swim'+`unit'*waterexp+`unit'*swimexp
lincom `unit'*waterexp+`unit'*swimexp
lincom anycontact+`swim'+`unit'*waterexp+`unit'*swimexp, or
lincom `unit'*waterexp+`unit'*swimexp, or

}

if "`model'"=="gmlinear" {

xi: xtgee `outcome' anycontact `swim' waterexp swimexp `covar' if `touse', family(binomial) link(identity) robust i(`clustervar')
lincom `unit'*waterexp+`unit'*swimexp
lincom anycontact+`unit'*waterexp+`swim'+`unit'*swimexp

}



if "`model'"=="glm" {
xi: glm `outcome' anycontact `swim' waterexp swimexp `covar' if `touse', family(binomial) link(identity) cluster(`clustervar') 
lincom `unit'*waterexp+`unit'*swimexp
lincom anycontact+`unit'*waterexp+`swim'+`unit'*swimexp
		}



if "`model'"=="glmRR" {
xi: glm `outcome' anycontact `swim' waterexp swimexp `covar' if `touse', family(binomial) link(log) cluster(`clustervar')
lincom `unit'*waterexp+`unit'*swimexp
lincom anycontact+`swim'+`unit'*waterexp+`unit'*swimexp, rr
lincom `unit'*waterexp+`unit'*swimexp, rr
}

	}
		}
end

