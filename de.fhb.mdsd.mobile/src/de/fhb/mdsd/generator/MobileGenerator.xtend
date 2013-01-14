/*
 * generated by Xtext
 */
package de.fhb.mdsd.generator

import com.google.inject.Inject
import de.fhb.mdsd.mobile.Activity
import de.fhb.mdsd.mobile.App
import de.fhb.mdsd.mobile.Button
import de.fhb.mdsd.mobile.Menu
import de.fhb.mdsd.mobile.Row
import de.fhb.mdsd.mobile.Tab
import de.fhb.mdsd.mobile.TextField
import de.fhb.mdsd.mobile.TextView
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator
import org.eclipse.xtext.naming.IQualifiedNameProvider
import de.fhb.mdsd.mobile.View

class MobileGenerator implements IGenerator {
	
	@Inject extension IQualifiedNameProvider
 
  	override void doGenerate(Resource resource, IFileSystemAccess fsa) {
    	fsa.generateFile("../AndroidManifest.xml", resource.compileManifest);
    	fsa.generateFile("../res/values/styles.xml", resource.allContents.filter(typeof(App)).head.compileStyles)
    	
    	for (a : resource.allContents.toIterable.filter(typeof(Activity))) {
      		fsa.generateFile(resource.allContents.filter(typeof(App)).head.packageName.replace(".", "/") + "/" + a.name.toFirstUpper + "Activity.java", a.compileActivity)
      		fsa.generateFile("../res/layout/" + a.name.toLowerCase + ".xml", a.compileLayout)
      		// TODO generate file for fragments
      		if (a.menu != null) {
      			fsa.generateFile("../res/menu/" + a.name.toLowerCase + ".xml", a.menu.compileMenu)
      		}
    	}
    }
  
  	def compileManifest(Resource resource) '''
		<?xml version="1.0" encoding="utf-8"?>
		<manifest xmlns:android="http://schemas.android.com/apk/res/android"
			package="«resource.allContents.filter(typeof(App)).head.packageName»"
			android:versionCode="1"
			android:versionName="1.0" >
		
			<uses-sdk
				android:minSdkVersion="14"
				android:targetSdkVersion="17" />

			<application
				android:allowBackup="true"
				android:icon="@drawable/ic_launcher"
				android:label="@string/app_name"
				android:theme="@style/AppTheme"«IF !resource.allContents.filter(typeof(App)).head.bottomBar.equals("true")» >
				«ELSE»
				android:uiOptions="splitActionBarWhenNarrow" >
				«ENDIF»
				«FOR a : resource.allContents.toIterable.filter(typeof(Activity))»
				«IF a.label != null»
				<activity
					android:name=".«a.name.toFirstUpper»Activity"
					android:label="«a.label»" >
				«ELSE»
				<activity android:name="«a.name.toFirstUpper»Activity" >
				«ENDIF»
					«IF a.main != null»
					<intent-filter>
						<action android:name="android.intent.action.MAIN" />
						
						<category android:name="android.intent.category.LAUNCHER" />
					</intent-filter>
					«ENDIF»
				</activity>
	        	«ENDFOR»
			</application>

		</manifest>
  	'''

	def compileStyles(App app) '''
		<resources>
			
			«IF app.design.equals("light")»
			<style name="AppTheme" parent="android:Theme.Holo.Light" />
			«ELSEIF app.design.equals("dark")»
			<style name="AppTheme" parent="android:Theme.Holo" />
			«ELSEIF app.design.equals("light with dark action bar")»
			<style name="AppTheme" parent="android:Theme.Holo.Light.DarkActionBar" />
			«ELSE»
			<style name="AppTheme" parent="android:Theme.Holo.Light" />
			«ENDIF»
		
		</resources>
	'''
  	  
