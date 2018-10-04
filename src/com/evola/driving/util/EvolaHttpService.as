package com.evola.driving.util
{
	import com.evola.driving.controls.EDTAlert;
	
	import mx.controls.Alert;
	import mx.messaging.messages.AbstractMessage;
	import mx.messaging.messages.IMessage;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.mxml.HTTPService;

	public class EvolaHttpService extends HTTPService
	{

		public var faultFunction:Function;

		private var _restUrl:String;
		
		public var skipError401 : Boolean = false;

		public function EvolaHttpService(rootURL:String=null, destination:String=null)
		{
			super(rootURL, destination);

			method="GET";
			resultFormat="e4x";

			addEventListener(FaultEvent.FAULT, onFault);
			addEventListener(ResultEvent.RESULT, onResult);
		}
		
		protected function onResult(event:ResultEvent):void
		{

			//ako imamo xml i on pocinje sa html tagom onda je u pitanje spring security greska: redirect to login
			
			if(event.result && event.result is XML){

				if(event.result.head.length() > 0 && event.result.body.length() > 0)
				{

					event.stopImmediatePropagation();
					event.preventDefault();

					//simuliramo not authorized event
					
					var message : IMessage = new AbstractMessage();
					message.headers = {};
					message.headers[AbstractMessage.STATUS_CODE_HEADER] = 401;
						
					var fault : FaultEvent = new FaultEvent(FaultEvent.FAULT, false, true, null, null, message);
					
					//greska
					dispatchEvent(fault);
				}
			}
		}
		
		public function set restUrl(value:String):void
		{

			_restUrl=value;
		}

		protected function onFault(event:FaultEvent):void
		{
			if (event.statusCode == 401 && !skipError401)
			{
				EDTAlert.show("Istekla je sesija. Osveži stranicu u svom pregledaču i ponovo se uloguj.", event.toString());
			}
			else if (faultFunction == null)
			{
				EDTAlert.show("Greška :(. Pokušaj ponovo ili osveži stranicu u svom pregledaču.", event.toString());
			}
			else
			{
				faultFunction(event);
			}
		}

		override public function send(params:Object=null):AsyncToken
		{

			if (_restUrl)
				url=Settings.SERVER_URL + "/rest/" + _restUrl;

//			if (params == null)
//				params={AuthenticationToken: Settings.userToken};
//			else
//				params.AuthenticationToken=Settings.userToken;

			return super.send(params);
		}

	}
}
