module Metrics::Utils

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;
import String;
import List;

public set[tuple[loc,Declaration]] getMethodAsts(M3 model) {
	return {<methodloc,getMethodASTEclipse(methodloc, model=model)> | methodloc <- methods(model)};
}
