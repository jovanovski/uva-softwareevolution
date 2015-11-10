module Analysis::UnitSize

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;
import List;
import Set;

import Analysis::Utils;
import Metrics::Volume;
import Metrics::Utils;

public Score analyseModelUnitSize(M3 model, int suggs = 5) {
	methodvols = countLinesInModules(model);
	rvl = getRelVolumePerRisk(getVolumePerRisk(getUnitSizeRiskPerMethod(methodvols), model@containment, model@documentation));
	score = getRiskRatioScore(rvl);
	
	println("Unit size: <score>");
	println("Risk volume (%):");
	println("  very high: <rvl[VeryHigh()]>");
	println("  high: <rvl[High()]>");
	println("  moderate: <rvl[Moderate()]>");
	println("  low: <rvl[Low()]>");	
	println("The <suggs> largest units are:");
	for (<m,v> <- take(suggs,sort(methodvols, bool (<ma,va>,<mb,vb>) { return va > vb; }))) {
		println("<v>: <m>");
	};	
	println("These units could be good candidates for refactoring.");
	println();
	
	return score;
}

public rel[loc,Risk] getUnitSizeRiskPerMethod(rel[loc,int] methodunitsizes) {
	return {<methodloc,getUnitSizeRisk(methodunitsize)> | <methodloc,methodunitsize> <- methodunitsizes};
} 

public Risk getUnitSizeRisk(int size) {
	if (size <= 20) return Low();
	if (size <= 50) return Moderate();
	if (size <= 100) return High();
	return VeryHigh();
}