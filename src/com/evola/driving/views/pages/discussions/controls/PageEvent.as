package com.evola.driving.views.pages.discussions.controls
{
	import flash.events.Event;
	
	public class PageEvent extends Event
	{
		
		public static const PAGE_CLICK : String = "pageClick";
		
		public var pageIndex : int;
		
		public function PageEvent(type:String, pageIndex : int)
		{
			super(type, false, false);
			
			this.pageIndex = pageIndex;
		}
	}
}