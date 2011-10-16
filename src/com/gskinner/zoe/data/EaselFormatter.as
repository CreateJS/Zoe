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
package com.gskinner.zoe.data {
	
	import flash.geom.Point;
	
	/**
	 * Formats the captured animation sequence as Easel stub code.
	 * 
	 */
	public class EaselFormatter implements IStateFormatter {
		
		public function EaselFormatter() {
			
		}
		
		/**
		 * @inheritDoc
		 * 
		 */
		public function format(states:Vector.<AnimationState>, width:Number, height:Number, registrationPoint:Point, fileName:String):String {
			var output:Array = [];
			
			var l:uint = states.length;
			for (var i:uint=0;i<l;i++) {
				var s:AnimationState = states[i];
				output.push(s.name+':['+s.startFrame + ',' +s.endFrame + ']');
			}
			
			var regPoint:String = '';
			
			if (registrationPoint) {
				regPoint = '// regX='+registrationPoint.x + ', regY='+registrationPoint.y;
			}
			
			var statesStr:String = '{\n\t' + output.join(',\n\t') + '\n\t};';
			return 'var frameData = '+statesStr+'\nvar img = new Image()\nimg.src = "'+fileName+'"\nvar spriteSheet = new SpriteSheet(img,' + width + ',' + height + ',frameData);\n'+regPoint;
		}
	}
}