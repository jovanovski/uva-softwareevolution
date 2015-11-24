module SE::CloneDetection::AstMetrics

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;

public list[str] getNodeTypesVector(M3 model) {
	return astNodeTypes = toList({getName(n) | m <- methods(model), /node n <- getMethodASTEclipse(m, model=model)});
}

