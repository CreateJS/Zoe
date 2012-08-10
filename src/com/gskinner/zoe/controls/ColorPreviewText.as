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
	
	import flash.events.Event;
	
	import mx.controls.listClasses.BaseListData;
	import mx.core.IFlexModuleFactory;
	import mx.core.ITextInput;
	
	import spark.components.Group;
	import spark.components.TextInput;
	import spark.components.ToggleButton;
	import spark.events.TextOperationEvent;
	
	/**
	 * Skin for the Flex ColorPicker syle "textInputClass"
	 * Inserts a toggle button for transparency toggle.
	 * 
	 */
	public class ColorPreviewText extends Group implements ITextInput {
		
		/**
		 * textInput
		 */
		protected var textInput:TextInput;
		
		/**
		 * We can't get reference to this class though the ColorPicker API, 
		 * so we use a static interface to access its properties, via getInstance();
		 * 
		 */
		public var toggleTransparencyButton:ToggleButton;
		
		/**
		 * @private
		 * 
		 */
		protected static var _instance:ColorPreviewText;
		
		/**
		 * Creates a new instance of the ColorPreviewText 
		 * 
		 */
		public function ColorPreviewText() {
			super();
			
			_instance = this;
			
			textInput = new TextInput();
			textInput.addEventListener(TextOperationEvent.CHANGE, handleChangeText, false, 0, true);
			textInput.width = 50;
			toggleTransparencyButton = new ToggleButton();
			toggleTransparencyButton.setActualSize(17, 17);
			toggleTransparencyButton.styleName = "transparentSkin";
			toggleTransparencyButton.validateNow();
		}
		
		/**
		 * Returns this objects current instance.
		 * Used so we can access the values from toggleTransparencyButton (the ColorPicker doesn't give us access to this component)
		 * 
		 */
		public static function getInstance():ColorPreviewText {
			if (_instance == null) { _instance = new ColorPreviewText(); }
			return _instance;
		}
		
		/**
		 * @private
		 * 
		 */
		override protected function createChildren():void {
			super.createChildren();
			addElement(textInput);
			addElement(toggleTransparencyButton);
		}
		
		/**
		 * @private
		 * 
		 */
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			toggleTransparencyButton.x = 156;
		}
		
		/**
		 * @private
		 * 
		 */
		protected function handleChangeText(event:TextOperationEvent):void {
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		/**
		 * Required by ITextInput
		 * 
		 */
		public function get selectionActivePosition():int {
			return textInput.selectionActivePosition;
		}
		
		/**
		 * Required by ITextInput
		 * 
		 */
		public function get selectionAnchorPosition():int {
			return textInput.selectionAnchorPosition;
		}
		
		/**
		 * Required by ITextInput
		 * 
		 */
		public function get editable():Boolean {
			return textInput.editable;
		}
		
		/**
		 * Required by ITextInput
		 * 
		 */
		public function set editable(value:Boolean):void {
			textInput.editable = value;
		}
		
		/**
		 * Required by ITextInput
		 * 
		 */
		public function get maxChars():int {
			return textInput.maxChars;
		}
		
		/**
		 * Required by ITextInput
		 * 
		 */
		public function set maxChars(value:int):void {
			textInput.maxChars = value;
		}
		
		/**
		 * Required by ITextInput
		 * 
		 */
		public function get parentDrawsFocus():Boolean {
			return false;
		}
		
		/**
		 * Required by ITextInput
		 * 
		 */
		public function set parentDrawsFocus(value:Boolean):void {
		}
		
		/**
		 * Required by ITextInput
		 * 
		 */
		public function get restrict():String {
			return textInput.restrict;
		}
		
		/**
		 * Required by ITextInput
		 * 
		 */
		public function set restrict(value:String):void {
			textInput.restrict = value;
		}
		
		/**
		 * Required by ITextInput
		 * 
		 */
		public function get selectable():Boolean {
			return textInput.selectable;
		}
		
		/**
		 * Required by ITextInput
		 * 
		 */
		public function set selectable(value:Boolean):void {
			textInput.selectable = value;
		}
		
		/**
		 * Required by ITextInput
		 * 
		 */
		public function get text():String {
			return textInput.text;
		}
		
		/**
		 * Required by ITextInput
		 * 
		 */
		public function set text(value:String):void {
			textInput.text = value;
		}
		
		/**
		 * Required by ITextInput
		 * 
		 */
		public function showBorderAndBackground(visible:Boolean):void {
			
		}
		
		/**
		 * Required by ITextInput
		 * 
		 */
		public function selectRange(anchorPosition:int, activePosition:int):void {
			textInput.selectRange(anchorPosition, activePosition);
		}
		
		/**
		 * Required by ITextInput
		 * 
		 */
		public function get data():Object {
			return null;
		}
		
		/**
		 * Required by ITextInput
		 * 
		 */
		public function set data(value:Object):void {
		}
		
		/**
		 * Required by ITextInput
		 * 
		 */
		public function get listData():BaseListData {
			return null;
		}
		
		/**
		 * Required by ITextInput
		 * 
		 */
		public function set listData(value:BaseListData):void { }
		
		/**
		 * Required by ITextInput
		 * 
		 */
		public function get fontContext():IFlexModuleFactory {
			return null;
		}
		
		/**
		 * Required by ITextInput
		 * 
		 */
		public function set fontContext(moduleFactory:IFlexModuleFactory):void {
		}
		
		/**
		 * Required by ITextInput
		 * 
		 */
		public function get enableIME():Boolean {
			return false;
		}
		
		/**
		 * Required by ITextInput
		 * 
		 */
		public function get imeMode():String {
			return null;
		}
		
		/**
		 * Required by ITextInput
		 * 
		 */
		public function set imeMode(value:String):void { }
	}
}