	def compileActivity(Activity a) '''
		«IF a.eContainer != null»
		package «a.eContainer.eAllContents.toIterable.filter(typeof(App)).head.packageName»;
		«ENDIF»
		
		import android.app.ActionBar;
		import android.app.FragmentTransaction;
		import android.content.Intent;
		import android.os.Bundle;
		import android.support.v4.app.Fragment;
		import android.support.v4.app.FragmentActivity;
		import android.support.v4.app.FragmentManager;
		import android.support.v4.app.FragmentPagerAdapter;
		import android.support.v4.view.ViewPager;
		import android.view.Gravity;
		import android.view.LayoutInflater;
		import android.view.Menu;
		import android.view.View;
		import android.view.ViewGroup;
		import android.widget.ArrayAdapter;
		import android.widget.TextView;
		
		public class «a.name»Activity extends FragmentActivity «IF a.navigation != null»«IF a.navigation.elements.filter(typeof(Tab)).size > 0»implements ActionBar.TabListener «ELSEIF a.navigation.elements.filter(typeof(Row)).size > 0»implements ActionBar.OnNavigationListener «ENDIF»«ENDIF»{
			
			«IF a.navigation != null && a.navigation.elements.filter(typeof(Tab)).size > 0»
			PagerAdapter mPagerAdapter;
			
			ViewPager mViewPager;
			
			«ENDIF»
			@Override
			protected void onCreate(Bundle savedInstanceState) {
				super.onCreate(savedInstanceState);
				setContentView(R.layout.«a.name.toLowerCase»);
				
				final ActionBar actionBar = getActionBar();
				«IF a.navigation != null && a.navigation.elements.filter(typeof(Row)).size > 0»
				actionBar.setDisplayShowTitleEnabled(false);
				«ENDIF»
				«IF a.navigation != null && a.navigation.elements.filter(typeof(Tab)).size > 0»
				actionBar.setNavigationMode(ActionBar.NAVIGATION_MODE_TABS);
				
				mPagerAdapter = new PagerAdapter(getSupportFragmentManager());
				
				mViewPager = (ViewPager) findViewById(R.id.pager);
				mViewPager.setAdapter(mPagerAdapter);

				mViewPager.setOnPageChangeListener(new ViewPager.SimpleOnPageChangeListener() {
					@Override
					public void onPageSelected(int position) {
						actionBar.setSelectedNavigationItem(position);
					}
				});
				
				«FOR t : a.navigation.elements.filter(typeof(Tab))»
				actionBar.addTab(actionBar.newTab().setText("«t.text.toUpperCase»").setTabListener(this));
				«ENDFOR»
				«FOR t : a.navigation.elements.filter(typeof(Tab))»
				«IF t.selected != null»
				actionBar.setSelectedNavigationItem(«a.navigation.elements.indexOf(t)»);
				«ENDIF»
				«ENDFOR»
				«ELSEIF a.navigation != null && a.navigation.elements.filter(typeof(Row)).size > 0»
				actionBar.setNavigationMode(ActionBar.NAVIGATION_MODE_LIST);
				
				actionBar.setListNavigationCallbacks(
					new ArrayAdapter<String>(
						actionBar.getThemedContext(),
						android.R.layout.simple_list_item_1, android.R.id.text1,
						new String[] {
							«FOR r : a.navigation.elements.filter(typeof(Row))»
							"«r.text.toFirstUpper»",
							«ENDFOR»
						}),
					this);
				«FOR r : a.navigation.elements.filter(typeof(Row))»
				«IF r.selected != null»
				actionBar.setSelectedNavigationItem(«a.navigation.elements.indexOf(r)»);
				«ENDIF»
				«ENDFOR»
				«ENDIF»
			}
			
			«IF a.menu != null»
			@Override
			public boolean onCreateOptionsMenu(Menu menu) {
				getMenuInflater().inflate(R.menu.«a.name.toLowerCase», menu);
				return true;
			}
			«ENDIF»
			
			«IF a.navigation != null && a.navigation.elements.filter(typeof(Tab)).size > 0»
			@Override
			public void onTabUnselected(ActionBar.Tab tab, FragmentTransaction ft) {
			}
			
			@Override
			public void onTabSelected(ActionBar.Tab tab, FragmentTransaction ft) {
				mViewPager.setCurrentItem(tab.getPosition());
			}
			
			@Override
			public void onTabReselected(ActionBar.Tab tab, FragmentTransaction ft) {
			}
			
			public class PagerAdapter extends FragmentPagerAdapter {
				
				public PagerAdapter(FragmentManager fm) {
					super(fm);
				}
				
				@Override
				public Fragment getItem(int position) {
					Fragment fragment = new DummySectionFragment();
					Bundle args = new Bundle();
					args.putInt(DummySectionFragment.ARG_SECTION_NUMBER, position + 1);
					fragment.setArguments(args);
					return fragment;
				}

				@Override
				public int getCount() {
					return 3;
				}
				
				@Override
				public CharSequence getPageTitle(int position) {
					return getActionBar().getTabAt(position).getText().toString().toUpperCase();
				}
			}
			
			«ELSEIF a.navigation != null && a.navigation.elements.filter(typeof(Row)).size > 0»
			@Override
			public boolean onNavigationItemSelected(int position, long id) {
				Fragment fragment = new DummySectionFragment();
				Bundle args = new Bundle();
				args.putInt(DummySectionFragment.ARG_SECTION_NUMBER, position + 1);
				fragment.setArguments(args);
				getSupportFragmentManager().beginTransaction().replace(R.id.container, fragment).commit();
				return true;
			}
			
			«ENDIF»
			
			«IF a.navigation != null && a.navigation.elements.size > 0»
			public static class DummySectionFragment extends Fragment {

				public static final String ARG_SECTION_NUMBER = "section_number";
				
				public DummySectionFragment() {
				}
				
				@Override
				public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
					TextView textView = new TextView(getActivity());
					textView.setGravity(Gravity.CENTER);
					textView.setText(Integer.toString(getArguments().getInt(ARG_SECTION_NUMBER)));
					return textView;
				}
			}
			«ENDIF»
		}
	'''
	
