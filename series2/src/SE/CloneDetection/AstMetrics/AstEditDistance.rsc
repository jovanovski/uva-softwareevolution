module SE::CloneDetection::AstMetrics::AstEditDistance

import Type;
import Node;
import Set;
import List;
import IO;
import SE::CloneDetection::AstMetrics::AstNormalization;

public bool isEditDistanceLessThan(list[node] ns1, list[node] ns2, int maxDistance) {
	<res,_> = getEditDistanceWithMax(ns1, ns2, maxDistance);
	return res;
}

// calculates the distance between AST node forests
public tuple[bool,int] getEditDistanceWithMax(list[node] ns1, list[node] ns2, int maxDistance) {
	if (maxDistance < 0) {
		return <false,0>;
	} else if (maxDistance == 0) {
		return <ns1 == ns2,0>;
	} else if (isEmpty(ns1)) {
		return countRelevantNodesWithMax(ns2, maxDistance);
	} else if (isEmpty(ns2)) {
		return countRelevantNodesWithMax(ns1, maxDistance);	
	} else {
		cts = {};
		<n1,ns1rem> = headTail(ns1);
		<n2,ns2rem> = headTail(ns2);
		<addres,addct> = countRelevantNodesWithMax([n1],maxDistance);
		if (addres) {
			<subaddres,subaddct> = getEditDistanceWithMax(ns1rem, ns2, maxDistance-addct);
			if (subaddres) {
				cts += addct+subaddct;
			}
		}
		<remres,remct> = countRelevantNodesWithMax([n2],maxDistance);
		if (remres) {
			<subremres,subremct> = getEditDistanceWithMax(ns1, ns2rem, maxDistance-remct);
			if (subremres) {
				cts += remct+subremct;
			}
		}		
		repct = 0;
		<n1Props,n1Children> = getNodePropsAndChildren(n1);
		<n2Props,n2Children> = getNodePropsAndChildren(n2); 
		if (typeOf(n1) == typeOf(n2) && getName(n1) == getName(n2) && n1Props == n2Props) {
			repct += 1;
		}		
		<subrepres1,subrepct1> = getEditDistanceWithMax(n1Children,n2Children, maxDistance-repct);
		if (subrepres1) {
			repct = repct + subrepct1;
			<subrepres2,subrepct2> = getEditDistanceWithMax(ns1rem, ns2rem, maxDistance-repct);
			if (subrepres2) {
				cts += repct+subrepct2;
			}
		}		
		return isEmpty(cts) ? <false,0> : <true,min(cts)>;		
	}

	return isEditDistanceLessThan(t1,t2,maxDistance);
}

private tuple[bool,int] countRelevantNodesWithMax(list[node] f, int maxDistance) {
	if (maxDistance < 0) {
		return <false,0>;
	}
	int c = 0;
	for (/node n <- f) {
		switch (n) {
			case Declaration: c += 1;
			case Statement: c += 1;
			case Expression: c += 1;
		}
		if (c > maxDistance) {
			return <false,0>;
		}
	}
	return <true,c>;
}

private tuple[list[value],list[node]] getNodePropsAndChildren(node n) {
	nodeProps = [];
	nodeChildren = [];
	for (c <- getChildren(n)) {
		switch (c) {
			case node n: nodeChildren += n;
			case list[node] ns: nodeChildren += ns;
			case value v: nodeProps += v; 
		}
	}
	return <nodeProps, nodeChildren>;
}