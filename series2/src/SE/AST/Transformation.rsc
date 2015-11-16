module SE::AST::Transformation

import lang::java::m3::AST;

public list[Statement] listMethodStatements(\method(_, _, _, _, Statement impl)) = listStatements(impl);
public list[Statement] listMethodStatements(\constructor(_, _, _, Statement impl)) = listStatements(impl);

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