/*******************************************************************************
 * Copyright (c) 2015 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.eclipse.xtext.xtext.generator

import com.google.inject.Inject
import com.google.inject.Injector
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.Grammar

abstract class AbstractGeneratorFragment2 implements IGeneratorFragment2 {
	
	@Accessors(PROTECTED_GETTER)
	@Inject XtextProjectConfig projectConfig
	
	@Accessors(PROTECTED_GETTER)
	@Inject ILanguageConfig language
	
	@Accessors(PROTECTED_GETTER)
	@Inject Grammar grammar
	
	override checkConfiguration(Issues issues) {
	}
	
	override initialize(Injector injector) {
		injector.injectMembers(this)
	}
	
}