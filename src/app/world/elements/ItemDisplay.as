package app.world.elements
{
	import flash.display.MovieClip;
	import app.world.data.ItemData;
	import app.world.data.BitmapItemData;
	import app.data.GameAssets;

	public class ItemDisplay extends MovieClip
	{
		// Constructor
		public function ItemDisplay(pItemData:ItemData) {
			super();
			var item:MovieClip;
			if(!pItemData.isBitmap()) { item = new (pItemData.itemClass)(); }
			else { item = (pItemData as BitmapItemData).getLargeOutfitImageAsMovieClip(); }
			addChild(item);
			
			if(pItemData.colors != null) {
				GameAssets.colorItemUsingColorList(item, GameAssets.getColorsWithPossibleHoverEffect(pItemData));
			}
			else { GameAssets.colorDefault(item); }
		}
	}
}
