package data
{
	/**
	 * <b>Description</b>:
	 *
	 * @project sktEditor
	 * @class NodeIO
	 * @author wangfuyuan
	 * @usage
	 * @since 2018-9-30
	 * @modified 2018-9-30
	 * @modifier wangfuyuan
	 */
	public class NodeIO
	{
		
		public static function readFromJson(json:String):SkillTree{
			var jo:* = JSON.parse(json);
			var t:SkillTree = new SkillTree();
			t.name = jo["name"];
			t.root = SkillNode.fromJson(jo["root"]);
			return t;
		}
		
		public static function writeAsJson(skt:SkillTree):String{
			var obj:* = {};
			obj["root"] = skt.root.toJson();
			obj["name"] = skt.name;
			return JSON.stringify(obj);
		}
	}
}