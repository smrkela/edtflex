package com.evola.driving.views.pages.discussions
{
	import mx.collections.XMLListCollection;

	[Bindable]
	public class DiscussionsModel
	{
		public var totalMessages:int;
		
		public var searchText:String;
		
		public var pageSize : int;
		
		public var mode : String; //my | all
		
		public var myDiscussionsStartPageIndex : int;
		public var allDiscussionsStartPageIndex : int;
		
		public var allDiscussionMessages:XMLListCollection;
		public var myDiscussionMessages:XMLListCollection;
		
		public var myDiscussionsTotalPages : int;
		public var allDiscussionsTotalPages : int;
		
		public var currentLoadingIndex : int;
		
		public function DiscussionsModel()
		{
		}
	}
}