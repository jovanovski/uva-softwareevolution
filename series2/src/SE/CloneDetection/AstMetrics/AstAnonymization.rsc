module SE::CloneDetection::AstMetrics::AstAnonymization

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::m3::AST;

public list[node] anonymizeIdentifiersLiteralsAndTypes(list[node] asts) = [anonymizeIdentifiersLiteralsAndTypes(ast) | ast <- asts];

public node anonymizeIdentifiersLiteralsAndTypes(node ast) {
	return visit(ast){
		// identifiers - declaration
   		case n1:\method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions, Statement impl) => {
   			n2 = \method(\return, "me", parameters, exceptions, impl);
   			n2@src = n1@src;
   		}
   		case n1:\method(Type \return, str name, list[Declaration] parameters, list[Expression] exceptions) => {
   			n2 = \method(\return, "me", parameters, exceptions);
   			n2@src = n1@src;   
   		}
		
		// identifiers - expression
		case \fieldAccess(bool isSuper, Expression expression, _) => \fieldAccess(isSuper, expression, "fa")
   		case \fieldAccess(bool isSuper, _) => \fieldAccess(isSuper, "fa")
		case \methodCall(bool isSuper, _, list[Expression] arguments) => \methodCall(isSuper, "specialMethod", arguments)
		case \methodCall(bool isSuper, Expression receiver, _, list[Expression] arguments) => \methodCall(isSuper, receiver, "specialMethod", arguments)
		case \variable(_, int extraDimensions) => \variable("p", extraDimensions)
		case \variable(_, int extraDimensions, Expression \initializer) => \variable("p", extraDimensions, \initializer)
		case \simpleName(_) => \simpleName("p")
		
		// identifiers - statement
   		case n1:\label(_, Statement body) => {
   			n2 = \label("la", body); 
   			n2@src = n1@src; 
		}		
		// literals
		case \characterLiteral(_) => \characterLiteral("a")
		case \booleanLiteral(_) => \booleanLiteral(true)
		case \stringLiteral(_) => \stringLiteral("ab")
		
		// types
		case Type t => wildcard()		
	}
}