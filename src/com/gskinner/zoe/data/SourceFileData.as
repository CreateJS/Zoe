/*
* Zoë by gskinner.com.
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

package com.gskinner.zoe.data {
	
	import flash.geom.Rectangle;
	import flash.utils.escapeMultiByte;
	import flash.utils.unescapeMultiByte;
	
	/**
	 * VO to hold settings for individual SWF files
	 * used to define each row in the main file dropdown 
	 * 
	 */
	public class SourceFileData {
		
		/**
		 * The total number of frames to capture (0 means capture all)
		 */
		public var frameCount:Number;
		
		/**
		 * The maximum width of the bitmap to export
		 */
		public var bitmapWidth:Number;
		
		/**
		 * The maximum height of the bitmap to export
		 */
		public var bitmapHeight:Number;
		
		/**
		 * Background color to display behind the animation.
		 */
		public var backgroundColor:uint;
		
		/**
		 * Shows or hides the transparency grid behind the animation.
		 */
		public var showGrid:Boolean;
		
		/**
		 * The bounds to capture from the loaded animation.
		 */
		public var frameBounds:Rectangle;
		
		/**
		 * Extra padding to apply to the frameBound upon export (will not visually display)
		 */
		public var exportPadding:Number;
		
		/**
		 * 
		 */
		public var overPaint:Boolean;
		
		/**
		 *  The scale of the clip.
		 */
		public var scale:Number;
		
		/**
		 * The absolute URI to the swf
		 */
		public var sourcePath:String;
		
		/**
		 * Sets the image format to be exported. (A full SpriteSheet, or individual frames)
		 * 
		 */
		public var imageExportType:String;
		
		/**
		 * Specifies whether there JSON source should be exported or not.
		 */
		public var dataExportType:String;
		
		/**
		 * Specfies the name of the callback used when exporting jsonp
		 */
		public var jsonpCallback:String = 'callback';
		
		/**
		 * Specifies threshold level for comparing Bitmapdata.
		 */
		public var threshold:Number;
		
		/**
		 * Specifies reuse frames.
		 */
		public var reuseFrames:Boolean;
		
		/**
		 * Flag to always export image with pow(2,n) sizes.
		 */
		public var maintainPow2:Boolean;
		
		/**
		 * Flag to always export image with pow(2,n) sizes.
		 */
		public var maintainMinSize:Boolean;
		
		/**
		 * What fps our Spritesheet should be exported with.
		 */
		public var fps:Number = 24;
		
		/**
		 * @private
		 */
		protected var _name:String;
		
		/**
		 * @private
		 */
		protected var _destinationPath:String;
		
		/**
		 * @private
		 */
		public var variableFrameDimensions:Boolean;
		
		/**
		 * @private
		 */
		public var isDirty:Boolean = true;
		
		/**
		 * @private
		 * 
		 */
		public var basePath:String;
		
		protected var _animations:Object;
		
		/**
		 * Creates a new SourceFileData instance
		 * 
		 */
		public function SourceFileData() {
			frameBounds = new Rectangle();
			backgroundColor = 0xcccccc;
			showGrid = true;
			maintainPow2 = true;
			maintainMinSize = true;
			exportPadding = 0;
			overPaint = false;
			frameCount = 0;
			scale = 1;
			_animations = {};
			
			//Set the default image size
			bitmapHeight = bitmapWidth = 2048;
			
			//Turn on re-use by default, set to a low tolerance (will only remove frames exactly the same) 
			reuseFrames = true;
			threshold = .01;
		}
		
		/**
		 * The name to use for export and display in the main ui.
		 * 
		 */
		public function set name(value:String):void {
			_name = escapeMultiByte(value);
		}
		public function get name():String {
			return unescapeMultiByte(_name);
		}
		
		/**
		 * Defines the output folder to save captured assets.
		 * 
		 */
		public function set destinationPath(value:String):void {
			_destinationPath = escapeMultiByte(value);
		}
		public function get destinationPath():String {
			return unescapeMultiByte(_destinationPath);
		}
		
		public function getNextAnimationName(label:String):String {
			return _animations[label] == null?null:_animations[label].next;
		}
		
		public function getAnimationSpeed(label:String):Number {
			return _animations[label] == null?1:_animations[label].speed; 
		}
		
		public function setAnimationData(anim:String, next:String, speed:Number):void {
			var value:Object = this._animations[anim] || {};
			value.next = next;
			value.speed = speed;
			
			this._animations[anim] = value;
		}
		
		/**
		 * Convert to an generic object, so we can save as AMF to the file system.
		 * 
		 */
		public function serialize():Object {
			
			var obj:Object = {
				bitmapWidth:bitmapWidth,
				bitmapHeight:bitmapHeight,
				backgroundColor:backgroundColor,
				showGrid:showGrid,
				frameBounds:{x:frameBounds.x, y:frameBounds.y, width:frameBounds.width, height:frameBounds.height},
				exportPadding:exportPadding,
				overPaint:overPaint,
				scale:scale,
				destinationPath:destinationPath,
				sourcePath:sourcePath,
				name:name,
				threshold:threshold,
				jsonpCallback:jsonpCallback,
				
				imageExportType:imageExportType,
				dataExportType:dataExportType,
				fps:fps,
				animations:_animations,
				
				reuseFrames:reuseFrames,
				variableFrameDimensions:variableFrameDimensions,
				frameCount:frameCount,
				maintainPow2:maintainPow2,
				maintainMinSize:maintainMinSize,
				basePath:basePath,
				isDirty:isDirty
			}
			
			return obj;
		}
		
		/**
		 * Converts our saved data into valid properties.
		 * 
		 */
		public function deserialize(value:Object):void {
			bitmapWidth = value.bitmapWidth;
			bitmapHeight = value.bitmapHeight;
			backgroundColor = value.backgroundColor;
			showGrid = value.showGrid;
			frameBounds = new Rectangle(value.frameBounds.x||0, value.frameBounds.y||0, value.frameBounds.width||0, value.frameBounds.height||0);
			
			exportPadding = value.exportPadding;
			
			// Fix old (Pre 0.5.0 padding values)
			if (!isNaN(exportPadding) && exportPadding > 2) {
				exportPadding = 2;
			}
			
			overPaint = value.overPaint || false;
			
			destinationPath = value.destinationPath;
			sourcePath = value.sourcePath;
			name = value.name;
			variableFrameDimensions = value.variableFrameDimensions == null?true:value.variableFrameDimensions;
			threshold = isNaN(value.threshold) ? 0 : value.threshold;
			frameCount = isNaN(value.frameCount)? 0: value.frameCount;
			isDirty = value.isDirty;
			reuseFrames = value.reuseFrames;
			dataExportType = value.dataExportType || ExportType.DATA_JSON;
			imageExportType = value.imageExportType || ExportType.IMAGE_SPRITE_SHEET;
			scale = value.scale || 1;
			maintainPow2 = value.maintainPow2 || true;
			maintainMinSize = value.maintainMinSize || true;
			jsonpCallback = value.jsonpCallback || 'callback';
			fps = isNaN(value.fps)?24:value.fps;
			_animations = value.animations || {};
			basePath = value.basePath || '';
		}
	}
}