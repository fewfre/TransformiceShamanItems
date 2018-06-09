package app.world.elements
{
	import com.piterwilson.utils.*;
	import app.data.*;
	import app.world.data.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;

	public class CustomItem extends Sprite
	{
		// Storage
		public var outfit:MovieClip;
		public var animatePose:Boolean;

		private var _itemData:ItemData;

		// Properties
		public function set scale(pVal:Number) : void { outfit.scaleX = outfit.scaleY = pVal; }

		// Constructor
		// pData = { x:Number, y:Number, item:ItemData, ?params:URLVariables }
		public function CustomItem(pData:Object) {
			super();
			animatePose = false;

			this.x = pData.x;
			this.y = pData.y;

			this.buttonMode = true;
			this.addEventListener(MouseEvent.MOUSE_DOWN, function () { startDrag(); });
			this.addEventListener(MouseEvent.MOUSE_UP, function () { stopDrag(); });

			/****************************
			* Store Data
			*****************************/
			_itemData = pData.item;
			
			/*if(pData.params) _parseParams(pData.params);*/

			updateItem();
		}

		public function updateItem() {
			var tScale = 1.75;
			if(outfit != null) { tScale = outfit.scaleX; removeChild(outfit); }
			outfit = addChild(new (_itemData.itemClass)()) as MovieClip;
			outfit.scaleX = outfit.scaleY = tScale;
			
			/*var tChild:DisplayObject = null;
			for(var i:int = 0; i < outfit.numChildren; i++) {
				tChild = outfit.getChildAt(i);
				if(_itemData.colors != null) {
					GameAssets.colorItem({ obj:tChild, colors:_itemData.colors });
				}
				else { GameAssets.colorDefault(tChild); }
			}
			tChild = null;*/
			
			if(_itemData.colors != null) {
				GameAssets.colorItem({ obj:outfit, colors:_itemData.colors });
			}
			else { GameAssets.colorDefault(outfit); }
			
			// if(animatePose) outfit.play(); else outfit.stopAtLastFrame();
		}

		private function _parseParams(pParams:URLVariables) : void {
			/*trace(pParams.toString());

			_setParamToType(pParams, ITEM.SKIN, "s", false);*/
		}
		private function _setParamToType(pParams:URLVariables, pType:String, pParam:String, pAllowNull:Boolean=true) {
			/*var tData:ItemData = null;
			if(pParams[pParam] != null) {
				if(pParams[pParam] == '') {
					tData = null;
				} else {
					tData = GameAssets.getItemFromTypeID(pType, pParams[pParam]);
				}
			}
			_itemDataMap[pType] = pAllowNull ? tData : ( tData == null ? _itemDataMap[pType] : tData );*/
		}

		public function getParams() : URLVariables {
			/*var tParms = new URLVariables();

			var tData:ItemData;
			tParms.s = (tData = getItemData(ITEM.SKIN)) ? tData.id : '';

			return tParms;*/
			return null;
		}

		/****************************
		* Color
		*****************************/
		public function getColors(pType:String) : Array {
			return _itemData.colors;
		}

		public function colorItem(pType:String, arg2:int, pColor:String) : void {
			_itemData.colors[arg2] = GameAssets.convertColorToNumber(pColor);
			updateItem();
		}

		/****************************
		* Update Data
		*****************************/
		public function getItemData(pType:String) : ItemData {
			return _itemData;
		}

		public function setItemData(pItem:ItemData) : void {
			_itemData = pItem;
			updateItem();
		}

		public function removeItem(pType:String) : void {
			_itemData = null;
			updateItem();
		}
	}
}
