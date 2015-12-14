module SE::CloneDetection::AstMetrics::AstPqGram

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import Type;
import Node;
import Set;
import List;
import Map;
import IO;
import util::Math;
import SE::CloneDetection::AstMetrics::Common;
import SE::CloneDetection::AstMetrics::AstNormalization;

public data PqNode 
	= pqNode(NodeIdentity nid)
	| pqNull();
public alias PqRegister = list[PqNode];
public alias PqGram = list[PqRegister];


public rel[PqGram,PqGram] generatePqGramPairs(set[PqGram] gs, real maxPqDistance) {
	if (maxPqDistance < 0 || maxPqDistance > 1) {
		throw "maxPqDistance must be between 0 and 1";
	}
	map[int,set[PqGram]] gsBySize = ();	
	for (g <- gs) {
		s = size(g);
		gsBySize[s] = s in gsBySize ? gsBySize[s] + {g} : {g};
	}

	rel[PqGram,PqGram] pairs = {};
	return {<g1,g2> | s <- gsBySize, g1 <- gsBySize[s], g2 <- gsBySize[s], g1 != g2 && pqDistance(g1,g2) <= maxPqDistance};
	//for (s <- gsBySize) {
	//	gsGroup = gsBySize[s];
	//	<g,gsGroup> = takeOneFrom(gsGroup);
	//	//pGroup = {g};
	//	queue = {g};
	//	while (!isEmpty(queue)) {
	//		<g1,queue> = takeOneFrom(queue);
	//		matches = {g2 | g2 <- gsGroup, pqDistance(g1,g2) <= maxPqDistance};
	//		gsGroup -= matches;
	//		queue += matches;
	//		pairs += {<g1,g2> | g2 <- matches};
	//	}
	//}
	//return pairs;
}

public set[set[Segment]] generateUnitGroupsFromPqPairs(rel[PqGram,PqGram] gps, map[NormalizedAst,PqGram] gs, map[NodeList,NormalizedAst] nmasts, map[NodeList,set[Segment]] nls) {
	set[set[Segment]] ugs = {};
	map[PqGram,NormalizedAst] invgs = invertUnique(gs);		
	map[NormalizedAst,set[NodeList]] invnmasts = invert(nmasts); // in very rare cases, multiple nodelists can resolve to a single normalized ast, but these asts are very similar so we just include all of them
	
	return {{s | nl <- invnmasts[invgs[g1]] + invnmasts[invgs[g2]], s <- nls[nl]} | <g1,g2> <- gps};
}

public real pqDistance(NormalizedAst ast1, NormalizedAst ast2) {
	return pqDistance(generatePqGram(ast1),generatePqGram(ast2));
}

public real pqDistance(PqGram g1, PqGram g2) {
	ins = [];
	for (t <- g1) {
		if (t in g2) {
			ins += t;
			g2 -= [t];
		}
	}
	return 1.0 - 2.0 * (toReal(size(ins)) / toReal(size(g1 + g2)));
}

public map[NormalizedAst,PqGram] generatePqGrams(set[NormalizedAst] nmasts, int p=2,int q=3) {
	map[NormalizedAst,PqGram] res = ();
	map[NormalizedAst,PqGram] mem = ();
	for (nmast <- nmasts) {
		<g,mem> = generatePqGram(nmast,p,q,mem);
		res[nmast] = g;
	}
	return res;
}

private tuple[PqGram,map[NormalizedAst,PqGram]] generatePqGram(NormalizedAst ast,int p,int q, map[NormalizedAst,PqGram] mem) {
	if (p <= 0 || q <= 0) {
		throw "p and q must be greater than 0";
	}
	return generatePqGram(ast,p,q,pqCreateRegister(p),mem);
}

private tuple[PqGram,map[NormalizedAst,PqGram]] generatePqGram(n:normalizedNode(id,children),int p, int q, PqRegister ancs, map[NormalizedAst,PqGram] mem) {
	if (n in mem) {
		return <mem[n],mem>;
	}
	PqGram g = [];	
	ancs = pqShiftRegister(ancs, pqNode(id));
	PqRegister siblings = pqCreateRegister(q);
	if (isEmpty(children)) {
		g = pqAppendRegisters(g,ancs,siblings);
	} else {
		for (c:normalizedNode(cid,cChildren) <- children) {
			pqShiftRegister(siblings,pqNode(cid));
			g = pqAppendRegisters(g,ancs,siblings);
			<xg,mem> = generatePqGram(c,p,q,ancs,mem);
			g += xg;
		}
		for(i <- [0..q-1]) {
			pqShiftRegister(siblings, pqNull());
			g = pqAppendRegisters(g,ancs,siblings);
		} 
	}
	mem[n] = g;
	return <g,mem>;
}

private PqRegister pqCreateRegister(int p) {
	PqRegister r = [];
	for (i <- [0..p]) {
		r += pqNull();
	}
	return r;
}

private PqRegister pqShiftRegister(PqRegister r, PqNode n) {
	return slice(r,1,size(r)-1) + [n];
}

private PqGram pqAppendRegisters(PqGram g, PqRegister ancs, PqRegister siblings) {
	return g + [ancs + siblings];
}

