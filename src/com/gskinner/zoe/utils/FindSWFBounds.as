/*
* Zoë by gskinner.com.
* Visit www.gskinner.com/blog for documentation, updates and more free code.
*
* Copyright (c) 2010 Grant Skinner
* 
* Permission is hereby granted, free of charge, to any person
* obtaining a copy of this software and associated documentation
* files (the "Software"), to deal in the Software without
* restriction, including without limitation the rights to use,
* copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the
* Software is furnished to do so, subject to the following
* conditions:
* 
* The above copyright notice and this permission notice shall be
* included in all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
* OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
* NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
* HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
* OTHER DEALINGS IN THE SOFTWARE.
*/

package com.gskinner.zoe.utils {
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	
	/**
	 * To accommodate nested animations, we can't relay on .getBounds();
	 * Instead the swf's frames are written to a BitmapData, then using getColorBoundsRect();
	 * we can get pixel perfect bounds, and everything thats visible on screen.
	 * 
	 */
	public class FindSWFBounds extends EventDispatcher {
		
		/**
		 * @private
		 */
		protected var findBoundsBmpd:BitmapData;
		
		/**
		 * @private
		 */
		protected var boundsColorTint:uint = 0x0000FF;
		
		/**
		 * @private
		 */
		protected var findBoundsColorTransform:ColorTransform;
		
		/**
		 * @private
		 */
		protected var swf:MovieClip;
		
		/**
		 * @private
		 */
		protected var startFrameRate:uint;
		
		/**
		 * @private
		 */
		protected var _bounds:Rectangle;
		
		/**
		 * @private
		 */
		protected var _frameCount:uint;
		
		/**
		 * @private
		 */
		protected var count:uint;
		
		/**
		 * @private
		 */
		protected var stage:Stage;
		
		/**
		 * Creates a new FindSWFBouds object
		 * @param swf The target clip to find bounds on.
		 * @param frameCount If this is a programmatic animation or one frame animation, set the number of frames to capture.
		 * 
		 */
		public function FindSWFBounds(swf:MovieClip, frameCount:uint) {
			this.swf = swf;
			this._frameCount = isNaN(frameCount) || frameCount==0?swf.totalFrames:frameCount;
		}
		
		/**
		 * Listens on ENTER_FRAME to capture each frame of a the target movie clip.
		 * 
		 */
		public function findBounds():void {
			var bounds:Rectangle = swf.getBounds(swf);
			
			if (stage == null) {
				stage = swf.stage;
			}
			
			findBoundsBmpd = new BitmapData(stage.width, stage.height, true, 0xff000000);
			
			/*
			//For debugging, display capture on screen.
			var b:Bitmap = new  Bitmap(findBoundsBmpd);
			FlexGlobals.topLevelApplication.stage.addChild(b);
			//*/
			
			findBoundsColorTransform = new ColorTransform();
			findBoundsColorTransform.color = boundsColorTint;
			
			swf.gotoAndPlay(0);
			
			count = 0;
			
			startFrameRate = stage.frameRate;
			stage.frameRate = 60;
			handleFindBounds(null);
			
			if (_frameCount > 1) {
				swf.addEventListener(Event.ENTER_FRAME, handleFindBounds, false, 0, false);
			}
		}
		
		/**
		 * Returns the bounds found by this class.
		 * You need to call findBounds(); first.
		 * 
		 */
		public function get bounds():Rectangle {
			if (_bounds == null) {
				throw new new IllegalOperationError('No bounds found, call findBounds() first.');
			}
			return _bounds;
		}
		
		/**
		 * @private
		 * 
		 */
		protected function handleFindBounds(event:Event):void {
			findBoundsBmpd.draw(swf, null, findBoundsColorTransform);
			if (_frameCount == ++count) {
				stage.frameRate = startFrameRate;
				swf.removeEventListener(Event.ENTER_FRAME, handleFindBounds);
				
				_bounds = findBoundsBmpd.getColorBoundsRect(0xFFFFFF, boundsColorTint, false);
				
				findBoundsBmpd.dispose();
				
				dispatchEvent(new Event(Event.COMPLETE));
			}
		}
	}
}