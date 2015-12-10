module SE::CloneDetection::AstMetrics::AstNormalization

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import Type;
import Node;
import Set;
import List;
import IO;

public alias NodeIdentity = tuple[Symbol, str, list[value]]; 
data NormalizedAst 
	= normalizedNode(NodeIdentity id, list[NormalizedAst] children);

public NormalizedAst normalizeAst(Declaration d) = normalizeAstNode(d);
public NormalizedAst normalizeAst(Statement s) = normalizeAstNode(s);
public NormalizedAst normalizeAst(Expression e) = normalizeAstNode(e);

private NormalizedAst normalizeAstNode(node n) {
	list[value] props = [];
	list[node] children = [];
	for (c <- getChildren(n)) {
		switch (c) {
			case Declaration d: children += d;
			case Statement s: children += s;
			case Expression e: children += e;
			case list[Declaration] ds: children += ds;
			case list[Statement] ss: children += ss;
			case list[Expression] es: children += es;
			case value v: props += v;
		}
	}
	return normalizedNode(<typeOf(n),getName(n),props>,[normalizeAstNode(c) | c <- children]);
}