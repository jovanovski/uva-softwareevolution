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
	rvl = getRelVolumePerRisk(getVolumePerRisk(getUnitSizeRiskPerMethod(methodvols), model@containment));
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
	
	if (m <= 25 && h <= 0 && vh <= 0) return PlusPlus();
	if (m <= 30 && h <= 5 && vh <= 0) return Plus();
	if (m <= 40 && h <= 10 && vh <= 0) return O();
	if (m <= 50 && h <= 15 && vh <= 5) return Min();
	return MinMin();
}

public map[Risk,int] getVolumePerRisk(rel[loc,Risk] methodrisks, rel[loc, loc] con) {
	r = (Low(): 0, Moderate(): 0, High(): 0, VeryHigh(): 0);
	for (<l,risk> <- methodrisks) {
		mvol = size(getLinesInUnit(l, con));
		r[risk] += mvol;
	};
	return r;
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