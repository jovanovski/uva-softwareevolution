module Analysis::UnitTesting

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import util::Math;
import IO;

import Analysis::Utils;
import Metrics::Volume;
import Metrics::UnitTesting;

// Based on "Assessing the Relationship between Software Assertions and Faults: An Empirical Investigation" by Gunnar Kudrjavets, Nachiappan Nagappan & Thomas Ball.

// Actual scores are based on qualitative interpretation of case study in the paper.

public Score analyseModelUnitTesting(M3 model) {
	vol = countLinesInModel(model);
	assts = getModelAssertions(model);
	density = round(toReal(assts) / (toReal(vol) / 1000));
	score = getAssertionDensityScore(density);
	
	println("Unit Testing: <score>");	
	println("Total assertions: <assts>");
	println("Assertion density: <density>");
	println();
	
	return score;
}

public Score getAssertionDensityScore(int dens) {
	if (dens > 100) return PlusPlus();
	if (dens > 50) return Plus();
	if (dens > 25) return O();
	if (dens > 10) return Min();
	return MinMin();
}

public int getModelAssertionDensity(M3 model) {
	vol = countLinesInModel(model);
	assts = getModelAssertions(model);
	
	return round(toReal(assts) / (toReal(vol) / 1000)); 	
}