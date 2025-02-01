package app.world.elements
{
	import app.data.*;
	import app.world.data.*;
	import com.fewfre.utils.Fewf;
	import com.fewfre.utils.FewfUtils;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;

	public class CustomItem extends Sprite
	{
		// Storage
		public var outfit:MovieClip;
		public var animatePose:Boolean;
		public var isOutfit:Boolean;
		
		private var _dragging:Boolean = false;
		private var _dragBounds:Rectangle;

		private var _itemData:ItemData;

		// Properties
		public function set scale(pVal:Number) : void { outfit.scaleX = outfit.scaleY = pVal; }

		// Constructor
		public function CustomItem(item:ItemData=null, pShareCode:String=null, pIsOutfit:Boolean=false) {
			super();
			animatePose = false;
			isOutfit = pIsOutfit;

			this.buttonMode = true;
			this.addEventListener(MouseEvent.MOUSE_DOWN, function (e:MouseEvent) {
				_dragging = true;
				var bounds:Rectangle = _dragBounds.clone();
				bounds.x -= e.localX * scaleX;
				bounds.y -= e.localY * scaleY;
				startDrag(false, bounds);
			});
			Fewf.stage.addEventListener(MouseEvent.MOUSE_UP, function () { if(_dragging) { _dragging = false; stopDrag(); } });

			// Store Data
			_itemData = item;
			
			if(pShareCode) parseShareCode(pShareCode);

			if(_itemData != null) updateItem();
		}
		public function move(pX:Number, pY:Number) : CustomItem { x = pX; y = pY; return this; }
		public function appendTo(pParent:Sprite): CustomItem { pParent.addChild(this); return this; }
		
		public function copy() : CustomItem { return new CustomItem(null, getShareCodeFewfreSyntax(), true); }

		public function updateItem() {
			var tScale = ConstantsApp.DEFAULT_CHARACTER_SCALE;
			if(outfit != null) { tScale = outfit.scaleX; removeChild(outfit); }
			
			if(!_itemData.isBitmap()) { outfit = new (_itemData.itemClass)(); }
			else { outfit = (_itemData as BitmapItemData).getLargeOutfitImageAsMovieClip(); }
			addChild(outfit);
			outfit.scaleX = outfit.scaleY = tScale;
			// Don't let the pose eat mouse input
			outfit.mouseChildren = false;
			outfit.mouseEnabled = false;
			
			/*var tChild:DisplayObject = null;
			for(var i:int = 0; i < outfit.numChildren; i++) {
				tChild = outfit.getChildAt(i);
				if(_itemData.colors != null) {
					GameAssets.colorItem({ obj:tChild, colors:GameAssets.getColorsWithPossibleHoverEffect(_itemData) });
				}
				else { GameAssets.colorDefault(tChild); }
			}
			tChild = null;*/
			
			if(_itemData.colors != null) {
				GameAssets.colorItemUsingColorList(outfit, GameAssets.getColorsWithPossibleHoverEffect(_itemData));
			}
			else { GameAssets.colorDefault(outfit); }
			
			// if(animatePose) outfit.play(); else outfit.stopAtLastFrame();
		}
		
		public function setDragBounds(pX:Number, pY:Number, pWidth:Number, pHeight:Number): CustomItem {
			_dragBounds = new Rectangle(pX, pY, pWidth, pHeight); return this;
		}
		public function clampCoordsToDragBounds() : void {
			this.x = Math.max(_dragBounds.x, Math.min(_dragBounds.right, this.x));
			this.y = Math.max(_dragBounds.y, Math.min(_dragBounds.bottom, this.y));
		}
		
		public function getSaveImageDisplayObject() : DisplayObject {
			return _itemData.isBitmap() ? (_itemData as BitmapItemData).getFullImage() : this;
		}

		/////////////////////////////
		// Item Data
		/////////////////////////////
		public function getCurrentItemData() : ItemData {
			return _itemData;
		}
		
		public function getItemData(pType:ItemType) : ItemData {
			return _itemData;
		}

		public function setItemData(pItem:ItemData) : void {
			_itemData = pItem;
			updateItem();
		}

		public function removeItem(pType:ItemType) : void {
			_itemData = null;
			updateItem();
		}

		/////////////////////////////
		// Share Code
		/////////////////////////////
		public function parseShareCode(pCode:String) : Boolean {
			if(pCode.indexOf("=") > -1) {
				return _parseFewfreSyntax(pCode);
			} else {
				return false;
			}
		}
		
		private function _itemDataToShareString(pData:ItemData) : String {
			if(pData.isCustomizable && String(pData.colors) != String(pData.defaultColors)) { // Quick way to compare two arrays with primitive types
				return pData.id+"_"+_intListToHexList(pData.colors).join("+");
			}
			return pData.id;
		}
		
		private function _parseItemDataShareString(pItemType:ItemType, pShareString:String) : ItemData {
			var tData:ItemData = null;
			var tShareStringSplit = pShareString.split("_");
			var id = tShareStringSplit[0], colors = (tShareStringSplit[1] || "").split(/[ \+]/); // split on + or space (since + turns into space in urls)
			
			tData = GameAssets.getItemFromTypeID(pItemType, id);
			if(isOutfit) tData = tData.copy();
			
			if(colors.length > 0 && tData.isCustomizable) { tData.colors = _hexArrayToIntList(colors, tData.defaultColors); }
			return tData;
		}
		
		private function _intListToHexList(pColors:Vector.<uint>) : Vector.<String> {
			var hexList = new Vector.<String>();
			for(var i = 0; i < pColors.length; i++) {
				hexList.push( FewfUtils.colorIntToHexString(pColors[i]) );
			}
			return hexList;
		}
		
		private function _hexArrayToIntList(pColors:Array, pDefaults:Vector.<uint>) : Vector.<uint> {
			var ints = new Vector.<uint>();
			for(var i = 0; i < pDefaults.length; i++) {
				ints.push( pColors[i] ? FewfUtils.colorHexStringToInt(pColors[i]) : pDefaults[i] );
			}
			return ints;
		}
		
		/////////////////////////////
		// Fewfre Share Code Syntax
		/////////////////////////////
		private function _parseFewfreSyntax(pCode:String) : Boolean {
			// try {
				var pParams = new URLVariables();
				pParams.decode(pCode);
				
				for each(var tType:ItemType in ItemType.ALL) {
					var tItemShareCode:String = pParams[tType.toString()];
					if(tItemShareCode) {
						_itemData = _parseItemDataShareString(tType, tItemShareCode);
						break;
					}
				}
			// } catch (error:Error) { return false; };
			return true;
		}

		public function getShareCodeFewfreSyntax() : String {
			var parts:Array = [
				_itemData.type.toString()+"="+_itemDataToShareString(_itemData)
			];
			return parts.join("&");
		}
	}
}
