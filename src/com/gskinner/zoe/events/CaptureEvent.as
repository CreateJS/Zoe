package com.gskinner.zoe.events {
	
	import flash.events.Event;
	
	public class CaptureEvent extends Event {
		
		public static const BEGIN:String = "begin";
		public static const INVALID_BITMAP:String = "invalidBitmap";
		public static const INVALID_PATH:String = "invalidPath";
		public static const SWF_INIT:String = "swfInit";
		public static const REG_PT_CHANGE:String = "regPtChange";
		public static const VAR_HEIGHT_COMPLETE:String = "varHeightComplete";
		
		public var message:String;
		public var data:Object;
		
		public function CaptureEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, message:String = null, data:Object = null) {
			super(type, bubbles, cancelable);
			this.data = data;
			this.message =  message;
		}
		
		override public function clone():Event {
			return new CaptureEvent(type, bubbles, cancelable, message);
		}
	}
}