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
	import app.ui.common.*;
	import app.data.*;
	import app.world.data.*;
	import app.world.elements.*;

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
	import flash.ui.Keyboard;
	import app.ui.panes.colorpicker.ColorPickerTabPane;
	import ext.ParentApp;
	import app.ui.panes.base.PaneManager;
	import app.ui.panes.base.SidePane;
	import app.ui.panes.base.ButtonGridSidePane;
	import app.ui.panes.infobar.Infobar;
	import app.ui.panes.infobar.GridManagementWidget;
	
	public class World extends MovieClip
	{
		// Storage
		private var character      : CustomItem;
		private var _paneManager   : PaneManager;

		private var shopTabs       : ShopTabList;
		private var _toolbox       : Toolbox;
		
		private var _shareScreen   : LinkTray;
		private var _langScreen    : LangScreen;
		private var _aboutScreen   : AboutScreen;

		private var currentlyColoringType:ItemType=null;
		private var configCurrentlyColoringType:String;
		
		// Constants
		public static const TAB_OUTFITS:String = "outfits";
		public static const COLOR_PANE_ID = "colorPane";
		public static const COLOR_FINDER_PANE_ID = "colorFinderPane";
		
		// Constructor
		public function World(pStage:Stage) {
			super();
			_buildWorld(pStage);
			pStage.addEventListener(MouseEvent.MOUSE_WHEEL, _onMouseWheel);
			pStage.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDownListener);
		}
		
		private function _buildWorld(pStage:Stage) {
			GameAssets.init();

			/****************************
			* Create CustomItem
			*****************************/
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

			this.character = new CustomItem(GameAssets.boxes_small[0], parms).setXY(185, 275).appendTo(this);

			/****************************
			* Setup UI
			*****************************/
			var tShop:RoundedRectangle = new RoundedRectangle(ConstantsApp.SHOP_WIDTH, ConstantsApp.APP_HEIGHT).setXY(450, 10)
				.appendTo(this).drawAsTray();
			_paneManager = tShop.addChild(new PaneManager()) as PaneManager;
			
			this.shopTabs = new ShopTabList(70, ConstantsApp.APP_HEIGHT).setXY(375, 10).appendTo(this);
			this.shopTabs.addEventListener(ShopTabList.TAB_CLICKED, _onTabClicked);
			var tabs:Vector.<Object> = new <Object>[
				{ text:"tab_box_small", event:ItemType.BOX_SMALL.toString() },
				{ text:"tab_box_large", event:ItemType.BOX_LARGE.toString() },
				{ text:"tab_plank_small", event:ItemType.PLANK_SMALL.toString() },
				{ text:"tab_plank_large", event:ItemType.PLANK_LARGE.toString() },
				{ text:"tab_ball", event:ItemType.BALL.toString() },
				{ text:"tab_trampoline", event:ItemType.TRAMPOLINE.toString() },
				{ text:"tab_anvil", event:ItemType.ANVIL.toString() },
				{ text:"tab_cannonball", event:ItemType.CANNONBALL.toString() },
				{ text:"tab_balloon", event:ItemType.BALLOON.toString() },
				{ text:"tab_cartouche", event:ItemType.CARTOUCHE.toString() }
			];
			if(Fewf.assets.getData("config").badges) {
				tabs.push({ text:"tab_badge", event:ItemType.BADGE.toString() });
			}
			this.shopTabs.populate(tabs);

			/////////////////////////////
			// Top Area
			/////////////////////////////
			_toolbox = new Toolbox(character, _onShareCodeEntered).setXY(188, 28).appendTo(this)
				.on(Toolbox.SAVE_CLICKED, _onSaveClicked)
				.on(Toolbox.SHARE_CLICKED, _onShareButtonClicked)
				.on(Toolbox.CLIPBOARD_CLICKED, _onClipboardButtonClicked).on(Toolbox.IMGUR_CLICKED, _onImgurButtonClicked)
				
				.on(Toolbox.SCALE_SLIDER_CHANGE, _onScaleSliderChange);
			
			// Outfit Button
			new ScaleButton({ origin:0.5, obj:new $Outfit(), obj_scale:0.4 }).appendTo(this).setXY(_toolbox.x+167, _toolbox.y+12.5+21)
				.on(ButtonBase.CLICK, function(pEvent:Event){ _paneManager.openPane(TAB_OUTFITS); });
			
			/////////////////////////////
			// Bottom Left Area
			/////////////////////////////
			var tLangButton = addChild(new LangButton({ x:22, y:pStage.stageHeight-17, width:30, height:25, origin:0.5 }));
			tLangButton.addEventListener(ButtonBase.CLICK, _onLangButtonClicked);
			
			// About Screen Button
			var aboutButton:SpriteButton = new SpriteButton({ size:25, origin:0.5 }).appendTo(this)
				.setXY(tLangButton.x+(tLangButton.Width/2)+2+(25/2), pStage.stageHeight - 17)
				.on(ButtonBase.CLICK, _onAboutButtonClicked) as SpriteButton;
			new TextBase("?", { size:22, color:0xFFFFFF, bold:true, origin:0.5 }).setXY(0, -1).appendTo(aboutButton)
			
			
			if(!!(ParentApp.reopenSelectionLauncher())) {
				new ScaleButton({ obj:new $BackArrow(), obj_scale:0.5, origin:0.5 }).appendTo(this)
				.setXY(22, pStage.stageHeight-17-28)
					.on(ButtonBase.CLICK, function():void{ ParentApp.reopenSelectionLauncher()(); });
			}
			
			/****************************
			* Screens
			*****************************/
			_shareScreen = new LinkTray({ x:pStage.stageWidth * 0.5, y:pStage.stageHeight * 0.5 });
			_shareScreen.addEventListener(Event.CLOSE, _onShareScreenClosed);
			
			_langScreen = new LangScreen({  });
			_langScreen.addEventListener(Event.CLOSE, _onLangScreenClosed);

			_aboutScreen = new AboutScreen();
			_aboutScreen.addEventListener(Event.CLOSE, _onAboutScreenClosed);

			/****************************
			* Create item panes
			*****************************/
			for each(var tType:ItemType in ItemType.ALL) {
				_paneManager.addPane(tType.toString(), _setupItemPane(tType));
				// // Based on what the character is wearing at start, toggle on the appropriate buttons.
				// getTabByType(tType).toggleGridButtonWithData( character.getItemData(tType) );
				
				// Select newest item in each pane
				getButtonArrayByType(tType)[ getButtonArrayByType(tType).length-1 ].toggleOn();
			}
			
			Fewf.dispatcher.addEventListener(ConstantsApp.DOWNLOAD_ITEM_DATA_IMAGE, _onSaveItemDataAsImage);
			
			/****************************
			* Other panes
			*****************************/
			var tPane:SidePane = null;
			
			// Outfit Pane
			tPane = _paneManager.addPane(TAB_OUTFITS, new OutfitManagerTabPane(character, _useShareCode, function(){ return character.getShareCodeFewfreSyntax(); }));
			tPane.addEventListener(Event.CLOSE, function(pEvent:Event){
				_paneManager.openPane(character.getCurrentItemData().type.toString());
			});
			
			// Color Picker Pane
			tPane = _paneManager.addPane(COLOR_PANE_ID, new ColorPickerTabPane({}));
			tPane.addEventListener(ColorPickerTabPane.EVENT_COLOR_PICKED, _onColorPickChanged);
			tPane.addEventListener(ColorPickerTabPane.EVENT_PREVIEW_COLOR, _onColorPickHoverPreview);
			tPane.addEventListener(Event.CLOSE, _onColorPickerBackClicked);
			tPane.addEventListener(ColorPickerTabPane.EVENT_ITEM_ICON_CLICKED, function(e){
				_onColorPickerBackClicked(e);
				_removeItem(getColorPickerPane().infoBar.itemData.type);
			});
			
			// Color Finder Pane
			tPane = _paneManager.addPane(COLOR_FINDER_PANE_ID, new ColorFinderPane({ }));
			tPane.addEventListener(Event.CLOSE, _onColorFinderBackClicked);
			tPane.addEventListener(ColorFinderPane.EVENT_ITEM_ICON_CLICKED, function(e){
				_onColorFinderBackClicked(e);
				_removeItem(getColorFinderPane().infoBar.itemData.type);
			});
			
			// Select First Pane
			shopTabs.tabs[0].toggleOn();
			
			tPane = null;
		}

		private function _setupItemPane(pType:ItemType) : ShopCategoryPane {
			var tPane:ShopCategoryPane = new ShopCategoryPane(pType);
			tPane.addEventListener(ShopCategoryPane.ITEM_TOGGLED, _onItemToggled);
			
			tPane.infoBar.on(Infobar.COLOR_WHEEL_CLICKED, function(){ _colorButtonClicked(pType); });
			tPane.infoBar.on(Infobar.ITEM_PREVIEW_CLICKED, function(){ _removeItem(pType); });
			tPane.infoBar.on(Infobar.EYE_DROPPER_CLICKED, function(){ _eyeDropButtonClicked(pType); });
			tPane.infoBar.on(GridManagementWidget.RANDOMIZE_CLICKED, function(){ _randomItemOfType(pType); });
			return tPane;
		}

		private function _onMouseWheel(pEvent:MouseEvent) : void {
			if(this.mouseX < this.shopTabs.x) {
				_toolbox.scaleSlider.updateViaMouseWheelDelta(pEvent.delta);
				character.scale = _toolbox.scaleSlider.value;
			}
		}

		private function _onKeyDownListener(e:KeyboardEvent) : void {
			if (e.keyCode == Keyboard.RIGHT || e.keyCode == Keyboard.LEFT || e.keyCode == Keyboard.UP || e.keyCode == Keyboard.DOWN){
				var pane:SidePane = _paneManager.getOpenPane();
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

		private function _onScaleSliderChange(pEvent:Event):void {
			character.scale = _toolbox.scaleSlider.value;
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
				var itemType:ItemType = character.getCurrentItemData().type;
				shopTabs.UnpressAll();
				shopTabs.toggleTabOn(itemType.toString(), false);
			}
		}

		private function _onSaveClicked(pEvent:Event) : void {
			FewfDisplayUtils.saveAsPNG(this.character.getSaveImageDisplayObject(), "shamanitem");
		}
		
		private function _onSaveItemDataAsImage(pEvent:FewfEvent) : void {
			if(!pEvent.data) { return; }
			var itemData:ItemData = pEvent.data as ItemData;
			var tName = "shop-"+itemData.type+itemData.id;
			if(itemData.type == ItemType.CARTOUCHE) {
				tName = "Macaron "+itemData.id;
			}
			if(!itemData.isBitmap()) {
				FewfDisplayUtils.saveAsPNG(GameAssets.getColoredItemImage(itemData), tName, ConstantsApp.ITEM_SAVE_SCALE);
			} else {
				FewfDisplayUtils.saveAsPNG((itemData as BitmapItemData).getFullImage(), tName, 1);
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

		private function _onImgurButtonClicked(e:Event) : void {
			Fewf.dispatcher.addEventListener(ImgurApi.EVENT_DONE, _onImgurDone);
			ImgurApi.uploadImage(character);
			_toolbox.imgurButtonEnable(false);
		}
		private function _onImgurDone(e:*) : void {
			Fewf.dispatcher.removeEventListener(ImgurApi.EVENT_DONE, _onImgurDone);
			_toolbox.imgurButtonEnable(true);
		}

		// Note: does not automatically de-select previous buttons / infobars; do that before calling this
		// This function is required when setting data via parseParams
		private function _updateUIBasedOnCharacter() : void {
			// var tType:ItemType = character.getCurrentItemData().type;
			// var tPane:ShopCategoryPane = getTabByType(tType);
			// tPane.toggleGridButtonWithData( character.getItemData(tType) );
			// shopTabs.toggleTabOn(tType.toString());
			
			_goToItem( character.getCurrentItemData() );
			
			// for each(var tType:ItemType in ItemType.ALL) {
			// 	tPane = getTabByType(tType);
			// 	// Based on what the character is wearing at start, toggle on the appropriate buttons.
			// 	tPane.toggleGridButtonWithData( character.getItemData(tType) );
			// }
		}
		
		private function _goToItem(pItemData:ItemData) : void {
			var itemType:ItemType = pItemData.type;
			
			shopTabs.UnpressAll();
			shopTabs.toggleTabOn(itemType.toString());
			var tPane:ShopCategoryPane = getShopPane(itemType);
			var itemBttn:PushButton = tPane.toggleGridButtonWithData( pItemData );
			tPane.scrollItemIntoView(itemBttn);
		}

		private function _onItemToggled(pEvent:FewfEvent) : void {
			var tType:ItemType = pEvent.data.type;
			var tItemList:Vector.<ItemData> = GameAssets.getItemDataListByType(tType);
			
			// // Select buttons on other tabs
			// var tButtons2:Array = null;
			// for(var j:int = 0; j < ITEM.ALL.length; j++) {
			// 	if(ITEM.ALL[j] == tType) { continue; }
			// 	tButtons2 = getButtonArrayByType(ITEM.ALL[j]);
			// 	for(var i:int = 0; i < tButtons2.length; i++) {
			// 		if (tButtons2[i].pushed)  { tButtons2[i].toggleOff(); }
			// 	}
			// 	_paneManager.getPane(ITEM.ALL[j]).infoBar.removeInfo();
			// }
			// tButtons2 = null;

			var tPane:ShopCategoryPane = getShopPane(tType);
			var tInfoBar:Infobar = tPane.infoBar;
			var tButton:PushButton = tPane.getButtonWithItemData(pEvent.data.itemData);
			var tData:ItemData;
			// If clicked button is toggled on, equip it. Otherwise remove it.
			if(tButton.pushed) {
				tData = tItemList[pEvent.data.id];
				setCurItemID(tType, tButton.id);
				this.character.setItemData(tData);

				if(!tData.isBitmap()) {
					tInfoBar.addInfo( tData, GameAssets.getColoredItemImage(tData) );
				} else {
					var img:MovieClip = GameAssets.getColoredItemImage(tData);
					var bitmap:Bitmap = img.getChildAt(0) as Bitmap;
					tInfoBar.addInfo(tData, img);
					// If bitmap loaded after, re-add so it can be resized
					bitmap.addEventListener(Event.COMPLETE, function(e):void{
						tInfoBar.addInfo(tData, GameAssets.getColoredItemImage(tData));
					})
				}
				tInfoBar.showColorWheel(GameAssets.getNumOfCustomColors(tButton.Image as MovieClip) > 0);
			} else {
				_removeItem(tType);
			}
		}

		private function _removeItem(pType:ItemType) : void {
			return; // No reason to ever remove something currently
			
			var tTabPane:ShopCategoryPane = getShopPane(pType);
			if(!tTabPane || tTabPane.infoBar.hasData == false) { return; }

			// If item has a default value, toggle it on. otherwise remove item.
			/*if(pType == ITEM.SKIN || pType == ITEM.POSE) {*/
				var tDefaultIndex = tTabPane.buttons.length-1;//(pType == ITEM.POSE ? GameAssets.defaultPoseIndex : GameAssets.defaultSkinIndex);
				tTabPane.buttons[tDefaultIndex].toggleOn();
			/*} else {
				this.character.removeItem(pType);
				tTabPane.infoBar.removeInfo();
				tTabPane.buttons[ tTabPane.selectedButtonIndex ].toggleOff();
			}*/
		}
		
		private function _onTabClicked(pEvent:FewfEvent) : void {
			_paneManager.openPane(pEvent.data.toString());
			
			var tPane:SidePane = _paneManager.getPane(pEvent.data.toString());
			if(tPane is ShopCategoryPane && (tPane as ShopCategoryPane).infoBar.hasData) {
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

		// private function _onRandomizeDesignClicked(pEvent:Event) : void {
		// 	for(var i:int = 0; i < ITEM.LAYERING.length; i++) {
		// 		_randomItemOfType(ITEM.LAYERING[i]);
		// 	}
		// 	_randomItemOfType(ITEM.POSE);
		// }

		private function _randomItemOfType(pType:ItemType) : void {
			var pane:ShopCategoryPane = getShopPane(pType);
			pane.chooseRandomItem();
		}

		private function _onShareButtonClicked(pEvent:Event) : void {
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

			_shareScreen.open(tURL);
			addChild(_shareScreen);
		}

		private function _onShareScreenClosed(pEvent:Event) : void {
			removeChild(_shareScreen);
		}

		private function _onLangButtonClicked(pEvent:Event) : void {
			_langScreen.open();
			addChild(_langScreen);
		}

		private function _onLangScreenClosed(pEvent:Event) : void {
			removeChild(_langScreen);
		}

		private function _onAboutButtonClicked(e:Event) : void {
			_aboutScreen.open();
			addChild(_aboutScreen);
		}

		private function _onAboutScreenClosed(e:Event) : void {
			removeChild(_aboutScreen);
		}

		//{REGION Get TabPane data
			private function getShopPane(pType:ItemType) : ShopCategoryPane {
				return _paneManager.getPane(pType.toString()) as ShopCategoryPane;
			}

			private function getInfobarByType(pType:ItemType) : Infobar {
				return getShopPane(pType).infoBar;
			}

			private function getButtonArrayByType(pType:ItemType) : Vector.<PushButton> {
				return getShopPane(pType).buttons;
			}

			private function getCurItemID(pType:ItemType) : int {
				return getShopPane(pType).selectedButtonIndex;
			}

			private function setCurItemID(pType:ItemType, pID:int) : void {
				getShopPane(pType).selectedButtonIndex = pID;
			}
			
			private function getColorPickerPane() : ColorPickerTabPane {
				return _paneManager.getPane(COLOR_PANE_ID) as ColorPickerTabPane;
			}
			private function getColorFinderPane() : ColorFinderPane {
				return _paneManager.getPane(COLOR_FINDER_PANE_ID) as ColorFinderPane;
			}
		//}END Get TabPane data

		//{REGION Color Tab
			private function _onColorPickChanged(e:FewfEvent):void {
				if(e.data.allUpdated) {
					this.character.getItemData(this.currentlyColoringType).colors = e.data.allColors;
				} else {
					this.character.getItemData(this.currentlyColoringType).colors[e.data.colorIndex] = uint(e.data.color);
				}
				_refreshSelectedItemColor();
			}

			private function _onColorPickHoverPreview(pEvent:FewfEvent) : void {
				// Updated preview data
				GameAssets.swatchHoverPreviewData = pEvent.data;
				// refresh render for anything that uses it
				_refreshSelectedItemColor();
			}
			
			private function _refreshSelectedItemColor() : void {
				character.updateItem();
				
				var pType:ItemType = this.currentlyColoringType;
				var tItemData = this.character.getItemData(pType);
				var tItem:MovieClip = GameAssets.getColoredItemImage(tItemData);
				GameAssets.copyColor(tItem, getButtonArrayByType(pType)[ getCurItemID(pType) ].Image as MovieClip );
				GameAssets.copyColor(tItem, getInfobarByType( pType ).Image );
				GameAssets.copyColor(tItem, getColorPickerPane().infoBar.Image);
				/*var tMC:MovieClip = this.character.getItemFromIndex(this.currentlyColoringType);
				if (tMC != null)
				{
					GameAssets.colorDefault(tMC);
					GameAssets.copyColor( tMC, getButtonArrayByType(pType)[ getCurItemID(pType) ].Image );
					GameAssets.copyColor(tMC, getInfobarByType(pType).Image);
					GameAssets.copyColor(tMC, getColorPickerPane().infoBar.Image);
					
				}*/
			}
			
			private function _refreshButtonCustomizationForItemData(data:ItemData) : void {
				if(!data) { return; }
				if(data.isBitmap()) { return; } // Bitmaps have no customization
				
				var pane:ShopCategoryPane = getShopPane(data.type);
				var i:int = GameAssets.getItemIndexFromTypeID(data.type, data.id);
				
				var tItem:MovieClip = GameAssets.getColoredItemImage(data);
				GameAssets.copyColor(tItem, pane.buttons[i].Image as MovieClip );
			}

			private function _colorButtonClicked(pType:ItemType) : void {
				if(this.character.getItemData(this.currentlyColoringType) == null) { return; }

				var tData:ItemData = getInfobarByType(pType).itemData;
				getColorPickerPane().infoBar.addInfo( tData, GameAssets.getItemImage(tData) );
				this.currentlyColoringType = pType;
				getColorPickerPane().init( tData.uniqId(), tData.colors, tData.defaultColors );
				_paneManager.openPane(COLOR_PANE_ID);
				_refreshSelectedItemColor();
			}

			private function _onColorPickerBackClicked(pEvent:Event):void {
				_paneManager.openPane(getColorPickerPane().infoBar.itemData.type.toString());
			}

			private function _eyeDropButtonClicked(pType:ItemType) : void {
				if(this.character.getItemData(pType) == null) { return; }

				var tData:ItemData = getInfobarByType(pType).itemData;
				var tItem:MovieClip = GameAssets.getColoredItemImage(tData);
				var tItem2:MovieClip = !tData.isBitmap() ? GameAssets.getColoredItemImage(tData) : (tData as BitmapItemData).getLargeOutfitImageAsMovieClip();
				getColorFinderPane().infoBar.addInfo( tData, tItem );
				this.currentlyColoringType = pType;
				getColorFinderPane().setItem(tItem2);
				_paneManager.openPane(COLOR_FINDER_PANE_ID);
			}

			private function _onColorFinderBackClicked(pEvent:Event):void {
				_paneManager.openPane(getColorFinderPane().infoBar.itemData.type.toString());
			}
		//}END Color Tab
	}
}
