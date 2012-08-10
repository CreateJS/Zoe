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
	
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	/**
	 * Utility class used to create a dotted line.
	 * Used to show padding when creating sprite sheet. 
	 */
	
	public class DottedLine extends Sprite {
		
		/**
		 * @private
		 * 
		 */
		protected var pattern:Array;
		
		/**
		 * @private
		 * 
		 */
		protected var colors:Array;
		
		/**
		 * @private
		 * 
		 */
		protected var _x:Number = 0;
		
		/**
		 * @private
		 * 
		 */
		protected var bmpd:BitmapData;
		
		/**
		 * @private
		 * 
		 */
		protected var _padding:Number = 0;
		
		/**
		 * @private
		 * 
		 */
		protected var _area:Rectangle;
		
		/**
		 * @private
		 * 
		 */
		protected var patternLength:Number = 0;
		
		/**
		 * Draws a rectangle with a dotted line.
		 * 
		 */
		public function DottedLine() {
			pattern = [4,4];
			colors = [0xFF000000, 0x0000FF00];
			
			createLineStyle();
		}
		
		/**
		 * Redraws the view.
		 * 
		 */
		public function update(area:Rectangle, padding:Number):void {
			_padding = padding+2;
			_area = area;
			drawLine();
		}
		
		/**
		 * @private
		 * 
		 */
		protected function createLineStyle():void {
			var l:Number = pattern.length;
			patternLength = 0;
			for (var i:Number = 0; i < l; i++) {
				patternLength +=  pattern[i];
			}
			
			bmpd = new BitmapData(patternLength,1,true,0x000000);
			
			for (i=0; i<patternLength; i++) {
				for (var j:Number = 0; j <  pattern[i]; j++) {
					bmpd.setPixel32(_x++ , 0, colors[i]);
				}
			}
		}
		
		/**
		 * @private
		 * 
		 */
		protected function drawLine():void {
			var g:Graphics = this.graphics;
			g.clear();
			g.beginBitmapFill(bmpd, new Matrix(1,0,0,1,_area.left % patternLength ,0), true );
			g.drawRect(0-_padding, -_padding , _area.width + _padding*2, 1);
			g.endFill();
			
			g.beginBitmapFill(bmpd, new Matrix( 0,1,1,0,0,1 + _area.top % patternLength + patternLength - _area.width % patternLength), true );
			g.drawRect(0-_padding, 0-_padding, 1, _area.height+_padding*2);
			g.endFill();
			
			g.beginBitmapFill(bmpd, new Matrix(0,1,1,0,0,1 + _area.top % patternLength + patternLength - _area.width % patternLength), true );
			g.drawRect((_area.width|0)+_padding, 0-_padding, 1, _area.height+_padding*2);
			g.endFill();
			
			g.beginBitmapFill(bmpd, new Matrix(1,0,0,1,_area.left % patternLength ,0), true );
			g.drawRect(0-_padding, (_area.height|0)+_padding, _area.width+_padding*2, 1);
			g.endFill();
			
			var rect:Rectangle = this.getRect(this)
			
			g.beginFill(0xCCCCCC, .5);
			g.drawRect(rect.x, rect.y, this.width, this.height);
			
			g.drawRect(0, 0, _area.width, _area.height);
			g.endFill();
		}
	}
}