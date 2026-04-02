package app.world.data
{
	import app.data.ItemType;
	import app.ui.common.LoadingSpinner;
	import com.fewfre.utils.Fewf;
	import flash.display.*;
	import flash.events.Event;

	public class BadgeBitmapItemData extends BitmapItemData
	{
		// Storage
		public var urlSmall : String;
		
		// Properties
		public function get isManualUpload() : Boolean { return !!this.url && this.url.indexOf('/u/') != -1; }
		
		// Constructor
		public function BadgeBitmapItemData(pType:ItemType, pUrl:String, pUrlSmall:String=null) {
			var tId:String = (pUrlSmall || pUrl).split('/').pop().replace('L', '');
			super(pType, tId, pUrl);
			this.url = pUrl;
			this.urlSmall = pUrlSmall;
		}
		public override function copy() : ItemData { return new BadgeBitmapItemData(type, url, urlSmall); }
		
		public override function getSmallImage() : Bitmap {
			return Fewf.assets.lazyLoadImageUrlAsBitmap(this.urlSmall || this.url);
		}
		
		public override function getFullImage() : Bitmap {
			if(!this.url) { return getSmallImage(); }
			return super.getFullImage();
		}
		public override function getLargeOutfitImageAsMovieClip() : MovieClip {
			return super.getLargeOutfitImageAsMovieClip();
		}
	}
}
