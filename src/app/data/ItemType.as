package app.data
{
	public final class ItemType
	{
		public static const BOX_SMALL			: ItemType = new ItemType("smallbox");
		public static const BOX_LARGE			: ItemType = new ItemType("largebox");
		public static const PLANK_SMALL			: ItemType = new ItemType("smallplank");
		public static const PLANK_LARGE			: ItemType = new ItemType("largeplank");
		public static const BALL				: ItemType = new ItemType("ball");
		public static const TRAMPOLINE			: ItemType = new ItemType("trampoline");
		public static const ANVIL				: ItemType = new ItemType("anvil");
		public static const CANNONBALL			: ItemType = new ItemType("cannonball");
		public static const BALLOON				: ItemType = new ItemType("balloon");
		public static const CARTOUCHE			: ItemType = new ItemType("cartouche");
		public static const BADGE				: ItemType = new ItemType("badge");
		
		public static const ALL : Vector.<ItemType> = new <ItemType>[
			BOX_SMALL, BOX_LARGE, PLANK_SMALL, PLANK_LARGE, BALL, TRAMPOLINE, ANVIL, CANNONBALL, BALLOON, CARTOUCHE, BADGE ];
		
		// Enum Storage + Constructor
		private var _value: String;
		function ItemType(pValue:String) { _value = pValue; }
		
		// This is required for proper auto string convertion on `trace`/`Dictionary` and such - enums should always have
		public function toString() : String { return _value.toString(); }
		public static function fromString(pValue:String) : ItemType {
			if(!pValue) return null;
			for each(var type:ItemType in ALL) {
				if(type.toString() == pValue) {
					return type;
				}
			}
			return null;
		}
	}
}
