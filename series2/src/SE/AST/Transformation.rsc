module SE::AST::Transformation

import lang::java::m3::AST;
import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import IO;

public list[Statement] listStatementNodes(Declaration d) {
	sts = [];
	top-down visit(d) {
		case Statement s: sts += replaceNestedStatementsAndStatementLists(s);
	}
	return sts;
}

private Statement replaceNestedStatementsAndStatementLists(Statement s) {
	return top-down visit(s) {
		case list[Statement] l => []
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


public Declaration renameStuff(Declaration ast){
	return visit(ast){
		case \variable(_, int extraDimensions) => \variable("p", extraDimensions)
		case \variable(_, int extraDimensions, Expression \initializer) => \variable("p", extraDimensions, \initializer)
		case \simpleName(_) => \simpleName("p")
		case \characterLiteral(_) => \characterLiteral("a")
		case \booleanLiteral(_) => \booleanLiteral(true)
		case \stringLiteral(_) => \stringLiteral("ab")
		case Type t => wildcard()
		case \methodCall(bool isSuper, _, list[Expression] arguments) => \methodCall(isSuper, "specialMethod", arguments)
		case \methodCall(bool isSuper, Expression receiver, _, list[Expression] arguments) => \methodCall(isSuper, receiver, "specialMethod", arguments)
		case \fieldAccess(bool isSuper, Expression expression, _) => \fieldAccess(isSuper, expression, "fa")
   		case \fieldAccess(bool isSuper, _) => \fieldAccess(isSuper, "fa")
   		case \label(_, Statement body) => \label("la", body)
   		case \method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl) => \method(\return, "me", parameters, exceptions, impl)
   		case \method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions) => \method(\return, "me", parameters, exceptions)
	}
}

public bool compareASTs(){
	M3 model = createM3FromEclipseProject(|project://testproj|);
	Declaration ast1 = getMethodASTEclipse(|java+method:///testproj/cls1/res()|, model=model);
	Declaration ast2 = getMethodASTEclipse(|java+method:///testproj/cls2/res1()|, model=model);
	
	ast1 = renameStuff(ast1);
	ast2 = renameStuff(ast2);
	
	iprint(ast2);
	
	
	return ast1==ast2;
}
