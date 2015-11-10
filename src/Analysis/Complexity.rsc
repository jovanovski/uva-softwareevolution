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

public map[Risk,int] getVolumePerRisk(rel[str,loc,Risk] methodrisks, rel[loc, loc] con, rel[loc, loc] doc) {
	r = (Low(): 0, Moderate(): 0, High(): 0, VeryHigh(): 0);
	for (<n,l,risk> <- methodrisks) {
		mvol = size(getLinesInUnit(l, con, doc));
		r[risk] += mvol;
	};
	return r;
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
