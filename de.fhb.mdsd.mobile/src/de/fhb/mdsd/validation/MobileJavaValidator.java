package de.fhb.mdsd.validation;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.validation.Check;

import de.fhb.mdsd.mobile.MobilePackage;
import de.fhb.mdsd.mobile.NavigationType;
import de.fhb.mdsd.mobile.Row;
import de.fhb.mdsd.mobile.Tab;

public class MobileJavaValidator extends AbstractMobileJavaValidator {

//	@Check
//	public void checkGreetingStartsWithCapital(Greeting greeting) {
//		if (!Character.isUpperCase(greeting.getName().charAt(0))) {
//			warning("Name should start with a capital", MyDslPackage.Literals.GREETING__NAME);
//		}
//	}
	
	@Check
	public void checkNavigationType(NavigationType n) {
		boolean usingTabs = false;
		boolean usingDropdown = false;
		for (EObject element : n.getElements()) {
			if (element instanceof Tab && !usingDropdown) {
				usingTabs = true;
			} else if (element instanceof Row && !usingTabs) {
				usingDropdown = true;
			} else {
				error("Use only one navigation type", MobilePackage.Literals.NAVIGATION_TYPE__ELEMENTS);
			}
		}
	}
}
