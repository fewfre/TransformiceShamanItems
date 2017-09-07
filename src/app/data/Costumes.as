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

	public class Costumes
	{
		private static var _instance:Costumes;
		public static function get instance() : Costumes {
			if(!_instance) { new Costumes(); }
			return _instance;
		}
		
		private const _MAX_COSTUMES_TO_CHECK_TO:Number = 100;//999;
		
		public var boxes_small:Array;
		public var boxes_large:Array;
		public var planks_small:Array;
		public var planks_large:Array;
		public var balls:Array;
		public var trampolines:Array;
		public var anvils:Array;
		public var cannonballs:Array;
		public var balloons:Array;

		public function Costumes() {
			if(_instance){ throw new Error("Singleton class; Call using Costumes.instance"); }
			_instance = this;

			this.boxes_small = _setupCostumeArray({ base:"$Objet_1", type:ITEM.BOX_SMALL, pad:2 });
			this.boxes_large = _setupCostumeArray({ base:"$Objet_2", type:ITEM.BOX_LARGE, pad:2 });
			this.planks_small = _setupCostumeArray({ base:"$Objet_3", type:ITEM.PLANK_SMALL, pad:2 });
			this.planks_large = _setupCostumeArray({ base:"$Objet_4", type:ITEM.PLANK_LARGE, pad:2 });
			this.balls = _setupCostumeArray({ base:"$Objet_6", type:ITEM.BALL, pad:2 });
			this.trampolines = _setupCostumeArray({ base:"$Objet_7", type:ITEM.TRAMPOLINE, pad:2 });
			this.anvils = _setupCostumeArray({ base:"$Objet_10", type:ITEM.ANVIL, pad:2 });
			this.cannonballs = _setupCostumeArray({ base:"$Objet_17", type:ITEM.CANNONBALL, pad:2 });
			this.balloons = _setupCostumeArray({ base:"$Objet_28", type:ITEM.BALLOON, pad:2 });
		}

		// pData = { base:String, type:String, after:String, pad:int }
		private function _setupCostumeArray(pData:Object) : Array {
			var tArray:Array = new Array();
			var tClassName:String;
			var tClass:Class;
			for(var i = 0; i <= _MAX_COSTUMES_TO_CHECK_TO; i++) {
				tClass = Fewf.assets.getLoadedClass( pData.base+(pData.pad ? zeroPad(i, pData.pad) : i)+(pData.after ? pData.after : "") );
				if(tClass != null) {
					tArray.push( new ItemData({ id:i, type:pData.type, itemClass:tClass}) );
				}
			}
			return tArray;
		}

		public function zeroPad(number:int, width:int):String {
			var ret:String = ""+number;
			while( ret.length < width )
				ret="0" + ret;
			return ret;
		}

		public function getArrayByType(pType:String) : Array {
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
				default: trace("[Costumes](getArrayByType) Unknown type: "+pType);
			}
			return null;
		}

		public function getItemFromTypeID(pType:String, pID:String) : ItemData {
			return FewfUtils.getFromArrayWithKeyVal(getArrayByType(pType), "id", pID);
		}

		/****************************
		* Color
		*****************************/
		public function copyColor(copyFromMC:MovieClip, copyToMC:MovieClip) : MovieClip {
			if (copyFromMC == null || copyToMC == null) { return; }
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

		public function colorDefault(pMC:MovieClip) : MovieClip {
			if (pMC == null) { return; }

			var tChild:*=null;
			var tHex:int=0;
			var loc1:*=0;
			while (loc1 < pMC.numChildren)
			{
				tChild = pMC.getChildAt(loc1);
				if (tChild.name.indexOf("Couleur") == 0 && tChild.name.length > 7)
				{
					tHex = int("0x" + tChild.name.substr(tChild.name.indexOf("_") + 1, 6));
					applyColorToObject(tChild, tHex);
				}
				++loc1;
			}
			return pMC;
		}

		// pData = { obj:DisplayObject, color:String OR int, ?swatch:int, ?name:String, ?colors:Array<int> }
		public function colorItem(pData:Object) : DisplayObject {
			if (pData.obj == null) { return; }

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
		public function convertColorToNumber(pColor) : int {
			return pColor is Number || pColor == null ? pColor : int("0x" + pColor);
		}
		
		// pColor is an int hex value. ex: 0x000000
		public function applyColorToObject(pItem:DisplayObject, pColor:int) : void {
			if(pColor < 0) { return; }
			var tR:*=pColor >> 16 & 255;
			var tG:*=pColor >> 8 & 255;
			var tB:*=pColor & 255;
			pItem.transform.colorTransform = new flash.geom.ColorTransform(tR / 128, tG / 128, tB / 128);
		}

		public function getColors(pMC:MovieClip) : Array {
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

		public function getNumOfCustomColors(pMC:MovieClip) : int {
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
		
		public function getColoredItemImage(pData:ItemData) : MovieClip {
			return colorItem({ obj:getItemImage(pData), colors:pData.colors });
		}

		/****************************
		* Asset Creation
		*****************************/
		public function getItemImage(pData:ItemData) : MovieClip {
			var tItem:MovieClip = new pData.itemClass();
			colorDefault(tItem);
			return tItem;
		}
	}
}
