//module SE::CloneDetection::AstMetrics
//
//import lang::java::jdt::m3::Core;
//import lang::java::m3::Core;
//import lang::java::m3::AST;
//import Set;
//import Node;
//import List;
//import Map;
//import IO;
//import util::Math;
//import SE::Utils;
//
//private int hammingDistance(int vSize, Vector v1, Vector v2) = (0 | it + abs(v1[i] - v2[i]) | i <- [0..vSize]);
//private real euclideanDistance(int vSize, Vector v1, Vector v2) = sqrt((0 | it + pow(v1[i] - v2[i],2) | i <- [0..vSize]));
//
//
//
//
//
////public map[str,rel[Segment,Segment]] generateClonePairs(map[Vector,set[list[node]]] mvs) {
////	map[str,rel[Segment,Segment]] pairs = ();
////	i = 0;
////	for (v <- mvs) {
////		nodelists = mvs[v];
////		while (!isEmpty(nodelists)) {
////			<s1,nodelists> = takeOneFrom(nodelists);
////			str uri = s1[0]@src.uri;
////			for (pair <- {<s1,s2> | s2 <- nodelists, areType2Equivalent(s1,s2)}) {
////				i += 1;
////				pairs = addAndCombinePairs(pair,pairs);
////			}
////		}
////	}
////	//for (pair <- {<s1[0]@src.uri, s1,s2> | v <- mvs, s1 <- mvs[v], s2 <- mvs[v], areType2Equivalent(s1,s2)}) {
////	//	pairs += pair;
////	//	//pairs = addAndCombinePairs(<s1,s2>,pairs);
////	//}
////	return pairs;
////}
////
//
////
////public test bool propType2EquivalenceDisregardsNonRelevantNodes(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl) {
////	m = \method(\return, name, parameters, exceptions, impl);
////	m2 = visit(m) {
////		case str s => "foo"
////		case int i => 1
////		case bool b => false
////		case Type t => string()
////	}
////	
////	return areType2Equivalent(m,m2);
////}
