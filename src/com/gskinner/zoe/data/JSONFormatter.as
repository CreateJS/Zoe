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
 * We don't use the JSON lib, so we can add custom formating to the exported data.
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
		public function format(values:Vector.<AnimationState>, width:Number, height:Number, registrationPoint:Point, fileName:String):String {
			var data:Object = {};
			
			data.src = fileName;
			data.w = width;
			data..h = height;
			
			if (registrationPoint) {
				data.registrationPoint = [registrationPoint.x, registrationPoint.y];
			}
			
			//Encode states
			var states:Object = {};
			data.states = states;
			var l:uint = values.length;
			
			for (var i:uint=0;i<l;i++) {
				var state:AnimationState = values[i];
				states[state.name] = {start: state.startFrame, end: state.endFrame};
			}
			
			return JSON.encode(data, true);
		}
	}
}