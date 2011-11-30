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
	import com.gskinner.zoe.data.FrameData;
	import com.gskinner.zoe.data.IStateFormatter;
	import com.gskinner.zoe.data.JSONFormatter;
	import com.gskinner.zoe.events.CaptureEvent;
	import com.gskinner.zoe.model.FileModel;
	import com.maccherone.json.JSON;
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
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
		protected var bitmaps:Array;
		
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
		protected var _threshold:Number;
		
		/**
		 * @private
		 * 
		 */
		protected var boundsColorTint:uint = 0x0000FF;
		
		/**
		 * @private
		 * 
		 */
		protected var stage:Stage;
		
		/**
		 * @private
		 * 
		 */
		protected var findBoundsBmpd:BitmapData;
		
		/**
		 * @private
		 * 
		 */
		protected var findBoundsColorTransform:ColorTransform;
		
		/**
		 * @private
		 * 
		 */
		protected var rects:Vector.<Rectangle> 
		
		/**
		 * @private
		 * 
		 */
		protected var rectLookup:Dictionary;
		
		/**
		 * @private
		 * 
		 */
		protected var positions:Vector.<Point>;
		
		/**
		 * @private
		 * 
		 */
		protected var pointLookup:Dictionary;
		
		/**
		 * @private
		 * 
		 */
		protected var sheetWidth:Number;
		
		/**
		 * @private
		 * 
		 */
		protected var sheetHeight:Number;
		
		/**
		 * @private
		 * 
		 */
		protected var captureBounds:Array;
		
		/**
		 * @private
		 * 
		 */
		protected var hashFrames:Object= {};
		/**
		 * @private
		 * 
		 */
		protected var isComplex:Boolean = false;
		
		/**
		 * @private
		 * 
		 */
		protected var _displayPoint:Point;
		
		
		/**
		 * @private
		 * 
		 */
		protected var sheetData:Vector.<Object>;
	
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
		 * Returns the current swf's frame count.
		 * 
		 */
		public function get frameCount():Number {
			return fileModel.selectedItem.frameCount == 0?swf.totalFrames:fileModel.selectedItem.frameCount;
		}
		
		/**
		 * Sets Threshold level for comparing bitmaps.
		 * 
		 */
		public function set threshold(value:Number):void {
			_threshold = value;
		}
		
		/**
		 * Begins the frame by frame capture of the current swf.
		 * This operation is asynchronous, when capture is complete a complete event will be dispatched. 
		 *  
		 */
		public function capture():void {
			isComplex = false;
			sheetData = new Vector.<Object>();
			positions = null;
			pointLookup = null;
			
			dispatchEvent(new CaptureEvent(CaptureEvent.BEGIN));
			
			bitmaps = [];
			
			currentCaptureFrame = 0;
			startFrameRate = swf.stage.frameRate;
			swf.stage.frameRate = 60;
			swf.gotoAndPlay(0);
			
			captureBounds = [];
			
			var variableFrameDimensions:Boolean = fileModel.selectedItem.variableFrameDimensions;
			var reuseFrames:Boolean = fileModel.selectedItem.reuseFrames;
			
			if ((variableFrameDimensions && !reuseFrames) || (variableFrameDimensions && reuseFrames)) {
				captureVariableSizeFrames();
			} else {
				handleCaptureFrames(null);
				swf.addEventListener(Event.ENTER_FRAME, handleCaptureFrames, false, 0, true);
			}
		}
		
		protected function captureVariableSizeFrames():void {
			var bounds:Rectangle = swf.getBounds(swf);
			
			if (stage == null) { stage = swf.stage; }
			
			findBoundsBmpd = new BitmapData(stage.width, stage.height, true, 0xff000000);
			findBoundsColorTransform = new ColorTransform();
			findBoundsColorTransform.color = boundsColorTint;
			
			handleVariableCaptureFrames(null);
			swf.addEventListener(Event.ENTER_FRAME, handleVariableCaptureFrames, false, 0, true);
		}
		
		protected function handleVariableCaptureFrames(event:Event):void {
			findBoundsBmpd.draw(swf, null, findBoundsColorTransform);
			
			var frame:Rectangle = findBoundsBmpd.getColorBoundsRect(0xFFFFFF, boundsColorTint, false);
			captureBounds[currentCaptureFrame] = frame;

			var row:Number = currentCaptureFrame / columnCount | 0;
			var col:Number = currentCaptureFrame % columnCount | 0;
			
			var frameX:Number = (col * frame.width)-frame.width;
			var frameY:Number = row * frame.height;
			
			var mtx:Matrix = new Matrix();
			mtx.translate(frameX-frame.x, frameY-frame.y);
			
			var rect:Rectangle = new Rectangle(frame.x, frame.y, frame.width, frame.height);
			
			//Capture just one frame here, we peice it together at the end.
			var mtx2:Matrix = new Matrix();
			mtx2.translate(-rect.x, -rect.y);
			
			if (rect.width != 0) {
				var singleFrame:BitmapData = new BitmapData(rect.width, rect.height, true, 0xff0000);
				singleFrame.draw(swf, mtx2, null,null, new Rectangle(0,0, rect.width, rect.height),true);
				var label:String = (swf.currentLabel == null) ? 'all' : swf.currentLabel;
				bitmaps.push(new FrameData(singleFrame, currentCaptureFrame, label));
			} else {
				bitmaps.push(null);
			}
			
			findBoundsBmpd.fillRect(findBoundsBmpd.rect, 0xFFFFFF);
			
			currentCaptureFrame++;
			
			if (currentCaptureFrame == this.frameCount) {
				swf.stage.frameRate = startFrameRate;
				swf.removeEventListener(Event.ENTER_FRAME, handleVariableCaptureFrames);
				finishCapture();
			}
		}
		
		protected function createOutputFile():void {
			var fs:FileStream = new FileStream();
			var saveFile:File;
			
			saveFile = new File(fileModel.selectedItem.destinationPath + '/' + fileModel.selectedItem.name + '.png');
			
			//Its possible to get security errors here.
			try {
				fs.open(saveFile, FileMode.WRITE);
			} catch (e:Error) {
				dispatchEvent(new CaptureEvent(CaptureEvent.INVALID_PATH, false, false, 'Invalid path:\n' + saveFile.nativePath + '\n' + e.message));
				dispatchEvent(new Event(Event.COMPLETE));
				return;
			}
			
			if (saveFile.exists) {
				saveFile.deleteFile();
			}
			
			//fs.writeBytes(PNGEncoder.encode(captureBmpd));
			fs.close();
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/**
		 * Builds a Rectangle list so we can run it though a frame packing program 
		 * 
		 */
		protected function buildRectList():void {
			rects = new Vector.<Rectangle>();
			rectLookup = new Dictionary();
			
			var l:uint = captureBounds.length;
			for (var i:uint=0; i<l; i++) {
				var rect:Rectangle = captureBounds[i] as Rectangle;
				rect.x = Math.floor(rect.x);
				rect.y = Math.floor(rect.y);
				rect.width = Math.ceil(rect.width);
				rect.height = Math.ceil(rect.height);
				
				rects.push(rect);
				rectLookup[rect] = i;
			}
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
			var paddedBounds:Rectangle = frameBounds.clone();
			paddedBounds.inflate(fileModel.selectedItem.exportPadding, fileModel.selectedItem.exportPadding);
			return formatter.format(getStates(), paddedBounds.width, paddedBounds.height, registrationPoint, fileName, frameCount, sheetData, isComplex);
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
			var count:Number = 0;
			for (var i:uint=0;i<l;i++) {
				swf.gotoAndStop(i);
				
				var lbl:String = (swf.currentFrameLabel == null) ? 'all' : swf.currentFrameLabel;
				
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
				var framesObj:Object = hashFrames[lbl];
				states.push(new AnimationState(lbl, startIndex, endIndex, framesObj));
				
			}
			
			return states;
		}
		
		/**
		 * @private
		 * 
		 */
		
		public function updateRegistrationPoint(pt:Point):void {
			registrationPoint = pt;
		}
	
		/**
		 * @private
		 * 
		 */
		protected function findNextPower2(value:Number):Number {
			var pow:Number;
			for (;true;) {
				pow = Math.pow(2, Math.round(Math.log(value++) / Math.log(2)));
				if (pow >= value) {
					break;
				}
			}
			return  pow;
		}
		
		/**
		 * @private
		 * 
		 */
		protected function handleCaptureFrames(event:Event):void {
			var _frameBounds:Rectangle = fileModel.selectedItem.frameBounds;
			
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
			
			bitmaps.push(new FrameData(singleFrame,currentCaptureFrame, swf.currentLabel));
			
			captureBounds[currentCaptureFrame] = rect;
			
			if (++currentCaptureFrame == frameCount) {
				finishCapture();
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
			var point:Point;
			var matrix:Matrix;
			var captureBmd:BitmapData;
			var frameData:FrameData;
			
			//Reuse frames.
			//This will drop bitmaps, and update the bitmaps array.
			if (fileModel.selectedItem.reuseFrames && fileModel.selectedItem.threshold > 0) {
				compareBitmaps();
				isComplex = true;
				
				//Update our rects list for the packer code.
				l = bitmaps.length;
				rects = new Vector.<Rectangle>();
				rectLookup = new Dictionary();
				for (i=0;i<l;i++) {
					//If a frame is re-used the value will be an index of where to lookup the prev one.
					if (!(bitmaps[i] is Number)) {
						rect = (bitmaps[i] as FrameData).ref.rect;
						rects.push(rect);
						rectLookup[rect] = rects.length-1;
					}
				}
			} else {
				buildRectList();
			}
			
			//Pack it, if we need to.
			if (fileModel.selectedItem.variableFrameDimensions) {
				positionRects();
			}
			
			//Frames we will draw
			var bitmapList:Array = [];
			l = bitmaps.length;
			var realCount:int = -1;
			for (i=0;i<l;i++) {
				//If a frame is re-used the value will be an index of where to lookup the prev one.
				if (!(bitmaps[i] is Number)) {
					frameData = bitmaps[i];
					point = positions != null?positions[++realCount]:null;
					frameData.point = point;
					
					bitmapList.push(frameData);
				}
			}
			
			//If positions is empty, populate it 
			if (!positions) {
				//Build our normal un-packed rect list.
				var requestedWidth:Number = fileModel.selectedItem.bitmapWidth || 4096;
				var requestedHeight:Number = fileModel.selectedItem.bitmapHeight || 4096;
				
				var currX:Number = 0;
				var currY:Number = 0;
				
				l = bitmapList.length;
				positions = new Vector.<Point>(l);
				pointLookup = new Dictionary();
				
				sheetWidth = 0;
				sheetHeight = 0;
				
				for(i=0;i<l;i++) {
					frameData = bitmapList[i];
					var bmpd:BitmapData = frameData.ref;
					rect = bmpd.rect;
					
					var frameX:Number = currX;
					var frameY:Number = currY;
					
					var pt:Point = new Point(frameX, frameY);
					frameData.point = pt;
					positions.push(pt);
					pointLookup[pt] = rect;
					
					sheetWidth = Math.max(sheetWidth, currX + rect.width);
					sheetHeight = Math.max(sheetHeight, currY + rect.height);
					
					currX += rect.width;
					if (currX + rect.width > requestedWidth) {
						currY += rect.height;
						currX = 0;
					}
				}
			}
			
			//Create export bitmap(s) ... if needed
			var exportSheet:BitmapData = new BitmapData(sheetWidth, sheetHeight, true, 0xffffff);
			
			l = bitmapList.length;
			for (i=0;i<l;i++) {
				frameData = bitmapList[i];
				bmpd = frameData.ref;
				point = frameData.point;
				
				matrix = new Matrix();
				matrix.translate(point.x, point.y);
				
				rect = new Rectangle(point.x, point.y, bmpd.width, bmpd.height);
				
				exportSheet.draw(bmpd, matrix, null, null, rect, true);
			}
			
			saveImage(fileModel.selectedItem.destinationPath + '/'+fileModel.selectedItem.name + '.png', exportSheet);
			
			isComplex = fileModel.selectedItem.variableFrameDimensions || fileModel.selectedItem.reuseFrames
			
			//Export other data
			if (fileModel.selectedItem.exportFrames) {
				for (i=0;i<l;i++) {
					frameData = (bitmaps[i] is Number)?bitmaps[bitmaps[i]]:bitmaps[i];
					var bitmap:BitmapData = frameData.ref;
					var saved:Boolean = saveImage(fileModel.selectedItem.destinationPath+'/'+fileModel.selectedItem.name+'_frame_'+i+'.png', bitmap);
					//An error happened during export ... user already has been notifyes, so ignore and move on.
					if (!saved) { return; }
				}
			}
			
			if (fileModel.selectedItem.exportJSON) {
				var json:String;
				
				if (!isComplex) {
					json = createData(new JSONFormatter(), fileModel.selectedItem.name+'.png')
				} else {
					json = buildJSON();
				}
				
				saveFile = new File(fileModel.selectedItem.destinationPath + '/'+fileModel.selectedItem.name + '.json');
				fs.open(saveFile, FileMode.WRITE);
				fs.writeUTFBytes(json);
				fs.close();
			}
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/**
		 * @private
		 * 
		 */
		protected function buildJSON():String {
			var l:uint;
			var i:uint;
			var frameData:FrameData;
			var rect:Rectangle;
			var point:Point;
			
			//Build the frames array.
			var frames:Array = [];
			l = bitmaps.length;
			for (i=0;i<l;i++) {
				var tempData:Object = bitmaps[i];
				if (!(tempData is Number)) {
					frameData = bitmaps[i];
					rect = pointLookup[frameData.point];
					point = frameData.point;
					
					//Frame format: [x,y,w,h,index,regX,regY]
					var ox:Number = 0;
					var oy:Number = 0;
					
					if (fileModel.selectedItem.variableFrameDimensions) {
						ox = -rect.x+fileModel.selectedItem.displayPt.x;
						oy = -rect.y+fileModel.selectedItem.displayPt.y;
					} else {
						ox = fileModel.selectedItem.registrationPt.x;
						oy = fileModel.selectedItem.registrationPt.y;
					}
					frames.push([point.x, point.y,rect.width, rect.height,0,ox,oy]);
				}
			}
			
			//Build labels out
			var animations:Object = {};
			var states:Vector.<AnimationState> = getStates();
			l = states.length;
			for (i=0;i<l;i++) {
				var state:AnimationState = states[i];
				animations[state.name] = {frames:getFramesForRange(state.startFrame, state.endFrame)};
			}
			
			var jsonData:Object = {}
			jsonData.frames = frames;
			jsonData.animations = animations;
			jsonData.images = [fileModel.selectedItem.name + '.png'];
			
			var jsonString:String = com.maccherone.json.JSON.encode(jsonData, true, 500);
			
			return jsonString;
		}
		
		/**
		 * @private
		 * 
		 */
		protected function getFramesForRange(start:uint, end:uint):Array {
			var frames:Array = [];
			
			var frameData:FrameData;
			var actualIndex:uint = start;
			var tempCount:uint = actualIndex;
			
			if (tempCount > 0) {
				while (tempCount--) {
					if (bitmaps[tempCount] is Number) {
						actualIndex--;
					}
				}
			}
			
			for (var i:uint=start;i<end;i++) {
				var data:Object = bitmaps[i];
				
				if (data is Number) { actualIndex--; continue; }
				
				frameData = data as FrameData;
				
				var count:uint = frameData.count;
				while (count--) {
					frames.push(actualIndex);
				}
				
				actualIndex++;
			}
			
			return frames;
		}
		
		/**
		 * @private
		 * 
		 */
		protected function saveImage(path:String, bmdd:BitmapData):Boolean {
			var saveFile:File = new File(path);
			var fs:FileStream = new FileStream();
			
			try {
				fs.open(saveFile, FileMode.WRITE);
			} catch (e:Error) {
				dispatchEvent(new CaptureEvent(CaptureEvent.INVALID_PATH, false, false, 'Invalid path:\n' + saveFile.nativePath + '\n' + e.message));
				dispatchEvent(new Event(Event.COMPLETE));
				return false;
			}
			
			fs.writeBytes(PNGEncoder.encode(bmdd));
			fs.close();
			return true;
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
		
		/**
		 * @private
		 * 
		 */
		protected function compareBitmaps():void {
			for (var i:Number=0; i<bitmaps.length; i++) {
				if (bitmaps[i] is Number) { continue; }
				
				var bmpd:BitmapData = bitmaps[i].ref as BitmapData;
				compare(bmpd, i+1);
			} 
		}
		
		/**
		 * @private
		 * 
		 */
		protected function compare(item:BitmapData, startIndex:uint):void {
			var l:uint = bitmaps.length;
			var bc:BitmapCompare = new BitmapCompare(20);
			bc.threshold = _threshold;
			
			for (var i:Number=startIndex; i<l; i++) {
				if (bitmaps[i] is Number) { continue; }
				
				var searchBmp:BitmapData = (bitmaps[i] as FrameData).ref as BitmapData;
				var diff:Boolean = bc.different(item,searchBmp,i);
				
				//Flag this to be re-used
				if (!diff && !(bitmaps[i] is Number)) {
					bitmaps[i] = startIndex-1;
					(bitmaps[bitmaps[i]] as FrameData).count++;
				}
			}
		}
		
		/**
		 * @private
		 * 
		 */
		protected function rectSort(rect1:Rectangle,rect2:Rectangle):Number {
			return rect1.height-rect2.height;
		}
		
		/**
		 * @private
		 * 
		 */
		protected function positionRects():void {
			//Sort them first
			rects.sort(rectSort);
			
			var l:uint = rects.length;
			positions = new Vector.<Point>(l);
			pointLookup = new Dictionary();
			
			var ttlW:Number = 0;
			var ttlH:Number = 0;
			for (var i:uint=0; i<l; i++) {
				var rect:Rectangle = rects[i];
				ttlW += rect.width;
				ttlH += rect.height;
			}
			
			var w:Number = ttlW / Math.sqrt(l) * 3;
			var h:Number = rects[l - 1].height;
			var maxW:Number = 0;
			var maxH:Number = 0;
			var ry:Number = 0;
			var rx:Number = 0;
			
			while (rects.length) {
				rect = rects.pop();
				if (rx+rect.width > w) {
					// see if we can fit anything else in:
					var j:int = rects.length - 1;
					while (j-- > 0) {
						var rect2:Rectangle = rects[j];
						if (rx+rect2.width <= w) {
							// this fits.
							positions[rectLookup[rect2]] = new Point(rx,ry);
							rx += rect2.width;
							rects.splice(j,1);
						}
					}
					
					if (rx > maxW) {
						maxW = rx;
					}
					
					rx = 0;
					ry +=  h;
					h = rect.height;
					if (ry+h > maxH) {
						maxH = ry + h;
					}
				}
				
				var p:Point = new Point(rx,ry);
				positions[rectLookup[rect]] = p;
				pointLookup[p] = rect;
				rx += rect.width;
			}
			
			sheetWidth = maxW;
			sheetHeight = maxH;
		}
	}
}