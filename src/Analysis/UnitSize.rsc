module Analysis::UnitSize

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;
import List;
import Set;

import Analysis::Utils;
import Metrics::Volume;

public Score analyseModelUnitSize(M3 model, int suggs = 5) {
	methodvols = countLinesInModules(model);
	rvl = getRelVolumePerRisk(getVolumePerRisk(getUnitSizeRiskPerMethod(methodvols), methodvols));
	score = getUnitSizeScore(rvl);
	
	println("Unit size: <score>");
	println();
	println("Risk volume (%):");
	println("  very high: <rvl[VeryHigh()]>");
	println("  high: <rvl[High()]>");
	println("  moderate: <rvl[Moderate()]>");
	println("  low: <rvl[Low()]>");
	println();
	
	println("The <suggs> largest units are:");
	for (<m,v> <- take(suggs,sort(methodvols, bool (<ma,va>,<mb,vb>) { return va > vb; }))) {
		println("<v>: <m>");
	};	
	println("These units could be good candidates for refactoring.");
	println();
	
	return score;
}

// categorization source: http://swerl.tudelft.nl/twiki/pub/Main/TechnicalReports/TUD-SERG-2014-008.pdf
public Score getUnitSizeScore(map[Risk,real] rv) {
	vh = rv[VeryHigh()];
	h = rv[High()];
	m = rv[Moderate()];
	
	if (m <= 12.3 && h <= 6.1 && vh <= 0.8) return PlusPlus();
	if (m <= 27.6 && h <= 16.1 && vh <= 7.0) return Plus();
	if (m <= 35.4 && h <= 25.0 && vh <= 14.0) return O();
	if (m <= 54.0 && h <= 43.0 && vh <= 24.2) return Min();
	return MinMin();
}

public rel[loc,Risk] getUnitSizeRiskPerMethod(rel[loc,int] methodunitsizes) {
	return {<methodloc,getUnitSizeRisk(methodunitsize)> | <methodloc,methodunitsize> <- methodunitsizes};
} 

public Risk getUnitSizeRisk(int size) {
	if (size <= 24) return Low();
	if (size <= 31) return Moderate();
	if (size <= 48) return High();
	return VeryHigh();
}