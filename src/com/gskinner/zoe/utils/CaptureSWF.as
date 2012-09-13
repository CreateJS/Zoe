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
	
	import com.gskinner.zoe.data.AnimationState;
	import com.gskinner.zoe.data.ExportType;
	import com.gskinner.zoe.data.FrameData;
	import com.gskinner.zoe.events.CaptureEvent;
	import com.gskinner.zoe.events.ResultEvent;
	import com.gskinner.zoe.model.FileModel;
	import com.maccherone.json.JSON;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.PNGEncoderOptions;
	import flash.display.Stage;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import mx.controls.SWFLoader;
	import mx.core.Application;
	
	/**
	 * Utility class used to capture each frame of the loaded clip.
	 * Also reads timeline information from the file, used for building a EaselJS BitmapSequence object
	 * 
	 */
	public class CaptureSWF extends EventDispatcher  {
		
		protected static const MAX_WIDTH:Number = 2048;
		protected static const MAX_HEIGHT:Number = 2048;
		
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
		protected var swf:SWFLoader;
		
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
		protected var isComplex:Boolean = false;
		
		protected var zeroRegistrationPoint:Point;
		
		/**
		 * @private
		 * 
		 */
		protected var _displayPoint:Point;
		
		protected var _frameCaptureWidth:Number;
		
		protected var _frameCaptureHeight:Number;
		
		protected var _startSwf:SWFLoader;
		
		protected var source:String;
	
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
			
			zeroRegistrationPoint = new Point();
		}
		
		/**
		 * Sets a new swf and registrationPoint.
		 * 
		 */
		public function updateSWF(swf:SWFLoader, source:String):void {
			this.swf = swf;
			this.source =  source;
		}
		
		public function get clip():MovieClip {
			return swf.content as MovieClip;
		}
		
		/**
		 * Returns the current swf's frame count.
		 * 
		 */
		public function get frameCount():Number {
			return fileModel.selectedItem.frameCount == 0?clip.totalFrames:fileModel.selectedItem.frameCount;
		}
		
		/**
		 * Sets Threshold level for comparing bitmaps.
		 * 
		 */
		public function set threshold(value:Number):void {
			_threshold = value;
		}
		
		/**
		 * Begins the frame by frame capture of the current clip.
		 * This operation is asynchronous, when capture is complete a complete event will be dispatched. 
		 *  
		 */
		public function capture():void {
			isComplex = false;
			positions = null;
			pointLookup = null;
			
			//Reload the swf
			_startSwf = swf;
			
			swf = new SWFLoader();
			swf.setActualSize(MAX_WIDTH, MAX_HEIGHT);
			swf.addEventListener(Event.INIT, handleSwfInit, false, 0, true);
			swf.load(source);
			
			dispatchEvent(new CaptureEvent(CaptureEvent.BEGIN));
		}
		
		protected function handleSwfInit(event:Event):void {
			bitmaps = [];
			
			currentCaptureFrame = 0;
			startFrameRate = _startSwf.stage.frameRate;
			_startSwf.stage.frameRate = 60;
			clip.gotoAndPlay(0);
			
			captureBounds = [];
			
			var variableFrameDimensions:Boolean = fileModel.selectedItem.variableFrameDimensions;
			var reuseFrames:Boolean = fileModel.selectedItem.reuseFrames;
			
			if ((variableFrameDimensions && !reuseFrames) || (variableFrameDimensions && reuseFrames)) {
				captureVariableSizeFrames();
			} else {
				var _frameBounds:Rectangle = fileModel.selectedItem.frameBounds;
				_frameCaptureWidth = _frameBounds.width;
				_frameCaptureHeight = _frameBounds.height;
				
				if (fileModel.selectedItem.maintainPow2) {
					_frameCaptureWidth = findNextPower2(_frameCaptureWidth);
					_frameCaptureHeight = findNextPower2(_frameCaptureHeight);
				}
				
				handleCaptureFrames(null);
				clip.addEventListener(Event.ENTER_FRAME, handleCaptureFrames, false, 0, true);
			}
		}
		
		public function createSizeBitmap():void {
			findBoundsBmpd = new BitmapData(MAX_WIDTH,MAX_HEIGHT, true, 0xff000000);
		}
		
		protected function captureVariableSizeFrames():void {
			var bounds:Rectangle = clip.getBounds(swf);
			
			stage = _startSwf.stage;
			
			handleVariableCaptureFrames(null);
			clip.addEventListener(Event.ENTER_FRAME, handleVariableCaptureFrames, false, 0, true);
		}
		
		public function getCurrentFrameBounds():Rectangle {
			if (!findBoundsBmpd) {
				createSizeBitmap();
			}
			findBoundsBmpd.fillRect(findBoundsBmpd.rect, 0xFFFFFF);
			findBoundsBmpd.draw(swf, null, findBoundsColorTransform);
			var frame:Rectangle = findBoundsBmpd.getColorBoundsRect(0xFFFFFF, boundsColorTint, false);
			return frame;
		}
		
		protected function handleVariableCaptureFrames(event:Event):void {
			var frame:Rectangle = getCurrentFrameBounds();
			frame.inflate(fileModel.selectedItem.exportPadding, fileModel.selectedItem.exportPadding);
			
			var scale:Number = fileModel.selectedItem.scale;
			frame.x *= scale;
			frame.y *= scale;
			frame.width *= scale;
			frame.height *= scale;
			
			captureBounds[currentCaptureFrame] = frame;

			var row:Number = currentCaptureFrame / columnCount | 0;
			var col:Number = currentCaptureFrame % columnCount | 0;
			
			var frameX:Number = (col * frame.width)-frame.width;
			var frameY:Number = row * frame.height;
			
			//var mtx:Matrix = new Matrix();
			//mtx.translate(frameX-frame.x, frameY-frame.y);
			
			var rect:Rectangle = new Rectangle(frame.x, frame.y, frame.width, frame.height);

			if (rect.width == 0) {
				rect = new Rectangle(frame.x, frame.y, 1, 1); 
			}
			
			//Capture just one frame here, we piece it together at the end.
			var mtx2:Matrix = new Matrix();
			mtx2.scale(scale, scale);
			mtx2.translate(-rect.x, -rect.y);
			
			var singleFrame:BitmapData = new BitmapData(rect.width, rect.height, true, 0xff0000);
			singleFrame.draw(swf, mtx2, null,null, new Rectangle(0,0, rect.width, rect.height),true);
			var label:String = (clip.currentLabel == null) ? 'all' : clip.currentLabel;
			
			var frameData:FrameData = new FrameData(singleFrame, currentCaptureFrame, label);
			frameData.registrationPoint = getRegistrationPoint();
			bitmaps.push(frameData);
			
			currentCaptureFrame++;
			
			if (currentCaptureFrame == this.frameCount) {
				_startSwf.stage.frameRate = startFrameRate;
				clip.removeEventListener(Event.ENTER_FRAME, handleVariableCaptureFrames);
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
		 * Each animation state is defined by using frame labels in the clip.
		 * Use in the main UI so we can play each sequence.
		 * 
		 */
		public function getStates():Vector.<AnimationState> {
			var states:Vector.<AnimationState> = new Vector.<AnimationState>();
			var l:uint = frameCount+1;
			var stateHash:Object = {};
			var count:Number = 0;
			for (var i:uint=0;i<=l;i++) {
				clip.gotoAndStop(i);
				
				var frameLabel:String = (clip.currentFrameLabel == null) ? 'all' : clip.currentFrameLabel;
				var frameLabelObject:Object
				
				if (frameLabel.indexOf('=') != -1) {
					try { //wdg:: try catch, just incase a incorrect string slips in.
						frameLabelObject = new URLVariables(frameLabel);
					} catch (e:*) {
						frameLabelObject = {label:frameLabel};
					}
				} else {
					frameLabelObject = {label:frameLabel};
				}
				var label:String = frameLabelObject.label;
				
				//Not a label, so just add any actions and move on.
				if (!('label' in frameLabelObject)) {
					states[states.length-1].addActions(frameLabelObject);
					continue;
				}
				
				if (stateHash[label] != null) { continue; }
				
				var startIndex:uint;
				var endIndex:uint;
				
				//Check to see if the next frame has a label.
				//Theres a weird bug with frame 0 and 1 returning the same label, so try frame 2, if its actually 0.
				clip.gotoAndStop(i==0?2:i+1);
				var nextLabel:String = clip.currentFrameLabel;
				
				if (nextLabel != null) {
					endIndex = startIndex = Math.max(0, i-1);
				} else {
					endIndex = findEndIndex(i+1, label);
					startIndex = Math.max(0, i-1);
					i = endIndex+1;
				}				
				
				//trace('frameLabel, nextLabel: ', frameLabel, nextLabel, startIndex, endIndex);
				
				stateHash[label] = true; 
				
				var state:AnimationState = new AnimationState(label, startIndex, endIndex);
				if (frameLabelObject) {
					state.addActions(frameLabelObject);
				}
				states.push(state);
			}
			
			return states;
		}
	
		/**
		 * @private
		 * 
		 */
		protected function findNextPower2(value:Number):int {
			value--; //Minus one just in-case this value is actually a pow(2,n) already.
			
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
			var scale:Number = fileModel.selectedItem.scale;
			
			var row:Number = currentCaptureFrame / columnCount | 0;
			var col:Number = currentCaptureFrame % columnCount | 0;
			
			var frameX:Number = (col * _frameCaptureWidth)-_frameCaptureWidth;
			var frameY:Number = row * _frameCaptureHeight;
			
			var rect:Rectangle = new Rectangle(frameX, frameY, _frameCaptureWidth, _frameCaptureHeight);
			
			//Capture just one frame here, we peice it together at the end.
			var mtx2:Matrix = new Matrix();
			mtx2.scale(scale, scale);
			mtx2.translate(-_frameBounds.x, -_frameBounds.y);
			
			var singleFrame:BitmapData = new BitmapData(_frameCaptureWidth, _frameCaptureHeight, true, 0xff0000);
			singleFrame.draw(swf, mtx2, null,null, new Rectangle(0,0, _frameCaptureWidth, _frameCaptureHeight),true);
			
			var frameData:FrameData = new FrameData(singleFrame,currentCaptureFrame, clip.currentLabel);
			frameData.registrationPoint = getRegistrationPoint();
			bitmaps.push(frameData);
			
			captureBounds[currentCaptureFrame] = rect;
			
			if (++currentCaptureFrame == frameCount) {
				finishCapture();
			}
		}
		
		protected function getRegistrationPoint():Point {
			var registrationPointClip:DisplayObject = clip.getChildByName('registrationPoint');
			
			if (registrationPointClip) {
				return new Point(registrationPointClip.x, registrationPointClip.y);
			} else {
				return zeroRegistrationPoint;
			}
		}
		
		/**
		 * @private
		 * 
		 */
		protected function finishCapture():void {
			clip.removeEventListener(Event.ENTER_FRAME, handleCaptureFrames);
			_startSwf.stage.frameRate = startFrameRate;
			
			var fs:FileStream = new FileStream();
			var saveFile:File;
			
			var i:uint;
			var l:uint;
			var rect:Rectangle;
			var point:Point;
			var matrix:Matrix;
			var captureBmd:BitmapData;
			var frameData:FrameData;
			var result:Object;
			
			var exportBitmaps:Array = [];
			var requestedWidth:Number = fileModel.selectedItem.bitmapWidth;
			var requestedHeight:Number = fileModel.selectedItem.bitmapHeight;
			var maintainPow2:Boolean = fileModel.selectedItem.maintainPow2;
			
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
			
			var padding:Number = 0;//fileModel.selectedItem.exportPadding;
			
			//If positions is empty, populate it
			if (!positions) {
				//Build our normal un-packed rect list.
				var currX:Number = padding;
				var currY:Number = padding;
				
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
					
					sheetWidth = Math.max(sheetWidth, currX + rect.width + padding + padding);
					sheetHeight = Math.max(sheetHeight, currY + rect.height + padding + padding);
					
					currX += rect.width+padding+padding;
					
					if (currX + rect.width > requestedWidth) {
						currY += rect.height + padding + padding;
						currX = padding;
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
					if (maintainPow2) {
						var newW:Number = findNextPower2(realWidth);
						var newH:Number = findNextPower2(realHeight);
						
						var tmpBitmap:BitmapData = new BitmapData(newW, newH, true, 0xffffff);
						tmpBitmap.copyPixels(bmpd,new Rectangle(0,0,realWidth,realHeight), new Point());
						
						bmpd = tmpBitmap;
						(exportBitmaps[i].bmpd as BitmapData).dispose();
					}
					
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
				result = buildJSON();
				
				saveFile = new File(fileModel.selectedItem.destinationPath + '/'+fileModel.selectedItem.name + '.json');
				fs.open(saveFile, FileMode.WRITE);
				fs.writeUTFBytes(result.json);
				fs.close();
			}
			
			swf.unloadAndStop();
			swf = _startSwf;
			dispatchEvent(new ResultEvent(ResultEvent.COMPLETE, result));
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
		protected function buildJSON():Object {
			var l:uint;
			var i:uint;
			var frameData:FrameData;
			var rect:Rectangle;
			var point:Point;
			var frames:Object = [];
			
			var states:Vector.<AnimationState> = getStates();
			var statesCount:uint = states.length;
			var animations:Object = {};
			var padding:uint = fileModel.selectedItem.exportPadding;
			
			var origRect:Rectangle = fileModel.selectedItem.frameBounds;
			
			var framesDroppedCount:uint = 0;
			
			l = bitmaps.length;
			
			if (isComplex || fileModel.selectedItem.maintainPow2) {
				//Build the frames array.
				for (i=0;i<l;i++) {
					var tempData:Object = bitmaps[i];
					if (!(tempData is Number)) {
						frameData = bitmaps[i];
						rect = pointLookup[frameData.point];
						point = frameData.point;
						
						var captureRect:Rectangle = captureBounds[i];
						rect.inflate(-fileModel.selectedItem.exportPadding, -fileModel.selectedItem.exportPadding);
						
						var ox:Number = 0; 
						var oy:Number = 0;
						
						if (frameData.registrationPoint.x != 0) {
							ox = frameData.registrationPoint.x-captureRect.x-padding;
						}
						
						if (frameData.registrationPoint.y != 0) {	
							oy = frameData.registrationPoint.y-captureRect.y-padding;
						}
						
						//Round the Reg Points
						ox = Math.round(ox);
						oy = Math.round(oy);
						
						//Reset the padding on the c
						captureRect.inflate(-fileModel.selectedItem.exportPadding, -fileModel.selectedItem.exportPadding);
						
						//Frame format: [x,y,w,h,index,regX,regY]
						if (fileModel.selectedItem.imageExportType == ExportType.IMAGE_FRAME) {
							frames.push([0,0,rect.width, rect.height,i,ox,oy]);
						} else {
							frames.push([
								point.x==0?point.x+padding:point.x+padding,
								point.y==0?point.y+padding:point.y+padding,
								rect.width,
								rect.height,
								frameData.sheetIndex,
								ox,
								oy,
							]);
						}
					} else {
						framesDroppedCount++;
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
					var framesList:Array = getFramesForRange(state.startFrame, state.endFrame);
					//trace(state.name, framesList);
					var animationDef:Object = {frames:framesList};
					
					if (state.next != null) {
						animationDef.next = state.next;
					}
					if (!isNaN(state.frequency)) {
						animationDef.frequency =  state.frequency;
					}
					animations[state.name] = animationDef;
				}
			} else {
				var frameBounds:Rectangle = fileModel.selectedItem.frameBounds;
				var registrationPoint:Point = (bitmaps[0] as FrameData).registrationPoint;
				
				frames = {
					width:frameBounds.width, 
					height:frameBounds.height, 
					regX:(registrationPoint) ? registrationPoint.x: 0, 
					regY:(registrationPoint) ? registrationPoint.y: 0, 
					count:frameCount
				};
				
				for(i=0;i<statesCount;i++) {
					state = states[i];
					var frameDef:Array = [state.startFrame, state.endFrame];
					if (state.next != null || !isNaN(state.frequency)) {
						frameDef.push(state.next);
					}
					if (!isNaN(state.frequency)) {
						frameDef.push(state.frequency);
					}
					animations[state.name] = frameDef;
				}
			}
			
			var startFrames:Number = frames.length + framesDroppedCount;
			var currentFrames:Number = frames.length;
			
			var jsonData:Object = {}
			jsonData.frames = frames;
			jsonData.animations = animations;
			jsonData.images = exportedImageNames;
			
			//We don't use the default JSON object, because here we can create a pretty output.
			var jsonString:String = com.maccherone.json.JSON.encode(jsonData, true, 500);
			
			return {json:jsonString, startFrames:startFrames, currentFrames:currentFrames, droppedFrames:framesDroppedCount};
		}
		
		/**
		 * @private
		 * 
		 */
		protected function getFramesForRange(start:uint, end:uint):Array {
			if (start == bitmaps.length) { start--; }
			if (end == bitmaps.length) { end--; }
			
			if (start == end) {
				if (bitmaps[start] is Number) {
					return [bitmaps[bitmaps[start]].actualIndex];
				} else {
					return [bitmaps[start].actualIndex];
				}
			}
			
			var frames:Array = [];
			var frameData:FrameData;
			var currentLabel:String;
			
			for (var i:uint=start;i<=end;i++) {
				var data:Object = bitmaps[i];
				
				if (data is Number) {
					frameData = bitmaps[data];
				} else {
					frameData = data as FrameData;
				}
				
				if (frameData == null) { continue; }
				
				//Somtimes the last 2 frames can be incorrect, so filter them here.
				if (currentLabel != null && currentLabel != frameData.currentLabel) {
					break;
				}
				
				currentLabel = frameData.currentLabel;
				
				frames.push(frameData.actualIndex);
			}
			
			return frames;
		}
		
		/**
		 * @private
		 * 
		 */
		protected function saveImage(path:String, bmpd:BitmapData):Boolean {
			var saveFile:File = new File(path);
			var fs:FileStream = new FileStream();
			
			try {
				fs.open(saveFile, FileMode.WRITE);
			} catch (e:Error) {
				dispatchEvent(new CaptureEvent(CaptureEvent.INVALID_PATH, false, false, 'Invalid path:\n' + saveFile.nativePath + '\n' + e.message));
				dispatchEvent(new Event(Event.COMPLETE));
				return false;
			}
			
			var png:ByteArray = new ByteArray();
			var  options:PNGEncoderOptions = new PNGEncoderOptions(true);
			bmpd.encode(bmpd.rect, options, png);
			
			fs.writeBytes(png);
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
				clip.gotoAndStop(i);
				var lbl:String = clip.currentFrameLabel;
				if (lbl == null || lastLabel == lbl) { continue; }
				if (lbl != null) {
					var frameIndex:int = i;
					while (frameIndex--) {
						clip.gotoAndStop(frameIndex);
						if (clip.numChildren != 0) {
							//found frame
							index = frameIndex;
							break out;
						}
					}
				}
			}
			
			if (clip.currentFrame == frameCount-1) {
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