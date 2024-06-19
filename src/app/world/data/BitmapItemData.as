package app.world.data
{
	import app.data.*;
	import flash.display.*;
	import flash.geom.*;
	import com.fewfre.utils.Fewf;
	import flash.events.Event;
	import com.fewfre.utils.FewfDisplayUtils;
	import app.ui.screens.LoadingSpinner;

	public class BitmapItemData extends ItemData
	{
		public var url : String;
		public var urlSmall : String;
		
		public function BitmapItemData(pType:ItemType, pUrl:String, pUrlSmall:String=null) {
			var id:String = pUrl.split('/').pop();
			id = id.replace('x_', '').replace('L', '').replace('.png', '');
			super(pType, id, {});
			this.url = pUrl;
			this.urlSmall = pUrlSmall;
		}
		
		protected override function _initDefaultColors() : void {
			defaultColors = new Vector.<uint>();
		}
		
		public override function isBitmap() : Boolean { return true; }

		public override function getPart(pID:String, pOptions:Object=null) : Class {
			return null;
		}
		
		public function getSmallImage() : Bitmap {
			return Fewf.assets.lazyLoadImageUrlAsBitmap(this.urlSmall || this.url);
		}
		
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
				bg.addChild(new LoadingSpinner({ scale:2, speedScale:0.5, y:-16 }));
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
