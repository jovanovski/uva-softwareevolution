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

public Vectors computeVectors(M3 model, int minT=20) {
	nodeTypes = getNodeTypes(model);
	VectorTemplate template = sort(nodeTypes);
	Vectors vs = {};
	for (m <- methods(model), node mast <- getMethodASTEclipse(m, model=model)) {
		<_,_,mvs> = computeVectorsRecursively(mast, template,minT);
		vs += mvs;
	}
	return vs;
}

public Vector emptyVector(VectorTemplate template) = [0 | _ <- template];
public Vector mergeVectors(int templateSize, Vector v1, Vector v2) = [v1[i] + v2[i] | i <- [0..(templateSize)]];

private tuple[int, Vector, Vectors] computeVectorsRecursively(value n, VectorTemplate template, int minT) {
    s = size(template);
    c = 0;
    v = emptyVector(template);
    Vectors vs = {};
	switch (n) {
	    case list[value] xs: {
	    	for (x <- xs) {
				<xc,xv,xvs> = computeVectorsRecursively(x, template, minT);
				c += xc;
				v = mergeVectors(s, v,xv);
				vs += xvs;
			}
	    }
	    case node n: {
		    <xc,xv,xvs> = computeVectorsRecursively(getChildren(n), template, minT);
		    c += xc;
		    v = mergeVectors(s, v,xv);
		    vs += xvs;
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
			 	c += 1;
				i = indexOf(template, nt);
				v[i] = v[i] + 1;
				if (c >= minT) {
					vs += <v,l>;
				}				
			}
	    } 
	}
	return <c, v, vs>;
}