module SE::Test::CloneDetection::Type23::VectorGenerationTest

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import Set;
import List;
import Map;
import IO;
import Node;
import SE::CloneDetection::AstMetrics::VectorGeneration;

public test bool propVectorSumEqualsToNumberOfRelevantNodes(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl) {
	m = \method(\return,name, parameters, exceptions, impl);
	template = getVectorTemplate(m);
	vs = computeVectors(m, template);
	for (<v,ns> <- vs) {
		c = countRelevantNodes(ns);
	}
	return true;
}

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
private int sumNodeCount(NodeCount nc) = (0 | it + nc[nt] | nt <- nc);
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
private bool subSeqsMatchIsEmpty(list[int] T, bool (list[int]) match) {
	return isEmpty({1 | [*_,*U,*_] := T, match(U)});
}