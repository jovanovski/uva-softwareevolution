module Analysis::Utils

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import util::Math;
import List;
import Set;

public data Score = PlusPlus()
		   		  | Plus()
				  | O()
				  | Min()
				  | MinMin();
		   
map[Score,int] scoreVals = (
	PlusPlus(): 2,
	Plus(): 1,
	O(): 0,
	Min(): -1,
	MinMin(): -2
);

public Score avgscore(list[Score] scores) {
	vs = [scoreVals[s] | s <- scores];
	roundedavg = round(toReal(sum(vs)) / toReal(size(vs)));
	return getOneFrom({s | s <- scoreVals, scoreVals[s] == roundedavg});
}