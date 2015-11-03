module Analysis::Complexity

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import List;
import util::Math;
import IO;

import Metrics::Complexity;
import Analysis::Core;

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

public Score ccscore(M3 model) {
	rv = ccriskrelvolume(model);	
	return head([s | <m,h,vh,s> <- scorethresholds, rv[Moderate()] <= m && rv[High()] <= h && rv[VeryHigh()] <= vh]);
}

public map[Risk,real] ccriskrelvolume(M3 model) {
	rv = ccriskvolume(model);
	total = (0 | it + rv[risk] | risk <- rv);
	return (risk: toReal(rv[risk])/total*100 | risk <- rv);
}

public map[Risk,int] ccriskvolume(M3 model) {
	r = (Low(): 0, Moderate(): 0, High(): 0, VeryHigh(): 0);
	for (<methodloc,risk> <- methodccrisks(model)) {
		methodvolume = 1;
		r[risk] += methodvolume;
	};
	return r;
}

public set[tuple[loc,Risk]] methodccrisks(M3 model) {
	return { <methodloc,head([score | <min,score> <- riskthresholds, methodcc >= min])> | <methodloc,methodcc> <- methodccs(model) };
}
