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
	
	public class ExportType {
		
		/**
		 * Constants used for Export formats.
		 * 
		 */
		
		/**
		 * When set Zoe will export individual PNG files.
		 * 
		 */
		public static const FORMAT_FRAME:String = 'formatFrame';
		
		/**
		 * When set Zoe will export a single PNG sprite sheet.
		 * 
		 */
		public static const FORMAT_WEB:String = 'formatWeb';
		
		/**
		 * When set Zoe will export no data.
		 * 
		 */
		public static const EXPORT_NONE:String = 'exportNone';
		
		/**
		 * When set Zoe will export JSON stub code for Easel.
		 * @see http://www.easeljs.com
		 * 
		 */
		public static const EXPORT_JSON:String  = 'exportJson';
		
	}
}