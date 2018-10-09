package data
{
	import flash.utils.Dictionary;

	/**
	 * <b>Description</b>:
	 *
	 * @project sktEditor
	 * @class FunctionProvider
	 * @author wangfuyuan
	 * @usage
	 * @since 2018-10-5
	 * @modified 2018-10-5
	 * @modifier wangfuyuan
	 */
	public class FunctionProvider
	{
		public function FunctionProvider()
		{
		}
		
		public var funcName:String;
		public var paramList:Array = [];
		public var returnType:String;
		public var desc:String;
		public var express:String;
		
		public static var Providers:Array = [];
		private static var _map:Dictionary = new Dictionary();
		
		public static function fromJson(json:String):void{
			var obj:Object = JSON.parse(json);
			var list:* = obj["gfp"];
			var len:Number = list.length;
			for (var i:int = 0; i < len; i++) 
			{
				var o:* = list[i];
				var fp:FunctionProvider = new FunctionProvider();
				fp.funcName = o["funcName"];
				fp.paramList = o["paramList"];
				fp.returnType = o["returnType"];
				fp.desc = o["desc"];
				fp.express = o["express"];
				FunctionProvider.Providers.push(fp);
				FunctionProvider._map[fp.funcName] = fp;
			}
		}
		
		public static function get(name:String):FunctionProvider{
			return FunctionProvider._map[name];
		}
	}
}