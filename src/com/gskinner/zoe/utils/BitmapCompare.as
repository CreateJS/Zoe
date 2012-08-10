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
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	
	/**
	 * Utility class used to compare bitmaps for reusing frames when exporting sprite sheet.
	 * 
	 */
	
	public class BitmapCompare {
		
		protected var colorMatrix:ColorMatrixFilter;
		
		/**
		 * @private
		 * 
		 */
		protected var blur:BlurFilter;
		
		/**
		 * @private
		 * 
		 */
		protected var _blurAmount:Number;
		
		/**
		 * @private
		 * 
		 */
		protected var _threshold:Number = 0.5;
		
		public function BitmapCompare(blurAmount:Number=10) {
			colorMatrix =  new ColorMatrixFilter(
				[
				0.3086, 0.6094, 0.0820, 0, 0, 
				0.3086, 0.6094, 0.0820, 0, 0, 
				0.3086, 0.6094, 0.0820, 0, 0,
				0, 0, 0, 1, 0
				]);
			
			_blurAmount = blurAmount;
			blur = new BlurFilter(blurAmount, blurAmount);
		}
		
		/**
		 * @private
		 * 
		 */
		public function get threshold():Number { return _threshold; }
		
		/**
		 * @private
		 * 
		 */
		public function set threshold(value:Number):void {
			_threshold = value;
		}
		
		/**
		 * @private
		 * 
		 */
		public function get blurAmount():Number { return _blurAmount; }
		
		/**
		 * @private
		 * 
		 */
		public function set blurAmount(value:Number):void {
			_blurAmount = value;
		}
		
		/**
		 * @private
		 * 
		 */
		public function different(item:BitmapData, item2:BitmapData, index:Number):Boolean {
			var result:Object = item.compare(item2);
			if (result is BitmapData) {
				var resultBmpd:BitmapData = result as BitmapData;
				resultBmpd.applyFilter(resultBmpd, resultBmpd.rect, new Point(), colorMatrix);
				resultBmpd.applyFilter(resultBmpd, resultBmpd.rect, new Point(), blur);
				
				var container:BitmapData = new BitmapData(item.width,item.height,true,0x000000);
				var changedPixels:Number = container.threshold(resultBmpd, resultBmpd.rect, new Point(), ">", threshold * 0xFFFFFFFF, 0xFF000000, 0xFFFFFFFF, false);
				
				if (changedPixels > 0) {
					return true;
				}
				return false;
			} else {
				if (result == 0) {
					//BitmapData objects are equivalent (with the same width, height, and identical pixel values;
					return false;
				} else if (result == -3) {
					//widths of the BitmapData objects are not equal;
				} else if (result == -4) {
				}//heights of the BitmapData objects are not equal, but the widths are the same;
			}
			return true;
		}
	}
}