module Analysis::Core

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;

import Analysis::Utils;
import Analysis::Complexity;

public map[str,Score] getModelScores(M3 model) {
	return (
		"Complexity": getModelCcScore(model)
	);
}