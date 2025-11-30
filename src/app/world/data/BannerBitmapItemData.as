package app.world.data
{
	import app.data.*;
	import flash.display.*;
	import flash.geom.*;
	import com.fewfre.utils.Fewf;
	import flash.events.Event;
	import com.fewfre.utils.FewfDisplayUtils;

	public class BannerBitmapItemData extends BitmapItemData
	{
		// Constructor
		public function BannerBitmapItemData(pType:ItemType, pUrl:String) {
			super(pType, pUrl, null);
		}
		public override function copy() : ItemData { return new BannerBitmapItemData(type, url); }
		
		public override function getSmallImage() : Bitmap {
			var bitmap : Bitmap = new Bitmap(), sizex:Number = 120;
			var origImage : Bitmap = this.getFullImage();
			bitmap.bitmapData = _centerBitmapIntoSize(origImage, sizex);
			origImage.addEventListener(Event.COMPLETE, function(e:Event):void{
				bitmap.bitmapData = _centerBitmapIntoSize(e.currentTarget as Bitmap, sizex);
				bitmap.dispatchEvent(e);
			});
			return bitmap;
		}
		private function _centerBitmapIntoSize(pImage:Bitmap, pWidth:Number) : BitmapData {
			if(!pImage || pImage.width == 0) { return null; }
			var sizey:Number = 48;
			return FewfDisplayUtils.bitmapDataDrawBestQuality(new BitmapData(pWidth, sizey, true, 0xFFFFFF), pImage, new Matrix(1, 0, 0, 1, pWidth/2 - pImage.width/2, sizey/2 - pImage.height/2));
		}
	}
}
