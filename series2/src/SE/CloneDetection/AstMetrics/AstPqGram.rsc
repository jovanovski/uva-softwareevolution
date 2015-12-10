module SE::CloneDetection::AstMetrics::AstPqGram

import Type;
import Node;
import Set;
import List;
import IO;
import util::Math;
import SE::CloneDetection::AstMetrics::AstNormalization;

public data PqNode 
	= pqNode(NodeIdentity nid)
	| pqNull();
public alias PqRegister = list[PqNode];
public alias PqGram = list[PqRegister];

public real pqDistance(NormalizedAst ast1, NormalizedAst ast2) {
	return pqDistance(pqProfile(ast1),pqProfile(ast2));
}

public real pqDistance(PqGram g1, PqGram g2) {
	return 1.0 - 2.0 * (toReal(size(g1 & g2)) / toReal(size(g1 + g2)));
}

public PqGram pqProfile(NormalizedAst ast,int p=2,int q=3) {
	if (p <= 0 || q <= 0) {
		throw "p and q must be greater than 0";
	}
	return pqProfile(ast,p,q,pqCreateRegister(p));
}

private PqGram pqProfile(normalizedNode(id,children),int p, int q, PqRegister ancs) {
	PqGram g = [];
	
	ancs = pqShiftRegister(ancs, pqNode(id));
	PqRegister siblings = pqCreateRegister(q);
	if (isEmpty(children)) {
		g = pqAppendRegisters(g,ancs,siblings);
	} else {
		for (c:normalizedNode(cid,cChildren) <- children) {
			pqShiftRegister(siblings,pqNode(cid));
			g = pqAppendRegisters(g,ancs,siblings);
			g += pqProfile(c,p,q,ancs);
		}
		for(i <- [0..q-1]) {
			pqShiftRegister(siblings, pqNull());
			g = pqAppendRegisters(g,ancs,siblings);
		} 
	}
	
	return g;
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
