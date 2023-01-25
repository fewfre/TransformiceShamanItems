package app.data
{
	import com.adobe.images.*;
	import com.fewfre.utils.*;
	import com.piterwilson.utils.ColorMathUtil;
	import app.data.*;
	import app.world.data.*;
	import app.world.elements.*;
	import flash.display.*;
	import flash.geom.*;
	import flash.net.*;

	public class GameAssets
	{
		private static const _MAX_COSTUMES_TO_CHECK_TO:Number = 999;
		
		public static var boxes_small:Array;
		public static var boxes_large:Array;
		public static var planks_small:Array;
		public static var planks_large:Array;
		public static var balls:Array;
		public static var trampolines:Array;
		public static var anvils:Array;
		public static var cannonballs:Array;
		public static var balloons:Array;
		public static var cartouches:Array;
		
		// { type:ITEM, id:String, colorI:int }
		public static var swatchHoverPreviewData:Object = null;

		public static function init() : void {
			boxes_small = _setupCostumeArray({ base:"$Objet_1", type:ITEM.BOX_SMALL, pad:2 });
			boxes_large = _setupCostumeArray({ base:"$Objet_2", type:ITEM.BOX_LARGE, pad:2 });
			planks_small = _setupCostumeArray({ base:"$Objet_3", type:ITEM.PLANK_SMALL, pad:2 });
			planks_large = _setupCostumeArray({ base:"$Objet_4", type:ITEM.PLANK_LARGE, pad:2 });
			balls = _setupCostumeArray({ base:"$Objet_6", type:ITEM.BALL, pad:2 });
			trampolines = _setupCostumeArray({ base:"$Objet_7", type:ITEM.TRAMPOLINE, pad:2 });
			anvils = _setupCostumeArray({ base:"$Objet_10", type:ITEM.ANVIL, pad:2 });
			cannonballs = _setupCostumeArray({ base:"$Objet_17", type:ITEM.CANNONBALL, pad:2 });
			balloons = _setupCostumeArray({ base:"$Objet_28", type:ITEM.BALLOON, pad:2 });
			cartouches = _setupCostumeArray({ base:"$Macaron_", type:ITEM.CARTOUCHE });
		}

		// pData = { base:String, type:String, after:String, pad:int }
		private static function _setupCostumeArray(pData:Object) : Array {
			var tArray:Array = new Array();
			var tClassName:String;
			var tClass:Class;
			var breakCount = 0; // quit early if enough nulls in a row
			for(var i = 0; i <= _MAX_COSTUMES_TO_CHECK_TO; i++) {
				// hardcoded skip for duplicate items in game files - TODO: add values to config maybe?
				if(i == 26 && pData.type == ITEM.BALLOON) {
					continue;
				}
				
				tClass = Fewf.assets.getLoadedClass( pData.base+(pData.pad ? zeroPad(i, pData.pad) : i)+(pData.after ? pData.after : "") );
				if(tClass != null) {
					breakCount = 0;
					tArray.push( new ItemData({ id:i, type:pData.type, itemClass:tClass}) );
				} else {
					breakCount++;
					if(breakCount > 5) {
						break;
					}
				}
			}
			return tArray;
		}

		public static function zeroPad(number:int, width:int):String {
			var ret:String = ""+number;
			while( ret.length < width )
				ret="0" + ret;
			return ret;
		}

		public static function getArrayByType(pType:String) : Array {
			switch(pType) {
				case ITEM.BOX_SMALL:	return boxes_small;
				case ITEM.BOX_LARGE:	return boxes_large;
				case ITEM.PLANK_SMALL:	return planks_small;
				case ITEM.PLANK_LARGE:	return planks_large;
				case ITEM.BALL:			return balls;
				case ITEM.TRAMPOLINE:	return trampolines;
				case ITEM.ANVIL:		return anvils;
				case ITEM.CANNONBALL:	return cannonballs;
				case ITEM.BALLOON:		return balloons;
				case ITEM.CARTOUCHE:	return cartouches;
				default: trace("[GameAssets](getArrayByType) Unknown type: "+pType);
			}
			return null;
		}

		public static function getItemFromTypeID(pType:String, pID:String) : ItemData {
			return FewfUtils.getFromArrayWithKeyVal(getArrayByType(pType), "id", pID);
		}

		/****************************
		* Color
		*****************************/
		public static function copyColor(copyFromMC:MovieClip, copyToMC:MovieClip) : MovieClip {
			if (copyFromMC == null || copyToMC == null) { return null; }
			var tChild1:*=null;
			var tChild2:*=null;
			var i:int = 0;
			while (i < copyFromMC.numChildren) {
				tChild1 = copyFromMC.getChildAt(i);
				tChild2 = copyToMC.getChildAt(i);
				if (tChild1.name.indexOf("Couleur") == 0 && tChild1.name.length > 7) {
					tChild2.transform.colorTransform = tChild1.transform.colorTransform;
				}
				i++;
			}
			return copyToMC;
		}

		public static function colorDefault(pMC:MovieClip) : MovieClip {
			if (pMC == null) { return null; }

			var tChild:*=null;
			var tHex:int=0;
			var i:int=0;
			while (i < pMC.numChildren) {
				tChild = pMC.getChildAt(i);
				if (tChild.name.indexOf("Couleur") == 0 && tChild.name.length > 7)
				{
					// tHex = int("0x" + tChild.name.substr(tChild.name.indexOf("_") + 1, 6));
					tHex = int("0x" + tChild.name.split("_")[1].substr(-6, 6));
					applyColorToObject(tChild, tHex);
				}
				i++;
			}
			return pMC;
		}

		// pData = { obj:DisplayObject, color:String OR int, ?swatch:int, ?name:String, ?colors:Array<int> }
		public static function colorItem(pData:Object) : DisplayObject {
			if (pData.obj == null) { return null; }

			var tHex:int = convertColorToNumber(pData.color);

			var tChild:DisplayObject;
			var i:int=0;
			while (i < pData.obj.numChildren) {
				tChild = pData.obj.getChildAt(i);
				if (tChild.name == pData.name || (tChild.name.indexOf("Couleur") == 0 && tChild.name.length > 7)) {
					if(pData.colors != null && pData.colors[tChild.name.charAt(7)] != null) {
						applyColorToObject(tChild, convertColorToNumber(pData.colors[tChild.name.charAt(7)]));
					}
					else if (!pData.swatch || pData.swatch == tChild.name.charAt(7)) {
						applyColorToObject(tChild, tHex);
					}
				}
				i++;
			}
			return pData.obj;
		}
		public static function convertColorToNumber(pColor) : int {
			return pColor is Number || pColor == null ? pColor : int("0x" + pColor);
		}
		
		// pColor is an int hex value. ex: 0x000000
		public static function applyColorToObject(pItem:DisplayObject, pColor:int) : void {
			if(pColor < 0) { return; }
			var tR:*=pColor >> 16 & 255;
			var tG:*=pColor >> 8 & 255;
			var tB:*=pColor & 255;
			pItem.transform.colorTransform = new flash.geom.ColorTransform(tR / 128, tG / 128, tB / 128);
		}

		public static function getColors(pMC:MovieClip) : Array {
			var tChild:*=null;
			var tTransform:*=null;
			var tArray:Array=new Array();

			var i:int=0;
			while (i < pMC.numChildren) {
				tChild = pMC.getChildAt(i);
				if (tChild.name.indexOf("Couleur") == 0 && tChild.name.length > 7) {
					tTransform = tChild.transform.colorTransform;
					tArray[tChild.name.charAt(7)] = ColorMathUtil.RGBToHex(tTransform.redMultiplier * 128, tTransform.greenMultiplier * 128, tTransform.blueMultiplier * 128);
				}
				i++;
			}
			return tArray;
		}

		public static function getNumOfCustomColors(pMC:MovieClip) : int {
			var tChild:*=null;
			var num:int = 0;
			var i:int = 0;
			while (i < pMC.numChildren) {
				tChild = pMC.getChildAt(i);
				if (tChild.name.indexOf("Couleur") == 0 && tChild.name.length > 7) {
					num++;
				}
				i++;
			}
			return num;
		}
		
		public static function getColoredItemImage(pData:ItemData) : MovieClip {
			return colorItem({ obj:getItemImage(pData), colors:getColorsWithPossibleHoverEffect(pData) }) as MovieClip;
		}
		
		public static function getColorsWithPossibleHoverEffect(pData:ItemData) : Array {
			if(!pData.colors || !swatchHoverPreviewData) { return pData.colors; }
			var colors = pData.colors.concat();
			if(pData.type == swatchHoverPreviewData.type && pData.id == swatchHoverPreviewData.id) {
				var i = swatchHoverPreviewData.colorI;
				colors[i] = GameAssets.invertColor(colors[i]);
			}
			return colors;
		}
		
		public static function invertColor(pColor:uint) : uint {
			var tR:*=pColor >> 16 & 255;
			var tG:*=pColor >> 8 & 255;
			var tB:*=pColor & 255;
			
			return (255-tR)<<16 | (255-tG)<<8 | (255-tB);
		}

		/****************************
		* Asset Creation
		*****************************/
		public static function getItemImage(pData:ItemData) : MovieClip {
			var tItem:MovieClip = new pData.itemClass();
			colorDefault(tItem);
			return tItem;
		}
	}
}
