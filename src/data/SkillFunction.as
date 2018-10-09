package data
{
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mx.utils.StringUtil;

	/**
	 * <b>Description</b>:
	 *
	 * @project sktEditor
	 * @class SkillFunction
	 * @author wangfuyuan
	 * @usage
	 * @since 2018-10-5
	 * @modified 2018-10-5
	 * @modifier wangfuyuan
	 */
	public class SkillFunction
	{
		/**
		 * "number" | "bool" | "string" | "func" 
		 */		
		public var funcType:String = "func";
		
		/**
		 * "number" | "bool" | "string" | "void" |  
		 */	
		public var returnType:String = "void";
		
		public var params:Array = [];
		
		public var baseValue:Object = "null";
		
		private static var HASHCOUNT:Number = 0;
		public var hashCode:Number;
		
		public function SkillFunction()
		{
			this.hashCode = ++HASHCOUNT;
		}
		
		private const FORMAT_CLICK:String = "<a href='event:{1}'><u><font color='#0022ff' size='18'>{0}</font></u></a>";
		private const FORMAT_Normal:String = "<font color='#0022ff' size='18'>{0}</font>";
		private const VALUE:String = "<font color='#ffaa00' size='18'>{0}</font>";
		/**
		 * 0 - no wrap
		 * 1 - wrap self
		 * 2 - wrap params 
		 * @param wrapMode
		 * @return 
		 * 
		 */		
		public function getExpression(wrapMode:Number = 0):String{
			const undefinedValue:String = "<font color='#ff0011' size='18'>Null</font>";
			var res:String = "";
			if(isNull()){
				res = undefinedValue;
			}else{
				if(funcType != "func"){
					res = StringUtil.substitute(VALUE,baseValue);
				}else{
					var p:FunctionProvider = FunctionProvider.get(String(this.baseValue));
					if(!p){
						res = undefinedValue;
					}else{
						var pArr:Array = [];
						var m = wrapMode == 2 ? 1 : 0;
						for (var i:int = 0; i < params.length; i++) 
						{
							pArr.push(params[i].getExpression(m));
						}
						res = StringUtil.substitute(p.express,pArr);
					}
				}
			}
			
			var f:String = FORMAT_Normal;
			if(wrapMode == 1){
				f = FORMAT_CLICK;
			}
			res = StringUtil.substitute(f,res,this.hashCode);
			return res;
		}
		
		public static function createDefaultValue(type:String):SkillFunction{
			var f:SkillFunction = new SkillFunction();
			if(type == "func"){
				f.funcType = type;
				f.returnType = "void";
				f.baseValue = "null";
			}else{	
				f.funcType = type;
				f.returnType = type;
				f.baseValue = getBaseValueBy(f.returnType)
			}
			f.params = [];
			return f;
		}
		
		private static function getBaseValueBy(t:String):Object
		{
			if(t == "bool"){
				return "true";
			}
			if(t == "number"){
				return 0;
			}
			return "null";
		}
		
		public function copy():SkillFunction{
			return cloneObject(this);
		}
		
		
		private function cloneObject(source:Object) :* {
			
			var typeName:String = getQualifiedClassName(source);//获取全名
			
			
			var packageName:String = typeName.split("::")[0];//切出包名
			
			
			var type:Class = getDefinitionByName(typeName) as Class;//获取Class
			
			trace(type);
			
			registerClassAlias(packageName, type);//注册Class
			
			//复制对象
			
			var copier:ByteArray = new ByteArray();
			
			copier.writeObject(source);
			
			copier.position = 0;
			
			return copier.readObject();
			
		}
		
		public function toJson():Object{
			var obj:* = {};
			obj["funcType"] = this.funcType;
			obj["returnType"] = this.returnType;
			obj["baseValue"] = this.baseValue;
			var parr:Array = [];
			for (var i:int = 0; i < this.params.length; i++) 
			{
				var pp:SkillFunction = this.params[i];
				parr.push(pp.toJson());
			}
			obj["params"] = parr;
			return obj;
		}
		
		public static function fromJson(json:Object):SkillFunction{
			var sk:SkillFunction = new SkillFunction();
			sk.funcType = json["funcType"];
			sk.returnType = json["returnType"];
			sk.baseValue = json["baseValue"];
			sk.params = [];
			var parr:Array = json["params"];
			if(parr.length > 0){
				for (var i:int = 0; i < parr.length; i++) 
				{
					sk.params.push(SkillFunction.fromJson(parr[i]));
				}
			}
			return sk;
		}
		
		public function isNull():Boolean
		{
			return baseValue == null || baseValue == "null";
		}
	}
}