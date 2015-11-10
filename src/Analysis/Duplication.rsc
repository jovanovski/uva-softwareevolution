module Analysis::Duplication

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import Metrics::Volume;
import Metrics::Duplication;
import Analysis::Utils;
import IO;
import util::Math;

public Score analyseModelDuplication(M3 model) {
	int dup = duplicationInModel(model);
	int ls = countLinesInModel(model);
	score = duplicationMetric(dup, ls);
	
	println("Duplication: <score>");
	println("Procentage of code duplicated: <(toReal(dup)/toReal(ls))*100>%");
	println("LOC that are duplicates: <dup>");
	println();
	
	return score;
}

public Score duplicationMetric(dup, lines){
	real res = dup / (lines / 100.0);
	
	if(res <= 3.0) return PlusPlus();;
	if(res <= 5.0) return Plus();
	if(res <= 10.0) return O();
	if(res <= 20.0) return Min();
	return MinMin();
}
