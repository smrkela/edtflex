package com.evola.driving.views.pages.discussions
{
	import com.evola.driving.controls.EDTAlert;
	import com.evola.driving.controls.questiondiscuss.QuestionDiscussPopup;
	import com.evola.driving.controls.spinner.SpinnerUtil;
	import com.evola.driving.model.Question;
	import com.evola.driving.views.pages.discussions.controls.PageEvent;
	
	import mx.collections.XMLListCollection;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;

	[Bindable]
	public class DiscussionsPresenter
	{

		public var model:DiscussionsModel=new DiscussionsModel();
		public var view:DiscussionsPage;

		public function DiscussionsPresenter()
		{
		}

		public function initialize():void
		{

			if (!model.mode)
				model.mode="my";

			load();
		}

		private function load():void
		{

			SpinnerUtil.showSpinner(view);
			
			if (model.mode == "my")
			{

				model.myDiscussionMessages=new XMLListCollection();
				view.serviceLoadMyDiscussions.send({startPage: model.currentLoadingIndex, searchText: model.searchText});
			}
			else
			{

				model.allDiscussionMessages=new XMLListCollection();
				view.serviceLoadAllDiscussions.send({startPage: model.currentLoadingIndex, searchText: model.searchText});
			}
		}

		public function onMyDiscussionsLoaded(event:ResultEvent):void
		{
			
			SpinnerUtil.removeSpinner(view);

			var result:XML=XML(event.result);

			model.myDiscussionsTotalPages=result.attribute('total-pages');
			model.pageSize = result.attribute('page-size');
			model.myDiscussionsStartPageIndex=model.currentLoadingIndex;
			model.totalMessages = result.attribute('total-messages');
			
			model.myDiscussionMessages=new XMLListCollection(result.child('question-message'));
		}

		public function onAllDiscussionsLoaded(event:ResultEvent):void
		{
			
			SpinnerUtil.removeSpinner(view);

			var result:XML=XML(event.result);

			model.allDiscussionsTotalPages=result.attribute('total-pages');
			model.pageSize = result.attribute('page-size');
			model.allDiscussionsStartPageIndex=model.currentLoadingIndex;
			model.totalMessages = result.attribute('total-messages');
			
			model.allDiscussionMessages=new XMLListCollection(result.child('question-message'));
		}

		public function messageClicked(message:XML):void
		{

			var question:Question=new Question();
			question.id=message.attribute('question-id');
			question.text=message.attribute('question-text');

			QuestionDiscussPopup.init(question, true);
		}

		public function pageChangeClicked(event:PageEvent):void
		{

			var index:int=event.pageIndex;
			var currentIndex:int;

			if (model.mode == "my")
				currentIndex=model.myDiscussionsStartPageIndex;
			else
				currentIndex=model.allDiscussionsStartPageIndex;

			if (index != currentIndex)
			{

				model.currentLoadingIndex=index;
				load();
			}
		}

		public function linkClicked(index : int):void
		{

			if(index == 0){
			
				model.mode="my";
				model.currentLoadingIndex = model.myDiscussionsStartPageIndex;
			}
			else{
				
				model.mode = "all";
				model.currentLoadingIndex = model.allDiscussionsStartPageIndex;
			}
						
			load();
		}
		
		public function refresh():void
		{

			load();
		}
		
		public function searchClicked(searchText : String):void
		{

			model.searchText = searchText;
			
			load();
		}
		
		public function resetSearchClicked():void
		{

			model.searchText = null;
			
			load();
		}
		
		public function onFault(event:FaultEvent):void
		{

			SpinnerUtil.removeSpinner(view);
			
			EDTAlert.show("Greška :(. Pokušaj ponovo ili osveži stranicu u svom pregledaču.", event.toString());
		}
	}
}
