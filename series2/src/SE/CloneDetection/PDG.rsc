module SE::CloneDetection::PDG

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import IO;
import Map;
import Set;
import List;
import Node;
import Type;
import SE::CloneDetection::Common;

import graph::DataStructures;
import graph::factory::GraphFactory;
import SE::CloneDetection::Common;

int defaultMinStatements = 6;

alias NodeIdentity = tuple[Symbol \type, str name, list[value] props]; 

public LocClasses detectType4(M3 model, int minS=defaultMinStatements) {
	print("Generating asts... ");
	asts = (mloc: getMethodASTEclipse(mloc, model=model) | mloc <- methods(model));
	asts = (asts[mloc]@src: asts[mloc] | mloc <- asts);
	println("<size(asts)> ast(s) generated.");
	print("Generating pdgs... ");	
	map[tuple[rel[node,node],rel[node,node]],set[loc]] invertMap = ();
	for (mloc <- asts, countStatements(asts[mloc]) > minS) {
		ast = asts[mloc];
		pdgs = generatePdgs(mloc, ast,model);
		if (size(pdgs) > 1) {
			throw "expected only one pdg to be generated";
		}
		for (mData <- pdgs) {
			pdg = pdgs[mData];
			ns = (i: removeNestedStatements(mData.nodeEnvironment[i]) | i <- mData.nodeEnvironment);
			
			mergedCdg = {<ns[from],ns[to]> | <from,to> <- pdg.controlDependence};
			mergedDdg = {<ns[from],ns[to]> | <from,to> <- pdg.dataDependence};
			tuple[rel[node,node],rel[node,node]] mergedPdg = <mergedCdg,mergedDdg>;
			
			invertMap[mergedPdg] = mergedPdg in invertMap ? invertMap[mergedPdg] + {mloc} : {mloc};
		}
	}
	return {invertMap[mergedPdg] | mergedPdg <- invertMap, size(invertMap[mergedPdg]) > 1};
	
	//pdgs = (ast@src: generatePdg(mast,model)| ast <- asts);
//
//
	//int i = 0;
	//map[loc,value] res = ();
	//for (mloc <- methods(model)) { 
	//	
	//	println(i);
	//	i += 1;
	//	mast = getMethodASTEclipse(mloc,model=model);
	//	if (countStatements(mast) > minS) {
	//		mpdgs = createProgramDependences(mloc, mast, model, Intra());
	//		//DataDependence dataDependence = createDDG(generatedData.methodData, generatedData.controlFlow);
	//		//res[mloc] = dataDependence;
	//	}
	//} 
	//return res;
}

private ProgramDependences generatePdgs(mloc, node ast, M3 model) {
	return createProgramDependences(mloc, ast, model, Intra());
}

private node removeNestedStatements(node n) {
	list[Statement] emptyStatementList = [];
	return top-down visit (n) {
		case n => n
		case Statement s => \empty()
		case list[Statement] ls => emptyStatementList
	};
}

private int countStatements(node n) {
	c = 0;
	visit (n) {
		case Statement s: c += 1;
	}
	return c;
}