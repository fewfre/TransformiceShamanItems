package app.ui.panes
{
	import app.data.ConstantsApp;
	import app.data.FavoriteItemsLocalStorageManager;
	import app.data.GameAssets;
	import app.data.ItemType;
	import app.ui.buttons.PushButton;
	import app.ui.buttons.ScaleButton;
	import app.ui.buttons.SpriteButton;
	import app.ui.panes.base.ButtonGridSidePane;
	import app.ui.panes.infobar.Infobar;
	import app.ui.screens.LoadingSpinner;
	import app.world.data.BitmapItemData;
	import app.world.data.ItemData;
	import app.world.events.ItemDataEvent;
	import com.fewfre.display.Grid;
	import com.fewfre.events.FewfEvent;
	import com.fewfre.utils.Fewf;
	import com.fewfre.utils.FewfUtils;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;

	public class ShopCategoryPane extends ButtonGridSidePane
	{
		private var _type: ItemType;
		private var _defaultSkinColorButton: ScaleButton;
		public var _favoritesGrid : Grid;
		
		public function get type():ItemType { return _type; }
		
		public static const ITEM_TOGGLED : String = 'ITEM_TOGGLED'; // ItemDataEvent
		
		// Constructor
		public function ShopCategoryPane(pType:ItemType) {
			this._type = pType;
			var buttonPerRow:int = 6;
			if(_type == ItemType.PLANK_LARGE) { buttonPerRow = 4; }
			if(_type == ItemType.BOX_LARGE || _type == ItemType.TRAMPOLINE) { buttonPerRow = 5; }
			super(buttonPerRow);
			
			// Start reversed by default
			grid.reverse();
			
			this.addInfoBar( new Infobar({ showEyeDropper:true, showDownload:true, gridManagement:true, showFavorites:true }) );
			_infobar.on(Infobar.FAVORITE_CLICKED, _addRemoveFavoriteToggled);
			_setupGrid(GameAssets.getItemDataListByType(_type));
			
			_favoritesGrid = new Grid(ConstantsApp.PANE_WIDTH, 10, 3).move(7, 60+5).appendTo(this);
			_renderFavorites();
		}
		
		/****************************
		* Public
		*****************************/
		public override function open() : void {
			super.open();
		}
		
		public function getCellWithItemData(itemData:ItemData) : DisplayObject {
			return !itemData ? null : FewfUtils.vectorFind(grid.cells, function(c:DisplayObject){ return itemData.matches(_findPushButtonInCell(c).data.itemData) });
		}
		
		public function getButtonWithItemData(itemData:ItemData) : PushButton {
			return _findPushButtonInCell(getCellWithItemData(itemData));
		}
		
		public function toggleGridButtonWithData(pData:ItemData, pScrollIntoView:Boolean=false) : PushButton {
			if(pData) {
				var tIndex:int = GameAssets.getItemIndexFromTypeID(_type, pData.id);
				buttons[ tIndex ].toggleOn();
				return buttons[tIndex];
			}
			return null;
		}
		
		// Toggle active button to retrigger it's effects 
		public function retoggleActiveButton() : void {
			var i:int = _findIndexActivePushButton(buttons);
			if(i > -1) {
				buttons[i].toggleOff();
				buttons[i].toggleOn();
			}
		}
		
		public function chooseRandomItem() : void {
			var tLength = grid.cells.length;
			var cell:DisplayObject = grid.cells[ Math.floor(Math.random() * tLength) ];
			var btn:PushButton = _findPushButtonInCell(cell);
			btn.toggleOn();
			if(_flagOpen) scrollItemIntoView(cell);
		}
		
		public function selectNewestItem() : void {
			buttons[ buttons.length-1 ].toggleOn();
		}
		
		// Update image when colors have been changed
		public function refreshButtonImage(pItemData:ItemData) : void {
			if(!pItemData || !pItemData.isCustomizable) { return; }
			
			var i:int = GameAssets.getItemIndexFromTypeID(pItemData.type, pItemData.id);
			var btn:PushButton = this.buttons[i];
			btn.setImage(GameAssets.getColoredItemImage(pItemData));
		}
		
		/****************************
		* Private
		*****************************/
		private function _setupGrid(pItemList:Vector.<ItemData>) : void {
			resetGrid();

			var shopItemButton : PushButton;
			for(var i:int = 0; i < pItemList.length; i++) {
				shopItemButton = !pItemList[i].isBitmap()
					? newButtonFromItemData(pItemList[i], i)
					: newButtonFromBitmapItemData(pItemList[i] as BitmapItemData, i);
				// Finally add to grid (do it at end so auto event handlers can be hooked up properly)
				addToGrid(shopItemButton);
			}
			refreshScrollbox();
		}
		
		private function newButtonFromItemData(pItemData:ItemData, i:int) : PushButton {
			var shopItem : MovieClip = GameAssets.getItemImage(pItemData);
			shopItem.scaleX = shopItem.scaleY = 1;
			return new PushButton({ allowToggleOff:false, width:grid.cellSize, height:grid.cellSize, obj:shopItem, data:{ type:_type, itemData:pItemData } });
		}
		
		private function newButtonFromBitmapItemData(pItemData:BitmapItemData, i:int) : PushButton {
			var shopItemButton : PushButton = new PushButton({ allowToggleOff:false, width:grid.cellSize, height:grid.cellSize, data:{ type:_type, itemData:pItemData } });
			
			var shopItem : Bitmap = pItemData.getSmallImage();
			shopItemButton.setImage(shopItem);
			if(shopItem.width == 0) {
				shopItemButton.setImage(new LoadingSpinner({ speedScale:0.5 }), 0.75);
			}
			
			shopItem.addEventListener(Event.COMPLETE, function(e:Event){
				// Bitmap image from before has loaded, but now needs to be resized/fitted, so just pass it back in.
				shopItemButton.setImage(e.currentTarget as Bitmap);
			});

			
			shopItem.scaleX = shopItem.scaleY = 1; // This scale needed since it's otherwise set to 0 by autosizer if bitmap isn't loaded yet
			return shopItemButton;
		}
		
		/****************************
		* Favorites
		*****************************/
		private function _renderFavorites() : void {
			var favIds:Array = FavoriteItemsLocalStorageManager.getFavoritesIdList(_type).concat().reverse(); // Reverse so newest show first
			
			_favoritesGrid.reset();
			_favoritesGrid.columns = Math.min(16, Math.max(10, favIds.length));
			
			var tItemData:ItemData;
			for each(var tId:String in favIds) {
				tItemData = GameAssets.getItemFromTypeID(_type, tId);
				if(tItemData) {
					_favoritesGrid.add(new SpriteButton({ size:_favoritesGrid.cellSize, obj:GameAssets.getItemImage(tItemData), obj_scale:"auto", data:tItemData })
						.onButtonClick(_favoriteClicked));
				}
			}
			
			// Update rest of UI to make room for it
			_scrollbox.y = 65 + _favoritesGrid.calculatedHeight+5; // shift it down an extra 5 so that main grid list isn't touching it (padding)
			_grid.y = favIds.length > 0 ? 0 : 3; // If fav grid exists, then shift grid up to avoid an extra gap between fav list and grid
			_scrollbox.resize(_scrollbox.scrollPane.width, defaultScrollboxHeight - (_favoritesGrid.calculatedHeight+3))
		}
		
		private function _favoriteClicked(e:FewfEvent) : void {
			var itemData:ItemData = (e.currentTarget as SpriteButton).data as ItemData;
			toggleGridButtonWithData(itemData, true);
		}
		
		private function _addRemoveFavoriteToggled(e:FewfEvent) : void {
			var pushed:Boolean = e.data.pushed, tId:String = _infobar.itemData.id;
			if(pushed) {
				FavoriteItemsLocalStorageManager.addFavoriteId(_type, tId);
			} else {
				FavoriteItemsLocalStorageManager.removeFavoriteId(_type, tId);
			}
			_renderFavorites();
		}
		
		/****************************
		* Events
		*****************************/
		protected override function _onCellPushButtonToggled(e:FewfEvent) : void {
			super._onCellPushButtonToggled(e);
			dispatchEvent(new ItemDataEvent(ITEM_TOGGLED, e.data.itemData));
		}
	}
}
