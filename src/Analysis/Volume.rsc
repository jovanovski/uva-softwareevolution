module Analysis::Volume

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;

import Analysis::Utils;
import Metrics::Volume;
import IO;

public Score analyseModelVolume(M3 model) {
	ls = countLinesInModel(model);
	score = volumeMetric(ls);
	
	println("Volume: <score>");	
	println("Lines of code (not counting empty & comments): <ls>");
	println();
	
	return score;
}

public Score volumeMetric(int lines){
	if(lines < 66000) return PlusPlus();
	if(lines < 246000) return Plus();
	if(lines < 665000) return O();
	if(lines < 1310000) return Minus();
	return MinusMinus();
}