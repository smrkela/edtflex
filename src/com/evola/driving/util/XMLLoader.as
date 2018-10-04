package com.evola.driving.util
{
	import com.evola.driving.model.Question;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.controls.Alert;

	[Event(name="xmlLoaded", type="flash.events.Event")]
	public class XMLLoader extends EventDispatcher
	{
		private var _loader:URLLoader;

		private var _numOfQuestionFiles:int=0;
		private var _currentLoadingFileIndex:int=0;
		private var _loadedSettingsXML:XML;
		private var _loadedQuestionFiles:Array; //of XML

		public function XMLLoader()
		{
		}
		
		public function get loadedSettingsXML() : XML{
			
			return _loadedSettingsXML;
		}
		
		public function get loadedQuestionFiles() : Array{
			
			return _loadedQuestionFiles;
		}

		public function load():void
		{
			
			trace("START: "+new Date().toString());

			var request:URLRequest=new URLRequest("data/evola_driving.xml");

			_loader=new URLLoader();
			_loadedQuestionFiles = new Array();

			try
			{
				_loader.load(request);
			}
			catch (error:SecurityError)
			{
				Alert.show("Security error: " + error.message);
			}

			_loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			_loader.addEventListener(Event.COMPLETE, onSettingsFileLoaded);

		}

		protected function onSettingsFileLoaded(event:Event):void
		{

			_loader.removeEventListener(Event.COMPLETE, onSettingsFileLoaded);
			_loader.addEventListener(Event.COMPLETE, onQuestionFileLoaded);

			try
			{

				_loadedSettingsXML=new XML(event.target.data);

				var questionFiles:XMLList=_loadedSettingsXML.child("question-files").child("question-file");

				_numOfQuestionFiles=questionFiles.length();
				_currentLoadingFileIndex=0;

				loadQuestionsFile();
			}
			catch (e:TypeError)
			{

				Alert.show("Could not parse settings XML file:\n" + event.target.data);
			}
		}

		private function loadQuestionsFile():void
		{

			var questionFiles:XMLList=_loadedSettingsXML.child("question-files").child("question-file");
			var qf:XML=questionFiles[_currentLoadingFileIndex];
			var url:String=qf.attribute("url");

			var request:URLRequest=new URLRequest(url);

			_loader.load(request);
		}

		protected function onQuestionFileLoaded(event:Event):void
		{

			try
			{

				var loadedQuestionsFile:XML=new XML(event.target.data);

				_loadedQuestionFiles.push(loadedQuestionsFile);
			}
			catch (e:TypeError)
			{
				Alert.show("Could not parse settings XML file:\n" + event.target.data);
			}

			if (_currentLoadingFileIndex == _numOfQuestionFiles - 1)
			{
				finishLoading();
			}
			else
			{

				_currentLoadingFileIndex++;
				loadQuestionsFile();
			}
		}

		private function finishLoading():void
		{
			
			trace("FINISH LOADING: "+new Date().toString());
			
			dispatchEvent(new Event("xmlLoaded"));
		}

		protected function errorHandler(event:IOErrorEvent):void
		{
			Alert.show("Had problem loading the XML File: " + event.text);
		}
	}
}
