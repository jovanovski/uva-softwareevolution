module SE::CloneDetection::AstMetrics::AstAnonymization

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;

public list[node] anonymizeIdentifiersLiteralsAndTypes(list[node] asts) = [anonymizeIdentifiersLiteralsAndTypes(ast) | ast <- asts];

public node anonymizeIdentifiersLiteralsAndTypes(node ast) {
	return visit(ast){
		// identifiers - declaration
   		case \method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl) => \method(\return, "me", parameters, exceptions, impl)
   		case \method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions) => \method(\return, "me", parameters, exceptions)
		
		// identifiers - expression
		case \fieldAccess(bool isSuper, Expression expression, _) => \fieldAccess(isSuper, expression, "fa")
   		case \fieldAccess(bool isSuper, _) => \fieldAccess(isSuper, "fa")
		case \methodCall(bool isSuper, _, list[Expression] arguments) => \methodCall(isSuper, "specialMethod", arguments)
		case \methodCall(bool isSuper, Expression receiver, _, list[Expression] arguments) => \methodCall(isSuper, receiver, "specialMethod", arguments)
		case \variable(_, int extraDimensions) => \variable("p", extraDimensions)
		case \variable(_, int extraDimensions, Expression \initializer) => \variable("p", extraDimensions, \initializer)
		case \simpleName(_) => \simpleName("p")
		
		// identifiers - statement
   		case \label(_, Statement body) => \label("la", body)
		
		// literals
		case \characterLiteral(_) => \characterLiteral("a")
		case \booleanLiteral(_) => \booleanLiteral(true)
		case \stringLiteral(_) => \stringLiteral("ab")
		
		// types
		case Type t => wildcard()
		
	}
}