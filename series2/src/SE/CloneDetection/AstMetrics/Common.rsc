module SE::CloneDetection::AstMetrics::Common

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;

public alias NodeList = list[Statement];
public alias Segment = tuple[loc,NodeList];
public alias Vector = list[int];
public alias Vectors = rel[Vector,Segment];

public alias VectorSegmentsMap = map[Vector,set[Segment]];
public alias SizeVectorsMap = map[int,set[Vector]];
public alias SegmentGroup = set[Segment];
public alias SegmentGroups = set[SegmentGroup];
public alias VectorGroup = set[Vector];
public alias VectorGroups = set[VectorGroup];

public alias SegmentPair = tuple[Segment,Segment];
public alias SegmentPairs = set[SegmentPair];

anno loc node@src;