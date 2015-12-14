module SE::CloneDetection::AstMetrics::Common

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;

public alias NodeList = list[Statement];
public alias Segment = tuple[loc,NodeList];

public alias SegmentGroup = set[Segment];
public alias SegmentGroups = set[SegmentGroup];

public alias SegmentPair = tuple[Segment,Segment];
public alias SegmentPairs = set[SegmentPair];

anno loc node@src;