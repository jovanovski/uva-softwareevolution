module SE::Utils

import List;

public loc mergeLocations(list[loc] ls) {
	if (isEmpty(ls)) {
		throw "empty list of locations";
	}
	<l,ls> = pop(ls);
	return (l | mergeLocations(it,l2) | l2 <- ls);
}
public loc mergeLocations(loc l1, loc l2) {
	if (l1.uri != l2.uri) {
		throw "cannot merge locations from different files";
	}
	if (l1.offset > l2.offset) {
		<l1,l2> = <l2,l1>;
	}
	l1.length = l2.offset + l2.length - l1.offset;
	l1.end = l2.end;
	return l1;
}