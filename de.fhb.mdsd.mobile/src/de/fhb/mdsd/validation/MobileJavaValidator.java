package de.fhb.mdsd.validation;

import java.util.ArrayList;
import java.util.List;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.validation.Check;

import de.fhb.mdsd.mobile.Item;
import de.fhb.mdsd.mobile.ListPreference;
import de.fhb.mdsd.mobile.Menu;
import de.fhb.mdsd.mobile.MenuItem;
import de.fhb.mdsd.mobile.MobilePackage;
import de.fhb.mdsd.mobile.Navigation;
import de.fhb.mdsd.mobile.Row;
import de.fhb.mdsd.mobile.Tab;

public class MobileJavaValidator extends AbstractMobileJavaValidator {

	/*
	 * Die Navigation einer Activity darf nur einen Navigationstyp enthalten.
	 */
	@Check
	public void checkNavigation(Navigation navigation) {
		boolean usingTabs = false;
		boolean usingDropdown = false;
		for (EObject element : navigation.getElements()) {
			if (element instanceof Tab && !usingDropdown) {
				usingTabs = true;
			} else if (element instanceof Row && !usingTabs) {
				usingDropdown = true;
			} else {
				error("Use only one navigation type", MobilePackage.Literals.NAVIGATION__ELEMENTS);
			}
		}
	}
	
	/*
	 * Innerhalb der Aktionen in der Aktionsleiste darf höchstens ein Aktion als
	 * Suche und eine als Aktualisierung gekennzeichnet sein.
	 */
	@Check
	public void checkMenu(Menu menu) {
		boolean usingSearchView = false;
		boolean usingRefreshView = false;
		for (MenuItem menuItem : menu.getMenuItems()) {
			try {
				if (menuItem.getSearchView().equals("searchView") && !usingSearchView) {
					usingSearchView = true;
				} else {
					error("Use only one menu item as search view", MobilePackage.Literals.MENU__MENU_ITEMS);
				}
				if (menuItem.getRefreshView().equals("refreshView") && !usingRefreshView) {
					usingRefreshView = true;
				} else {
					error("Use only one menu item as refresh view", MobilePackage.Literals.MENU__MENU_ITEMS);
				}
			} catch (NullPointerException e) {
			}
		}
	}
	
	/*
	 * Die Werte der Einträge für eine ListPreference dürfen sich nicht doppeln.
	 */
	@Check
	public void checkListPreference(ListPreference p) {
		List<String> values = new ArrayList<String>();
		for (Item i : p.getEntries().getItems()) {
			if (values.contains(i.getValue())) {
				error("Duplicate values not allowed", MobilePackage.Literals.LIST_PREFERENCE__ENTRIES);
			}
			values.add(i.getValue());
		}
	}
}
