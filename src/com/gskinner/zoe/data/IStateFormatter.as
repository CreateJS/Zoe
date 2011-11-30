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
	 * Zoe currently supports JSON export, for EaselJS support.
	 * Here we define the interface for those formatters.
	 * @see JSONFormatter
	 * 
	 */
	public interface IStateFormatter {
		
		/**
		 * Formats the AnimationStates into a String for export.
		 * 
		 * @param states The Vector of AnimationState to format.
		 * @param width The width of each frame.
		 * @param height The height of each frame.
		 * @param registrationPoint The registrationPoint, as defined in the loaded swf.
		 * @param fileName The base file to use for export.
		 * @param frameCount The number frame use for export.
		 * 
		 */
		function format(states:Vector.<AnimationState>, width:Number, height:Number, registrationPoint:Point, fileName:String, frameCount:Number, sheetData:Vector.<Object>=null, complex:Boolean=false):String;
	}
}