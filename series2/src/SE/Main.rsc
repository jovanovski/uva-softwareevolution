module SE::Main

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import List;

public list[Statement] listStatements(\method(_, _, _, _, Statement impl)) = listStatements(impl);
public list[Statement] listStatements(\constructor(_, _, _, Statement impl)) = listStatements(impl);

private list[Statement] listStatements(Statement s) {
	sts = [];
	top-down visit(s) {
		case Statement s1: if (s != s1) sts += replaceNestedStatements(s1);	
	}
	return sts;
}

private Statement replaceNestedStatements(Statement s) {
	return top-down visit(s) {
		case Statement s1: if (s != s1) return \empty();
	}
}
