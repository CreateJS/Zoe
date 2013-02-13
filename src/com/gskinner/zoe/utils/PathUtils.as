package com.gskinner.zoe.utils {
	/**
	 * ...
	 * @version 0.2
	 * @author mprzybys
	 */
	public class PathUtils {
		
		public static function justPath(filepath:String):String {
			return process(filepath)[0];
		}
		
		public static function justFile(filepath:String):String {
			return process(filepath)[1];
		}
		
		public static function justFilename(filepath:String):String {
			return process(filepath)[2];
		}
		
		public static function justExtension(filepath:String):String {
			return process(filepath)[3];
		}
		
		public static function validate(filepath:String):Boolean {
			return PATTERN.test(filepath);
		}
		
		private static const PATTERN:RegExp = /(?:(?:([a-zA-Z]{1}:(?:\/|\\))(.*(?:\/|\\))*)?((\w*?)(\.\w{3,4})))|(?:(?:([a-zA-Z]{1}:(?:\/|\\))(.*(?:\/|\\))*))/;
		
		private static function process(filepath:String):Array {
			var path:String = "";
			var file:String = "";
			var name:String = "";
			var extn:String = "";
			
			var result:Object = PATTERN.exec(filepath);
			if (result != null) {
				if (result[1] != undefined) path += result[1];
				if (result[2] != undefined) path += result[2];
				if (result[3] != undefined) file += result[3];
				if (result[4] != undefined) name += result[4];
				if (result[5] != undefined) extn += result[5];
				if (result[6] != undefined) path += result[6];
				if (result[7] != undefined) path += result[7];
			}
			
			return [ path, file, name, extn ];
		}
		
	}

}