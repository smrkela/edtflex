package com.evola.driving.controls.questiondiscuss
{
	import com.evola.driving.controls.EDTAlert;
	import com.evola.driving.model.Question;
	import com.evola.driving.util.ModelParser;
	import com.evola.driving.util.PresenterProvider;
	import com.evola.driving.views.pages.discussions.controls.PageEvent;
	
	import flash.events.MouseEvent;
	
	import mx.collections.XMLListCollection;
	import mx.managers.PopUpManager;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.utils.StringUtil;

	[Bindable]
	public class QuestionDiscussPresenter
	{

		public var model:QuestionDiscussModel=new QuestionDiscussModel();
		public var view:QuestionDiscussPopup;

		public function QuestionDiscussPresenter()
		{
		}

		public function initialize(question:Question, showLoadedQuestion : Boolean):void
		{

			model.question=question;
			model.messages=new XMLListCollection();
			model.isLoading=false;
			model.isWritingMessage=false;
			model.messageText="";
			model.deletedMessage=null;
			model.isSavingMessage=false;
			model.currentPageIndex=0;
			model.totalPages=0;
			model.loadedQuestion = null;
			model.showLoadedQuestion = showLoadedQuestion;

			PopUpManager.addPopUp(view, PresenterProvider.mainPresenter.view, true);

			positionAndSize();

			load(0);
		}

		private function load(pageIndex:int):void
		{

			model.isLoading=true;
			view.serviceLoadMessages.send({questionId: model.question.id, pageIndex: pageIndex});
		}

		public function close():void
		{

			PopUpManager.removePopUp(view);
		}

		public function saveMessage():void
		{

			var message:String=model.messageText;

			message=StringUtil.trim(message);

			if (!message)
			{

				EDTAlert.show("Unesi tekst pre čuvanja poruke.", "Da bi sačuvao poruku, moraš ukucati tekst.");
				return;
			}

			//poruka ne sme da ima vise od 2000 karaktera
			if (message.length > 2000)
			{

				EDTAlert.show("Poruka ne može da ima više od 2000 slova.", "Smanji tekst poruke.");
				return
			}

			var parentMessageId:String=model.repliedMessage ? model.repliedMessage.@id : null;

			model.isSavingMessage=true;

			view.serviceSaveMessage.send({userId: Settings.userId, questionId: model.question.id, messageText: message, parentMessageId: parentMessageId});
		}

		public function cancelMessage():void
		{

			model.isWritingMessage=false;
			model.messageText="";
		}

		public function writeMessageClicked(event:MouseEvent):void
		{

			model.repliedMessage=null;
			model.isWritingMessage=true;

			view.txtMessage.setFocus();
		}

		public function replyMessageClicked(message:XML):void
		{

			model.repliedMessage=message;
			model.isWritingMessage=true;

			view.txtMessage.setFocus();
		}

		public function onSaveMessageResult(event:ResultEvent):void
		{

			var message:XML=XML(event.result);

			//uspesno sacuvana poruka
			//treba da je dodamo medju ostale i zatvorimo editor

			model.messages.addItem(message);

			model.isWritingMessage=false;
			model.messageText="";

			model.isSavingMessage=false;

			//povecavamo broj poruka za ovo pitanje
			model.question.discussionCount++;
			model.totalMessages++;
		}

		public function onLoadMessagesResult(event:ResultEvent):void
		{

			var result:XML=XML(event.result);

			model.isLoading=false;
			model.isAdministrator=result.attribute('is-administrator') == "true";
			model.currentPageIndex=result.attribute('current-page-index');
			model.totalPages=result.attribute('total-pages');
			model.pageSize=result.attribute('page-size');
			model.totalMessages=result.attribute('total-messages');

			model.messages=new XMLListCollection(result.child("question-message"));
			
			model.loadedQuestion = ModelParser.parseQuestion(result.child('question')[0], PresenterProvider.mainPresenter.model);
		}

		public function onDeleteMessageResult(event:ResultEvent):void
		{

			var index:int=model.messages.getItemIndex(model.deletedMessage);

			model.messages.removeItemAt(index);

			model.deletedMessage=null;

			model.question.discussionCount--;
			model.totalMessages--;
		}

		public function deleteMessageClicked(message:XML):void
		{

			model.deletedMessage=message;

			view.serviceDeleteMessage.send({questionMessageId: message.attribute('id')});
		}

		public function deleteMessageFaultFunction(event:FaultEvent):void
		{

			model.deletedMessage=null;

			EDTAlert.show("Poruka nije uspešno obrisana. Pokušaj ponovo.", event.toString());
		}

		public function saveMessageFaultFunction(event:FaultEvent):void
		{

			model.isSavingMessage=false;

			EDTAlert.show("Poruka nije uspešno sačuvana. Pokušaj ponovo.", event.toString());
		}

		public function loadMessagesFaultFunction(event:FaultEvent):void
		{

			model.isLoading=false;

			EDTAlert.show("Greška pri učitavanju diskusije i pitanju.", event.toString());
		}

		public function pageClicked(event:PageEvent):void
		{

			load(event.pageIndex);
		}

		public function positionAndSize():void
		{

			if (view && view.isPopUp)
			{

				var app:EvolaDrivingTesting=PresenterProvider.mainPresenter.view;

				var width:Number=app.width * 0.8;
				var height:Number=app.height * 0.9;

				view.width=width;
				view.height=height;

				PopUpManager.centerPopUp(view);
			}
		}

	}
}