	def compileLayout(Activity a) '''
		«IF a.navigation != null && a.navigation.elements.filter(typeof(Tab)).size > 0»
		<android.support.v4.view.ViewPager xmlns:android="http://schemas.android.com/apk/res/android"
			android:id="@+id/pager"
			android:layout_width="match_parent"
			android:layout_height="match_parent" />
		«FOR t : a.navigation.elements.filter(typeof(Tab))»
		«IF t.frag != null»
		«t.frag.view.compileView»
		«ENDIF»
		«ENDFOR»
		«ELSEIF a.navigation != null && a.navigation.elements.filter(typeof(Row)).size > 0»
		<FrameLayout xmlns:android="http://schemas.android.com/apk/res/android"
			android:id="@+id/container"
			android:layout_width="match_parent"
			android:layout_height="match_parent" />
		«ELSEIF a.view != null»
		«a.view.compileView»
		«ENDIF»
	'''
	
	def compileView(View view) '''
		<?xml version="1.0" encoding="utf-8"?>
		<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
			android:layout_width="match_parent"
			android:layout_height="match_parent"
			android:orientation="vertical"
			android:padding="16dp" >
		
			«FOR e : view.elements»
			«IF e instanceof Button»
			«compileButton(e as Button, view.elements.indexOf(e)+1)»
			«ELSEIF e instanceof TextField»
			«compileTextField(e as TextField, view.elements.indexOf(e)+1)»
			«ELSEIF e instanceof TextView»
			«compileTextView(e as TextView, view.elements.indexOf(e)+1)»
			«ENDIF»
			«ENDFOR»
		
		</LinearLayout>
	'''
	
	def compileButton(Button button, int pos) '''
		<Button
			android:id="@+id/button«pos»"
			android:layout_width="wrap_content"
			android:layout_height="wrap_content"
			android:layout_marginBottom="8dp"
			android:text="«button.text»" />
	'''
	
	def compileTextField(TextField textField, int pos) '''
		<EditText
			android:id="@+id/editText«pos»"
			android:layout_width="match_parent"
			android:layout_height="wrap_content"
			android:layout_marginBottom="8dp"
			android:ems="10"
			android:hint="«textField.hint»"
			«IF textField.inputType.equals("emailAddress")»
			android:inputType="textEmailAddress" />
			«ELSEIF textField.inputType.equals("password")»
			android:inputType="textPassword" />
			«ENDIF»
	'''
	
	def compileTextView(TextView textView, int pos) '''
		<TextView
			android:id="@+id/textView«pos»"
			android:layout_width="wrap_content"
			android:layout_height="wrap_content"
			android:layout_marginBottom="8dp"
			android:text="«textView.text»"
			«IF textView.appearance.equals("large")»
			android:textAppearance="?android:attr/textAppearanceLarge" />
			«ELSEIF textView.appearance.equals("medium")»
			android:textAppearance="?android:attr/textAppearanceMedium" />
			«ELSEIF textView.appearance.equals("small")»
			android:textAppearance="?android:attr/textAppearanceSmall" />
			«ENDIF»
	'''
	
	def compileMenu(Menu menu) '''
		<menu xmlns:android="http://schemas.android.com/apk/res/android" >
		
			«FOR item : menu.items»
			<item
				android:id="@+id/menu_«item.title.toLowerCase»"
				«IF item.icon != null»android:icon="@drawable/«item.icon»"«ENDIF»
				android:showAsAction="«item.showAsAction»"
				android:title="«item.title»"/>
			«ENDFOR»
		
		</menu>
	'''
}