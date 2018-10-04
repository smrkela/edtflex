package com.evola.driving.controls.questiondiscuss
{
	import com.evola.driving.model.Question;
	
	import mx.collections.XMLListCollection;

	[Bindable]
	public class QuestionDiscussModel
	{

		//da li da se prikazuje ucitano pitanje
		public var showLoadedQuestion:Boolean;
		
		//pitanje ucitano sa servera
		public var loadedQuestion:Question;
		
		//broj poruka po stranici
		public var pageSize:int;
		
		//ukupan broj stranica
		public var totalPages:int;
		
		//ukupno poruka
		public var totalMessages : int;
		
		//index trenutne stranice
		public var currentPageIndex:int;
		
		//da li je u toku cuvanje poruke
		public var isSavingMessage:Boolean;
		
		//poruka koja je u procesu brisanja
		public var deletedMessage:XML;

		//da li je trenutni korisnik administrator
		public var isAdministrator:Boolean;

		//tekst poruke
		public var messageText:String;

		public var isWritingMessage:Boolean;

		public var question:Question;

		public var isLoading:Boolean;

		public var messages:XMLListCollection;
		
		//poruka na koju se odgovara
		public var repliedMessage : XML;

		public function QuestionDiscussModel()
		{
		}
	}
}
