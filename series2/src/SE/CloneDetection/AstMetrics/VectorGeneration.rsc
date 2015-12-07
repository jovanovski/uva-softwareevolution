module SE::CloneDetection::AstMetrics::VectorGeneration

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import Set;
import List;
import Map;
import IO;
import Node;
import SE::CloneDetection::AstMetrics::Core;

public data NodeType
	= declarationNode(str name)
	| statementNode(str name)
	| expressionNode(str name);

public alias VectorTemplate = list[NodeType];
public alias NodeCount = map[NodeType, int];
public alias NodeCounts = rel[NodeCount,Segment];

public Vectors generateVectors(M3 model, int minS=6) = generateVectors(model, getVectorTemplate(model), minS=minS);
public Vectors generateVectors(M3 model, VectorTemplate template, int minS=6) {
	return generateVectors([getMethodASTEclipse(meth,model=model) | meth <- methods(model)], template, minS=minS);
}
public Vectors generateVectors(list[node] ns, int minS=6) = generateVectors(ns, getVectorTemplate(ns), minS=minS);
public Vectors generateVectors(list[node] ns, VectorTemplate template, int minS=6) {
	return ({} | it + generateVectors(n, template,minS=minS) | n <- ns);
}
public Vectors generateVectors(node n, int minS=6) = generateVectors(n, getVectorTemplate(n), minS=minS);
public Vectors generateVectors(node n, VectorTemplate template, int minS=6) {
	<_,_,ncs> = generateNodeCountsRecursively(n,minS=minS);
	return {<[nt in nc ? nc[nt] : 0 | nt <- template],ns> | <nc,ns> <- ncs};
}

public VectorTemplate getVectorTemplate(value v) = sort(getNodeTypes(v));
public set[NodeType] getNodeTypes(M3 model) {
	set[NodeType] nodeTypes = {};
	for (m <- methods(model), n <- getMethodASTEclipse(m, model=model)) {
		nodeTypes += getNodeTypes(n);
	}
	return nodeTypes;
}
public set[NodeType] getNodeTypes(value v) {
	set[NodeType] nodeTypes = {};
	visit (v) {
		case Declaration d: nodeTypes += declarationNode(getName(d));
		case Statement s: nodeTypes += statementNode(getName(s));
		case Expression e: nodeTypes += expressionNode(getName(e));
	};
	return nodeTypes;
}

public tuple[int, NodeCount, NodeCounts] generateNodeCountsRecursively(value n, int minS=6) {
    c = 0;
    nc = ();
    NodeCounts ncs = {};
	switch (n) {
		case list[Statement] xs: {
			xrs = [<generateNodeCountsRecursively(x,minS=minS), x> | x <- xs];
			for (<<xc,xnc,xncs>,_> <- xrs) {
				c += xc;
				nc = mergeNodeCounts(nc,xnc);
				ncs += xncs;
			}	
			//for(ys <- getMinSeqs(xrs, bool (lrel[tuple[int,NodeCount,NodeCounts],node] zs) {
			//	return (0 | it + zc | <<zc,_,_>,_> <- zs) >= minS;
			//})) {
			//	<<mc,mnc,mncs>,mn> = head(ys);
			//	mns = [mn];
			//	for (<<xc,xnc,xncs>,xn> <- tail(ys)) {
			//		mc += xc;
			//		mnc = mergeNodeCounts(mnc,xnc);
			//		mncs += xncs;
			//		mns += [xn];
			//	}
			//	ncs += <mnc, mns>;
			//}
		}
	    case list[value] xs: {	    	
			xrs = [generateNodeCountsRecursively(x,minS=minS) | x <- xs];
			for (<xc,xnc,xncs> <- xrs) {
				c += xc;
				nc = mergeNodeCounts(nc,xnc);
				ncs += xncs;
			}
	    }
	    case node n: {
	    	<dc,dnc,dncs> = generateNodeCountsRecursively(getChildren(n),minS=minS);
	    	c += dc;
	    	nc = mergeNodeCounts(nc,dnc);
	    	ncs += dncs;
			NodeType nt;
	    	switch (n) {
		    	case Declaration d: nc = addNodeType(nc, declarationNode(getName(d)));
				case Statement s: nt = {
					nc = addNodeType(nc, statementNode(getName(s)));
					c += 1;
					if (c >= minS) {
						ncs += {<nc, <n@src, [n]>>};
					}
				}
				case Expression e: nc = addNodeType(nc, expressionNode(getName(e)));
	    	}
	    } 
	}
	return <c, nc, ncs>;
}
public NodeCount mergeNodeCounts(NodeCount nc1, NodeCount nc2) {
	for (i <- nc2) {
		nc1[i] = i in nc1 ? nc1[i] + nc2[i] : nc2[i];
	}
	return nc1;
}
public set[list[&T]] getMinSeqs(list[&T] xs, bool (list[&T]) match) {
	rs = {};
	l = size(xs);
	for (i <- [0..l]) {
		if (i < l-1) {
			for (j <- [i+2..l+1]) {
				ys = slice(xs, i, j - i);
				if (match(ys)) {
					rs += ys;
					break;
				}
			}
		}
		if (i > 1) {
			for (j <- [i-2..-1]) {
				ys = slice(xs,j,i-j);
				if (match(ys)) {
					rs += ys;
					break;
				}
			}
		}
	}
	return rs;
}
private NodeCount addNodeType(NodeCount nc, NodeType nt) {
	nc[nt] = nt in nc ? nc[nt] + 1 : 1;
	return nc;
}

