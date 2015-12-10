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

public tuple[NormalizedAst,map[node,NormalizedAst]] normalizeAst(Declaration d, map[node,NormalizedAst] mem) = normalizeAstNode(d,mem);
public tuple[NormalizedAst,map[node,NormalizedAst]] normalizeAst(Statement s, map[node,NormalizedAst] mem) = normalizeAstNode(s,mem);
public tuple[NormalizedAst,map[node,NormalizedAst]] normalizeAst(Expression e, map[node,NormalizedAst] mem) = normalizeAstNode(e,mem);

private tuple[NormalizedAst,map[node,NormalizedAst]] normalizeAstNode(node n, map[node,NormalizedAst] mem) {
	list[value] props = [];
	list[node] children = [];
	if (n in mem) {
		return <mem[n],mem>;
	}
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
	normalizedChildren = [];
	for (c <- children) {
		<cn,mem> = normalizeAstNode(c,mem);
		normalizedChildren += cn;
	}
	nn = normalizedNode(<typeOf(n),getName(n),props>,normalizedChildren);
	mem[n] = nn;
	return <nn,mem>;
}