module SE::CloneDetection::AstMetrics::AstNormalization

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import Type;
import Node;
import Set;
import List;
import IO;
import SE::CloneDetection::AstMetrics::Common;

public alias NodeIdentity = tuple[Symbol, str, int, list[value]]; 	// type, name, arity & children that are not declarations, statements or expressions
public data NormalizedAst 
	= normalizedNode(NodeIdentity id, list[NormalizedAst] children);

public map[NodeList,NormalizedAst] generateNormalizedAsts(set[NodeList] nls) {
	map[NodeList,NormalizedAst] res = ();
	map[node,NormalizedAst] mem = ();
	for (nl <- nls) {
		<nmast,mem> = normalizeAstNode(\block(nl),mem);
		res[nl] = nmast; 
	}
	return res;
}

public tuple[NormalizedAst,map[node,NormalizedAst]] normalizeAstNode(node n, map[node,NormalizedAst] mem) {
	if (n in mem) {
		return <mem[n],mem>;
	}
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
	normalizedChildren = [];
	for (c <- children) {
		<cn,mem> = normalizeAstNode(c,mem);
		normalizedChildren += cn;
	}
	nn = normalizedNode(<typeOf(n),getName(n),arity(n),props>,normalizedChildren);
	mem[n] = nn;
	return <nn,mem>;
}