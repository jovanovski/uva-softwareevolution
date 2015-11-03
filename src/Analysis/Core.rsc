module Analysis::Core

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;

import Analysis::Utils;
import Analysis::Complexity;
import Analysis::Duplication;
import Analysis::Volume;
import Analysis::UnitSize;

map[str, list[str]] scpmntmap = (
	"Analysability": ["Volume", "Duplication", "Unit size", "Unit testing"],
	"Changeability": ["Complexity per unit", "Duplication"],
	"Stability": ["Unit testing"],
	"Testability": ["Complexity per unit", "Unit size", "Unit testing"] 
); 

public map[str,Score] computeModelScpScores(M3 model) {
	return (
		"Volume": volumeMetric(model),
		"Complexity per unit": getModelCcScore(model),
		"Duplication": duplicationMetric(model),
		"Unit size": getModelUnitSizeScore(model),
		"Unit testing": O()
	);
}

public map[str,Score] computeMntScores(map[str,Score] scpscores) {
	return (c: avgscore([scpscores[p] | p <- scpmntmap[c]]) | c <- scpmntmap);
}

//data X = x() | y(int i);
//test bool f(X t) = y(_) := t;

public void analyseModel(M3 model) {
	println("Source code property scores:");
	scpscores = computeModelScpScores(model);
	for (prop <- scpscores) {
		println("<prop>: <scpscores[prop]>");
	};
	
	println("");
	println("Maintainability scores:");
	mntscores = computeMntScores(scpscores);
	for (c <- mntscores) {
		println("<c>:<mntscores[c]>");
	}
	
	println("");
	println("Overall score: <avgscore([mntscores[s] | s <- mntscores])>");
}