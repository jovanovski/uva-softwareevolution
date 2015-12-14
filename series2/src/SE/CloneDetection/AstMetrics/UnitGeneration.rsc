module SE::CloneDetection::AstMetrics::UnitGeneration

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import Set;
import List;
import Map;
import IO;
import Node;
import SE::Utils;
import SE::CloneDetection::AstMetrics::Common;

public map[NodeList,set[Segment]] indexSegmentsByNodeList(set[Segment] us) {
	map[NodeList,set[Segment]] ugs = ();
	for (s:<_,ns> <- us) {
		ugs[ns] = ns in ugs ? ugs[ns] + {s} : {s};
	}
	return ugs;
}

public set[Segment] generateUnits(M3 model,int minS=6) {
	return generateUnits([getMethodASTEclipse(meth,model=model) | meth <- methods(model)],minS=minS);
}

public set[Segment] generateUnits(list[node] asts,int minS=6) {
	set[Segment] ls = {};
	for (ast <- asts) {
		<_,ls2> = generateUnits(ast,minS);
		ls += ls2;
	}
	return ls;
}

private tuple[int,set[Segment]] generateUnits(value v,int minS) {
	c = 0;
	set[Segment] ls = {};
	switch (v) {
		case list[Statement] xs: {
			xrs = [<generateUnits(x,minS),x> | x <- xs];
			for (<<xc,xls>,_> <- xrs) {
				c += xc;
				ls += xls;
			}
			for(ys <- getMinSeqs(xrs, bool (lrel[tuple[int,set[Segment]],Statement] zs) {
				return (0 | it + zc | <<zc,_>,_> <- zs) >= minS;
			})) {
				<_,mn> = head(ys);
				ml = mn@src;
				mns = [mn];
				for (<_,xn> <- tail(ys)) {
					mns += [xn];
					ml = mergeLocations(ml,xn@src);
				}
				ls += {<ml,mns>};
			}	
		}
		case list[value] xs: {
			for (x <- xs) {
				<xc,xls> = generateUnits(x,minS);
				c += xc;
				ls += xls;
			}
		}
		case node n: {
			<xc,xls> = generateUnits(getChildren(n),minS);
			c += xc;
			ls += xls;
			switch (n) {
				case Statement s: {
					c += 1;
					if (c >= minS) {
						ls += {<s@src,[s]>};
					}
				}
			}
		}
	}
	return <c,ls>;
}

private set[list[&T]] getMinSeqs(list[&T] xs, bool (list[&T]) matchFunc) {
	rs = {};
	l = size(xs);
	for (i <- [0..l]) {
		if (i < l-1) {
			for (j <- [i+2..l+1]) {
				ys = slice(xs, i, j - i);
				if (matchFunc(ys)) {
					rs += ys;
					break;
				}
			}
		}
		if (i > 1) {
			for (j <- [i-2..-1]) {
				ys = slice(xs,j,i-j);
				if (matchFunc(ys)) {
					rs += ys;
					break;
				}
			}
		}
	}
	return rs;
}