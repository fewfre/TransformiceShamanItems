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
		
		public function toggleGridButtonWithData(pData:ItemData) : void {
			if(pData) {
				var tIndex:int = GameAssets.getItemIndexFromTypeID(_type, pData.id);
				buttons[ tIndex ].toggleOn();
			}
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

			var grid:Grid = this.grid;
			if(!grid) { grid = this.addGrid( new Grid(385, buttonPerRow) ).setXY(15, 5); }
			grid.reset();

			var shopItem : MovieClip;
			var shopItemButton : PushButton;
			var i:int = -1;
			while (i < pItemList.length-1) { i++;
				shopItem = GameAssets.getItemImage(pItemList[i]);
				shopItem.scaleX = shopItem.scaleY = scale;

				shopItemButton = new PushButton({ allowToggleOff:false, width:grid.cellSize, height:grid.cellSize, obj:shopItem, id:i, data:{ type:_type, id:i } });
				grid.add(shopItemButton);
				this.buttons.push(shopItemButton);
				shopItemButton.addEventListener(PushButton.STATE_CHANGED_AFTER, _onItemToggled);
			}
			grid.reverse();
			this.UpdatePane();
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
