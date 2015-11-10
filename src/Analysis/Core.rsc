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
import Analysis::UnitTesting;

public bool useDocumentation = false;

map[str, list[str]] scpmntmap = (
	"Analysability": ["Volume", "Duplication", "Unit size", "Unit testing"],
	"Changeability": ["Complexity per unit", "Duplication"],
	"Stability": ["Unit testing"],
	"Testability": ["Complexity per unit", "Unit size", "Unit testing"] 
); 

public map[str,Score] computeModelScpScores(M3 model, int suggs = 5) {
	return (
		"Volume": analyseModelVolume(model),
		"Complexity per unit": analyseModelComplexity(model, suggs=suggs),
		"Duplication": analyseModelDuplication(model),
		"Unit size": analyseModelUnitSize(model, suggs=suggs),
		"Unit testing": analyseModelUnitTesting(model)
	);
}

public map[str,Score] computeMntScores(map[str,Score] scpscores) {
	return (c: avgscore([scpscores[p] | p <- scpmntmap[c]]) | c <- scpmntmap);
}

data X = x() | y(int i);
test bool f() {
	return false;
}

public Score analyseModel(M3 model, int suggs = 5) {
	println("-- Analysis --");
	println();
	scpscores = computeModelScpScores(model,suggs=suggs);
	
	println("-- Summary --");	
	println("Source code property scores:");
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
	
	score = avgscore([mntscores[s] | s <- mntscores]);
	println("Overall score: <score>");
	
	println("-- Done --");
	
	return score;
}