module SE::CloneDetection::AstMetrics

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import Set;
import Node;
import List;
import IO;
import util::Maybe;

data NodeType
	= declarationNode(str name)
	| statementNode(str name)
	| expressionNode(str name);

alias VectorTemplate = list[NodeType];
alias Vector = list[int];
alias Vectors = rel[Vector,loc];
alias NodeCount = map[NodeType, int];
alias NodeCounts = rel[NodeCount,loc];

public map[Vector,set[loc]] groupVectors(Vectors vs) {
	map[Vector,set[loc]] vsm = ();
	for (<v,l> <- vs) {
		vsm[v] = v in vsm ? vsm[v] + l : {l};
	}
	return vsm;
}

public set[NodeType] getNodeTypes(M3 model) {
	set[NodeType] nodeTypes = {};
	for (m <- methods(model), mast <- getMethodASTEclipse(m, model=model)) {
		visit (mast) {
			case Declaration d: nodeTypes += declarationNode(getName(d));
			case Statement s: nodeTypes += statementNode(getName(s));
			//case Expression e: nodeTypes += expressionNode(getName(e));
		};
	}
	return nodeTypes;
}

public Vectors computeVectors(M3 model, int minT=20) {
	nodeTypes = getNodeTypes(model);
	list[NodeType] template = sort(nodeTypes);	
	return {<[nt in nc ? nc[nt] : 0 | nt <- template],l> | <nc,l> <- computeNodeCounts(model,minT=minT)};
}

public NodeCounts computeNodeCounts(M3 model, int minT=20) {
	NodeCounts ncs = {};
	for (m <- methods(model), node mast <- getMethodASTEclipse(m, model=model)) {
		<_,_,mncs> = computeNodeCountsRecursively(mast,minT);
		ncs += mncs;
	}
	return ncs;
}

public NodeCount mergeNodeCounts(NodeCount nc1, NodeCount nc2) {
	for (i <- nc2) {
		nc1[i] = i in nc1 ? nc1[i] + nc2[i] : nc2[i];
	}
	return nc1;
}

anno loc node@src;

private tuple[int, NodeCount, NodeCounts] computeNodeCountsRecursively(value n, int minT) {
    c = 0;
    nc = ();
    NodeCounts ncs = {};
	switch (n) {
	    case list[value] xs: {	    	
	    	for (x <- xs) {
				<xc,xnc,xncs> = computeNodeCountsRecursively(x, minT);
				c += xc;
				nc = mergeNodeCounts(nc,xnc);
				ncs += xncs;
			}
	    }
	    case node n: {
    		<xc,xnc,xncs> = computeNodeCountsRecursively(getChildren(n), minT);    
		    c += xc;
		    nc = mergeNodeCounts(nc,xnc);
		    ncs += xncs;
			NodeType nt;
	    	switch (n) {
		    	case Declaration d: nt = declarationNode(getName(d));
				case Statement s: nt = statementNode(getName(s));
				//case Expression e: nt = expressionNode(getName(e));
	    	}
			 if (nt?) {
			 	c += 1;
			 	nc[nt] = nt in nc ? nc[nt] + 1 : 1;			 	
				if (c >= minT && "src" in getAnnotations(n)) {
					ncs += <nc, n@src>;
				}
			}
	    } 
	}
	return <c, nc, ncs>;
}
