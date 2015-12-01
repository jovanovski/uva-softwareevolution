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
alias Vectors = rel[Vector,list[node]];
alias NodeCount = map[NodeType, int];
alias NodeCounts = rel[NodeCount,list[node]];

anno loc node@src;

public map[Vector,set[loc]] groupVectors(Vectors vs) {
	map[Vector,set[loc]] vsm = ();
	for (<v,l> <- vs) {
		vsm[v] = v in vsm ? vsm[v] + l : {l};
	}
	return vsm;
}

public Vectors computeVectors(M3 model, int minS=6) = computeVectors(model, getVectorTemplate(model), minS=minS);
public Vectors computeVectors(M3 model, VectorTemplate template, int minS=6) {
	return computeVectors([getMethodASTEclipse(meth,model=model) | meth <- methods(model)], template, minS=minS);
}
public Vectors computeVectors(list[node] ns, int minS=6) = computeVectors(ns, getVectorTemplate(ns), minS=minS);
public Vectors computeVectors(list[node] ns, VectorTemplate template, int minS=6) {
	return ({} | it + computeVectors(n, template,minS=minS) | n <- ns);
}
public Vectors computeVectors(node n, int minS=6) = computeVectors(n, getVectorTemplate(ns), minS=minS);
public Vectors computeVectors(node n, VectorTemplate template, int minS=6) {
	<_,_,ncs> = computeNodeCountsRecursively(n,minS=minS);
	return {<[nt in nc ? nc[nt] : 0 | nt <- template],n2> | <nc,n2> <- ncs};
}
private VectorTemplate checkVectorTemplate(value v, VectorTemplate template) = template == [] ? getVectorTemplate(v) : template;

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

public tuple[int, NodeCount, NodeCounts] computeNodeCountsRecursively(value n, int minS=6) {
    c = 0;
    nc = ();
    NodeCounts ncs = {};
	switch (n) {
		case list[Statement] xs: {
			xrs = [<computeNodeCountsRecursively(x,minS=minS), x> | x <- xs];
			for (<<xc,xnc,xncs>,_> <- xrs) {
				c += xc;
				nc = mergeNodeCounts(nc,xnc);
				ncs += xncs;
			}	
			for(ys <- getMinSeqs(xrs, bool (lrel[tuple[int,NodeCount,NodeCounts],node] zs) {
				return (0 | it + zc | <<zc,_,_>,_> <- zs) >= minS;
			})) {
				mc = 0;
				mnc = ();
				NodeCounts mncs = {};
				<<mc,mnc,mncs>,ml> = head(ys);
				mls = [ml];
				for (<<xc,xnc,xncs>,xl> <- tail(ys)) {
					mc += xc;
					mnc = mergeNodeCounts(mnc,xnc);
					mncs += xncs;
					mls += [xl];
				}
				ncs += <mnc, mls>;
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
						ncs += {<nc, [n]>};
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

public map[value,value] mytest(Vectors vs) {
	ms = ();
	for (<v,ls> <- vs) {
		ms[v] = v in ms ? ms[v] + {ls} : {ls};
	}
	iprintln(ms);
	return ms;
}

public test bool propVectorSumEqualsToNumberOfRelevantNodes(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl) {
	m = \method(\return,name, parameters, exceptions, impl);
	template = getVectorTemplate(m);
	vs = computeVectors(m, template);
	for (<v,ns> <- vs) {
		c = countRelevantNodes(ns);
	}
	return true;
}

public test bool propMergedNodeCountsSumIsEqual(NodeCount nc1, NodeCount nc2) {
	mnc = mergeNodeCounts(nc1, nc2);
	return sumNodeCount(mnc) == (sumNodeCount(nc1) + sumNodeCount(nc2));
}
private int sumNodeCount(NodeCount nc) = (0 | it + nc[nt] | nt <- nc);

public test bool propNodeCountSumEqualsToNumberOfRelevantNodes(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl) {
	m = \method(\return,name, parameters, exceptions, impl);
	<c,nc,ncs> = computeNodeCountsRecursively(m,minS=2);
	if (c != countStatements(m)) {
		return false;
	}
	snc = sumNodeCount(nc);
	sns = countRelevantNodes(m);
	if (snc != sns) {
		return false;
	}
	for (<xnc,xns> <- ncs) {
		xsnc = sumNodeCount(xnc);
		xsns = countRelevantNodes(xns);
		if (xsnc != xsns) {
			return false;
		}
	}
	return true;
}
private int countStatements(node n) = (0 | it + 1 | /\Statement s <- n);
private int countRelevantNodes(list[node] ns) = (0 | it + countRelevantNodes(n) | n <- ns);
private int countRelevantNodes(node n) {
	c = 0;
	visit(n) {
		case Declaration _: c+=1;
		case Statement _: c+=1;
		case Expression _: c+=1;
	}
	return c;
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
