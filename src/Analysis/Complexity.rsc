module Analysis::Complexity

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import List;
import util::Math;
import IO;
import Set;

import Metrics::Complexity;
import Analysis::Utils;
import Metrics::Volume;


public Score analyseModelComplexity(M3 model, int suggs = 5) {
	methodccs = getModelCcPerMethod(model);
	rvl = getRelVolumePerRisk(getVolumePerRisk(getCcRiskPerMethod(methodccs)));
	score = getModelCcScore(rvl);
	
	println("Complexity: <score>");
	println();
	println("Risk volume (%):");
	println("  very high: <rvl[VeryHigh()]>");
	println("  high: <rvl[High()]>");
	println("  moderate: <rvl[Moderate()]>");
	println("  low: <rvl[Low()]>");
	println();
	println("The <suggs> units with the highest complexity are:");
	for (<n,l,cc> <- take(suggs,sort(methodccs, bool (<na,la,cca>,<nb,lb,ccb>) { return cca > ccb; }))) {
		println("<cc>: <n> in <l>");
	};
	println("These units could be good candidates for refactoring.");
	println();	
	
	return score;
}

public Score getModelCcScore(map[Risk,real] rv) {
	vh = rv[VeryHigh()];
	h = rv[High()];
	m = rv[Moderate()];
	
	if (m <= 25 && h <= 0 && vh <= 0) return PlusPlus();
	if (m <= 30 && h <= 5 && vh <= 0) return Plus();
	if (m <= 40 && h <= 10 && vh <= 0) return O();
	if (m <= 50 && h <= 15 && vh <= 5) return Min();
	return MinMin();
}

public rel[str,loc,Risk] getCcRiskPerMethod(rel[str,loc,int] methodccs) {
	return { <mname,mloc,getCcRisk(mcc)> | <mname,mloc,mcc> <- methodccs };
}

public Risk getCcRisk(int cc) {
	if (cc <= 10) return Low();
	if (cc <= 20) return Moderate();
	if (cc <= 50) return High();
	return VeryHigh();
}
