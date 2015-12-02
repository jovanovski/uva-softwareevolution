module SE::Test::CloneDetection::Type23::PairMergingTest

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import Set;
import List;
import Map;
import IO;
import Node;
import SE::CloneDetection::Type23::PairMerging;

data TestTree = ttn(value v, list[TestTree] children);
public test bool testGetRelation() {
	bool(TestTree,TestTree) eqFunc = bool (ttn(v1,_), ttn(v2,_)) {return v1 == v2;};
	bool(TestTree,TestTree) ctFunc = bool (ttn(_,cs), ttn(v2,_)) {return (false | it || v1 == v2 | /ttn(v1,_) <- cs);}; 
	
	cases = {
		<[ttn(i,[]) | i <- [1..5]],[ttn(i,[]) | i <- [1..5]],equivalent()>,
		<[ttn(i,[]) | i <- [1..5]],[ttn(i,[]) | i <- [2..3]],contains()>,
		<[ttn(i,[]) | i <- [2..3]],[ttn(i,[]) | i <- [1..5]],containedIn()>,
		<[ttn(i,[]) | i <- [2..5]],[ttn(i,[]) | i <- [1..4]],overlapsLeft(2)>,
		<[ttn(i,[]) | i <- [1..4]],[ttn(i,[]) | i <- [2..5]],overlapsRight(2)>,
		<[ttn(20,[ttn(i,[]) | i <- [1..5]])],[ttn(i,[]) | i <- [1..5]],contains()>,
		<[ttn(i,[]) | i <- [1..5]],[ttn(20,[ttn(i,[]) | i <- [1..5]])],containedIn()>
	};
	
	return (true | it && getSegmentRelation(l1,l2,eqFunc,ctFunc) == r| <l1,l2,r> <- cases);
}

