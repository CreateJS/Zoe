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
	
	import com.adobe.images.PNGEncoder;
	import com.gskinner.zoe.data.AnimationState;
	import com.gskinner.zoe.data.EaselFormatter;
	import com.gskinner.zoe.data.IStateFormatter;
	import com.gskinner.zoe.data.JSONFormatter;
	import com.gskinner.zoe.events.CaptureEvent;
	import com.gskinner.zoe.model.FileModel;
	import com.gskinner.zoe.views.ExportDialog;
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.UncaughtErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * Utility class used to capture each frame of the loaded swf.
	 * Also reads timeline information from the file, used for building a EaselJS BitmapSequence object
	 * 
	 */
	public class CaptureSWF extends EventDispatcher  {
		
		/**
		 * @private
		 * 
		 */
		protected var bitmaps:Vector.<BitmapData>;
		
		/**
		 * @private
		 * 
		 */
		protected var currentCaptureFrame:uint;
		
		/**
		 * @private
		 * 
		 */
		protected var registrationPoint:Point;
		
		/**
		 * @private
		 * 
		 */
		protected var swf:MovieClip;
		
		/**
		 * @private
		 * 
		 */
		protected var columnCount:uint;
		
		/**
		 * @private
		 * 
		 */
		protected var captureBmpd:BitmapData;
		
		/**
		 * @private
		 * 
		 */
		protected var captureData:Array;
		
		/**
		 * @private
		 * 
		 */
		protected var startFrameRate:uint;
		
		/**
		 * @private
		 * 
		 */
		protected var fileModel:FileModel;
		
		/**
		 * @private
		 * 
		 */
		protected var timeline:Vector.<uint>;
		
		/**
		 * Created a new CaptureSwf instance.
		 * We use an enter frame to capture individual frames, 
		 * they are drawn to individual bitmap objects, then on export 
		 * those objects are stitched together to make a sprite sheet.
		 * 
		 * @param model The Model to pull the swf data from.
		 * 
		 */
		public function CaptureSWF(model:FileModel) {
			super();
			
			fileModel = model;
			timeline = new Vector.<uint>();
			bitmaps = new Vector.<BitmapData>();
		}
		
		/**
		 * Sets a new swf and registrationPoint.
		 * 
		 */
		public function updateSWF(swf:MovieClip, registrationPoint:Point = null):void {
			this.registrationPoint = registrationPoint;
			this.swf = swf;
		}
		
		/**
		 * Returns a Vector of BitmapData objects, for use in export.
		 * 
		 */
		public function get frames():Vector.<BitmapData> {
			return bitmaps;
		}
		
		/**
		 * Returns the current swf's frame count.
		 * 
		 */
		public function get frameCount():Number {
			return fileModel.selectedItem.frameCount == 0?swf.totalFrames:fileModel.selectedItem.frameCount;
		}
		
		/**
		 * Begins the frame by frame capture of the current swf.
		 * This operation is asynchronous, when capture is complete a complete event will be dispatched. 
		 *  
		 */
		public function capture():void {
			if (!createExportBitmap(frameCount)) {
				return;
			}
			
			dispatchEvent(new CaptureEvent(CaptureEvent.BEGIN));
			
			timeline = new Vector.<uint>();
			bitmaps = new Vector.<BitmapData>();
			
			currentCaptureFrame = 0;
			startFrameRate = swf.stage.frameRate;
			swf.stage.frameRate = 60;
			swf.gotoAndPlay(0);
			
			handleCaptureFrames(null);
			swf.addEventListener(Event.ENTER_FRAME, handleCaptureFrames, false, 0, true);
		}
		
		/**
		 * Reads the timeline information from the loaded swf, and returns a formatted value.
		 * 
		 * @param formatter The formatter to use when exporting data.
		 * Currently you can use EaselFormatter or JSONFormatter
		 * @see com.gskinner.zoe.data.EaselFormatter
		 * @see com.gskinner.zoe.data.JSONFormatter
		 * 
		 * @param fileName The file name of the swf, used to create correct stub code for image loading.
		 * 
		 */
		public function createData(formatter:IStateFormatter, fileName:String):String {
			var frameBounds:Rectangle = fileModel.selectedItem.frameBounds;
			return formatter.format(getStates(), frameBounds.width, frameBounds.height, registrationPoint, fileName);
		}
		
		/**
		 * Returns a Vector of AnimationState's object.
		 * Each animation state is defined by using frame labels in the swf.
		 * Use in the main UI so we can play each sequence.
		 * 
		 */
		public function getStates():Vector.<AnimationState> {
			var states:Vector.<AnimationState> = new Vector.<AnimationState>();
			var l:uint = frameCount;
			var stateHash:Object = {};
			
			for (var i:uint=0;i<l;i++) {
				swf.gotoAndStop(i);
				
				var lbl:String = swf.currentFrameLabel;
				if (lbl == null || stateHash[lbl] != null) { continue; }
				
				var startIndex:uint;
				var endIndex:uint;
				
				//Check to see if the next frame has a label
				//Theres a weird bug with frame 0 and 1 returning the same label, so try frame 2, if its actually 0
				swf.gotoAndStop(i==0?2:i+1);
				var nextLabel:String = swf.currentFrameLabel;
				if (nextLabel != null) {
					endIndex = startIndex = Math.max(0, i-1);
				} else {
					endIndex = findEndIndex(i+1, lbl);
					startIndex = Math.max(0, i-1);
					i = endIndex+1;
				}
				
				stateHash[lbl] = true; 
				states.push(new AnimationState(lbl, startIndex, endIndex));
			}
			return states;
		}
		
		/**
		 * @private
		 * 
		 */
		protected function createExportBitmap(numFrames:int):Boolean {
			if (captureBmpd) {
				captureBmpd.dispose();
			}
			var frameBounds:Rectangle = fileModel.selectedItem.frameBounds;
			
			var requestedWidth:Number = numFrames*frameBounds.width;
			var requestedHeight:Number = frameBounds.height;
			
			var bitmapWidth:Number = fileModel.selectedItem.bitmapWidth || 4095;
			var bitmapHeight:Number = fileModel.selectedItem.bitmapHeight || 4095;

			var rows:uint = Math.ceil(requestedHeight%bitmapHeight);
			
			if (requestedWidth > bitmapWidth) {
				requestedWidth = bitmapWidth;
				columnCount = requestedWidth / frameBounds.width|0;
				columnCount--; //Offset by one, or edge might get messed up.
			} else {
				columnCount = numFrames;
			}
			
			var rowsToDraw:Number = Math.ceil(numFrames/columnCount);
			
			requestedWidth = columnCount*frameBounds.width;
			requestedHeight = rowsToDraw*frameBounds.height;
			
			if (requestedWidth > bitmapWidth || requestedHeight > bitmapHeight) {
				var message:String = 'Bitmap will be invalid!\nProposed width: '+requestedWidth + '\nProposed Height:'+requestedHeight;
				dispatchEvent(new CaptureEvent(CaptureEvent.INVALID_BITMAP, false, false, message));
				return false;
			}
			
			captureBmpd = new BitmapData(requestedWidth, requestedHeight, true, 0x00000000);
			return true;
		}
		
		/**
		 * @private
		 * 
		 */
		protected function handleCaptureFrames(event:Event):void {
			var _frameBounds:Rectangle = fileModel.selectedItem.frameBounds;
			
			timeline.push(currentCaptureFrame++);
			
			var row:Number = currentCaptureFrame / columnCount | 0;
			var col:Number = currentCaptureFrame % columnCount | 0;
			
			var frameX:Number = (col * _frameBounds.width)-_frameBounds.width;
			var frameY:Number = row * _frameBounds.height;
			
			var mtx:Matrix = new Matrix();
			mtx.translate(frameX-_frameBounds.x, frameY-_frameBounds.y);
			var rect:Rectangle = new Rectangle(frameX, frameY, _frameBounds.width, _frameBounds.height);
			
			//Capture just one frame here, we peice it together at the end.
			var mtx2:Matrix = new Matrix();
			mtx2.translate(-_frameBounds.x, -_frameBounds.y);
			var singleFrame:BitmapData = new BitmapData(_frameBounds.width, _frameBounds.height, true, 0xff0000);
			singleFrame.draw(swf, mtx2, null,null, new Rectangle(0,0, _frameBounds.width, _frameBounds.height),true);
			bitmaps.push(singleFrame);
			
			if (currentCaptureFrame == frameCount) {
				finishCapture()
			}
		}
		
		/**
		 * @private
		 * 
		 */
		protected function finishCapture():void {
			swf.removeEventListener(Event.ENTER_FRAME, handleCaptureFrames);
			swf.stage.frameRate = startFrameRate;
			
			var fs:FileStream = new FileStream();
			var saveFile:File;
			
			var i:uint;
			var l:uint;
			var rect:Rectangle;
			
			//Draw frames to a single bitmap.
			//Generate bitmapData using the total # of frames we have.
			//Export bitmap
			var _frameBounds:Rectangle = fileModel.selectedItem.frameBounds;
			
			l = bitmaps.length;
			
			if (fileModel.selectedItem.exportSheet) {
				createExportBitmap(l);
				for (i=0;i<l;i++) {
					var bitmap:BitmapData = bitmaps[i];
					
					var row:Number = i / columnCount | 0;
					var col:Number = i % columnCount | 0;
					
					var frameX:Number = col * _frameBounds.width;
					var frameY:Number = row * _frameBounds.height;
					
					var mtx:Matrix = new Matrix();
					mtx.translate(frameX, frameY);
					rect = new Rectangle(frameX, frameY, _frameBounds.width, _frameBounds.height);
					captureBmpd.draw(bitmap, mtx, null, null, rect, true);
				}
				
				saveFile = new File(fileModel.selectedItem.destinationPath + '/'+fileModel.selectedItem.name + '.png');
				fs.open(saveFile, FileMode.WRITE);
				fs.writeBytes(PNGEncoder.encode(captureBmpd));
				fs.close();
			}
			
			//Export frames
			if (fileModel.selectedItem.exportFrames) {
				for (i=0;i<l;i++) {
					bitmap = bitmaps[i];
					saveFile = new File(fileModel.selectedItem.destinationPath+'/'+fileModel.selectedItem.name+'_frame_'+i+'.png');
					fs.open(saveFile, FileMode.WRITE);
					fs.writeBytes(PNGEncoder.encode(bitmap));
					fs.close();
				}
			}
			
			if (fileModel.selectedItem.exportEasel) {
				saveFile = new File(fileModel.selectedItem.destinationPath + '/'+fileModel.selectedItem.name + '.js');
				fs.open(saveFile, FileMode.WRITE);
				fs.writeUTFBytes(createData(new EaselFormatter(), fileModel.selectedItem.name+'.png'));
				fs.close();
			}
			
			if (fileModel.selectedItem.exportJSON) {
				saveFile = new File(fileModel.selectedItem.destinationPath + '/'+fileModel.selectedItem.name + '.json');
				fs.open(saveFile, FileMode.WRITE);
				fs.writeUTFBytes(createData(new JSONFormatter(), fileModel.selectedItem.name+'.png'));
				fs.close();
			}
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/**
		 * @private
		 * 
		 */
		protected function findEndIndex(startIndex:int, lastLabel:String):uint {
			var index:Number = NaN;
			var l:uint = frameCount;
			out:for (var i:uint=startIndex;i<l;i++) {
				swf.gotoAndStop(i);
				var lbl:String = swf.currentFrameLabel;
				if (lbl == null || lastLabel == lbl) { continue; }
				if (lbl != null) {
					var frameIndex:int = i;
					while (frameIndex--) {
						swf.gotoAndStop(frameIndex);
						if (swf.numChildren != 0) {
							//found frame
							index = frameIndex;
							break out;
						}
					}
				}
			}
			
			if (swf.currentFrame == frameCount-1) {
				return frameCount-1;
			} else if (isNaN(index)) {
				return startIndex;
			} else {
				return index-1;
			}
		}
		
	}
}