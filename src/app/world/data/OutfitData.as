package app.world.data
{
	import app.data.GameAssets;
	import app.data.ItemType;
	import app.data.ShamanMode;
	import app.world.data.ItemData;
	import app.world.data.SkinData;
	import com.fewfre.utils.FewfUtils;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLVariables;
	import flash.utils.Dictionary;

	public class OutfitData extends EventDispatcher
	{
		// Constants
		public static const UPDATED : String = "updated";
		
		// Storage
		// private var _itemDataMap:Dictionary; // Record<ItemType, ItemData>
		private var _itemData:ItemData;
		
		public var _flagMakeItemDataCopiesFromShareCodes:Boolean;

		// Constructor
		public function OutfitData(pMakeCopies:Boolean=false) {
			super();
			_flagMakeItemDataCopiesFromShareCodes = pMakeCopies;
			// _itemDataMap = new Dictionary();
		}
		public function copy() : OutfitData { var od:OutfitData; (od=new OutfitData(_flagMakeItemDataCopiesFromShareCodes)).parseShareCode(this.stringify_fewfreSyntax()); return od; }
		public function on(type:String, listener:Function): OutfitData { this.addEventListener(type, listener); return this; }
		public function off(type:String, listener:Function): OutfitData { this.removeEventListener(type, listener); return this; }

		private function _dispatchUpdate() : void { dispatchEvent(new Event(UPDATED)); }

		/////////////////////////////
		//#region Item Data
		/////////////////////////////
		public function getCurrentItemData() : ItemData {
			return _itemData;
		}
		
		public function getItemData(pType:ItemType) : ItemData {
			// return _itemDataMap[pType];
			return _itemData;
		}

		// public function getItemDataVector() : Vector.<ItemData> {
		// 	var list:Vector.<ItemData> = new Vector.<ItemData>();
		// 	for each(var itemData:ItemData in _itemDataMap) {
		// 		list.push(itemData);
		// 	}
		// 	return list;
		// }

		public function setItemData(pItemData:ItemData) : OutfitData {
			// _itemDataMap[pItemData.type] = pItemData;
			_itemData = pItemData;
			_dispatchUpdate();
			return this;
		}

		// public function setItemDataVector(pItemDatas:Vector.<ItemData>) : OutfitData {
		// 	for each(var itemData:ItemData in pItemDatas) {
		// 		_itemDataMap[itemData.type] = itemData;
		// 	}
		// 	_dispatchUpdate();
		// 	return this;
		// }

		public function removeItem(pType:ItemType) : void {
			// _itemDataMap[pType] = null;
			_itemData = null;
			_dispatchUpdate();
		}

		/////////////////////////////
		//#region Share Code - Parse
		/////////////////////////////
		public function parseShareCode(pCode:String) : Boolean {
			if(!pCode) return true; // true since technically no errors, just an empty share code?
			
			if(pCode.indexOf("=") > -1) {
				return _parseFewfreSyntax(pCode);
			} else {
				return false;
			}
		}
		public function parseShareCodeSelf(pCode:String) : OutfitData {
			parseShareCode(pCode);
			return this;
		}
		
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
		
		private function _parseItemDataShareString(pItemType:ItemType, pShareString:String) : ItemData {
			var tData:ItemData = null;
			var tShareStringSplit = pShareString.split("_");
			var id = tShareStringSplit[0], colors = (tShareStringSplit[1] || "").split(/[ \+]/); // split on + or space (since + turns into space in urls)
			
			tData = GameAssets.getItemFromTypeID(pItemType, id);
			if(_flagMakeItemDataCopiesFromShareCodes) tData = tData.copy();
			
			if(colors.length > 0 && tData.isCustomizable) { tData.colors = _hexArrayToIntList(colors, tData.defaultColors); }
			return tData;
		}
		
		private function _hexArrayToIntList(pColors:Array, pDefaults:Vector.<uint>) : Vector.<uint> {
			var ints = new Vector.<uint>();
			for(var i = 0; i < pDefaults.length; i++) {
				ints.push( pColors[i] ? FewfUtils.colorHexStringToInt(pColors[i]) : pDefaults[i] );
			}
			return ints;
		}

		/////////////////////////////
		//#region Share Code - Stringify
		/////////////////////////////
		public function stringify_fewfreSyntax() : String {
			var parts:Array = [
				_itemData.type.toString()+"="+_itemDataToShareString(_itemData)
			];
			return parts.join("&");
		}
		
		private function _itemDataToShareString(pData:ItemData) : String {
			if(pData.isCustomizable && String(pData.colors) != String(pData.defaultColors)) { // Quick way to compare two arrays with primitive types
				return pData.id+"_"+_intListToHexList(pData.colors).join("+");
			}
			return pData.id;
		}
		
		private function _intListToHexList(pColors:Vector.<uint>) : Vector.<String> {
			var hexList = new Vector.<String>();
			for(var i = 0; i < pColors.length; i++) {
				hexList.push( FewfUtils.colorIntToHexString(pColors[i]) );
			}
			return hexList;
		}
	}
}
