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
		
		public static var boxes_small: Vector.<ItemData>;
		public static var boxes_large: Vector.<ItemData>;
		public static var planks_small: Vector.<ItemData>;
		public static var planks_large: Vector.<ItemData>;
		public static var balls: Vector.<ItemData>;
		public static var trampolines: Vector.<ItemData>;
		public static var anvils: Vector.<ItemData>;
		public static var cannonballs: Vector.<ItemData>;
		public static var balloons: Vector.<ItemData>;
		public static var cartouches: Vector.<ItemData>;
		
		// { type:ITEM, id:String, colorI:int }
		public static var swatchHoverPreviewData:Object = null;

		public static function init() : void {
			boxes_small = _setupCostumeList(ItemType.BOX_SMALL, "$Objet_1", { pad:2 });
			boxes_large = _setupCostumeList(ItemType.BOX_LARGE, "$Objet_2", { pad:2 });
			planks_small = _setupCostumeList(ItemType.PLANK_SMALL, "$Objet_3", { pad:2 });
			planks_large = _setupCostumeList(ItemType.PLANK_LARGE, "$Objet_4", { pad:2 });
			balls = _setupCostumeList(ItemType.BALL, "$Objet_6", { pad:2 });
			trampolines = _setupCostumeList(ItemType.TRAMPOLINE, "$Objet_7", { pad:2 });
			anvils = _setupCostumeList(ItemType.ANVIL, "$Objet_10", { pad:2 });
			cannonballs = _setupCostumeList(ItemType.CANNONBALL, "$Objet_17", { pad:2 });
			balloons = _setupCostumeList(ItemType.BALLOON, "$Objet_28", { pad:2 });
			cartouches = _setupCostumeList(ItemType.CARTOUCHE, "$Macaron_", {});
		}

		// pData = { after:String, pad:int }
		private static function _setupCostumeList(type:ItemType, base:String, pData:Object) : Vector.<ItemData> {
			var list:Vector.<ItemData> = new Vector.<ItemData>(), tClassName:String, tClass:Class;
			var breakCount = 0; // quit early if enough nulls in a row
			
			for(var i = 0; i <= _MAX_COSTUMES_TO_CHECK_TO; i++) {
				// hardcoded skip for duplicate items in game files - TODO: add values to config maybe?
				if(i == 26 && type == ItemType.BALLOON) {
					continue;
				}
				
				tClass = Fewf.assets.getLoadedClass( base+(pData.pad ? zeroPad(i, pData.pad) : i)+(pData.after ? pData.after : "") );
				if(tClass != null) {
					breakCount = 0;
					list.push( new ItemData(type, i, { itemClass:tClass }) );
				} else {
					breakCount++;
					if(breakCount > 5) {
						break;
					}
				}
			}
			return list;
		}

		public static function zeroPad(number:int, width:int):String {
			var ret:String = ""+number;
			while( ret.length < width )
				ret="0" + ret;
			return ret;
		}

		public static function getItemDataListByType(pType:ItemType) : Vector.<ItemData> {
			switch(pType) {
				case ItemType.BOX_SMALL:	return boxes_small;
				case ItemType.BOX_LARGE:	return boxes_large;
				case ItemType.PLANK_SMALL:	return planks_small;
				case ItemType.PLANK_LARGE:	return planks_large;
				case ItemType.BALL:			return balls;
				case ItemType.TRAMPOLINE:	return trampolines;
				case ItemType.ANVIL:		return anvils;
				case ItemType.CANNONBALL:	return cannonballs;
				case ItemType.BALLOON:		return balloons;
				case ItemType.CARTOUCHE:	return cartouches;
				default: trace("[GameAssets](getArrayByType) Unknown type: "+pType);
			}
			return null;
		}

		public static function getItemFromTypeID(pType:ItemType, pID:String) : ItemData {
			return FewfUtils.getFromVectorWithKeyVal(getItemDataListByType(pType), "id", pID);
		}

		public static function getItemIndexFromTypeID(pType:ItemType, pID:String) : int {
			return FewfUtils.getIndexFromVectorWithKeyVal(getItemDataListByType(pType), "id", pID);
		}

		/****************************
		* Color - GET
		*****************************/
		public static function findDefaultColors(pMC:MovieClip) : Vector.<uint> {
			return Vector.<uint>( _findDefaultColorsRecursive(pMC, []) );
		}
		private static function _findDefaultColorsRecursive(pMC:MovieClip, pList:Array) : Array {
			if (!pMC) { return pList; }

			var child:DisplayObject=null, name:String=null, colorI:int = 0;
			var i:*=0;
			while (i < pMC.numChildren)
			{
				child = pMC.getChildAt(i);
				name = child.name;
				
				if(name) {
					if (name.indexOf("Couleur") == 0 && name.length > 7) {
						colorI = int(name.charAt(7));
						pList[colorI] = int("0x" + name.split("_")[1]);
					}
					else if(name.indexOf("slot_") == 0) {
						_findDefaultColorsRecursive(child as MovieClip, pList);
					}
					i++;
				}
			}
			return pList;
		}

		public static function getNumOfCustomColors(pMC:MovieClip) : int {
			// Use recursive one since the array it returns is a bit more safe for this than the vector
			return _findDefaultColorsRecursive(pMC, []).length;
		}
		
		public static function getColorsWithPossibleHoverEffect(pData:ItemData) : Vector.<uint> {
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
		* Color - APPLY
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
		
		// pColor is an int hex value. ex: 0x000000
		public static function applyColorToObject(pItem:DisplayObject, pColor:int) : void {
			if(pColor < 0) { return; }
			var tR:*=pColor >> 16 & 255;
			var tG:*=pColor >> 8 & 255;
			var tB:*=pColor & 255;
			pItem.transform.colorTransform = new flash.geom.ColorTransform(tR / 128, tG / 128, tB / 128);
		}

		public static function colorItemUsingColorList(pSprite:Sprite, pColors:Vector.<uint>) : DisplayObject {
			if (pSprite == null) { return null; }

			var tChild: DisplayObject, name:String;
			var i:int=0;
			while (i < pSprite.numChildren) {
				tChild = pSprite.getChildAt(i); name = tChild.name;
				
				if (name.indexOf("Couleur") == 0 && name.length > 7) {
					// hardcoded fix for tfm eye:31, which has a color of: Couleur_08C7474 (0 and _ are swapped)
					var colorI:int = int(name.charAt(7) == '_' ? name.charAt(8) : name.charAt(7));
					// fallback encase colorI is outside of the list
					var color:uint = colorI < pColors.length ? pColors[colorI] : int("0x" + name.split("_")[1]);
					applyColorToObject(tChild, color);
				}
				else if(tChild.name.indexOf("slot_") == 0) {
					colorItemUsingColorList(tChild as Sprite, pColors);
				}
				i++;
			}
			return pSprite;
		}

		public static function colorDefault(pMC:MovieClip) : MovieClip {
			var colors:Vector.<uint> = findDefaultColors(pMC);
			colorItemUsingColorList(pMC, colors);
			return pMC;
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

		/****************************
		* Asset Creation
		*****************************/
		public static function getItemImage(pData:ItemData) : MovieClip {
			var tItem:MovieClip = new pData.itemClass();
			colorDefault(tItem);
			return tItem;
		}
		
		public static function getColoredItemImage(pData:ItemData) : MovieClip {
			return colorItemUsingColorList(getItemImage(pData), getColorsWithPossibleHoverEffect(pData)) as MovieClip;
		}
		
		/****************************
		* Misc
		*****************************/
		public static function createHorizontalRule(pX:Number, pY:Number, pWidth:Number) : Sprite {
			var tLine:Sprite = new Sprite(); tLine.x = pX; tLine.y = pY;
			
			tLine.graphics.lineStyle(1, 0x11181c, 1, true);
			tLine.graphics.moveTo(0, 0);
			tLine.graphics.lineTo(pWidth, 0);
			
			tLine.graphics.lineStyle(1, 0x608599, 1, true);
			tLine.graphics.moveTo(0, 1);
			tLine.graphics.lineTo(pWidth, 1);
			
			return tLine;
		}
	}
}
