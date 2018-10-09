package
{
	import data.SkillNode;
	import data.SkillTree;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	
	import flashx.textLayout.formats.TextAlign;
	
	import mx.core.UIComponent;
	

	/**
	 * <b>Description</b>:
	 *
	 * @project sktEditor
	 * @class Drawer
	 * @author wangfuyuan
	 * @usage
	 * @since 2018-9-29
	 * @modified 2018-9-29
	 * @modifier wangfuyuan
	 */
	public class Drawer extends UIComponent
	{
		[Bindable]
		public static var COLOR_DEFAULT:Number = 0xcccccc;
		[Bindable]
		public static var COLOR_IF:Number = 0x00CCFF;
		[Bindable]
		public static var COLOR_For:Number = 0x999966;
		[Bindable]
		public static var COLOR_Selector:Number = 0xCC9966;
		[Bindable]
		public static var COLOR_Delay:Number = 0xFF99CC;
		
		public var skt:SkillTree
		
		public var hasNull:Boolean = false;
		
		private var nodeBtns:Vector.<TextField> = new Vector.<TextField>();
		
		private var btnPool:Vector.<TextField> = new Vector.<TextField>();
		
		private var shp:Shape;
		private var shp2:Shape;
		
		public static var POS_DIC:Dictionary = new Dictionary();
		
		public function Drawer(t:SkillTree)
		{
			skt = t;
			shp = new Shape();
			addChild(shp);
			shp2 = new Shape();
			this.width = this.height = 2000;
			graphics.beginFill(0xdddddd);
			graphics.drawRect(0,0,2000,2000);
			graphics.endFill();
			
			addEventListener(Event.ADDED_TO_STAGE,onAdd);
		}
		
		private var _isMovingNode:Boolean = false;
		private var _sX:Number;
		private var _sY:Number;
		protected function onAdd(event:Event):void
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE,onMoveNode);
			stage.addEventListener(MouseEvent.MOUSE_UP,onMoveUp);
		}
		
		protected function onMoveUp(event:MouseEvent):void
		{
			if(_isMovingNode){
				_isMovingNode = false;
				trace("_isMovingNode = false")
				
				var node = this.selectedNode;
				if(node != null){
					Drawer.POS_DIC[node.id] = new Point(selectedTxt.x + selectedTxt.width/2,selectedTxt.y+selectedTxt.height/2);
					this.draw();
				}
			}
			
			
		}
		
		protected function onMoveNode(e:MouseEvent):void
		{
			if(_isMovingNode){
				var node = this.selectedNode;
				var target = e.target;
				if(node != null){
					var dx = Math.floor(e.stageX - _sX);
					var dy = Math.floor(e.stageY - _sY);
					selectedTxt.y += dy;
					selectedTxt.x += dx;
					trace(dx + ":" + dy)
					_sX = e.stageX;
					_sY = e.stageY;
				}
			}
		}
		
		public function draw():void{
			hasNull = false;
			shp.graphics.clear();
			shp2.graphics.clear();
			while(nodeBtns.length > 0){
				var b = nodeBtns.pop();
				recycleButton(b);
			}
			
			drawNode(skt.root);
			addChild(shp2);
		}
		
		private var orig:Point
		private function drawNode(n:SkillNode,p:Point = null):void
		{
			// TODO Auto Generated method stub
			if(p == null){
				p = new Point(this.width/2,50);
				orig = p;
			}
			
			var left = n.leftChild;
			var right = n.rightChild;
			
			var gap = 75;
			if(!left || !right){
				gap = 0
			}
			
			if(left != null){
				var g = gap 
				var pos = new Point(p.x - g,p.y + 75);
				if(Drawer.POS_DIC[left.id] != null){
					pos = Drawer.POS_DIC[left.id];
				}
				this.drawNode(left,pos);
				
				shp.graphics.lineStyle(4,0xaaffaa);
				shp.graphics.moveTo(p.x,p.y);
				shp.graphics.lineTo(pos.x,pos.y);
			}
			
			if(right != null){
				var g = gap
				var pos = new Point(p.x + gap,p.y + 75)
				if(Drawer.POS_DIC[right.id] != null){
					pos = Drawer.POS_DIC[right.id];
				}
				this.drawNode(right,pos);
				
				shp.graphics.lineStyle(4,0xffaaaa);
				shp.graphics.moveTo(p.x,p.y);
				shp.graphics.lineTo(pos.x,pos.y);
			}
			
			var b:TextField = getButton();
			nodeBtns.push(b);
			b.text = n.name;
			b.x = p.x - b.width/2;
			b.y = p.y - b.height/2;
			b.backgroundColor = getColorBy(n.nodeType);
			b.borderColor = 0xffeeee;
			b.addEventListener(MouseEvent.CLICK,onClickNode);
			b.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			node_map[b] = n;
			this.addChild(b);
			
			if(selectedNode != null && n.id == selectedNode.id){
//				b.backgroundColor = 0xaa11cc;
				shp.graphics.lineStyle(1,0x9900CC);
				shp.graphics.beginFill(0x9900CC);
				shp.graphics.drawRect(b.x - 5,b.y - 5,b.width + 10,b.height + 10);
				shp.graphics.endFill();
			}
			
			if(n.hasNull()){
				hasNull = true;
				shp2.graphics.beginFill(0xff0000);
				shp2.graphics.drawCircle(b.x + b.width,b.y,3);
				shp2.graphics.endFill();
			}
			
		}
		
		private function getColorBy(t:Number):uint
		{
			const color:Array = [Drawer.COLOR_DEFAULT,Drawer.COLOR_Selector,Drawer.COLOR_IF,Drawer.COLOR_For,Drawer.COLOR_Delay];
			return color[t];
		}
		
		protected function onMouseDown(e:MouseEvent):void
		{
			if(node_map[e.currentTarget] != this.selectedNode){
				return;
			}
			_sX = e.stageX;
			_sY = e.stageY;
			_isMovingNode = true;
			trace("_isMovingNode = true")
		}
		
		private function getChildNum(node:SkillNode):Number{
//			var c = 0;
//			var curNode:SkillNode = node;
//			while(true){
//				if(pos == 0){
//					if(curNode.leftChild != null){
//						c ++;
//						curNode = curNode.leftChild;
//					}else{
//						return c;
//					}
//				}else{
//					if(curNode.rightChild != null){
//						c ++;
//						curNode = curNode.rightChild;
//					}else{
//						return c;
//					}
//				}
//			}
			return node.getChildrenNum();
		}
		
		private var node_map:Dictionary = new Dictionary();
		
		public var selectedNode:SkillNode;
		public var selectedTxt:TextField;
		
		protected function onClickNode(e:MouseEvent):void
		{
			var target:* = e.currentTarget;
			var sk:SkillNode = node_map[target];
			if(sk){
				selectedNode = sk;
				selectedTxt = target;
			}
			draw();
			dispatchEvent(new Event("selectNode"));
		}
		
		private function getButton():TextField{
			if(btnPool.length > 0){
				return btnPool.pop();
			}else{
				var b:TextField = new TextField();
				b.selectable = false;
				b.width = 100;
				b.height = 35;
				b.background = true;
				b.border = true;
				b.wordWrap = true;
				b.textColor = 0xffffaa;
				var f :TextFormat = new TextFormat();
				f.align = TextAlign.CENTER;
				b.defaultTextFormat = f;
				return b;
			}
		}
		
		private function recycleButton(b:TextField):void{
			if(b.parent){
				b.parent.removeChild(b);
			}
			node_map[b] = null;
			b.removeEventListener(MouseEvent.CLICK,onClickNode);
			b.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			btnPool.push(b);
		}
		
	}
}