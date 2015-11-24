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
alias Vectors = rel[Vector,Maybe[loc]];

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
	VectorTemplate template = sort(nodeTypes);
	Vectors vs = {};
	for (m <- methods(model), node mast <- getMethodASTEclipse(m, model=model)) {
		<_,mvs> = computeVectorsRecursively(mast, template);
		vs += mvs;
	}
	return vs;
}

public Vector emptyVector(VectorTemplate template) = [0 | _ <- template];
public Vector mergeVectors(Vector v1, Vector v2) = [c1 + c2 | <c1,c2> <- zip(v1,v2)];

private tuple[Vector, Vectors] computeVectorsRecursively(value n, VectorTemplate template) {
    v = emptyVector(template);
    Vectors vs = {};
	switch (n) {
	    case list[value] cs: {
	    	for (c <- cs) {		
				<cv,cvs> = computeVectorsRecursively(c, template);
				v = mergeVectors(v,cv);
				vs += cvs;
			}
	    }
	    case node n: {
		    <cv,cvs> = computeVectorsRecursively(getChildren(n), template);
		    v = mergeVectors(v,cv);
		    vs += cvs;
			NodeType nt;
			loc l;
	    	switch (n) {
		    	case Declaration d: {
					nt = declarationNode(getName(d));
					l = ("src" in getAnnotations(d) ? just(d@src) : nothing());
				}
				case Statement s: {
					nt = statementNode(getName(s));
					l = ("src" in getAnnotations(s) ? just(s@src) : nothing());
				}
				case Expression e: {
					nt = expressionNode(getName(e));
					l = ("src" in getAnnotations(e) ? just(e@src) : nothing());
				}
	    	}
			 if (nt?) {
				i = indexOf(template, nt);
				v[i] = v[i] + 1;
				vs += <v,l>;
			}  	
	    } 
	}
	return <v, vs>;
}