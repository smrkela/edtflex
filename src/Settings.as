package
{
	import com.evola.driving.model.User;

	[Bindable]
	public class Settings
	{
		public static var FORUM_MESSAGE_LIMIT:int = 1000;
		public static var URL:String;
		public static var APPLICATION:String;
		public static var SERVER_URL:String="http://localhost/EDTService"; //"http://188.2.242.230:8080/EDTService";
		public static var SITE:String="www.vozacisrbije.com";
		public static var EMAIL:String="office.vozacisrbije@gmail.com";

		public static var user:User;

		//id user-a iz baze
		public static var userId:String;

		public static var learningOrderNumber:int=1; //1,2,3

		public function Settings()
		{
		}

		public static function configure(settingsXML:XML):void
		{

			URL=settingsXML.child("url")[0].attribute("value");
			APPLICATION=settingsXML.child("application")[0].attribute("value");

			if (APPLICATION)
				SERVER_URL="http://" + URL + "/" + APPLICATION;
			else
				SERVER_URL="http://" + URL;

			SITE=URL;

			try
			{
				//site ne moramo imati
				SITE=settingsXML.child("site")[0].attribute("value");
			}
			catch (e:Error)
			{
			}

			try
			{
				//email ne moramo imati
				EMAIL=settingsXML.child("email")[0].attribute("value");
			}
			catch (e:Error)
			{
			}
		}
	}
}
