package app.ui.panes
{
	import app.data.ItemType;
	import app.data.GameAssets;
	import flash.display.MovieClip;
	import app.ui.buttons.PushButton;
	import com.fewfre.events.FewfEvent;
	import com.fewfre.display.ButtonBase;
	import app.ui.buttons.ScaleButton;
	import flash.events.Event;
	import app.world.data.ItemData;
	import com.fewfre.display.Grid;
	import app.world.data.BitmapItemData;
	import com.fewfre.utils.Fewf;
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import app.ui.screens.LoadingSpinner;
	import app.ui.panes.base.ButtonGridSidePane;
	import app.ui.panes.infobar.Infobar;
	import com.fewfre.utils.FewfUtils;

	public class ShopCategoryPane extends ButtonGridSidePane
	{
		private var _type: ItemType;
		private var _defaultSkinColorButton: ScaleButton;
		public var selectedButtonIndex : int;
		
		public function get type():ItemType { return _type; }
		
		public static const ITEM_TOGGLED : String = 'ITEM_TOGGLED';
		
		// Constructor
		public function ShopCategoryPane(pType:ItemType) {
			this._type = pType;
			var buttonPerRow:int = 6;
			if(_type == ItemType.PLANK_LARGE) { buttonPerRow = 4; }
			if(_type == ItemType.BOX_LARGE || _type == ItemType.TRAMPOLINE) { buttonPerRow = 5; }
			super(buttonPerRow);
			
			// Start reversed by default
			grid.reverse();
			
			selectedButtonIndex = -1;
			this.addInfoBar( new Infobar({ showEyeDropper:true, gridManagement:true }) );
			_setupGrid(GameAssets.getItemDataListByType(_type));
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
		
		public function toggleGridButtonWithData(pData:ItemData) : PushButton {
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
			return new PushButton({ allowToggleOff:false, width:grid.cellSize, height:grid.cellSize, obj:shopItem, id:i, data:{ type:_type, id:i, itemData:pItemData } });
		}
		
		private function newButtonFromBitmapItemData(pItemData:BitmapItemData, i:int) : PushButton {
			var shopItemButton : PushButton = new PushButton({ allowToggleOff:false, width:grid.cellSize, height:grid.cellSize, id:i, data:{ type:_type, id:i, itemData:pItemData } });
			
			var shopItem : Bitmap = pItemData.getSmallImage();
			shopItemButton.ChangeImage(shopItem);
			if(shopItem.width == 0) {
				shopItemButton.ChangeImage(new LoadingSpinner({ speedScale:0.5 }), 0.75);
			}
			
			shopItem.addEventListener(Event.COMPLETE, function(e:Event){
				// Bitmap image from before has loaded, but now needs to be resized/fitted, so just pass it back in.
				shopItemButton.ChangeImage(e.currentTarget as Bitmap);
			});

			
			shopItem.scaleX = shopItem.scaleY = 1; // This scale needed since it's otherwise set to 0 by autosizer if bitmap isn't loaded yet
			return shopItemButton;
		}
		
		/****************************
		* Events
		*****************************/
		protected override function _onCellPushButtonToggled(e:FewfEvent) : void {
			super._onCellPushButtonToggled(e);
			dispatchEvent(new FewfEvent(ITEM_TOGGLED, e.data));
		}
	}
}
