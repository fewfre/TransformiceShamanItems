package app.world
{
	import app.data.*;
	import app.ui.*;
	import app.ui.buttons.*;
	import app.ui.panes.*;
	import app.ui.panes.base.ButtonGridSidePane;
	import app.ui.panes.base.SidePane;
	import app.ui.panes.ColorFinderPane;
	import app.ui.panes.colorpicker.ColorPickerTabPane;
	import app.ui.panes.ColorPickerTabPane;
	import app.ui.panes.infobar.GridManagementWidget;
	import app.ui.panes.infobar.Infobar;
	import app.ui.screens.*;
	import app.world.data.*;
	import app.world.elements.*;
	
	import com.fewfre.display.*;
	import com.fewfre.events.FewfEvent;
	import com.fewfre.utils.*;
	import ext.ParentApp;
	
	import flash.display.*;
	import flash.events.*
	import flash.external.ExternalInterface;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	import app.world.events.ItemDataEvent;
	
	public class World extends MovieClip
	{
		// Storage
		private var character      : CustomItem;
		private var _panes         : WorldPaneManager;

		private var shopTabs       : ShopTabList;
		private var _toolbox       : Toolbox;
		
		private var _shareScreen   : ShareScreen;
		private var _langScreen    : LangScreen;
		private var _aboutScreen   : AboutScreen;

		private var currentlyColoringType:ItemType=null;
		
		// Constructor
		public function World(pStage:Stage) {
			super();
			_buildWorld(pStage);
			pStage.addEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheel);
			pStage.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDownListener);
		}
		
		private function _buildWorld(pStage:Stage) {
			GameAssets.init();

			/////////////////////////////
			// Create CustomItem
			/////////////////////////////
			var parms:String = null;
			if(!Fewf.isExternallyLoaded) {
				try {
					var urlPath:String = ExternalInterface.call("eval", "window.location.href");
					if(urlPath && urlPath.indexOf("?") > 0) {
						urlPath = urlPath.substr(urlPath.indexOf("?") + 1, urlPath.length);
					}
					parms = urlPath;
				} catch (error:Error) { };
			}

			this.character = new CustomItem(GameAssets.boxes_small[0], parms)
				.move(185, 275).setDragBounds(0+4, 73+4, 375-8, ConstantsApp.APP_HEIGHT-73-8).appendTo(this);

			/////////////////////////////
			// Setup UI
			/////////////////////////////
			shopTabs = new ShopTabList(70, ConstantsApp.SHOP_HEIGHT).move(375, 10).appendTo(this).on(ShopTabList.TAB_CLICKED, _onTabClicked);
			shopTabs.addTab("tab_box_small", WorldPaneManager.itemTypeToId(ItemType.BOX_SMALL));
			shopTabs.addTab("tab_box_large", WorldPaneManager.itemTypeToId(ItemType.BOX_LARGE));
			shopTabs.addTab("tab_plank_small", WorldPaneManager.itemTypeToId(ItemType.PLANK_SMALL));
			shopTabs.addTab("tab_plank_large", WorldPaneManager.itemTypeToId(ItemType.PLANK_LARGE));
			shopTabs.addTab("tab_ball", WorldPaneManager.itemTypeToId(ItemType.BALL));
			shopTabs.addTab("tab_trampoline", WorldPaneManager.itemTypeToId(ItemType.TRAMPOLINE));
			shopTabs.addTab("tab_anvil", WorldPaneManager.itemTypeToId(ItemType.ANVIL));
			shopTabs.addTab("tab_cannonball", WorldPaneManager.itemTypeToId(ItemType.CANNONBALL));
			shopTabs.addTab("tab_balloon", WorldPaneManager.itemTypeToId(ItemType.BALLOON));
			shopTabs.addTab("tab_cartouche", WorldPaneManager.itemTypeToId(ItemType.CARTOUCHE));
			if(Fewf.assets.getData("config").badges) {
				shopTabs.addTab("tab_badge", WorldPaneManager.itemTypeToId(ItemType.BADGE));
			}
			
			var tShop:RoundRectangle = new RoundRectangle(ConstantsApp.SHOP_WIDTH, ConstantsApp.SHOP_HEIGHT).move(450, 10)
				.appendTo(this).drawAsTray();
			_panes = new WorldPaneManager().appendTo(tShop.root) as WorldPaneManager;

			/////////////////////////////
			// Top Area
			/////////////////////////////
			_toolbox = new Toolbox(character, _onShareCodeEntered).move(188, 28).appendTo(this)
				.on(Toolbox.SAVE_CLICKED, _onSaveClicked)
				.on(Toolbox.SHARE_CLICKED, _onShareButtonClicked)
				.on(Toolbox.CLIPBOARD_CLICKED, _onClipboardButtonClicked)
				
				.on(Toolbox.SCALE_SLIDER_CHANGE, _onScaleSliderChange)
				.on(Toolbox.DEFAULT_SCALE_CLICKED, _onScaleSliderDefaultClicked);
			
			// Outfit Button
			new ScaleButton({ origin:0.5, obj:new $Outfit(), obj_scale:0.4 }).appendTo(this).move(_toolbox.x+167, _toolbox.y+12.5+21)
				.onButtonClick(function(pEvent:Event){ _panes.openPane(WorldPaneManager.OUTFITS_PANE); });
			
			/////////////////////////////
			// Bottom Left Area
			/////////////////////////////
			var tLangButton:SpriteButton = LangScreen.createLangButton({ width:30, height:25, origin:0.5 })
				.move(22, ConstantsApp.APP_HEIGHT-17).appendTo(this)
				.onButtonClick(_onLangButtonClicked) as SpriteButton;
			
			// About Screen Button
			var aboutButton:SpriteButton = new SpriteButton({ size:25, origin:0.5 }).appendTo(this)
				.move(tLangButton.x+(tLangButton.Width/2)+2+(25/2), ConstantsApp.APP_HEIGHT - 17)
				.onButtonClick(_onAboutButtonClicked) as SpriteButton;
			new TextBase("?", { size:22, color:0xFFFFFF, bold:true, origin:0.5 }).move(0, -1).appendTo(aboutButton)
			
			
			if(!!(ParentApp.reopenSelectionLauncher())) {
				new ScaleButton({ obj:new $BackArrow(), obj_scale:0.5, origin:0.5 }).appendTo(this)
					.move(22, ConstantsApp.APP_HEIGHT-17-28)
					.onButtonClick(function():void{ ParentApp.reopenSelectionLauncher()(); });
			}
			
			/////////////////////////////
			// Screens
			/////////////////////////////
			_shareScreen = new ShareScreen().on(Event.CLOSE, _onShareScreenClosed);
			_langScreen = new LangScreen().on(Event.CLOSE, _onLangScreenClosed);
			_aboutScreen = new AboutScreen().on(Event.CLOSE, _onAboutScreenClosed);

			/////////////////////////////
			// Create item panes
			/////////////////////////////
			for each(var tType:ItemType in ItemType.ALL) {
				_panes.addPane(WorldPaneManager.itemTypeToId(tType), _setupItemPane(tType));
				// // Based on what the character is wearing at start, toggle on the appropriate buttons.
				// getTabByType(tType).toggleGridButtonWithData( character.getItemData(tType) );
				
				// We want each pane to always have something selected, since switching tabs switches the CustomItem shown
				getShopPane(tType).selectNewestItem();
			}
			
			Fewf.dispatcher.addEventListener(ConstantsApp.DOWNLOAD_ITEM_DATA_IMAGE, _onSaveItemDataAsImage);
			
			/////////////////////////////
			// Static Panes
			/////////////////////////////
			// Outfit Pane
			_panes.addPane(WorldPaneManager.OUTFITS_PANE, new OutfitManagerTabPane(character, _useShareCode, function(){ return character.getShareCodeFewfreSyntax(); }))
				.on(Event.CLOSE, function(pEvent:Event){ _panes.openShopPane(character.getCurrentItemData().type).retoggleActiveButton(); });
			
			// Color Picker Pane
			_panes.addPane(WorldPaneManager.COLOR_PANE, new ColorPickerTabPane())
				.on(ColorPickerTabPane.EVENT_COLOR_PICKED, _onColorPickChanged)
				.on(ColorPickerTabPane.EVENT_PREVIEW_COLOR, _onColorPickHoverPreview)
				.on(Event.CLOSE, _onColorPickerBackClicked)
				.on(ColorPickerTabPane.EVENT_ITEM_ICON_CLICKED, function(e){
					_onColorPickerBackClicked(e);
					_removeItem(_panes.colorPickerPane.infobar.itemData.type);
				});
			
			// Color Finder Pane
			_panes.addPane(WorldPaneManager.COLOR_FINDER_PANE, new ColorFinderPane())
				.on(Event.CLOSE, _onColorFinderBackClicked)
				.on(ColorFinderPane.EVENT_ITEM_ICON_CLICKED, function(e){
					_onColorFinderBackClicked(e);
					_removeItem(_panes.colorFinderPane.infobar.itemData.type);
				});
			
			// Select First Pane
			shopTabs.toggleOnFirstTab();
		}

		private function _setupItemPane(pType:ItemType) : ShopCategoryPane {
			var tPane:ShopCategoryPane = new ShopCategoryPane(pType);
			tPane.addEventListener(ShopCategoryPane.ITEM_TOGGLED, _onItemToggled);
			
			tPane.infobar.on(Infobar.COLOR_WHEEL_CLICKED, function(){ _colorButtonClicked(pType); });
			tPane.infobar.on(Infobar.ITEM_PREVIEW_CLICKED, function(){ _removeItem(pType); });
			tPane.infobar.on(Infobar.EYE_DROPPER_CLICKED, function(){ _eyeDropButtonClicked(pType); });
			tPane.infobar.on(GridManagementWidget.RANDOMIZE_CLICKED, function(){ _randomItemOfType(pType); });
			return tPane;
		}
		
		private function getShopPane(pType:ItemType) : ShopCategoryPane { return _panes.getShopPane(pType); }

		private function _onMouseWheel(pEvent:MouseEvent) : void {
			if(this.mouseX < this.shopTabs.x) {
				_toolbox.scaleSlider.updateViaMouseWheelDelta(pEvent.delta);
				character.scale = _toolbox.scaleSlider.value;
				character.clampCoordsToDragBounds();
			}
		}

		private function _onKeyDownListener(e:KeyboardEvent) : void {
			if (e.keyCode == Keyboard.RIGHT || e.keyCode == Keyboard.LEFT || e.keyCode == Keyboard.UP || e.keyCode == Keyboard.DOWN){
				var pane:SidePane = _panes.getOpenPane();
				if(pane && pane is ButtonGridSidePane) {
					(pane as ButtonGridSidePane).handleKeyboardDirectionalInput(e.keyCode);
				}
				else if(pane && pane is ColorPickerTabPane) {
					if (e.keyCode == Keyboard.UP || e.keyCode == Keyboard.DOWN) {
						(pane as ColorPickerTabPane).nextSwatch(e.keyCode == Keyboard.DOWN);
					}
				}
			}
		}

		private function _onScaleSliderChange(e:Event):void {
			character.scale = _toolbox.scaleSlider.value;
			character.clampCoordsToDragBounds();
		}

		private function _onScaleSliderDefaultClicked(e:Event):void {
			character.scale = _toolbox.scaleSlider.value = ConstantsApp.DEFAULT_CHARACTER_SCALE;
			character.clampCoordsToDragBounds();
		}

		private function _onShareCodeEntered(pCode:String, pProgressCallback:Function):void {
			if(!pCode || pCode == "") { return; pProgressCallback("placeholder"); }
			
			try {
				_useShareCode(pCode);
				
				// Now tell code box that we are done
				pProgressCallback("success");
			}
			catch (error:Error) {
				pProgressCallback("invalid");
			};
		}
		
		private function _useShareCode(pCode:String, pGoToItem:Boolean=true):void {
			if(pCode.indexOf("?") > -1) {
				pCode = pCode.substr(pCode.indexOf("?") + 1, pCode.length);
			}
			
			// Now update pose
			character.parseShareCode(pCode);
			character.updateItem();
			
			// for each(var tType:ItemType in ItemType.TYPES_WITH_SHOP_PANES) { _refreshButtonCustomizationForItemData(character.getItemData(tType)); }
			_refreshButtonCustomizationForItemData(character.getCurrentItemData());
			
			if(pGoToItem) {
				// now update the infobars
				_updateUIBasedOnCharacter();
			} else {
				// Still select the tab, just so people know what type of box/plank it is
				var itemData:ItemData = character.getCurrentItemData(), itemType:ItemType = itemData.type;
				shopTabs.toggleTabOn(WorldPaneManager.itemTypeToId(itemType), false);
				// And select the button to match new state, but don't fire click event
				getShopPane(itemType).getButtonWithItemData(itemData).toggleOn(false);
			}
		}

		private function _onSaveClicked(pEvent:Event) : void {
			_saveAsPNG(this.character.getSaveImageDisplayObject(), "shamanitem"); // Doesn't need a scale specified since the image is already scaled
		}
		
		private function _onSaveItemDataAsImage(e:ItemDataEvent) : void {
			if(!e.itemData) { return; }
			var itemData:ItemData = e.itemData;
			var tName = "shop-"+itemData.type+itemData.id;
			if(itemData.type == ItemType.CARTOUCHE) {
				tName = "Macaron "+itemData.id;
			}
			if(!itemData.isBitmap()) {
				_saveAsPNG(GameAssets.getColoredItemImage(itemData), tName, ConstantsApp.ITEM_SAVE_SCALE);
			} else {
				// We don't want it ever using the user-defined canvas size due to not being a flash object
				FewfDisplayUtils.saveAsPNG((itemData as BitmapItemData).getFullImage(), tName, 1);
			}
		}
		
		private function _saveAsPNG(pObj:DisplayObject, pName:String, pScale:Number = 1) : void {
			var hardcodedCanvasSaveSize:Object = Fewf.sharedObject.getData(ConstantsApp.SHARED_OBJECT_KEY_HARDCODED_CANVAS_SAVE_SIZE);
			if(!hardcodedCanvasSaveSize) {
				FewfDisplayUtils.saveAsPNG(pObj, pName, pScale);
			} else {
				FewfDisplayUtils.saveAsPNGWithFixedCanvasSize(this.character.getSaveImageDisplayObject(), pName, hardcodedCanvasSaveSize as Number);
			}
		}

		private function _onClipboardButtonClicked(e:Event) : void {
			try {
				FewfDisplayUtils.copyToClipboard(character);
				_toolbox.updateClipboardButton(false, true);
			} catch(e) {
				_toolbox.updateClipboardButton(false, false);
			}
			setTimeout(function(){ _toolbox.updateClipboardButton(true); }, 750);
		}

		// Note: does not automatically de-select previous buttons / infobars; do that before calling this
		// This function is required when setting data via parseParams
		private function _updateUIBasedOnCharacter() : void {
			// var tType:ItemType = character.getCurrentItemData().type;
			// var tPane:ShopCategoryPane = getTabByType(tType);
			// tPane.toggleGridButtonWithData( character.getItemData(tType) );
			// shopTabs.toggleTabOn(WorldPaneManager.itemTypeToId(tType));
			
			_goToItem( character.getCurrentItemData() );
			
			// for each(var tType:ItemType in ItemType.ALL) {
			// 	tPane = getTabByType(tType);
			// 	// Based on what the character is wearing at start, toggle on the appropriate buttons.
			// 	tPane.toggleGridButtonWithData( character.getItemData(tType) );
			// }
		}
		
		private function _goToItem(pItemData:ItemData) : void {
			var itemType:ItemType = pItemData.type;
			
			shopTabs.toggleTabOn(WorldPaneManager.itemTypeToId(itemType));
			var tPane:ShopCategoryPane = getShopPane(itemType);
			var itemBttn:PushButton = tPane.toggleGridButtonWithData( pItemData );
			tPane.scrollItemIntoView(itemBttn);
		}

		private function _onItemToggled(e:ItemDataEvent) : void {
			var tItemData:ItemData = e.itemData;
			
			// // Select buttons on other tabs
			// var tButtons2:Array = null;
			// for(var j:int = 0; j < ITEM.ALL.length; j++) {
			// 	if(ITEM.ALL[j] == tItemData.type) { continue; }
			// 	tButtons2 = getShopPane(ITEM.ALL[j]).buttons;
			// 	for(var i:int = 0; i < tButtons2.length; i++) {
			// 		if (tButtons2[i].pushed)  { tButtons2[i].toggleOff(); }
			// 	}
			// 	_panes.getPane(ITEM.ALL[j]).infoBar.removeInfo();
			// }
			// tButtons2 = null;

			var tPane:ShopCategoryPane = getShopPane(tItemData.type), tInfobar:Infobar = tPane.infobar;
			var tButton:PushButton = tPane.getButtonWithItemData(tItemData);
			// If clicked button is toggled on, equip it. Otherwise remove it.
			if(tButton.pushed) {
				this.character.setItemData(tItemData);

				if(!tItemData.isBitmap()) {
					tInfobar.addInfo( tItemData, GameAssets.getColoredItemImage(tItemData) );
				} else {
					var img:MovieClip = GameAssets.getColoredItemImage(tItemData);
					var bitmap:Bitmap = img.getChildAt(0) as Bitmap;
					tInfobar.addInfo(tItemData, img);
					// If bitmap loaded after, re-add so it can be resized
					bitmap.addEventListener(Event.COMPLETE, function(e):void{
						tInfobar.addInfo(tItemData, GameAssets.getColoredItemImage(tItemData));
					})
				}
				tInfobar.showColorWheel(tItemData.isCustomizable);
			} else {
				_removeItem(tItemData.type);
			}
		}

		private function _removeItem(pType:ItemType) : void {
			return; // No reason to ever remove something currently
			
			var tTabPane:ShopCategoryPane = getShopPane(pType);
			if(!tTabPane || tTabPane.infobar.hasData == false) { return; }

			// Toggle default value on (just the first item in the list)
			var tDefaultIndex = tTabPane.buttons.length-1;
			tTabPane.buttons[tDefaultIndex].toggleOn();
		}
		
		private function _onTabClicked(pEvent:FewfEvent) : void {
			_panes.openPane(pEvent.data.toString());
			
			var tPane:SidePane = _panes.getPane(pEvent.data.toString());
			if(tPane is ShopCategoryPane && (tPane as ShopCategoryPane).infobar.hasData) {
				(tPane as ShopCategoryPane).retoggleActiveButton();
			}
		}
		
		// Find the pressed button
		private function _findIndexActivePushButton(pButtons:Vector.<PushButton>):int {
			for(var i:int = 0; i < pButtons.length; i++){
				if((pButtons[i] as PushButton).pushed){
					return i;
				}
			}
			return -1;
		}

		// private function _onRandomizeDesignClicked(e:Event) : void {
		// 	for(var i:int = 0; i < ITEM.LAYERING.length; i++) {
		// 		_randomItemOfType(ITEM.LAYERING[i]);
		// 	}
		// 	_randomItemOfType(ITEM.POSE);
		// }

		private function _randomItemOfType(pType:ItemType) : void {
			var pane:ShopCategoryPane = getShopPane(pType);
			pane.chooseRandomItem();
		}

		//{REGION Screen Logic
			private function _onShareButtonClicked(e:Event) : void {
				var tURL = "";
				try {
					if(Fewf.isExternallyLoaded) {
						tURL = this.character.getShareCodeFewfreSyntax();
					} else {
						tURL = ExternalInterface.call("eval", "window.location.origin+window.location.pathname");
						tURL += "?"+this.character.getShareCodeFewfreSyntax();
					}
				} catch (error:Error) {
					tURL = "<error creating link>";
				};

				_shareScreen.open(tURL, character);
				addChild(_shareScreen);
			}
			private function _onShareScreenClosed(e:Event) : void { removeChild(_shareScreen); }

			private function _onLangButtonClicked(e:Event) : void { _langScreen.open(); addChild(_langScreen); }
			private function _onLangScreenClosed(e:Event) : void { removeChild(_langScreen); }

			private function _onAboutButtonClicked(e:Event) : void { _aboutScreen.open(); addChild(_aboutScreen); }
			private function _onAboutScreenClosed(e:Event) : void { removeChild(_aboutScreen); }
		//}END Screen Logic

		//{REGION Color Tab
			private function _onColorPickChanged(e:FewfEvent):void {
				if(e.data.allUpdated) {
					this.character.getItemData(this.currentlyColoringType).colors = e.data.allColors;
				} else {
					this.character.getItemData(this.currentlyColoringType).colors[e.data.colorIndex] = uint(e.data.color);
				}
				_refreshSelectedItemColor(this.currentlyColoringType);
			}

			private function _onColorPickHoverPreview(pEvent:FewfEvent) : void {
				// Updated preview data
				GameAssets.swatchHoverPreviewData = pEvent.data;
				// refresh render for anything that uses it
				_refreshSelectedItemColor(this.currentlyColoringType);
			}
			
			private function _refreshSelectedItemColor(pType:ItemType) : void {
				character.updateItem();
				
				var tPane:ShopCategoryPane = getShopPane(pType);
				var tItemData:ItemData = this.character.getItemData(pType);
				if(!tItemData) { return; }
				
				_refreshButtonCustomizationForItemData(tItemData);
				tPane.infobar.refreshItemImageUsingCurrentItemData();
				_panes.colorPickerPane.infobar.refreshItemImageUsingCurrentItemData();
			}
			
			private function _refreshButtonCustomizationForItemData(pItemData:ItemData) : void {
				if(!pItemData) { return; }
				var tPane:ShopCategoryPane = getShopPane(pItemData.type);
				tPane.refreshButtonImage(pItemData);
			}

			private function _colorButtonClicked(pType:ItemType) : void {
				if(this.character.getItemData(this.currentlyColoringType) == null) { return; }

				var tData:ItemData = getShopPane(pType).infobar.itemData;
				_panes.colorPickerPane.infobar.addInfo( tData, GameAssets.getItemImage(tData) );
				this.currentlyColoringType = pType;
				_panes.colorPickerPane.init( tData.uniqId(), tData.colors, tData.defaultColors );
				_panes.openPane(WorldPaneManager.COLOR_PANE);
				_refreshSelectedItemColor(pType);
			}

			private function _onColorPickerBackClicked(pEvent:Event):void {
				_panes.openShopPane(_panes.colorPickerPane.infobar.itemData.type);
			}

			private function _eyeDropButtonClicked(pType:ItemType) : void {
				if(this.character.getItemData(pType) == null) { return; }

				var tData:ItemData = getShopPane(pType).infobar.itemData;
				var tItem:MovieClip = GameAssets.getColoredItemImage(tData);
				var tItem2:MovieClip = !tData.isBitmap() ? GameAssets.getColoredItemImage(tData) : (tData as BitmapItemData).getLargeOutfitImageAsMovieClip();
				_panes.colorFinderPane.infobar.addInfo( tData, tItem );
				this.currentlyColoringType = pType;
				_panes.colorFinderPane.setItem(tItem2);
				_panes.openPane(WorldPaneManager.COLOR_FINDER_PANE);
			}

			private function _onColorFinderBackClicked(pEvent:Event):void {
				_panes.openShopPane(_panes.colorFinderPane.infobar.itemData.type);
			}
		//}END Color Tab
	}
}
