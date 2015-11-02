import com.android.uiautomator.core.*;
import com.android.uiautomator.testrunner.*;
import java.io.BufferedReader;
import java.io.FileReader;
import java.util.HashMap;

public class MyTestCase extends UiAutomatorTestCase
{
	private String fileName = "/data/local/tmp/" + this.getClass().getName() + ".txt";

	public void test_my_stuff() throws UiObjectNotFoundException, android.os.RemoteException {
		HashMap<String,Boolean> appsToSearch = new HashMap<String,Boolean>();

		BufferedReader br = null;
		String line = "";
		try {
			br = new BufferedReader(new FileReader(fileName));
			while((line = br.readLine()) != null) {
				appsToSearch.put(line, false);
			}
		}
		catch(Exception e) {}
		finally {
			try {
				br.close();
			}
			catch(Exception e) {}
		}

		go_to_apps_menu();
		do {
			for(String app : appsToSearch.keySet()) {
				if(! appsToSearch.get(app)) {
					appsToSearch.put(app, app_exists(app));
				}
			}
			swipe_left();
		}
		while(! now_in_widgets());

		for(String app : appsToSearch.keySet()) {
			if(appsToSearch.get(app)) {
				System.out.println("FOUND:" + app);
			}
			else {
				System.out.println("NOT_FOUND:" + app);
			}
		}
	}

	public boolean app_exists(String appName) {
		try {
			UiObject app = new UiObject(new UiSelector().text(appName));
			return app.exists();
		}
		catch(Exception e) {}
		return false;
	}

	public boolean go_to_apps_menu() {
		try {
			UiDevice dev = getUiDevice();
			dev.wakeUp(); 
			dev.pressEnter();
			dev.pressHome();
			UiObject apps = new UiObject(new UiSelector().description("Apps"));
			apps.click();
			apps = new UiObject(new UiSelector().description("Apps"));
			apps.click();
			return true;
		}
		catch(Exception e) {}
		return false;
	}

	public boolean now_in_widgets() {
		try {
			UiObject apps = new UiObject(new UiSelector().description("Widgets"));
			return apps.isSelected();
		}
		catch(UiObjectNotFoundException e) {}
		return false;
	}

	public void swipe_left() {
		UiDevice dev = getUiDevice();
		int width = dev.getDisplayWidth();
		int height = dev.getDisplayHeight();
		dev.swipe(width/2, height/2, 0, height/2, 10);
	}
}