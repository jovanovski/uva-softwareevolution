module Analysis::Duplication

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import Metrics::Volume;
import Metrics::Duplication;
import Analysis::Utils;
import IO;

public Score duplicationMetric(M3 model){
	int dup = duplicationInModel(model);
	int lines = countLinesInModel(model);
	real res = dup / (lines / 100.0);
	
	if(res <= 3.0) return PlusPlus();;
	if(res <= 5.0) return Plus();
	if(res <= 10.0) return O();
	if(res <= 20.0) return Minus();
	return MinusMinus();
}
