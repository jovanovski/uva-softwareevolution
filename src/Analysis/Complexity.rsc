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
import Metrics::Utils;


public Score analyseModelComplexity(M3 model, int suggs = 5) {
	methodccs = getModelCcPerMethod(model);
	rvl = getRelVolumePerRisk(getVolumePerRisk(getCcRiskPerMethod(methodccs), model@containment, model@documentation));
	score = getRiskRatioScore(rvl);
	
	println("Complexity: <score>");
	println("Risk volume (%):");
	println("  very high: <rvl[VeryHigh()]>");
	println("  high: <rvl[High()]>");
	println("  moderate: <rvl[Moderate()]>");
	println("  low: <rvl[Low()]>");
	println("The <suggs> units with the highest complexity are:");
	for (<l,cc> <- take(suggs,sort(methodccs, bool (<la,cca>,<lb,ccb>) { return cca > ccb; }))) {
		println("<cc>: <l>");
	};
	println("These units could be good candidates for refactoring.");
	println();	
	
	return score;
}

public rel[loc,Risk] getCcRiskPerMethod(rel[loc,int] methodccs) {
	return { <mloc,getCcRisk(mcc)> | <mloc,mcc> <- methodccs };
}

public Risk getCcRisk(int cc) {
	if (cc <= 10) return Low();
	if (cc <= 20) return Moderate();
	if (cc <= 50) return High();
	return VeryHigh();
}
