package com.gskinner.zoe.events {
	
	import flash.events.Event;
	
	public class CaptureEvent extends Event {
		
		public static const BEGIN:String = "begin";
		public static const INVALID_BITMAP:String = "invalidBitmap";
		public static const SWF_INIT:String = "swfInit";
		
		public var message:String;
		
		public function CaptureEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, message:String = null) {
			super(type, bubbles, cancelable);
			
			this.message =  message;
		}
		
		override public function clone():Event {
			return new CaptureEvent(type, bubbles, cancelable, message);
		}
	}
}