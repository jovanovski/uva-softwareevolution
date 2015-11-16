module SE::AST::Transformation

import lang::java::m3::AST;

public list[Statement] listStatementNodes(\method(_, _, _, _, Statement impl)) = listStatements(impl);
public list[Statement] listStatementNodes(\constructor(_, _, _, Statement impl)) = listStatements(impl);

private list[Statement] listStatementNodes(Statement s) {
	sts = [];
	top-down visit(s) {
		case Statement s1: if (s != s1) sts += replaceNestedStatements(s1);	
	}
	return sts;
}

private Statement listStatementNodes(Statement s) {
	return top-down visit(s) {
		case Statement s1 => s == s1 ? s : \empty()
	}
}

public Declaration anonymizeTypes(Declaration d) {
	return top-down visit(d) {
		case Type t1 => \void()
	}
}

public Declaration anonymizeIdentifiers(Declaration d) {
	int ctr = 0;
	map[str,str] vals = ();
	return visit(d) {
		case \simpleName(s) => {if (s notin vals) vals[s] = "v<ctr>"; ctr+=1; \simpleName(vals[s]); }  
	}
}

public Declaration anonymizeLiterals(Declaration d) {
	return visit(d) {
		case \characterLiteral(_) => \characterLiteral("a")
		case \booleanLiteral(_) => \booleanLiteral(true)
		case \stringLiteral(_) => \stringLiteral("")
	};
}
