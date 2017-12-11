package org.xtext.demo.interpreter

import org.xtext.demo.fsh.Expression
import org.eclipse.xtext.util.PolymorphicDispatcher
import com.google.common.collect.ImmutableMap
import java.math.BigDecimal
import org.xtext.demo.fsh.NumberLiteral
import org.xtext.demo.fsh.Plus
import org.xtext.demo.fsh.Minus
import org.xtext.demo.fsh.Div
import java.math.RoundingMode
import org.xtext.demo.fsh.Multi

public class Calculator {
	
	val dispatcher = PolymorphicDispatcher.createForSingleTarget("internalEvaluate", 2, 2, this);
	def evaluate(Expression expr) {
		dispatcher.invoke(expr, ImmutableMap.<String,Object>of());
	}
	
	protected def internalEvaluate(Expression e, ImmutableMap<String,Object> values) { 
		throw new UnsupportedOperationException(e.toString());
	}
	
	protected def internalEvaluate(NumberLiteral e, ImmutableMap<String,Object> values) { 
		return e.getValue();
	}
	
	protected def internalEvaluate(Plus plus, ImmutableMap<String,Object> values) {
		return evaluateAsBigDecimal(plus.getLeft(),values).add(evaluateAsBigDecimal(plus.getRight(),values));
	}
		
	protected def internalEvaluate(Minus minus, ImmutableMap<String,Object> values) {
		return evaluateAsBigDecimal(minus.getLeft(),values).subtract(evaluateAsBigDecimal(minus.getRight(),values));
	}
	protected def internalEvaluate(Div div, ImmutableMap<String,Object> values) {
		val left = evaluateAsBigDecimal(div.getLeft(),values);
		val right = evaluateAsBigDecimal(div.getRight(),values);
		return left.divide(right,20,RoundingMode.HALF_UP);
	}
	protected def internalEvaluate(Multi multi, ImmutableMap<String,Object> values) {
		return evaluateAsBigDecimal(multi.getLeft(),values).multiply(evaluateAsBigDecimal(multi.getRight(),values));
	}
	
	private def evaluateAsBigDecimal(Expression obj, ImmutableMap<String,Object> values) {
		val invoke = dispatcher.invoke(obj, values) as BigDecimal;
		return invoke;
	}
	
}