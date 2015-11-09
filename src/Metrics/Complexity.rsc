module Metrics::Complexity

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;
import List;
import IO;

import Metrics::Utils;

public rel[str,loc,int] getModelCcPerMethod(M3 model) {
	c = {};
	for (floc <- files(model)) {
		ast = createAstFromFile(floc, false);
		visit(ast) {
			case m:\method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl): c += <name, m@src, getStatementCc(impl)>;
			case m:\constructor(str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl): c += <name, m@src, getStatementCc(impl)>;
		}
	}
	return c;
}

int getStatementCc(Statement s) {
	c = 1;
	visit (s) {
		// statement
		case \do(Statement body, Expression condition): c += 1;
		case \foreach(Declaration parameter, Expression collection, Statement body): c += 1;
		case \for(list[Expression] initializers, Expression condition, list[Expression] updaters, Statement body): c += 1;
		case \for(list[Expression] initializers, list[Expression] updaters, Statement body): c += 1;
		case \if(Expression condition, Statement thenBranch): c += 1;
		case \if(Expression condition, Statement thenBranch, Statement elseBranch): c += 1;
		case \case(Expression expression): c += 1;
		case \catch(Declaration exception, Statement body): c += 1;
		case \while(Expression condition, Statement body): c += 1;
		
		// expression
		case \infix(Expression lhs, "&&", Expression rhs): c += 1;
	 	case \infix(Expression lhs, "||", Expression rhs): c += 1;
		case \conditional(Expression expression, Expression thenBranch, Expression elseBranch): c += 1;
	}
	return c;
}