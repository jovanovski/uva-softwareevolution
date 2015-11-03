module Metrics::Complexity

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import Metrics::Utils;


public set[tuple[loc,int]] methodcc(M3 model) {
	asts = methodasts(model); 
	return 
		{<methodloc,cc(impl)> | <methodloc,\method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl)> <- asts} 
		+ {<methodloc,cc(impl)> | <methodloc,\constructor(str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl)> <- asts};
}

int cc(Statement s) {
	c = 1;
	visit (s) {
		// statement
		case \foreach(Declaration parameter, Expression collection, Statement body): c += 1;
		case \for(list[Expression] initializers, Expression condition, list[Expression] updaters, Statement body): c += 1;
		case \for(list[Expression] initializers, list[Expression] updaters, Statement body): c += 1;
		case \if(Expression condition, Statement thenBranch): c += 1;
		case \if(Expression condition, Statement thenBranch, Statement elseBranch): c += 1;
		case \case(Expression expression): c += 1;
		case \defaultCase(): c += 1;
		case \catch(Declaration exception, Statement body): c += 1;
		case \while(Expression condition, Statement body): c += 1;
		
		// expression
		case \infix(Expression lhs, "&&", Expression rhs): c += 1;
	 	case \infix(Expression lhs, "||", Expression rhs): c += 1;
		case \conditional(Expression expression, Expression thenBranch, Expression elseBranch): c += 1;
	}
	return c;
}