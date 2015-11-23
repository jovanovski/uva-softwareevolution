module SE::AST::Transformation

import IO;
import Node;
import List;
import lang::java::m3::AST;
import util::Maybe;

data AstNode
	= \declarationNode(str name, int descendantCount, loc src)
	| \statementNode(str name, int descendantCount, loc src)
	| \expressionNode(str name, int descendantCount, loc src)
	| \typeNode(str name, int descendantCount); 

public list[AstNode] serializeAst(node n) {
	list[AstNode] nodes = [];
	top-down visit(n) {
		case \Declaration d: nodes += declarationNode("<getName(d)>(<getAstNodePropString(d)>)", weight(d), d@src);
		case \Statement s: nodes += statementNode("<getName(s)>(<getAstNodePropString(s)>)", weight(s), s@src); 
		case \Expression e: nodes += expressionNode("<getName(e)>(<getAstNodePropString(e)>)", weight(e), e@src);
		case \Type t: nodes += typeNode("<getName(t)>(<getAstNodePropString(t)>)", weight(t));
	}
	return nodes;
}

private str getAstNodePropString(node n) {
	props = for (c <- getChildren(n)) {
		switch (c) {
			case str s: append s;
			case int i: append i;
			case bool b: append b;
		}
	};
	return intercalate(",", props);	 
}

public int weight(node n) {
	int w = 0;
	visit(getChildren(n)) {
		case Declaration d: w += 1;
		case Statement s: w += 1;
		case Expression e: w += 1;
		case Type t : w += 1;
	}
	return w;
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
