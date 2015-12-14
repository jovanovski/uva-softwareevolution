module SE::CloneDetection::AstMetrics::AstGeneration

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;

public list[node] generateAsts(M3 model) {
	return [getMethodASTEclipse(meth,model=model) | meth <- methods(model)];
}