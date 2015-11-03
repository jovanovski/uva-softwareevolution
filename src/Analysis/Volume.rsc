module Analysis::Volume

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import Metrics::Utils;
import Analysis::Utils;
import IO;

public Score volumeMetric(M3 model){
	int lines = countLinesInModel(model);
	if(lines < 66000) return PlusPlus();
	if(lines < 246000) return Plus();
	if(lines < 665000) return O();
	if(lines < 1310000) return Minus();
	return MinusMinus();
}