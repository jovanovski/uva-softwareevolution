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

data Risk = Low()
		  | Moderate()
		  | High()
		  | VeryHigh();

public Score getModelCcScore(M3 model) {
	rv = getRelVolumePerCcRisk(getVolumePerCcRisk(getCcRiskPerMethod(getCcPerMethod(model)), countLinesInModules(model)));
	vh = rv[VeryHigh()];
	h = rv[High()];
	m = rv[Moderate()];
	
	if (m <= 25 && h <= 0 && vh <= 0) return PlusPlus();
	if (m <= 30 && h <= 5 && vh <= 0) return Plus();
	if (m <= 40 && h <= 10 && vh <= 0) return O();
	if (m <= 50 && h <= 15 && vh <= 5) return Min();
	return MinMin();
}

public map[Risk,real] getModelRelVolumePerCcRisk(M3 model) {
	return getRelVolumePerCcRisk(getVolumePerCcRisk(getCcRiskPerMethod(getCcPerMethod(model)), countLinesInModules(model)));
}

public map[Risk,real] getRelVolumePerCcRisk(map[Risk,int] rv) {
	total = (0 | it + rv[risk] | risk <- rv);
	return (risk: toReal(rv[risk])/total*100 | risk <- rv);
}

public map[Risk,int] getModelVolumePerCcRisk(M3 model) {
	return getVolumePerCcRisk(getCcRiskPerMethod(getCcPerMethod(model)), countLinesInModules(model));
}

public map[Risk,int] getVolumePerCcRisk(set[tuple[loc,Risk]] methodrisks, set[tuple[loc,int]] methodvols) {
	r = (Low(): 0, Moderate(): 0, High(): 0, VeryHigh(): 0);
	for (<methodloc,risk> <- methodrisks) {
		methodvol = methodvols[methodloc];
		r[risk] += getOneFrom(methodvol);
	};
	return r;
}

public set[tuple[loc,Risk]] getModelCcRiskPerMethod(M3 model) {
	return getCcRiskPerMethod(getCcPerMethod(model));
}

public set[tuple[loc,Risk]] getCcRiskPerMethod(set[tuple[loc,int]] methodccs) {
	return { <methodloc,getCcRisk(methodcc)> | <methodloc,methodcc> <- methodccs };
}

public Risk getCcRisk(int cc) {
	if (cc <= 10) return Low();
	if (cc <= 20) return Moderate();
	if (cc <= 50) return High();
	return VeryHigh();
}
