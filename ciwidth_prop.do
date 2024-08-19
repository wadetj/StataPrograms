
/*propci calculates sample sized needed for a sampled proportion at a specified 
confidence bound. Either the upper or lower bound ("upper" or "lower") must be specified
in the ubtype option. First number is the proportion, second is the desired upper 
or lower bound

example:

propci 0.01 0.015, ubtype("upper") level(95)
propci 0.04 0.02, ubtype("lower") level(90)

output includes N- number; p- proportion; tail-the binomial probability in the tail;
diff- difference between the tail probability and desired tail probability e.g., (1-level)/2

*/

capture program drop propci
program define propci, rclass

syntax [anything],  ubtype(string) [level(real 95)] [start(integer 5)] [stop(integer 5000)] 

tokenize `anything'	
	
local p=`1'
local ub=`2'
local lev=(1-(`level'/100))/2
local j=0	
local num=`stop'-`start'+1
matrix S=J(`num', 4, .)
local j=0
if "`ubtype'"=="upper" {
forvalues i=`start'(1)`stop' {
		local j=`j'+1
		local n=`i'
		local k=`n'*`p'
		local x= binomial(`n', `k', `ub')
		local d=abs(`x'-`lev')
		
		matrix S[`j', 1]=`n'
		matrix S[`j', 2]=`p'
		matrix S[`j', 3]=`x'
		matrix S[`j', 4]=`d'
	}
}

else if "`ubtype'"=="lower" {
	
forvalues i=`start'(1)`stop' {
		local j=`j'+1
		local n=`i'
		local k=`n'*`p'
		local x= binomialtail(`n', `k', `ub')
		local d=abs(`x'-`lev')
		
		matrix S[`j', 1]=`n'
		matrix S[`j', 2]=`p'
		matrix S[`j', 3]=`x'
		matrix S[`j', 4]=`d'
	}
}

  mata: Sm=st_matrix("S")
  mata: minindex(Sm[, 4], 1, i=., w=.)
  mata: Smin=Sm[i, ]
  mata: st_matrix("Smin", Smin)

matrix  colnames Smin= N p tail diff
matlist Smin
return scalar N=Smin[1,1]
return scalar UB=`ub'
return scalar level=`level'


end

  

/*propwaldci calculates sample sized needed for a sampled proportion at a specified 
confidence bound width assuming the normal approximation.
example:

propwaldci 0.4 0.01
propwaldci 0.4 0.01, level(90)

*/
	


capture program drop propwaldci
program define propwaldci, rclass

syntax anything, [level(real 95)] 

tokenize `anything'
scalar lev=`level'/100
scalar z=invnormal(1-((1-lev)/2))

scalar p=`1'
scalar w=`2'

scalar n=round((z^2*(p*(1-p)))/w^2)


di "N= " n
return scalar N=n

end


