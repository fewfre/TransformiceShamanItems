package app.world
{
	import app.data.ItemType;
	import app.ui.panes.*;
	import app.ui.panes.base.*;
	import app.ui.panes.colorpicker.ColorPickerTabPane;

	public class WorldPaneManager extends PaneManager
	{
		// Pane IDs
		public static const COLOR_PANE:String = "colorPane";
		public static const COLOR_FINDER_PANE:String = "colorFinderPane";
		
		public static const OUTFITS_PANE:String = "outfits";
		
		// Constructor
		public function WorldPaneManager() {
			super();
		}
		
		// ShopCategoryPane methods
		public function openShopPane(pType:ItemType) : ShopCategoryPane { return openPane(itemTypeToId(pType)) as ShopCategoryPane; }
		public function getShopPane(pType:ItemType) : ShopCategoryPane { return getPane(itemTypeToId(pType)) as ShopCategoryPane; }
		
		// Shortcuts to get panes with correct typing
		public function get colorPickerPane() : ColorPickerTabPane { return getPane(COLOR_PANE) as ColorPickerTabPane; }
		public function get colorFinderPane() : ColorFinderPane { return getPane(COLOR_PANE) as ColorFinderPane; }
		
		/////////////////////////////
		// Static
		/////////////////////////////
		public static function itemTypeToId(pType:ItemType) : String { return pType.toString(); }
	}
}