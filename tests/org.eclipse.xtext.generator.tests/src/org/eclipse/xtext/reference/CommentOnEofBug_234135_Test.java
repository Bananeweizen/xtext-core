/*******************************************************************************
 * Copyright (c) 2009 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 *******************************************************************************/
package org.eclipse.xtext.reference;

import org.eclipse.emf.common.util.EList;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.TerminalRule;
import org.eclipse.xtext.parsetree.LeafNode;
import org.eclipse.xtext.testlanguages.ReferenceGrammarTestLanguageStandaloneSetup;
import org.eclipse.xtext.tests.AbstractGeneratorTest;

/**
 * @author Jan K�hnlein - Initial contribution and API
 *
 */
public class CommentOnEofBug_234135_Test extends AbstractGeneratorTest {

    public void testCommentOnEof() throws Exception {
        with(ReferenceGrammarTestLanguageStandaloneSetup.class);
        String model = "//comment";
        EList<LeafNode> leafNodes = getRootNode(model).getLeafNodes();
        assertEquals(1, leafNodes.size());
        EObject grammarElement = leafNodes.get(0).getGrammarElement();
        assertNotNull(grammarElement);
        assertTrue(grammarElement instanceof TerminalRule);
    }

}
