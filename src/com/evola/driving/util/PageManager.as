package com.evola.driving.util
{
	import mx.managers.HistoryManager;

	public class PageManager
	{
		public function PageManager()
		{
		}
		
		public static var currentPageParams : Object;

		public static function selectPage(pageCode:String, parameters : Object = null):void
		{

			var mp : MainPresenter = PresenterProvider.mainPresenter;
			
			if (mp == null || mp.view == null)
				return;
			
			//register zabranjujemo do daljnjeg
			if(pageCode == "Register")
				return;

			var noUserPageCodes : Array = ["Login", "Register", "PasswordReset"];
			var isAskingNoUserPageCode : Boolean = pageCode && noUserPageCodes.indexOf(pageCode) != -1;
			
			//ako nismo ulogovani onda ne mozemo ici nige sem na login
			if (Settings.user == null && !isAskingNoUserPageCode)
				pageCode="Login";
			
			//ako smo ulogovani onda ne mozemo ici na login, register i password reset
			if(Settings.user != null && isAskingNoUserPageCode)
				pageCode = "Home";

			if (pageCode == null || pageCode == "null")
			{
				mp.view.currentState=null;
				mp.view.initializeMainPage();
			}
			else
			{
				currentPageParams = parameters;
				mp.view.currentState="state" + pageCode;
			}

			var fragment : String = "pc="+pageCode;
			
			if(parameters){
				
				for(var key : String in parameters){
					
					var value : String = parameters[key];
					
					fragment += "&"+key+"="+value;
				}
			}

			mp.browserManager.setFragment(fragment);
		}
	}
}
