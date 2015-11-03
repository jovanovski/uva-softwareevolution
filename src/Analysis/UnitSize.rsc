module Analysis::UnitSize

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import IO;

import Analysis::Utils;
import Metrics::Volume;

// categorization source: http://swerl.tudelft.nl/twiki/pub/Main/TechnicalReports/TUD-SERG-2014-008.pdf
public Score getModelUnitSizeScore(M3 model) {
	methodvols = countLinesInModules(model);
	rv = getRelVolumePerRisk(getVolumePerRisk(getUnitSizeRiskPerMethod(methodvols), methodvols));
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