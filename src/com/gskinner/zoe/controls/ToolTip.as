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

package com.gskinner.zoe.controls {

	import flash.display.Graphics;
	import flash.filters.DropShadowFilter;
	import flash.text.TextFormat;
	
	import mx.containers.Canvas;
	
	import spark.components.Label;
	
	public class ToolTip extends Canvas {
		
		/**
		 * @private
		 * 
		 */
		protected var _label:String;
		
		/**
		 * @private
		 * 
		 */
		protected var tf:TextFormat;
		
		/**
		 * @private
		 * 
		 */
		protected var padding:Number = 5;
		
		/**
		 * @private
		 * 
		 */
		protected var _txt:Label;
		
		/**
		 * Defines a custom ToolTip, currently used for displaying the Registration point. 
		 * 
		 */
		public function ToolTip() {
			super();
			
			_txt = new Label();
			_txt.styleName = 'contentFont';
			addElement(_txt);
			this.filters = [new DropShadowFilter(4, 45, 0x000000, 1, 5, 5, .56, 1)];	
		}
		
		/**
		 * @private
		 * 
		 */
		public function show():void {
			this.setVisible(true);
		}
		
		/**
		 * @private
		 * 
		 */
		public function hide():void {
			this.setVisible(false);
		}
		
		/**
		 * @private
		 * 
		 */
		public function set labelField(value:String):void {
			_label = value;
			_txt.text = _label;
			draw();
		} 
		
		/**
		 * Returns the width of this tip (including text width)
		 * 
		 */
		public function get actualWidth():Number { return _txt.width+padding; }
		
		/**
		 * Returns the height of this tip (including text height)
		 * 
		 */
		public function get actualHeight():Number { return _txt.height+(padding/2); }
		
		/**
		 * @private
		 * 
		 */
		protected function draw():void {
			var g:Graphics = this.graphics;
			g.clear();
			
			g.beginFill(0xFFFFCC, 1);
			g.drawRoundRect(-padding/2, -padding/2, _txt.width + padding, _txt.height + (padding/2), 8, 8);
			g.endFill();
		}
	}
}