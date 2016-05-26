/*******************************************************************************
 * Copyright (c) 2016 TypeFox GmbH (http://www.typefox.io) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.eclipse.xtext.ide.server.symbol

import com.google.inject.Inject
import com.google.inject.Provider
import com.google.inject.Singleton
import io.typefox.lsapi.Location
import io.typefox.lsapi.SymbolInformation
import io.typefox.lsapi.SymbolInformationImpl
import java.util.List
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.findReferences.IReferenceFinder
import org.eclipse.xtext.findReferences.IReferenceFinder.IResourceAccess
import org.eclipse.xtext.findReferences.ReferenceAcceptor
import org.eclipse.xtext.findReferences.TargetURICollector
import org.eclipse.xtext.findReferences.TargetURIs
import org.eclipse.xtext.ide.server.DocumentExtensions
import org.eclipse.xtext.naming.IQualifiedNameProvider
import org.eclipse.xtext.resource.EObjectAtOffsetHelper
import org.eclipse.xtext.resource.IResourceDescriptions
import org.eclipse.xtext.resource.IResourceServiceProvider
import org.eclipse.xtext.resource.XtextResource

import static extension org.eclipse.emf.ecore.util.EcoreUtil.*

/**
 * @author kosyakov - Initial contribution and API
 */
@Singleton
class DocumentSymbolService {

	@Inject
	extension DocumentExtensions

	@Inject
	extension EObjectAtOffsetHelper

	@Inject
	extension IQualifiedNameProvider

	@Inject
	IReferenceFinder referenceFinder

	@Inject
	TargetURICollector targetURICollector

	@Inject
	Provider<TargetURIs> targetURIProvider

	@Inject
	IResourceServiceProvider.Registry resourceServiceProviderRegistry

	def List<? extends Location> getDefinitions(XtextResource resource, int offset, IResourceAccess resourceAccess) {
		val element = resource.resolveElementAt(offset)
		if (element === null)
			return emptyList

		val locations = newArrayList
		val targetURIs = element.collectTargetURIs
		for (targetURI : targetURIs) {
			resourceAccess.readOnly(targetURI) [ resourceSet |
				locations += resourceSet.getEObject(targetURI, true).newLocation
			]
		}
		return locations
	}

	def List<? extends Location> getReferences(
		XtextResource resource,
		int offset,
		IResourceAccess resourceAccess,
		IResourceDescriptions indexData
	) {
		val element = resource.resolveElementAt(offset)
		if (element === null)
			return emptyList

		val locations = newArrayList
		val targetURIs = element.collectTargetURIs
		referenceFinder.findAllReferences(
			targetURIs,
			resourceAccess,
			indexData,
			new ReferenceAcceptor(resourceServiceProviderRegistry) [ reference |
				resourceAccess.readOnly(reference.sourceEObjectUri) [ resourceSet |
					val targetObject = resourceSet.getEObject(reference.sourceEObjectUri, true)
					locations += targetObject.newLocation(reference.EReference, reference.indexInList)
				]
			],
			null
		)

		return locations
	}

	protected def TargetURIs collectTargetURIs(EObject targetObject) {
		val targetURIs = targetURIProvider.get
		targetURICollector.add(targetObject, targetURIs)
		return targetURIs
	}

	def List<? extends SymbolInformation> getSymbols(XtextResource resource) {
		val symbols = newLinkedHashMap
		val contents = resource.getAllProperContents(true)
		while (contents.hasNext) {
			val obj = contents.next
			val symbol = obj.createSymbol
			if (symbol !== null) {
				symbols.put(obj, symbol)

				val container = obj.container
				val containerSymbol = symbols.get(container)
				symbol.container = containerSymbol?.name
			}
		}
		return symbols.values.toList
	}

	protected def EObject getContainer(EObject obj) {
		return obj.eContainer
	}

	protected def SymbolInformationImpl createSymbol(EObject object) {
		val symbolName = object.symbolName
		if(symbolName === null) return null

		val symbol = new SymbolInformationImpl
		symbol.name = symbolName
		symbol.kind = object.symbolKind
		symbol.location = object.newLocation
		return symbol
	}

	protected def String getSymbolName(EObject object) {
		return object.fullyQualifiedName?.toString
	}

	protected def int getSymbolKind(EObject object) {
		return 0
	}

}
