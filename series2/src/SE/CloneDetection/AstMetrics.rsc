module SE::CloneDetection::AstMetrics

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import Set;
import Node;
import List;
import IO;
import util::Math;

data NodeType
	= declarationNode(str name)
	| statementNode(str name)
	| expressionNode(str name);

alias VectorTemplate = list[NodeType];
alias Vector = list[int];
alias Vectors = rel[Vector,list[loc]];
alias NodeCount = map[NodeType, int];
alias NodeCounts = rel[NodeCount,list[loc]];

anno loc node@src;

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
			case Expression e: nodeTypes += expressionNode(getName(e));
		};
	}
	return nodeTypes;
}

public Vectors computeVectors(M3 model) {
	nodeTypes = getNodeTypes(model);
	list[NodeType] template = sort(nodeTypes);	
	return {<[nt in nc ? nc[nt] : 0 | nt <- template],l> | <nc,l> <- computeNodeCounts(model)};
}

public NodeCounts computeNodeCounts(M3 model) {
	NodeCounts ncs = {};
	for (m <- methods(model), node mast <- getMethodASTEclipse(m, model=model)) {
		<_,_,mncs> = computeNodeCountsRecursively(mast);
		ncs += mncs;
	}
	return ncs;
}

private tuple[int, NodeCount, NodeCounts] computeNodeCountsRecursively(value n, int minS=6) {
    c = 0;
    nc = ();
    NodeCounts ncs = {};
	switch (n) {
		case list[Statement] xs: {
			xrs = [<computeNodeCountsRecursively(x,minS=minS), x@src> | x <- xs];
			for (<<xc,xnc,xncs>,_> <- xrs) {
				c += xc;
				nc = mergeNodeCounts(nc,xnc);
				ncs += xncs;
			}	
			for(ys <- getMinSeqs(xrs, bool (lrel[tuple[int,NodeCount,NodeCounts],loc] ys) {
				return (0 | it + yc | <<yc,_,_>,_> <- ys) >= minS;
			})) {
				<<mc,mnc,mncs>,ml> = head(ys);
				mls = [ml];
				for (<<xc,xnc,xncs>,xl> <- tail(ys)) {
					xc += mc;
					mnc = mergeNodeCounts(mnc,xnc);
					mncs += xncs;
					mls += xl;
				}
				ncs += <nc, mls>;
			}
		}
	    case list[value] xs: {	    	
			xrs = [computeNodeCountsRecursively(x,minS=minS) | x <- xs];
			for (<xc,xnc,xncs> <- xrs) {
				c += xc;
				nc = mergeNodeCounts(nc,xnc);
				ncs += xncs;
			}
	    }
	    case node n: {
	    	<dc,dnc,dncs> = computeNodeCountsRecursively(getChildren(n),minS=minS);
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
						ncs += {<nc, [n@src]>};
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

private bool subSeqsMatchIsEmpty(list[int] T, bool (list[int]) match) {
	return isEmpty({1 | [*_,*U,*_] := T, match(U)});
}

public test bool propGetMinSeqsIsMinimal(list[int] xs, int sm) {
	match = bool (list[int] ys) {return sum([0]+ys) > sm;};
	seqs = getMinSeqs(xs, match);
	// all possile sequences in xs either:
	// 1) do not pass match 
	// 2) are in seqs and have no subseqs in seqs
	// 3) have a subseq in seqs 
	return (
		true 
		| it && (
			!match(T) 
			|| T in seqs && subSeqsMatchIsEmpty(T,match)
			|| !subSeqsMatchIsEmpty(T,match)
		)
		| [*_,*T,*_] := xs
	); 
}

private NodeCount addNodeType(NodeCount nc, NodeType nt) {
	nc[nt] = nt in nc ? nc[nt] + 1 : 1;
	return nc;
}

public int hammingDistance(int s, Vector v1, Vector v2) {
	return (0 | it + abs(v1[i] - v2[i]) | i <- [0..s]);
}

public real euclideanDistance(int s, Vector v1, Vector v2) {
	return sqrt((0 | it + pow(v1[i] - v2[i],2) | i <- [0..s]));
}

