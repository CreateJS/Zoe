package com.gskinner.zoe.events {
	
	import flash.events.Event;
	
	public class PreviewPanelEvent extends Event {
		
		public static const COLOR_CHANGED:String = 'colorChanged';
		public static const COLOR_OPEN:String = 'colorOpen';
		public static const COLOR_MOVE:String = 'colorMove';
		public static const PLAY_CLICKED:String = 'playClicked';
		public static const FREQUENCY_RATE_CHANGED:String = 'frequencyRateChanged';
		public static const UPDATE_FRAME_POSITION:String = 'updateFramePosition';
		public static const CHANGE_END_FRAME_POSITION:String = 'changeEndFramePosition';
		public static const CHANGE_START_FRAME_POSITION:String = 'changeStartFramePosition'; 
		public static const UPDATE_SLIDER_POSITION:String = 'updateSliderPosition';
		
		public function PreviewPanelEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
	}
}