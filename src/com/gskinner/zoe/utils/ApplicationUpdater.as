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
	
	import air.update.ApplicationUpdaterUI;
	import air.update.events.UpdateEvent;
	
	import flash.filesystem.File;
	
	/**
	 * @private
	 * 
	 */
	public class ApplicationUpdater {
		
		/**
		 * @private
		 * 
		 */
		protected static var updater:ApplicationUpdaterUI;
		
		/**
		 * @private
		 * 
		 */
		protected static var wasInitilized:Boolean = false;
		
		public function ApplicationUpdater() {
			
		}
		
		/**
		 * @private
		 * 
		 */
		public static function checkForUpdates(invisible:Boolean = false):void {
			if (wasInitilized == false) {
				updater = new ApplicationUpdaterUI();
				updater.isCheckForUpdateVisible = !invisible;
				updater.addEventListener(UpdateEvent.INITIALIZED, handleUpdaterInit, false, 0, true);
				
				updater.configurationFile = File.applicationDirectory.resolvePath('data/version.xml');
				
				updater.initialize();
			} else {
				updater.isCheckForUpdateVisible = !invisible;
				updater.checkNow();
			}
		}
		
		/**
		 * @private
		 * 
		 */
		protected static function handleUpdaterInit(event:UpdateEvent):void {
			wasInitilized = true;
			updater.checkNow();
		}
	}
}