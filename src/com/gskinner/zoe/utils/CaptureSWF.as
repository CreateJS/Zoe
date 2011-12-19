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
	import com.gskinner.zoe.data.ExportType;
	import com.gskinner.zoe.data.FrameData;
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
		public var exportedImageNames:Array;
		
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
			
			findBoundsColorTransform = new ColorTransform();
			findBoundsColorTransform.color = boundsColorTint;
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
		
		public function createSizeBitmap(stage):void {
			findBoundsBmpd = new BitmapData(stage.width, stage.height, true, 0xff000000);
		}
		
		protected function captureVariableSizeFrames():void {
			var bounds:Rectangle = swf.getBounds(swf);
			
			if (stage == null) { stage = swf.stage; }
			
			handleVariableCaptureFrames(null);
			swf.addEventListener(Event.ENTER_FRAME, handleVariableCaptureFrames, false, 0, true);
		}
		
		public function getCurrentFrameBounds():Rectangle {
			findBoundsBmpd.draw(swf, null, findBoundsColorTransform);
			var frame:Rectangle = findBoundsBmpd.getColorBoundsRect(0xFFFFFF, boundsColorTint, false);
			findBoundsBmpd.fillRect(findBoundsBmpd.rect, 0xFFFFFF);
			return frame;
		}
		
		protected function handleVariableCaptureFrames(event:Event):void {
			var frame:Rectangle = getCurrentFrameBounds();
			frame.inflate(fileModel.selectedItem.exportPadding, fileModel.selectedItem.exportPadding);
			captureBounds[currentCaptureFrame] = frame;

			var row:Number = currentCaptureFrame / columnCount | 0;
			var col:Number = currentCaptureFrame % columnCount | 0;
			
			var frameX:Number = (col * frame.width)-frame.width;
			var frameY:Number = row * frame.height;
			
			var mtx:Matrix = new Matrix();
			mtx.translate(frameX-frame.x, frameY-frame.y);
			
			var rect:Rectangle = new Rectangle(frame.x, frame.y, frame.width, frame.height);

			if (rect.width == 0) {
				rect = new Rectangle(frame.x, frame.y, 1,1); 
			}
			
			//Capture just one frame here, we peice it together at the end.
			var mtx2:Matrix = new Matrix();
			mtx2.translate(-rect.x, -rect.y);
			
			var singleFrame:BitmapData = new BitmapData(rect.width, rect.height, true, 0xff0000);
			singleFrame.draw(swf, mtx2, null,null, new Rectangle(0,0, rect.width, rect.height),true);
			var label:String = (swf.currentLabel == null) ? 'all' : swf.currentLabel;
			bitmaps.push(new FrameData(singleFrame, currentCaptureFrame, label));
			
			currentCaptureFrame++;
			
			if (currentCaptureFrame == this.frameCount) {
				swf.stage.frameRate = startFrameRate;
				swf.removeEventListener(Event.ENTER_FRAME, handleVariableCaptureFrames);
				finishCapture();
			}
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
		protected function findNextPower2(value:Number):int {
			var pow:int;
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
			
			var exportBitmaps:Array = [];
			var requestedWidth:Number = fileModel.selectedItem.bitmapWidth;
			var requestedHeight:Number = fileModel.selectedItem.bitmapHeight;
			
			exportedImageNames = [];
			
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
				positionRects(requestedWidth);
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
					
					var pt:Point = new Point(currX, currY);
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
			if (fileModel.selectedItem.imageExportType == ExportType.IMAGE_SPRITE_SHEET) {
				var exportSheet:BitmapData = new BitmapData(requestedWidth, requestedHeight, true, 0xffffff);
				var currentBitmapData:Object = {bmpd:exportSheet, w:0, h:0};
				exportBitmaps.push(currentBitmapData);
				
				var pointYOffset:Number = 0;
				
				var drawBitmaps:Array = bitmapList.slice();
				drawBitmaps.sort(sortBitmaps);
				
				l = drawBitmaps.length;
				for (i=0;i<l;i++) {
					frameData = drawBitmaps[i];
					bmpd = frameData.ref;
					point = frameData.point;
					var startPointY:Number = point.y;
					point.y = point.y - pointYOffset;
					
					if (point.y + bmpd.height > requestedHeight) {
						exportSheet = new BitmapData(requestedWidth, requestedHeight, true, 0xffffff);
						currentBitmapData = {bmpd:exportSheet, w:0, h:0};
						exportBitmaps.push(currentBitmapData);
						pointYOffset += requestedHeight;
						point.y = startPointY - pointYOffset;
					}
					
					if (point.y < 0) {
						pointYOffset += point.y;
						point.y = 0;
					}
					
					frameData.sheetIndex = exportBitmaps.length-1;
					
					matrix = new Matrix();
					matrix.translate(point.x, point.y);
					
					rect = new Rectangle(point.x, point.y, bmpd.width, bmpd.height);
					
					currentBitmapData.w = Math.max(currentBitmapData.w, point.x + rect.width);
					currentBitmapData.h = Math.max(currentBitmapData.h, point.y + rect.height);
					
					exportSheet.draw(bmpd, matrix, null, null, rect, true);
				}
				
				l = exportBitmaps.length;
				for (i=0;i<l;i++) {
					var fileName:String = fileModel.selectedItem.name + (l>1?'_'+i:'') + '.png';
					exportedImageNames.push(fileName);
					var realWidth:Number = exportBitmaps[i].w;
					var realHeight:Number = exportBitmaps[i].h;
					bmpd = exportBitmaps[i].bmpd;
					
					//Size the bitmap to a pow(2).
					//Doesn't work if we don't export all the frames (with correct positions);
					//if (realWidth < 2048 || realHeight < 2048) {
						//var newW:Number = findNextPower2(realWidth);
						//var newH:Number = findNextPower2(realHeight);
						var tmpBitmap:BitmapData = new BitmapData(realWidth, realHeight, true, 0xffffff);
						tmpBitmap.copyPixels(bmpd,new Rectangle(0,0,realWidth,realHeight), new Point());
						bmpd = tmpBitmap;
						(exportBitmaps[i].bmpd as BitmapData).dispose();
					//}
					
					saved = saveImage(fileModel.selectedItem.destinationPath + '/'+fileName, bmpd);
					bmpd.dispose();
					//An error happened during export ... user already has been notifyed, so ignore and move on.
					if (!saved) { return; }
				}
			}
			
			isComplex = fileModel.selectedItem.variableFrameDimensions || fileModel.selectedItem.reuseFrames || fileModel.selectedItem.imageExportType == ExportType.IMAGE_FRAME;
			
			//Export other data
			if (fileModel.selectedItem.imageExportType == ExportType.IMAGE_FRAME) {
				l = bitmapList.length;
				for (i=0;i<l;i++) {
					frameData = (bitmaps[i] is Number)?bitmaps[bitmaps[i]]:bitmaps[i];
					var bitmap:BitmapData = frameData.ref;
					fileName = fileModel.selectedItem.name+'_frame_'+i+'.png';
					exportedImageNames.push(fileName);
					var saved:Boolean = saveImage(fileModel.selectedItem.destinationPath+'/'+fileName, bitmap);
					//An error happened during export ... user already has been notifyed, so ignore and move on.
					if (!saved) { return; }
				}
			}
			
			if (fileModel.selectedItem.dataExportType == ExportType.DATA_JSON) {
				var json:String = buildJSON();
				
				saveFile = new File(fileModel.selectedItem.destinationPath + '/'+fileModel.selectedItem.name + '.json');
				fs.open(saveFile, FileMode.WRITE);
				fs.writeUTFBytes(json);
				fs.close();
			}
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		protected function sortBitmaps(one:FrameData, two:FrameData):int {
			if (one == null || two == null) {
				return -1;
			}
			return one.point.y < two.point.y?-1:1;
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
			var frames:Object = [];
			
			var states:Vector.<AnimationState> = getStates();
			var statesCount:uint = states.length;
			var animations:Object = {};
			
			var origRect:Rectangle = fileModel.selectedItem.frameBounds;
			var regPoint:Point=fileModel.selectedItem.registrationPt;
			
			l = bitmaps.length;
			
			if (isComplex) {
				//Build the frames array.
				for (i=0;i<l;i++) {
					var tempData:Object = bitmaps[i];
					if (!(tempData is Number)) {
						frameData = bitmaps[i];
						rect = pointLookup[frameData.point];
						point = frameData.point;
						
						//Frame format: [x,y,w,h,index,regX,regY]
						var captureRect:Rectangle = captureBounds[i];
						var ox:Number = regPoint.x-captureRect.x;
						var oy:Number = regPoint.y-captureRect.y;
						
						if (fileModel.selectedItem.imageExportType == ExportType.IMAGE_FRAME) {
							frames.push([0,0,rect.width, rect.height,i,ox,oy]);
						} else {
							frames.push([point.x, point.y,rect.width, rect.height,frameData.sheetIndex,ox,oy]);
						}
					}
				}
				
				//Update bitmaps array with correct index's
				l = bitmaps.length;
				var actualIndex:uint = 0;
				for (i=0;i<l;i++) {
					var data:Object = bitmaps[i];
					if (data is FrameData) {
						(data as FrameData).actualIndex = actualIndex;
						actualIndex++;
					}
				}
				
				//Build labels out
				for (i=0;i<statesCount;i++) {
					var state:AnimationState = states[i];
					animations[state.name] = {frames:getFramesForRange(state.startFrame, state.endFrame)};
				}
			} else {
				var frameBounds:Rectangle = fileModel.selectedItem.frameBounds;
				
				frames = {width:frameBounds.width, 
					height:frameBounds.height, 
					regX:(registrationPoint) ? registrationPoint.x: 0, 
						regY:(registrationPoint) ? registrationPoint.y: 0, 
						count:frameCount };
				
				for(i=0;i<statesCount;i++) {
					state = states[i];
					animations[state.name] = [state.startFrame, state.endFrame];
				}
			}
			
			
			var jsonData:Object = {}
			jsonData.frames = frames;
			jsonData.animations = animations;
			jsonData.images = exportedImageNames;
			
			var jsonString:String = com.maccherone.json.JSON.encode(jsonData, true, 500);
			
			return jsonString;
		}
		
		/**
		 * @private
		 * 
		 */
		protected function getFramesForRange(start:uint, end:uint):Array {
			if (start == end) {
				if (bitmaps[start] is Number) {
					return [bitmaps[start]];
				} else {
					return [start];
				}
			}
			
			var frames:Array = [];
			var frameData:FrameData;
			
			for (var i:uint=start;i<end;i++) {
				var data:Object = bitmaps[i];
				
				if (data is Number) {
					frameData = bitmaps[data];
				} else {
					frameData = data as FrameData;
				}
				
				frames.push(frameData.actualIndex);
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
		protected function positionRects(maxWidth:Number):void {
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
			
			var w:Number = maxWidth;
			var h:Number = rects[l - 1].height;
			var maxW:Number = 0;
			var maxH:Number = 0;
			var ry:Number = 0;
			var rx:Number = 0;
			var p:Point;
			
			while (rects.length) {
				rect = rects.pop();
				if (rx+rect.width > w) {
					// see if we can fit anything else in:
					var j:int = rects.length - 1;
					while (j-- > 0) {
						var rect2:Rectangle = rects[j];
						if (rx+rect2.width <= w) {
							// this fits.
							p = new Point(rx,ry);
							positions[rectLookup[rect2]] = p;
							pointLookup[p] = rect2;
							rx += rect2.width;
							rects.splice(j,1);
						}
					}
					
					if (rx + rect.width > maxW) {
						maxW = rx;
					}
					
					rx = 0;
					ry +=  h;
					h = rect.height;
					if (ry+h > maxH) {
						maxH = ry + h;
					}
				}
				
				p = new Point(rx,ry);
				positions[rectLookup[rect]] = p;
				pointLookup[p] = rect;
				rx += rect.width;
			}
			
			sheetWidth = maxW;
			sheetHeight = maxH;
		}
	}
}