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

public Score getModelCcScore(M3 model) {
	rv = getRelVolumePerRisk(getVolumePerRisk(getCcRiskPerMethod(getCcPerMethod(model)), countLinesInModules(model)));
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
	return getRelVolumePerRisk(getVolumePerRisk(getCcRiskPerMethod(getCcPerMethod(model)), countLinesInModules(model)));
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
