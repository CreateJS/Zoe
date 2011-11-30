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
	
	import flash.geom.Point;
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
		 * The absolute URI to the swf
		 */
		public var sourcePath:String;
		
		/**
		 * Dimensions in which sprite sheet is exported.
		 */
		public var _formatExportType:String;
		
		/**
		 * Format type to export.
		 */
		public var _exportType:String;
		
		/**
		 * Specifies whether Easel stub code should be exported or not. 
		 */
		public function set exportJSON(value:Boolean):void {
			_exportJSON = value;
		}
		public function get exportJSON():Boolean { return _exportJSON; }
		
		public function get exportType():String { return _exportType; }
		public function set exportType(value:String):void {
			_exportType = value;
			if (_exportType == ExportType.EXPORT_NONE) {
				exportJSON = false;
			} else if (_exportType == ExportType.EXPORT_JSON) {
				exportJSON = true;
			}
		}
		
		/**
		 * Sets the image format to be exported. (A full SpriteSheet, or individual frames)
		 * 
		 */
		public function get formatExportType():String { return _formatExportType; }
		public function set formatExportType(value:String):void {
			_formatExportType = value;
			if (_formatExportType == ExportType.FORMAT_FRAME) {
				exportFrames = true;
			} else if (_formatExportType == ExportType.FORMAT_WEB) {
				exportFrames = false;
			}
		}
		
		/**
		 * Specifies whether there JSON source should be exported or not.
		 */
		protected var _exportJSON:Boolean = true;
		
		/**
		 * Specifies whether or not to export the spritesheet, defaults to true.
		 */
		public var exportSheet:Boolean = true;
		
		/**
		 * Specifies whether or not to export individual frames.
		 */
		public var exportFrames:Boolean;
		
		/**
		 * Specifies threshold level for comparing Bitmapdata.
		 */
		public var threshold:Number;
		
		/**
		 * Specifies reuse frames.
		 */
		public var reuseFrames:Boolean;
		
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
		public var registrationPt:Point;
		
		/**
		 * @private
		 */
		public var displayPt:Point;
		
		/**
		 * @private
		 */
		public var variableFrameDimensions:Boolean;
		
		/**
		 * @private
		 */
		public var isDirty:Boolean = true;
		
		/**
		 * Creates a new SourceFileData instance
		 * 
		 */
		public function SourceFileData() {
			frameBounds = new Rectangle();
			backgroundColor = 0xcccccc;
			showGrid = true;
			exportPadding = 0;
			frameCount = 0;
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
				destinationPath:destinationPath,
				sourcePath:sourcePath,
				name:name,
				exportJSON:exportJSON,
				exportSheet:exportSheet,
				exportFrames:exportFrames,
				threshold:threshold,
				
				reuseFrames:reuseFrames,
				registrationPt:registrationPt,
				variableFrameDimensions:variableFrameDimensions,
				displayPt:displayPt,
				frameCount:frameCount,
				formatExportType:formatExportType,
				exportType:exportType,
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
			frameBounds = new Rectangle(value.frameBounds.x,value.frameBounds.y,value.frameBounds.width,value.frameBounds.height);
			exportPadding = value.exportPadding;
			destinationPath = value.destinationPath;
			sourcePath = value.sourcePath;
			name = value.name;
			displayPt = (value.displayPt!= null) ? new Point(value.displayPt.x, value.displayPt.y) : new Point(0, 0);
			variableFrameDimensions = value.variableFrameDimensions;
			exportJSON = value.exportJSON;
			exportSheet = value.exportSheet;
			exportFrames = value.exportFrames;
			reuseFrames = value.reuseFrames;
			registrationPt = (value.registrationPt != null) ? new Point(value.registrationPt.x, value.registrationPt.y) : new Point(0, 0);
			threshold = isNaN(value.threshold) ? 0 : value.threshold;
			frameCount = isNaN(value.frameCount)? 0: value.frameCount;
			formatExportType = value.formatExportType;
			exportType = value.exportType;
			isDirty = value.isDirty;
		}
	}
}