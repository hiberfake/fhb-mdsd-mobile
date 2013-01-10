
package de.fhb.mdsd;

/**
 * Initialization support for running Xtext languages 
 * without equinox extension registry
 */
public class MobileStandaloneSetup extends MobileStandaloneSetupGenerated{

	public static void doSetup() {
		new MobileStandaloneSetup().createInjectorAndDoEMFRegistration();
	}
}

