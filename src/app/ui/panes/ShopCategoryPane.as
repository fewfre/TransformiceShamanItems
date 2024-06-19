package app.ui.panes
{
	
	import app.ui.ShopInfoBar;
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

	public class ShopCategoryPane extends TabPane
	{
		private var _type: ItemType;
		private var _defaultSkinColorButton: ScaleButton;
		
		public function get type():ItemType { return _type; }
		
		public static const ITEM_TOGGLED : String = 'ITEM_TOGGLED';
		
		// Constructor
		public function ShopCategoryPane(pType:ItemType) {
			super();
			this._type = pType;
			this.addInfoBar( new ShopInfoBar({ showEyeDropButton:true, showGridManagementButtons:true }) );
			_setupGrid(GameAssets.getItemDataListByType(_type));
			
			infoBar.reverseButton.addEventListener(ButtonBase.CLICK, _onReverseGrid);
		}
		
		/****************************
		* Public
		*****************************/
		public override function open() : void {
			super.open();
		}
		
		public function toggleGridButtonWithData(pData:ItemData) : PushButton {
			if(pData) {
				var tIndex:int = GameAssets.getItemIndexFromTypeID(_type, pData.id);
				buttons[ tIndex ].toggleOn();
				return buttons[tIndex];
			}
			return null;
		}
		
		/****************************
		* Private
		*****************************/
		private function _setupGrid(pItemList:Vector.<ItemData>) : void {
			var buttonPerRow:int = 6;
			var scale:Number = 1;
			if(_type == ItemType.BOX_LARGE || _type == ItemType.TRAMPOLINE) {
					buttonPerRow = 5;
					scale = 1;
			}
			else if(_type == ItemType.PLANK_LARGE) {
					buttonPerRow = 4;
					scale = 1;
			}
			else if(_type == ItemType.BADGE) {
					buttonPerRow = 6;
					scale = 1;
			}

			var grid:Grid = this.grid;
			if(!grid) { grid = this.addGrid( new Grid(385, buttonPerRow) ).setXY(15, 5); }
			grid.reset();

			var shopItemButton : PushButton;
			for(var i:int = 0; i < pItemList.length; i++) {
				shopItemButton = !pItemList[i].isBitmap()
					? newButtonFromItemData(pItemList[i], i)
					: newButtonFromBitmapItemData(pItemList[i] as BitmapItemData, i);
				grid.add(shopItemButton);
				this.buttons.push(shopItemButton);
				shopItemButton.addEventListener(PushButton.STATE_CHANGED_AFTER, _onItemToggled);
			}
			grid.reverse();
			this.UpdatePane();
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
		private function _onItemToggled(e:FewfEvent) : void {
			dispatchEvent(new FewfEvent(ITEM_TOGGLED, e.data));
		}
		
		private function _onReverseGrid(e:Event) : void {
			this.grid.reverse();
		}
	}
}
