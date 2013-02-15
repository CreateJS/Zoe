package com.gskinner.zoe.events {
	
	import flash.events.Event;
	
	public class ResultEvent extends Event {

		public static const COMPLETE:String = Event.COMPLETE;
		
		public var data:Object;
		
		public function ResultEvent(type:String, data:Object) {
			this.data = data;
			
			super(type);
		}
		
		override public function clone():Event {
			return new ResultEvent(type, data);
		}
		
	}
	
}