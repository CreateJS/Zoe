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
package com.gskinner.zoe.model {
	
	import com.gskinner.filesystem.Preferences;
	import com.gskinner.utils.CallLater;
	import com.gskinner.zoe.data.SourceFileData;
	import com.gskinner.zoe.views.CapturePreview;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.collections.ArrayList;
	
	import spark.components.DropDownList;
	import spark.events.IndexChangeEvent;
	
	/**
	 * Instead of interacting with the top file list directly, we access it though this model.
	 * This way we can handle saving and ui updating here.
	 * 
	 */
	public class FileModel extends EventDispatcher {
		
		protected const FILES_NAME:String = 'com.gskinner.animationcapture.data.FileList::files';
		protected const INDEX_NAME:String = 'com.gskinner.animationcapture.data.FileList::index';
		
		protected var _dp:ArrayList;
		protected var _target:DropDownList;
		protected var _swfCapture:CapturePreview;
		
		public function FileModel() {
			//Erase old prefs if they exist
			if (isNaN(Preferences.getPref('v'))) {
				Preferences.clear(true);
				Preferences.setPref('v', 1, false, true);
			}
		}
	
		/**
		 * Returns a refernce to the swf CapturePreview
		 * 
		 */
		public function get swfCapture():CapturePreview {
			return _swfCapture;
		}
		
		/**
		 * Gets the currenly selected item from the list, or null.
		 * 
		 */
		public function get selectedItem():SourceFileData {
			return _target!=null?_target.selectedItem:null;
		}
		
		/**
		 * Sets the swf capture instance.
		 * 
		 */
		public function set swfCapture(value:CapturePreview):void {
			_swfCapture = value;
		}
		
		/**
		 * Deletes the selected item from the list, 
		 * and saves the updated state.
		 * 
		 */
		public function deleteSelected():void {
			_dp.removeItem(selectedItem);
			CallLater.call(saveState, 2);
			
			_target.selectedIndex = 0;
			
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		/**
		 * Sets the registration point for export.
		 * 
		 */
		public function set registrationPt(value:Point):void {
			selectedItem.registrationPt = value;
			CallLater.call(saveState, 2);
		}
		
		/**
		 * Gets the dropDownLiat we want to update (the main top drop-down)
		 * 
		 */
		public function get target():DropDownList { return _target; }
		public function set target(value:DropDownList):void {
			_target = value;
			_target.labelField = 'name';
			_target.addEventListener(IndexChangeEvent.CHANGE, handleSelectionChange, false, 0, true);
			
			var oldDp:Array = Preferences.getPref(FILES_NAME);
			if (oldDp != null) {
				var arr:Array = [];
				var l:uint = oldDp.length;
				for (var i:uint=0;i<l;i++) {
					var obj:Object = oldDp[i];
					var fileData:SourceFileData = new SourceFileData();
					fileData.deserialize(obj);
					arr.push(fileData);
				}
				
				_dp = new ArrayList(arr);
			} else {
				_dp = new ArrayList();
			}
			
			_target.dataProvider = _dp;
			_target.selectedIndex = Preferences.getPref(INDEX_NAME);
			
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		/**
		 * Updated the current items frame count
		 * 
		 */
		public function set selectedFrameCount(value:Number):void {
			selectedItem.frameCount = value;
			
			CallLater.call(saveState, 2);
		}
		
		/**
		 * Updates the selected items maximum bitmap export size.
		 * 
		 */
		public function setSelectedBitmapSize(w:Number, h:Number):void {
			selectedItem.bitmapWidth = w;
			selectedItem.bitmapHeight = h;
			
			CallLater.call(saveState, 2);
		}
		
		/**
		 * Sets the threshold level for comparsion.
		 * 
		 */
		
		public function setSelectedThreshold(value:Number):void {
			selectedItem.threshold = value;
			CallLater.call(saveState, 2);
		}
		
		/**
		 * Sets the current items background color.
		 * 
		 */
		public function setSelectedColor(showGrid:Boolean, color:uint):void {
			selectedItem.showGrid = showGrid;
			selectedItem.backgroundColor = color;
			
			CallLater.call(saveState, 2);
		}
		
		/**
		 * Sets the selected reuse frame option.
		 * 
		 */
		public function setSelectedReuseFrames(value:Boolean):void {
			selectedItem.reuseFrames = value;
			CallLater.call(saveState, 2);
		}
		
		/**
		 * Updates the current items source.
		 * 
		 */
		public function updateSelectedSourceFile(file:File):void {
			var oldFile:SourceFileData = _target.selectedItem;
			var newFile:SourceFileData = fileToData(file);
			newFile.name = oldFile.name;
			newFile.destinationPath = oldFile.destinationPath;
			
			_dp.setItemAt(newFile, _target.selectedIndex);
			CallLater.call(saveState, 2);
		}
		
		/**
		 * Updates the selected items name.
		 * 
		 */
		public function set selectedName(name:String):void {
			selectedItem.name = name;
			CallLater.call(saveState, 2);
		}
		
		/**
		 * Updated the current capture bounds.
		 * 
		 */
		public function setSelectedBounds(x:Number, y:Number, width:Number, height:Number, padding:Number = 0):void {
			selectedItem.exportPadding = padding;
			selectedItem.frameBounds = new Rectangle(x,y,width,height);
			
			CallLater.call(saveState, 2);
		}
		
		/**
		 * Changes the current export path for the SpriteSheet and supporting files.
		 * 
		 */
		public function set selectedDestinationPath(value:String):void {
			selectedItem.destinationPath = value;
			
			CallLater.call(saveState, 2);
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		/**
		 * Saves the current application state to the system.
		 * 
		 */
		public function saveState():void {
			Preferences.setPref(INDEX_NAME, _target.selectedIndex);
			
			var arr:Array = [];
			var l:uint = _dp.source.length;
			for (var i:uint=0;i<l;i++) {
				
				arr.push((_dp.source[i] as SourceFileData).serialize());
			}
			
			Preferences.setPref(FILES_NAME, arr, false, true);
		}
		
		/**
		 * Adds a new file to the list.
		 * 
		 */
		public function addItem(file:File):void {
			var currentIndex:int = indexOfItem(file);
			if (currentIndex > -1) {
				_target.selectedIndex = currentIndex;
			} else {
				_dp.addItem(fileToData(file));
				_target.selectedIndex = _dp.length-1;
			}
			
			CallLater.call(saveState, 2);
			
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		/**
		 * @private
		 * 
		 */
		protected function handleSelectionChange(event:IndexChangeEvent):void {
			CallLater.call(saveState, 2);
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		/**
		 * @private
		 * 
		 */
		protected function indexOfItem(file:File):int {
			var l:uint = _dp.length;
			for (var i:uint=0;i<l;i++) {
				var item:SourceFileData = _dp.getItemAt(i) as SourceFileData;
				if (item.sourcePath == file.url) { return i; }
			}
			return -1;
		}
		
		/**
		 * @private
		 * 
		 */
		protected function fileToData(file:File):SourceFileData {
			var pathPeices:Array = file.url.split('/');
			var name:String = pathPeices.pop().split('.')[0];
			
			var fileData:SourceFileData = new SourceFileData();
			fileData.name = name;
			fileData.sourcePath = file.url;
			fileData.destinationPath = pathPeices.join('/');
			
			return fileData;
		}
		
		/**
		 * @private
		 * 
		 */
		protected function dataToFile(data:Object):File {
			return new File(data.url);
		}
	}
}