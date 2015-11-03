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

// <cc,risk> 
list[tuple[int,Risk]] riskthresholds = [
	<50,VeryHigh()>,
	<21,High()>,
	<11,Moderate()>,
	<1,Low()>
];

// <moderate risk %, high risk %, very high risk %, score>
list[tuple[int,int,int,Score]] scorethresholds = [
	<25,0,0,PlusPlus()>,
	<30,5,0,Plus()>,
	<40,10,0,O()>,
	<50,15,5,Min()>,
	<100,100,100,MinMin()>
];

public Score getModelCcScore(M3 model) {
	rv = getRelVolumePerCcRisk(getVolumePerCcRisk(getCcRiskPerMethod(getCcPerMethod(model)), countLinesInModules(model)));	
	return head([s | <m,h,vh,s> <- scorethresholds, rv[Moderate()] <= m && rv[High()] <= h && rv[VeryHigh()] <= vh]);
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
	return { <methodloc,head([score | <min,score> <- riskthresholds, methodcc >= min])> | <methodloc,methodcc> <- methodccs };
}
