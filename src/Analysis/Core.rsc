module Analysis::Core

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;

import Analysis::Utils;
import Analysis::Complexity;

map[str, list[str]] scpmntmap = (
	"Analysability": ["Volume", "Duplication", "Unit size", "Unit testing"],
	"Changeability": ["Complexity per unit", "Duplication"],
	"Stability": ["Unit testing"],
	"Testability": ["Complexity per unit", "Unit size", "Unit testing"] 
); 

public map[str,Score] computeModelScpScores(M3 model) {
	return (
		"Volume": O(),
		"Complexity per unit": getModelCcScore(model),
		"Duplication": O(),
		"Unit size": O(),
		"Unit testing": O()
	);
}

public map[str,Score] computeModelMntScores(M3 model) {
	
}

public void analyseModel(M3 model) {
	println("The following source property scores have been computed:");
	scpscores = computeModelScpScores(model);
	for (prop <- scpscores) {
		println("<prop>: <scpscores[prop]>");
	};
	println("");
	println("This has resulted in the following maintainability scores:");
	for (c <- scpmntmap) {
		println("<c>:<avgscore([scpscores[p] | p <- scpmntmap[c]])>");
	}
}