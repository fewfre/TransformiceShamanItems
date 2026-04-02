package app.world.data
{
	import app.data.ItemType;
	import app.ui.common.LoadingSpinner;
	import com.fewfre.utils.Fewf;
	import flash.display.*;
	import flash.events.Event;

	public class BitmapItemData extends ItemData
	{
		// Storage
		public var url : String;
		
		// Properties
		public override function get isCustomizable() : Boolean { return false; }
		
		// Constructor
		public function BitmapItemData(pType:ItemType, pId:String, pUrl:String) {
			super(pType, pId.replace('x_', '').replace('.png', ''), {});
			this.url = pUrl;
		}
		public override function copy() : ItemData { return new BitmapItemData(type, id, url); }
		
		protected override function _initDefaultColors() : void { defaultColors = new Vector.<uint>(); } // Bitmaps don't use customizable colors
		
		public override function isBitmap() : Boolean { return true; }

		public override function getPart(pID:String, pOptions:Object=null) : Class {
			return null;
		}
		
		// Override me
		public function getSmallImage() : Bitmap { return getFullImage(); }
		
		public function getFullImage() : Bitmap {
			return Fewf.assets.lazyLoadImageUrlAsBitmap(url);
		}
		
		public function getLargeOutfitImageAsMovieClip() : MovieClip {
			var mc:MovieClip = new MovieClip();
			var bitmap : Bitmap = getLargeOutfitImageAsMovieClip_resize(this.getFullImage());
			bitmap.addEventListener(Event.COMPLETE, function(e:Event):void{
				mc.removeChildAt(0);
				mc.addChild(getLargeOutfitImageAsMovieClip_resize(e.currentTarget as Bitmap));
			});
			if(bitmap.width > 0) {
				mc.addChild(bitmap);
			} else {
				// We need a bg at the same size we plan to have mc be (160) so that auto scale logic will still be correct
				var bg:MovieClip = new MovieClip();
				bg.graphics.drawRect(-80, -80 - 16, 160, 160);
				new LoadingSpinner(2).setSpeedScale(0.5).move(0, -16).appendTo(bg);
				mc.addChild(bg);
			}
			return mc;
		}
		private function getLargeOutfitImageAsMovieClip_resize(bitmap:Bitmap) : Bitmap {
			if(this.type == ItemType.BADGE) bitmap.width = bitmap.height = 160;
			bitmap.x = -bitmap.width / 2;
			bitmap.y = -bitmap.height / 2 - 16; // offset since main "outfit" x is slightly outfit based on shaman item origin
			return bitmap;
		}
	}
}
