package org.xtext.demo.interpreter

import org.xtext.demo.fsh.Expression
import com.google.common.collect.ImmutableMap
import java.math.BigDecimal
import org.xtext.demo.fsh.NumberLiteral
import org.xtext.demo.fsh.Plus
import org.xtext.demo.fsh.Minus
import org.xtext.demo.fsh.Div
import java.math.RoundingMode
import org.xtext.demo.fsh.Multi
import org.xtext.demo.fsh.FunctionCall
import com.google.common.collect.Maps
import org.xtext.demo.fsh.DeclaredParameter
import org.xtext.demo.fsh.Definition
import org.xtext.demo.fsh.Param
import org.xtext.demo.fsh.GT
import org.xtext.demo.fsh.LT
import org.xtext.demo.fsh.EQ
import org.xtext.demo.fsh.GE
import org.xtext.demo.fsh.LE
import org.xtext.demo.fsh.IfStatement
import org.xtext.demo.fsh.CompareExpression

class Calculator {

	def BigDecimal evaluate(Expression obj) {
		return evaluate(obj, ImmutableMap.<String, BigDecimal>of())
	}

	def BigDecimal evaluate(Expression obj, ImmutableMap<String, BigDecimal> values) {
		return internalEvaluate(obj, values)
	}

	def dispatch protected internalEvaluate(NumberLiteral e, ImmutableMap<String, BigDecimal> values) {
		e.value
	}

	/** 
	 * @param values the currently known values by name 
	 */
	def dispatch protected BigDecimal internalEvaluate(FunctionCall e, ImmutableMap<String, BigDecimal> values) {
		if (e.func instanceof DeclaredParameter) {
			return values.get(e.func.name)
		}
		switch d : e.func {
			Definition: {
				var params = Maps.newHashMap
				for (var int i = 0; i < e.args.size; i++) {
					var declaredParameter = d.args.get(i)
					var evaluate = evaluate(e.args.get(i), values)
					params.put(declaredParameter.getName(), evaluate)
				}
				return evaluate(d.expr, ImmutableMap.copyOf(params))
			}
		}
	}

	def dispatch protected BigDecimal internalEvaluate(Plus plus, ImmutableMap<String, BigDecimal> values) {
		evaluate(plus.left, values) + evaluate(plus.right, values)
	}

	def dispatch protected BigDecimal internalEvaluate(Minus minus, ImmutableMap<String, BigDecimal> values) {
		evaluate(minus.left, values) - evaluate(minus.right, values)
	}

	def dispatch protected BigDecimal internalEvaluate(Div div, ImmutableMap<String, BigDecimal> values) {
		evaluate(div.left, values).divide(evaluate(div.right, values), 20, RoundingMode.HALF_UP)
	}
	
	def dispatch protected BigDecimal internalEvaluate(Param param, ImmutableMap<String, BigDecimal> values) {
		values.get(param.getParam().getName())
	}
	

	def dispatch protected BigDecimal internalEvaluate(Multi multi, ImmutableMap<String, BigDecimal> values) {
		evaluate(multi.left, values) * evaluate(multi.right, values)
	}
	

	def dispatch protected boolean internalEvaluateBool(GT greaterThan, ImmutableMap<String, BigDecimal> values) {
		internalEvaluate(greaterThan.getLeft(),values).compareTo(internalEvaluate(greaterThan.getRight(),values)) > 0;		
	}
	
	def dispatch protected boolean internalEvaluateBool(LT lessThan, ImmutableMap<String,BigDecimal> values) {
		return internalEvaluate(lessThan.getLeft(),values).compareTo(internalEvaluate(lessThan.getRight(),values)) < 0;		
	}
	
	def dispatch protected boolean internalEvaluateBool(EQ equal, ImmutableMap<String,BigDecimal> values) {
		return internalEvaluate(equal.getLeft(),values).compareTo(internalEvaluate(equal.getRight(),values)) == 0;		
	}
	
	def dispatch protected boolean  internalEvaluateBool(GE greaterOrEqual, ImmutableMap<String,BigDecimal> values) {
		return internalEvaluate(greaterOrEqual.getLeft(),values).compareTo(internalEvaluate(greaterOrEqual.getRight(),values)) >= 0;
	}
	
	def dispatch protected boolean  internalEvaluateBool(LE lessOrEqual, ImmutableMap<String,BigDecimal> values) {
		internalEvaluate(lessOrEqual.getLeft(),values).compareTo(internalEvaluate(lessOrEqual.getRight(),values)) >= 0;
	}
	
	def dispatch protected BigDecimal internalEvaluate(IfStatement ifStatement, ImmutableMap<String, BigDecimal> values) {
		val cond = internalEvaluateBool(ifStatement.getCond() as CompareExpression, values);
		return if (cond) internalEvaluate(ifStatement.getTruePart(), values) 
			else internalEvaluate(ifStatement.getFalsePart(), values);
	}
}
