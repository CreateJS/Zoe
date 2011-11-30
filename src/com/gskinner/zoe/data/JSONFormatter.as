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

/**
 * Formats captured data as JSON.
 * 
 */
package com.gskinner.zoe.data {
	
	import com.maccherone.json.JSON;
	
	import flash.geom.Point;
	
	/**
	 * Formats the captured animation sequence as JSON data.
	 * 
	 */
	public class JSONFormatter implements IStateFormatter {
		
		public function JSONFormatter() {
			
		}
		
		/**
		 * @inheritDoc
		 * 
		 */
		public function format(values:Vector.<AnimationState>, width:Number, height:Number, registrationPoint:Point, fileName:String, frameCount:Number, sheetData:Vector.<Object> = null, complex:Boolean=false):String {
			var data:Object = {};
			data.images = [fileName];
			if (sheetData.length>1) {
				data.frames = [];
				var len:uint = sheetData.length;
				for(var k:uint=0;k<len;k++) {
					var sheetItem:Object = sheetData[k];
					data.frames[k] = new Array(sheetItem.x, sheetItem.y, sheetItem.w, sheetItem.h, sheetItem.imageIndex, sheetItem.ox, sheetItem.oy);
				}
			} else {
				data.frames = {width:width, 
							   height:height, 
				               regX:(registrationPoint) ? registrationPoint.x: 0, 
				               regY:(registrationPoint) ? registrationPoint.y: 0, 
					   	       count:frameCount };
			}
			
			var l:uint = values.length;
			var animations:Object = {}
			if (l > 0) {
				data.animations = animations;
			}
			
			for(var i:uint=0;i<l;i++) {
				var state:AnimationState = values[i];
				if (complex) {
					if (state.frames.storedFrames != null) {
						if (state.frames.storedFrames.length > 0) { 
							delete state.frames.storedFrames;
						} 
					}
					animations[state.name] = state.frames;
				} else {
					animations[state.name] = new Array(state.startFrame, state.endFrame);
				}
			}
			return com.maccherone.json.JSON.encode(data, true, 160);
		}
	}
}