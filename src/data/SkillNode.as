package data
{
	import mx.utils.StringUtil;

	/**
	 * <b>Description</b>:
	 *
	 * @project sktEditor
	 * @class SkillNode
	 * @author wangfuyuan
	 * @usage
	 * @since 2018-9-29
	 * @modified 2018-9-29
	 * @modifier wangfuyuan
	 */
	public class SkillNode{
		public static var ID:Number = 1000;
		
		public var id:Number;
		
		public var name:String = "";
		
		public var leftChild:SkillNode;
		
		public var rightChild:SkillNode;
		
		public var parent:SkillNode;
		
		public var pos:int;
		
		// ------------------------------------
		public var nodeType:Number = 0;
		
		public var action:SkillFunction = SkillFunction.createDefaultValue("func");
		
		public var ifCondition:SkillFunction = SkillFunction.createDefaultValue("bool");
		
		public var filterCondition:SkillFunction = SkillFunction.createDefaultValue("bool");
		
		public var forName:SkillFunction = SkillFunction.createDefaultValue("string");
		public var forStart:SkillFunction = SkillFunction.createDefaultValue("number");
		public var forEnd:SkillFunction = SkillFunction.createDefaultValue("number");
		public var forStep:SkillFunction = SkillFunction.createDefaultValue("number");

		public var delay:SkillFunction = SkillFunction.createDefaultValue("number");
		
		
		
		public function SkillNode(){
			id = ++SkillNode.ID;
		}
		
		
		/**
		 * 插入进一个节点的子节点中
		 * @param node
		 * @param pos 0-left 1-right
		 * @param cpos 0-left 1-right
		 */
		public function insertAsChild(node:SkillNode,pos:Number,cpos:Number):void{
			var c:SkillNode = pos == 0 ? node.leftChild : node.rightChild;
			if(c){
				this.addNode(c,cpos);
			}
			if(pos == 0){
				node.leftChild = this;
			}else{
				node.rightChild = this;
			}
		}
		
		/**
		 * 添加一个子节点
		 * @param node 
		 * @param pos 0-left 1-right
		 */
		public function addNode(node:SkillNode,pos:Number):void{
			if(pos == 0){
				this.leftChild = node;
			}else{
				this.rightChild = node;
			}
			node.parent = this;
			node.pos = pos;
		}
		
		/**
		 * 删除一个子节点 
		 * @param node
		 */		
		public function removeNode(node:SkillNode):void{
			var left:SkillNode = this.leftChild;
			if(left != null && left.id == node.id){
				node.parent = null;
				this.leftChild = undefined;
				return;
			}
			var right:SkillNode = this.rightChild;
			if(right != null && right.id == node.id){
				node.parent = null;
				this.rightChild = undefined;
				return;
			}
		}
		
		public function getChildrenNum():Number
		{
			var c:Number = 0;
			if(this.leftChild != null && this.rightChild != null){
				c = 1;
			}
			if(this.leftChild != null){
				c += this.leftChild.getChildrenNum();
			}
			if(this.rightChild != null){
				c += this.rightChild.getChildrenNum();
			}
			return c;
		}
		
		public function hasNull():Boolean{
			var t:Number = nodeType;
			if(t == NodeType.Default){
				if(action == null || action.isNull()){
					return true;
				}
			}
			if(t == NodeType.Delay){
				if(delay == null || delay.isNull()){
					return true;
				}
			}
			if(t == NodeType.IF){
				if(ifCondition == null || ifCondition.isNull()){
					return true;
				}
			}
			if(t == NodeType.Selector){
				if(filterCondition == null || filterCondition.isNull()){
					return true;
				}
			}
			if(t == NodeType.For){
				if(forName == null || forName.isNull()){
					return true;
				}
				if(forEnd == null || forEnd.isNull()){
					return true;
				}
				if(forStart == null || forStart.isNull()){
					return true;
				}
				if(forStep == null || forStep.isNull()){
					return true;
				}
			}
			return false;
		}
		
		public function toCode(tab:Number = 0):String{
			const SP:String = "<font color='#0022ff' size='18'>{</font>";
			const EP:String = "<font color='#0022ff' size='18'>}</font>";
			
			var res:String = "";
			
			if(name != null && name.length > 0){
				res += getTabs(tab);
				res += StringUtil.substitute("<font color='#009933' size='16'>//{0}</font>",name);
				res += "\n";
			}
			
			if(nodeType == NodeType.Default){
				res += getTabs(tab);
				res += action.getExpression(0);
				res += "\n";
				if(leftChild != null){
					res += leftChild.toCode(tab);
				}
			}
			if(nodeType == NodeType.IF){
				res += getTabs(tab);
				res += StringUtil.substitute("<font color='#0022ff' size='18'>if({0})</font>",ifCondition.getExpression(0));
				res += (SP + "\n");
				
				if(leftChild != null){
					res += leftChild.toCode(tab+1);
				}
				
				res += getTabs(tab);
				res += (EP + "\n");
				
				
				if(rightChild != null){
					res += getTabs(tab);
					res += StringUtil.substitute("<font color='#0022ff' size='18'>else</font>",ifCondition.getExpression(0));
					res += (SP + "\n");
					res += rightChild.toCode(tab+1);
					
					res += getTabs(tab);
					res += (EP + "\n");
				}
			}
			
			if(nodeType == NodeType.Selector){
				res += getTabs(tab);
				res += StringUtil.substitute("<font color='#0022ff' size='18'>Select( when : {0})</font>",filterCondition.getExpression(0));
				res += (SP + "\n");
				
				if(rightChild != null){
					res += rightChild.toCode(tab+1);
				}
				
				res += getTabs(tab);
				res += (EP + "\n");
				
				if(leftChild != null){
					res += leftChild.toCode(tab);
				}
			}
			
			if(nodeType == NodeType.For){
				res += getTabs(tab);
				res += StringUtil.substitute("<font color='#0022ff' size='18'>For( var {0} = {1} ; {0} ＜ {2} ; {0} += {3})</font>",
					forName.getExpression(0),
						forStart.getExpression(0),
							forEnd.getExpression(0),
								forStep.getExpression(0));
				res += (SP + "\n");
				
				if(rightChild != null){
					res += rightChild.toCode(tab+1);
				}
				
				res += getTabs(tab);
				res += (EP + "\n");
				
				if(leftChild != null){
					res += leftChild.toCode(tab);
				}
			}
			
			if(nodeType == NodeType.Delay){
				res += getTabs(tab);
				res += StringUtil.substitute("<font color='#0022ff' size='18'>Wait( {0} ms):</font>",delay.getExpression(0));
				res += (SP + "\n");
				
				if(leftChild != null){
					res += leftChild.toCode(tab+1);
				}
				
				res += getTabs(tab);
				res += (EP + "\n");
			}
			
			return res;
		}
		
		private function getTabs(tab:Number):String
		{
			var res:String = "";
			for (var i:int = 0; i < tab; i++) 
			{
				res += "<font color='#eeeeee' size='18'>----</font>"; 
			}
			return res;
			
		}
		
		public function toJson():Object{
			var obj:* = {};
			obj["id"] = this.id;
			obj["name"] = this.name;
			obj["nodeType"] = this.nodeType;
			if(this.leftChild != null){
				obj["leftChild"] = this.leftChild.toJson();
			}
			if(this.rightChild != null){
				obj["rightChild"] = this.rightChild.toJson();
			}
			if(nodeType == NodeType.Default){
				obj["action"] = this.action.toJson();
			}
			if(nodeType == NodeType.Delay){
				if(delay != null){
					obj["delay"] = delay.toJson();
				}
			}
			if(nodeType == NodeType.IF){
				if(ifCondition != null){
					obj["ifCondition"] = ifCondition.toJson();
				}
			}
			if(nodeType == NodeType.Selector){
				if(filterCondition != null){
					obj["filterCondition"] = filterCondition.toJson();
				}
			}
			if(nodeType == NodeType.For){
				if(forName != null){
					obj["forName"] = forName.toJson();
				}
				if(forStart != null){
					obj["forStart"] = forStart.toJson();
				}
				if(forEnd != null){
					obj["forEnd"] = forEnd.toJson();
				}
				if(forStep != null){
					obj["forStep"] = forStep.toJson();
				}
			}
			return obj;
		}
		
		public static function fromJson(json:*):SkillNode{
			var node:SkillNode = new SkillNode();
			node.id = json["id"];
			node.name = json["name"];
			node.nodeType = json["nodeType"];
			if(json["action"] != null){
				node.action = SkillFunction.fromJson(json["action"]);
			}
			if(json["leftChild"] != null){
				node.leftChild = SkillNode.fromJson(json["leftChild"]);
				node.leftChild.parent = node;
			}
			if(json["rightChild"] != null){
				node.rightChild = SkillNode.fromJson(json["rightChild"]);
				node.rightChild.parent = node;
			}
			
			var t:Number = node.nodeType;
			if(t == NodeType.Default){
				
			}
			if(t == NodeType.Delay){
				if(json["delay"] != null){
					node.delay = SkillFunction.fromJson(json["delay"]);
				}
			}
			if(t == NodeType.IF){
				if(json["ifCondition"] != null){
					node.ifCondition = SkillFunction.fromJson(json["ifCondition"]);
				}
			}
			if(t == NodeType.Selector){
				if(json["filterCondition"] != null){
					node.filterCondition = SkillFunction.fromJson(json["filterCondition"]);
				}
			}
			if(t == NodeType.For){
				if(json["forName"] != null){
					node.forName = SkillFunction.fromJson(json["forName"]);
				}
				if(json["forStart"] != null){
					node.forStart = SkillFunction.fromJson(json["forStart"]);
				}
				if(json["forEnd"] != null){
					node.forEnd = SkillFunction.fromJson(json["forEnd"]);
				}
				if(json["forStep"] != null){
					node.forStep = SkillFunction.fromJson(json["forStep"]);
				}
			}
			
			return node;
		}
	}
}