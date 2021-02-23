package app.world
{
	import com.adobe.images.*;
	import com.piterwilson.utils.*;
	import com.fewfre.utils.AssetManager;
	import com.fewfre.display.*;
	import com.fewfre.events.*;
	import com.fewfre.utils.*;

	import app.ui.*;
	import app.ui.panes.*;
	import app.ui.screens.*;
	import app.ui.buttons.*;
	import app.data.*;
	import app.world.data.*;
	import app.world.elements.*;

	import fl.controls.*;
	import fl.events.*;
	import flash.display.*;
	import flash.text.*;
	import flash.events.*
	import flash.external.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.utils.*;
	import flash.display.MovieClip;
	import app.ui.panes.ColorPickerTabPane;
	import app.ui.panes.ColorFinderPane;
	
	public class World extends MovieClip
	{
		// Storage
		internal var character		: CustomItem;
		internal var _paneManager	: PaneManager;

		internal var shopTabs		: ShopTabContainer;
		internal var _toolbox		: Toolbox;
		internal var linkTray		: LinkTray;
		internal var _langScreen	: LangScreen;

		internal var button_hand	: PushButton;
		internal var button_back	: PushButton;
		internal var button_backHand: PushButton;

		internal var currentlyColoringType:String="";
		internal var configCurrentlyColoringType:String;
		
		// Constants
		public static const COLOR_PANE_ID = "colorPane";
		public static const COLOR_FINDER_PANE_ID = "colorFinderPane";
		public static const TAB_OTHER:String = "other";
		// public static const CONFIG_COLOR_PANE_ID = "configColorPane";
		
		// Constructor
		public function World(pStage:Stage) {
			super();
			_buildWorld(pStage);
			pStage.addEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheel);
		}
		
		private function _buildWorld(pStage:Stage) {
			GameAssets.init();

			/****************************
			* Create CustomItem
			*****************************/
			var parms:flash.net.URLVariables = null;
			try {
				var urlPath:String = ExternalInterface.call("eval", "window.location.href");
				if(urlPath && urlPath.indexOf("?") > 0) {
					urlPath = urlPath.substr(urlPath.indexOf("?") + 1, urlPath.length);
					parms = new flash.net.URLVariables();
					parms.decode(urlPath);
				}
			} catch (error:Error) { };

			this.character = addChild(new CustomItem({ x:190, y:275,
				item:GameAssets.boxes_small[0],
				params:parms
			})) as CustomItem;

			/****************************
			* Setup UI
			*****************************/
			var tShop:RoundedRectangle = addChild(new RoundedRectangle({ x:450, y:10, width:ConstantsApp.SHOP_WIDTH, height:ConstantsApp.APP_HEIGHT })) as RoundedRectangle;
			tShop.drawSimpleGradient(ConstantsApp.COLOR_TRAY_GRADIENT, 15, ConstantsApp.COLOR_TRAY_B_1, ConstantsApp.COLOR_TRAY_B_2, ConstantsApp.COLOR_TRAY_B_3);
			_paneManager = tShop.addChild(new PaneManager()) as PaneManager;
			
			this.shopTabs = addChild(new ShopTabContainer({ x:375, y:10, width:70, height:ConstantsApp.APP_HEIGHT,
				tabs:[
					{ text:"tab_box_small", event:ITEM.BOX_SMALL },
					{ text:"tab_box_large", event:ITEM.BOX_LARGE },
					{ text:"tab_plank_small", event:ITEM.PLANK_SMALL },
					{ text:"tab_plank_large", event:ITEM.PLANK_LARGE },
					{ text:"tab_ball", event:ITEM.BALL },
					{ text:"tab_trampoline", event:ITEM.TRAMPOLINE },
					{ text:"tab_anvil", event:ITEM.ANVIL },
					{ text:"tab_cannonball", event:ITEM.CANNONBALL },
					{ text:"tab_balloon", event:ITEM.BALLOON },
					{ text:"tab_cartouche", event:ITEM.CARTOUCHE },
				]
			})) as ShopTabContainer;
			this.shopTabs.addEventListener(ShopTabContainer.EVENT_SHOP_TAB_CLICKED, _onTabClicked);

			// Toolbox
			_toolbox = addChild(new Toolbox({
				x:188, y:28, character:character,
				onSave:_onSaveClicked, /*onAnimate:_onPlayerAnimationToggle,*/ /*onRandomize:_onRandomizeDesignClicked,*/
				onShare:_onShareButtonClicked, onScale:_onScaleSliderChange
			})) as Toolbox;
			
			var tLangButton = addChild(new LangButton({ x:22, y:pStage.stageHeight-17, width:30, height:25, origin:0.5 }));
			tLangButton.addEventListener(ButtonBase.CLICK, _onLangButtonClicked);
			
			addChild(new AppInfoBox({ x:tLangButton.x+(tLangButton.Width*0.5)+(25*0.5)+2, y:pStage.stageHeight-17 }));
			
			/****************************
			* Screens
			*****************************/
			linkTray = new LinkTray({ x:pStage.stageWidth * 0.5, y:pStage.stageHeight * 0.5 });
			linkTray.addEventListener(LinkTray.CLOSE, _onShareTrayClosed);
			
			_langScreen = new LangScreen({  });
			_langScreen.addEventListener(LangScreen.CLOSE, _onLangScreenClosed);
			
			/****************************
			* Create tabs and panes
			*****************************/
			var tPane = null;
			
			tPane = _paneManager.addPane(COLOR_PANE_ID, new ColorPickerTabPane({}));
			tPane.addEventListener(ColorPickerTabPane.EVENT_COLOR_PICKED, _onColorPickChanged);
			tPane.addEventListener(ColorPickerTabPane.EVENT_DEFAULT_CLICKED, _onDefaultsButtonClicked);
			tPane.addEventListener(ColorPickerTabPane.EVENT_EXIT, _onColorPickerBackClicked);
			
			tPane = _paneManager.addPane(COLOR_FINDER_PANE_ID, new ColorFinderPane({ }));
			tPane.addEventListener(ColorPickerTabPane.EVENT_EXIT, _onColorFinderBackClicked);

			// Create the panes
			var tTypes = [ ITEM.BOX_SMALL, ITEM.BOX_LARGE, ITEM.PLANK_SMALL, ITEM.PLANK_LARGE, ITEM.BALL, ITEM.TRAMPOLINE, ITEM.ANVIL, ITEM.CANNONBALL, ITEM.BALLOON, ITEM.CARTOUCHE ], tData:ItemData, tType:String;
			for(var i:int = 0; i < tTypes.length; i++) { tType = tTypes[i];
				tPane = _paneManager.addPane(tType, _setupPane(tType));
				// Based on what the character is wearing at start, toggle on the appropriate buttons.
				/*tData = character.getItemData(tType);
				if(tData) {
					var tIndex:int = FewfUtils.getIndexFromArrayWithKeyVal(GameAssets.getArrayByType(tType), "id", tData.id);
					tPane.buttons[ tIndex ].toggleOn();
				}*/
			}
			
			// Select First Pane
			shopTabs.tabs[0].toggleOn();
			_paneManager.getPane(tTypes[0]).buttons[0].toggleOn();
			
			tPane = null;
			tTypes = null;
			tData = null;
		}

		private function _setupPane(pType:String) : TabPane {
			var tPane:TabPane = new TabPane();
			tPane.addInfoBar( new ShopInfoBar({ showEyeDropButton:true }) );
			_setupPaneButtons(pType, tPane, GameAssets.getArrayByType(pType));
			tPane.infoBar.colorWheel.addEventListener(ButtonBase.CLICK, function(){ _colorButtonClicked(pType); });
			/*tPane.infoBar.imageCont.addEventListener(MouseEvent.CLICK, function(){ _removeItem(pType); });*/
			/*tPane.infoBar.refreshButton.addEventListener(ButtonBase.CLICK, function(){ _randomItemOfType(pType); });*/
			if(tPane.infoBar.eyeDropButton) {
				tPane.infoBar.eyeDropButton.addEventListener(ButtonBase.CLICK, function(){ _eyeDropButtonClicked(pType); });
			}
			return tPane;
		}

		private function _setupPaneButtons(pType:String, pPane:TabPane, pItemArray:Array) : void {
			var buttonPerRow = 6;
			var scale = 1;
			if(pType == ITEM.BOX_LARGE || pType == ITEM.PLANK_LARGE) {
					buttonPerRow = 5;
					scale = 1;
			}

			var grid:Grid = pPane.grid;
			if(!grid) { grid = pPane.addGrid( new Grid({ x:15, y:5, width:385, columns:buttonPerRow, margin:5 }) ); }
			grid.reset();

			var shopItem : MovieClip;
			var shopItemButton : PushButton;
			var i = -1;
			while (i < pItemArray.length-1) { i++;
				shopItem = GameAssets.getItemImage(pItemArray[i]);
				shopItem.scaleX = shopItem.scaleY = scale;

				shopItemButton = new PushButton({ width:grid.radius, height:grid.radius, obj:shopItem, id:i, data:{ type:pType, id:i } });
				grid.add(shopItemButton);
				pPane.buttons.push(shopItemButton);
				shopItemButton.addEventListener(PushButton.STATE_CHANGED_AFTER, _onItemToggled);
			}
			pPane.UpdatePane();
		}

		private function _onMouseWheel(pEvent:MouseEvent) : void {
			if(this.mouseX < this.shopTabs.x) {
				_toolbox.scaleSlider.updateViaMouseWheelDelta(pEvent.delta);
				character.scale = _toolbox.scaleSlider.getValueAsScale();
			}
		}

		private function _onScaleSliderChange(pEvent:Event):void {
			character.scale = _toolbox.scaleSlider.getValueAsScale();
		}

		private function _onPlayerAnimationToggle(pEvent:Event):void {
			character.animatePose = !character.animatePose;
			if(character.animatePose) {
				character.outfit.play();
			} else {
				character.outfit.stop();
			}
			_toolbox.toggleAnimateButtonAsset(character.animatePose);
		}

		private function _onSaveClicked(pEvent:Event) : void {
			FewfDisplayUtils.saveAsPNG(this.character, "shamanitem");
		}

		private function _onItemToggled(pEvent:FewfEvent) : void {
			var tType = pEvent.data.type;
			var tItemArray:Array = GameAssets.getArrayByType(tType);
			var tInfoBar:ShopInfoBar = getInfoBarByType(tType);

			// De-select all buttons that aren't the clicked one.
			var tButtons:Array = getButtonArrayByType(tType);
			for(var i:int = 0; i < tButtons.length; i++) {
				if(tButtons[i].data.id != pEvent.data.id) {
					if (tButtons[i].pushed)  { tButtons[i].toggleOff(); }
				}
			}
			
			// Select buttons on other tabs
			var tButtons2:Array = null;
			for(var j:int = 0; j < ITEM.ALL.length; j++) {
				if(ITEM.ALL[j] == tType) { continue; }
				tButtons2 = getButtonArrayByType(ITEM.ALL[j]);
				for(var i:int = 0; i < tButtons2.length; i++) {
					if (tButtons2[i].pushed)  { tButtons2[i].toggleOff(); }
				}
				_paneManager.getPane(ITEM.ALL[j]).infoBar.removeInfo();
			}
			tButtons2 = null;

			var tButton:PushButton = tButtons[pEvent.data.id];
			var tData:ItemData;
			// If clicked button is toggled on, equip it. Otherwise remove it.
			if(tButton.pushed) {
				tData = tItemArray[pEvent.data.id];
				setCurItemID(tType, tButton.id);
				this.character.setItemData(tData);

				tInfoBar.addInfo( tData, GameAssets.getColoredItemImage(tData) );
				tInfoBar.showColorWheel(GameAssets.getNumOfCustomColors(tButton.Image as MovieClip) > 0);
			} else {
				_removeItem(tType);
			}
		}

		private function toggleItemSelectionOneOff(pType:String, pButton:PushButton, pItemData:ItemData) : void {
			if (pButton.pushed) {
				this.character.setItemData( pItemData );
			} else {
				this.character.removeItem(pType);
			}
		}

		private function _removeItem(pType:String) : void {
			var tTabPane = getTabByType(pType);
			if(tTabPane.infoBar.hasData == false) { return; }

			// If item has a default value, toggle it on. otherwise remove item.
			/*if(pType == ITEM.SKIN || pType == ITEM.POSE) {*/
				var tDefaultIndex = 0;//(pType == ITEM.POSE ? GameAssets.defaultPoseIndex : GameAssets.defaultSkinIndex);
				tTabPane.buttons[tDefaultIndex].toggleOn();
			/*} else {
				this.character.removeItem(pType);
				tTabPane.infoBar.removeInfo();
				tTabPane.buttons[ tTabPane.selectedButtonIndex ].toggleOff();
			}*/
		}
		
		private function _onTabClicked(pEvent:flash.events.DataEvent) : void {
			_paneManager.openPane(pEvent.data);
		}

		// private function _onRandomizeDesignClicked(pEvent:Event) : void {
		// 	for(var i:int = 0; i < ITEM.LAYERING.length; i++) {
		// 		_randomItemOfType(ITEM.LAYERING[i]);
		// 	}
		// 	_randomItemOfType(ITEM.POSE);
		// }

		private function _randomItemOfType(pType:String) : void {
			/*if(getInfoBarByType(pType).isRefreshLocked) { return; }*/
			var tButtons = getButtonArrayByType(pType);
			var tLength = tButtons.length;
			tButtons[ Math.floor(Math.random() * tLength) ].toggleOn();
		}

		private function _onShareButtonClicked(pEvent:Event) : void {
			var tURL = "";
			try {
				tURL = ExternalInterface.call("eval", "window.location.origin+window.location.pathname");
				tURL += "?"+this.character.getParams();
			} catch (error:Error) {
				tURL = "<error creating link>";
			};

			linkTray.open(tURL);
			addChild(linkTray);
		}

		private function _onShareTrayClosed(pEvent:Event) : void {
			removeChild(linkTray);
		}

		private function _onLangButtonClicked(pEvent:Event) : void {
			_langScreen.open();
			addChild(_langScreen);
		}

		private function _onLangScreenClosed(pEvent:Event) : void {
			removeChild(_langScreen);
		}

		//{REGION Get TabPane data
			private function getTabByType(pType:String) : TabPane {
				return _paneManager.getPane(pType);
			}

			private function getInfoBarByType(pType:String) : ShopInfoBar {
				return getTabByType(pType).infoBar;
			}

			private function getButtonArrayByType(pType:String) : Array {
				return getTabByType(pType).buttons;
			}

			private function getCurItemID(pType:String) : int {
				return getTabByType(pType).selectedButtonIndex;
			}

			private function setCurItemID(pType:String, pID:int) : void {
				getTabByType(pType).selectedButtonIndex = pID;
			}
		//}END Get TabPane data

		//{REGION Color Tab
			private function _onColorPickChanged(pEvent:flash.events.DataEvent):void
			{
				var tVal:uint = uint(pEvent.data);
				this.character.getItemData(this.currentlyColoringType).colors[(_paneManager.getPane(COLOR_PANE_ID) as ColorPickerTabPane).selectedSwatch] = tVal;
				_refreshSelectedItemColor();
			}

			private function _onDefaultsButtonClicked(pEvent:Event) : void
			{
				this.character.getItemData(this.currentlyColoringType).setColorsToDefault();
				_refreshSelectedItemColor();
				(_paneManager.getPane(COLOR_PANE_ID) as ColorPickerTabPane).setupSwatches( this.character.getColors(this.currentlyColoringType) );
			}
			
			private function _refreshSelectedItemColor() : void {
				character.updateItem();
				
				var tItemData = this.character.getItemData(this.currentlyColoringType);
				var tItem:MovieClip = GameAssets.getColoredItemImage(tItemData);
				GameAssets.copyColor(tItem, getButtonArrayByType(this.currentlyColoringType)[ getCurItemID(this.currentlyColoringType) ].Image );
				GameAssets.copyColor(tItem, getInfoBarByType( this.currentlyColoringType ).Image );
				GameAssets.copyColor(tItem, _paneManager.getPane(COLOR_PANE_ID).infoBar.Image);
				/*var tMC:MovieClip = this.character.getItemFromIndex(this.currentlyColoringType);
				if (tMC != null)
				{
					GameAssets.colorDefault(tMC);
					GameAssets.copyColor( tMC, getButtonArrayByType(this.currentlyColoringType)[ getCurItemID(this.currentlyColoringType) ].Image );
					GameAssets.copyColor(tMC, getInfoBarByType(this.currentlyColoringType).Image);
					GameAssets.copyColor(tMC, _paneManager.getPane(COLOR_PANE_ID).infoBar.Image);
					
				}*/
			}

			private function _colorButtonClicked(pType:String) : void {
				if(this.character.getItemData(this.currentlyColoringType) == null) { return; }

				var tData:ItemData = getInfoBarByType(pType).data;
				_paneManager.getPane(COLOR_PANE_ID).infoBar.addInfo( tData, GameAssets.getItemImage(tData) );
				this.currentlyColoringType = pType;
				(_paneManager.getPane(COLOR_PANE_ID) as ColorPickerTabPane).setupSwatches( this.character.getColors(this.currentlyColoringType) );
				_paneManager.openPane(COLOR_PANE_ID);
			}

			private function _onColorPickerBackClicked(pEvent:Event):void {
				_paneManager.openPane(_paneManager.getPane(COLOR_PANE_ID).infoBar.data.type);
			}

			// private function _onConfigColorPickChanged(pEvent:flash.events.DataEvent):void
			// {
			// 	var tVal:uint = uint(pEvent.data);
			// 	/*_paneManager.getPane(TAB_OTHER).updateCustomColor(configCurrentlyColoringType, tVal);*/
			// 	GameAssets.shamanColor = tVal;
			// 	character.updateItem();
			// }

			// private function _shamanColorButtonClicked(/*pType:String, pColor:int*/) : void {
			// 	/*this.configCurrentlyColoringType = pType;*/
			// 	_paneManager.getPane(CONFIG_COLOR_PANE_ID).setupSwatches( [ GameAssets.shamanColor ] );
			// 	_paneManager.openPane(CONFIG_COLOR_PANE_ID);
			// }

			private function _eyeDropButtonClicked(pType:String) : void {
				if(this.character.getItemData(pType) == null) { return; }

				var tData:ItemData = getInfoBarByType(pType).data;
				var tItem:MovieClip = GameAssets.getColoredItemImage(tData);
				var tItem2:MovieClip = GameAssets.getColoredItemImage(tData);
				_paneManager.getPane(COLOR_FINDER_PANE_ID).infoBar.addInfo( tData, tItem );
				this.currentlyColoringType = pType;
				(_paneManager.getPane(COLOR_FINDER_PANE_ID) as ColorFinderPane).setItem(tItem2);
				_paneManager.openPane(COLOR_FINDER_PANE_ID);
			}

			private function _onColorFinderBackClicked(pEvent:Event):void {
				_paneManager.openPane(_paneManager.getPane(COLOR_FINDER_PANE_ID).infoBar.data.type);
			}
		//}END Color Tab
	}
}
