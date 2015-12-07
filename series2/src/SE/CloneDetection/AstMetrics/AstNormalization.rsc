module SE::CloneDetection::AstMetrics::AstNormalization

import Node;

public data NormalizedAst 
	= astNode(str name, list[value] properties, list[NormalizedAst] children);

public NormalizedAst normalizeAst(node n) {
	nodeProperties = [];
	nodeChildren = [];
	cn = getChildren(n);
	for (c <- cn) {
		switch (c) {
			case node n2:
				nodeChildren += normalizeAst(n2);
			case list[node] ns:
				nodeChildren += [normalizeAst(n2) | n2 <- ns];
			case _:
				nodeProperties += c;
		}
	}
	return basicNode(getName(n), nodeProperties, nodeChildren);	
}