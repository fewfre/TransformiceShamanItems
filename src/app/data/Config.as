package app.data
{
	import com.fewfre.utils.Fewf;

	public class Config
	{
		private static function get(pConfigField:String) : * { return (Fewf.assets.getData("config") || {})[pConfigField]; }
		
		public static function get cacheBreaker() : String { return get("cachebreaker"); }
		public static function get languagesObject() : Object { return get("languages"); }
		
		// Scripts
		public static function get uploadToImgurUrl() : String { return _fixProtocol(get("upload2imgur_url")); }
		// public static function get spriteSheetToGifUrl() : String { return _fixProtocol(get("spritesheet2gif_url")); }
		private static function _fixProtocol(pUrl:String) : String { return pUrl ? pUrl.replace("https://", Fewf.networkProtocol+"://") : pUrl; }
		
		// Assets
		public static function get packs() : Object { return get("packs"); }
		public static function get packsExternal() : Array { return get("packs_external"); }
		public static function get banners() : Array { return get("banners"); }
		
		public static function get badges() : Array { return get("badges"); }
		private static var _badgesAsVectorCache:Vector.<BadgeProps>;
		public static function get badgesAsVector() : Vector.<BadgeProps> {
			if (!_badgesAsVectorCache && get("badges")) {
				var arr:Array = get("badges");
				_badgesAsVectorCache = new Vector.<BadgeProps>();
				for each(var obj:Object in arr) {
					_badgesAsVectorCache.push(new BadgeProps(obj.s, obj.l));
				}
			}
			return _badgesAsVectorCache;
		}
	}
}

class BadgeProps {
	public var small:String;
	public var large:String;
	public function BadgeProps(pSmall:String, pLarge:String) {
		this.small = pSmall;
		this.large = pLarge;
	}
}