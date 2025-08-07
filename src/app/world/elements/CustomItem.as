package app.world.elements
{
	import app.data.ConstantsApp;
	import app.data.ItemType;
	import app.world.data.*;
	import com.fewfre.utils.Fewf;
	import com.fewfre.utils.FewfUtils;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	public class CustomItem
	{
		// Constants
		public static const LOOK_UPDATED : String = "look_updated";
		
		// Storage
		private var _root       : Sprite;
		private var _outfitData : OutfitData;
		private var _outfit     : ItemDisplay;
		
		private var _dragging   : Boolean = false;
		private var _dragBounds : Rectangle;

		// Properties
		public function get outfitData() : OutfitData { return _outfitData; }
		public function get outfit() : ItemDisplay { return _outfit; }
		
		public function get scale() : Number { return _outfit.scaleX; }
		public function set scale(pVal:Number) : void { _outfit.scaleX = _outfit.scaleY = pVal; }

		// Constructor
		public function CustomItem(pOutfitData:OutfitData=null) {
			_root = new Sprite();
			_outfitData = (pOutfitData || new OutfitData())
				.on(OutfitData.UPDATED, function(e:Event):void{ updateItem(); });
			updateItem();
			
			// Make interactable
			_initDragging();
		}
		public function move(pX:Number, pY:Number) : CustomItem { _root.x = pX; _root.y = pY; return this; }
		public function appendTo(pParent:Sprite): CustomItem { pParent.addChild(_root); return this; }
		public function on(type:String, listener:Function, useCapture:Boolean = false): CustomItem { _root.addEventListener(type, listener, useCapture); return this; }
		public function off(type:String, listener:Function, useCapture:Boolean = false): CustomItem { _root.removeEventListener(type, listener, useCapture); return this; }
		public function setVisibility(pVal:Boolean): CustomItem { _root.visible = pVal; return this; }

		public function updateItem() {
			if(!_outfitData.getCurrentItemData()) return;
			var itemData:ItemData = _outfitData.getCurrentItemData();
			
			var tScale = ConstantsApp.DEFAULT_CHARACTER_SCALE;
			if(_outfit != null) { tScale = _outfit.scaleX; _root.removeChild(_outfit); }
			
			_outfit = new ItemDisplay(itemData);
			_root.addChild(_outfit);
			_outfit.scaleX = _outfit.scaleY = tScale;
			// Don't let the pose eat mouse input
			_outfit.mouseChildren = false;
			_outfit.mouseEnabled = false;
			
			_root.dispatchEvent(new Event(LOOK_UPDATED));
		}
		
		public function getSaveImageDisplayObject() : DisplayObject {
			var itemData:ItemData = _outfitData.getCurrentItemData();
			return itemData.isBitmap() ? (itemData as BitmapItemData).getFullImage() : _outfit;
		}
		
		public function enableDoubleClick() : CustomItem {
			_root.doubleClickEnabled = true;
			return this;
		}

		/////////////////////////////
		// Dragging
		/////////////////////////////
		private function _initDragging() : void {
			_root.buttonMode = true;
			_root.addEventListener(MouseEvent.MOUSE_DOWN, function (e:MouseEvent) {
				_dragging = true;
				var bounds:Rectangle = _dragBounds.clone();
				bounds.x -= e.localX * _root.scaleX;
				bounds.y -= e.localY * _root.scaleY;
				_root.startDrag(false, bounds);
			});
			Fewf.stage.addEventListener(MouseEvent.MOUSE_UP, function () { if(_dragging) { _dragging = false; _root.stopDrag(); } });
		}
		public function setDragBounds(pX:Number, pY:Number, pWidth:Number, pHeight:Number): CustomItem {
			_dragBounds = new Rectangle(pX, pY, pWidth, pHeight); return this;
		}
		public function clampCoordsToDragBounds() : void {
			_root.x = Math.max(_dragBounds.x, Math.min(_dragBounds.right, _root.x));
			_root.y = Math.max(_dragBounds.y, Math.min(_dragBounds.bottom, _root.y));
		}
		
		/////////////////////////////
		// Shortcuts
		/////////////////////////////
		
		public function getCurrentItemData() : ItemData { return _outfitData.getCurrentItemData(); }
		public function getItemData(pType:ItemType) : ItemData { return _outfitData.getItemData(pType); }
		public function setItemData(pItemData:ItemData) : void { _outfitData.setItemData(pItemData); }
		public function removeItem(pType:ItemType) : void { _outfitData.removeItem(pType); }
	}
}
