package org.xtext.demo.ui.autoedit

import org.eclipse.jface.text.DocumentCommand
import org.eclipse.jface.text.IAutoEditStrategy
import org.eclipse.jface.text.IDocument
import org.eclipse.xtext.nodemodel.util.NodeModelUtils
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.ui.editor.model.IXtextDocument
import org.eclipse.xtext.util.concurrent.IUnitOfWork
import org.xtext.demo.fsh.Expression
import org.xtext.demo.fsh.Model
import org.xtext.demo.fsh.Statement
import org.xtext.demo.interpreter.Calculator

class InterpreterAutoEdit implements IAutoEditStrategy {
	
	override customizeDocumentCommand(IDocument document, DocumentCommand command) {
		for (String lineDelimiter : document.getLegalLineDelimiters()) {
			if (command.text.equals(lineDelimiter)) {					
				val computedResult = computeResult(document, command);
				if (computedResult !== null)
					command.text = lineDelimiter + "// = " + computedResult.toString() + lineDelimiter;					
			}
		}
	}
	
	def Object computeResult(IDocument document, DocumentCommand command) {
		return ( document as IXtextDocument)
				.readOnly(new IUnitOfWork<Object, XtextResource>() {
					override exec(XtextResource state) throws Exception {
						val expr = findExpression(command, state)
						if (expr === null)
							return null
						return new Calculator().evaluate(expr)
					}					
				});
	}
	
	def Expression findExpression(DocumentCommand command, XtextResource state) {
		if(!state.getContents().isEmpty()) {
			val m = state.getContents().get(0) as Model;
			for (Statement expr : m.getStatements()) {
				if (expr instanceof Expression) {
					val node = NodeModelUtils.getNode(expr);
					if (node.getOffset() <= command.offset
							&& (node.getOffset() + node.getLength()) >= command.offset) {
						return expr as Expression;
					}
				}
			}
		}
		return null;
	}
	
}