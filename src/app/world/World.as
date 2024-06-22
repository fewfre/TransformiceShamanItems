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
			var tShop:RoundedRectangle = new RoundedRectangle({ x:450, y:10, width:ConstantsApp.SHOP_WIDTH, height:ConstantsApp.APP_HEIGHT })
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
			
			var tOutfitButton:ScaleButton = addChild(new ScaleButton({ x:_toolbox.x+167, y:_toolbox.y+12.5+21, width:25, height:25, origin:0.5, obj:new $Outfit(), obj_scale:0.4 })) as ScaleButton;
			tOutfitButton.addEventListener(ButtonBase.CLICK, function(pEvent:Event){ _paneManager.openPane(TAB_OUTFITS); });
			
			/////////////////////////////
			// Bottom Left Area
			/////////////////////////////
			var tLangButton = addChild(new LangButton({ x:22, y:pStage.stageHeight-17, width:30, height:25, origin:0.5 }));
			tLangButton.addEventListener(ButtonBase.CLICK, _onLangButtonClicked);
			
			// About Screen Button
			var qMark:TextField = new TextField(); qMark.text = '?'; qMark.autoSize = TextFieldAutoSize.CENTER;
			qMark.setTextFormat(new TextFormat('Arial', 22, 0xFFFFFF, 'bold'));
			var aboutButton:SpriteButton = new SpriteButton({ size:25, origin:0.5, obj:qMark }).appendTo(this)
				.setXY(tLangButton.x+(tLangButton.Width/2)+2+(25/2), pStage.stageHeight - 17)
				.on(ButtonBase.CLICK, _onAboutButtonClicked) as SpriteButton;
			qMark.x -= 9; qMark.y -= 15;
			
			if(!!(ParentApp.reopenSelectionLauncher())) {
				new ScaleButton({ obj:new $BackArrow(), obj_scale:0.5, origin:0.5 }).appendTo(this)
				.setXY(22, pStage.stageHeight-17-28)
					.on(ButtonBase.CLICK, function():void{ ParentApp.reopenSelectionLauncher()(); });
			}
			
			/****************************
			* Screens
			*****************************/
			_shareScreen = new LinkTray({ x:pStage.stageWidth * 0.5, y:pStage.stageHeight * 0.5 });
			_shareScreen.addEventListener(LinkTray.CLOSE, _onShareScreenClosed);
			
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
			
			/****************************
			* Other panes
			*****************************/
			var tPane:TabPane = null;
			
			// Outfit Pane
			tPane = _paneManager.addPane(TAB_OUTFITS, new OutfitManagerTabPane(character, _useShareCode));
			tPane.infoBar.colorWheel.addEventListener(MouseEvent.MOUSE_UP, function(pEvent:Event){
				_paneManager.openPane(character.getCurrentItemData().type.toString());
			});
			// Grid Management Events
			tPane.infoBar.rightItemButton.addEventListener(ButtonBase.CLICK, function(){ _traversePaneButtonGrid(_paneManager.getPane(TAB_OUTFITS), true); });
			tPane.infoBar.leftItemButton.addEventListener(ButtonBase.CLICK, function(){ _traversePaneButtonGrid(_paneManager.getPane(TAB_OUTFITS), false); });
			
			// Color Picker Pane
			tPane = _paneManager.addPane(COLOR_PANE_ID, new ColorPickerTabPane({}));
			tPane.addEventListener(ColorPickerTabPane.EVENT_COLOR_PICKED, _onColorPickChanged);
			tPane.addEventListener(ColorPickerTabPane.EVENT_PREVIEW_COLOR, _onColorPickHoverPreview);
			tPane.addEventListener(ColorPickerTabPane.EVENT_EXIT, _onColorPickerBackClicked);
			tPane.infoBar.removeItemOverlay.addEventListener(MouseEvent.CLICK, function(e){
				_onColorPickerBackClicked(e);
				_removeItem(_paneManager.getPane(COLOR_PANE_ID).infoBar.data.type);
			});
			
			// Color Finder Pane
			tPane = _paneManager.addPane(COLOR_FINDER_PANE_ID, new ColorFinderPane({ }));
			tPane.addEventListener(ColorPickerTabPane.EVENT_EXIT, _onColorFinderBackClicked);
			tPane.infoBar.removeItemOverlay.addEventListener(MouseEvent.CLICK, function(e){
				_onColorFinderBackClicked(e);
				_removeItem(_paneManager.getPane(COLOR_FINDER_PANE_ID).infoBar.data.type);
			});
			
			// Select First Pane
			shopTabs.tabs[0].toggleOn();
			
			tPane = null;
		}

		private function _setupItemPane(pType:ItemType) : ShopCategoryPane {
			var tPane:ShopCategoryPane = new ShopCategoryPane(pType);
			tPane.addEventListener(ShopCategoryPane.ITEM_TOGGLED, _onItemToggled);
			
			tPane.infoBar.colorWheel.addEventListener(ButtonBase.CLICK, function(){ _colorButtonClicked(pType); });
			tPane.infoBar.removeItemOverlay.addEventListener(MouseEvent.CLICK, function(){ _removeItem(pType); });
			// Grid Management Events
			tPane.infoBar.randomizeButton.addEventListener(ButtonBase.CLICK, function(){ _randomItemOfType(pType); });
			tPane.infoBar.rightItemButton.addEventListener(ButtonBase.CLICK, function(){ _traversePaneButtonGrid(tPane, true); });
			tPane.infoBar.leftItemButton.addEventListener(ButtonBase.CLICK, function(){ _traversePaneButtonGrid(tPane, false); });
			// Misc
			if(tPane.infoBar.eyeDropButton) {
				tPane.infoBar.eyeDropButton.addEventListener(ButtonBase.CLICK, function(){ _eyeDropButtonClicked(pType); });
			}
			return tPane;
		}

		private function _onMouseWheel(pEvent:MouseEvent) : void {
			if(this.mouseX < this.shopTabs.x) {
				_toolbox.scaleSlider.updateViaMouseWheelDelta(pEvent.delta);
				character.scale = _toolbox.scaleSlider.value;
			}
		}

		private function _onKeyDownListener(e:KeyboardEvent) : void {
			if (e.keyCode == Keyboard.RIGHT){
				_traversePaneButtonGrid(_paneManager.getOpenPane(), true);
			}
			else if (e.keyCode == Keyboard.LEFT) {
				_traversePaneButtonGrid(_paneManager.getOpenPane(), false);
			}
			else if (e.keyCode == Keyboard.UP){
				_traversePaneButtonGridVertically(_paneManager.getOpenPane(), true);
			}
			else if (e.keyCode == Keyboard.DOWN) {
				_traversePaneButtonGridVertically(_paneManager.getOpenPane(), false);
			}
		}
		
		private function _traversePaneButtonGrid(pane:TabPane, pRight:Boolean):void {
			if(pane && pane.grid && pane.buttons && pane.buttons.length > 0 && pane.buttons[0] is PushButton) {
				var buttons:Array = pane.buttons;
				var activeButtonIndex:int = _findIndexActivePushButton(buttons);
				if(activeButtonIndex == -1) { activeButtonIndex = pane.grid.reversed ? buttons.length-1 : 0; }
				
				var dir:int = (pRight ? 1 : -1) * (pane.grid.reversed ? -1 : 1),
					length:uint = buttons.length;
					
				var newI:int = activeButtonIndex+dir;
				// mod it so it wraps - `length` added before mod to allow a `-1` dir to properly wrap
				newI = (length + newI) % length;
				
				var btn:PushButton = buttons[newI];
				btn.toggleOn();
				pane.scrollItemIntoView(btn);
			}
		}
		
		private function _traversePaneButtonGridVertically(pane:TabPane, pUp:Boolean):void {
			if(pane && pane is ColorPickerTabPane) {
				(pane as ColorPickerTabPane).nextSwatch(!pUp);
			}
			else if(pane && pane.grid && pane.buttons && pane.buttons.length > 0 && pane.buttons[0] is PushButton) {
				var buttons:Array = pane.buttons, grid:Grid = pane.grid;
				
				var activeButtonIndex:int = _findIndexActivePushButton(buttons);
				if(activeButtonIndex == -1) { activeButtonIndex = grid.reversed ? buttons.length-1 : 0; }
				var dir:int = (pUp ? -1 : 1) * (grid.reversed ? -1 : 1),
					length:uint = buttons.length;
				
				var rowI:Number = Math.floor(activeButtonIndex / grid.columns);
				rowI = (rowI + dir); // increment row in direction
				rowI = (grid.rows + rowI) % grid.rows; // wrap it in both directions
				var colI = activeButtonIndex % grid.columns;
				
				// we want to stay in the same column, and just move up/down a row
				// var newRowI:Number = (grid.rows + rowI) % grid.rows;
				var newI:int = rowI*grid.columns + colI;
				
				// since row is modded, it can only ever be out of bounds at the end - this happens if the last
				// row doesn't have enough items to fill all columns, and active column is in one of them.
				if(newI >= length) {
					// we solve it by going an extra step in our current direction, mod it again so it can wrap if needed,
					// and then we recalculate the button i
					rowI += dir;
					rowI = (grid.rows + rowI) % grid.rows; // wrap it again
					newI = rowI*grid.columns + colI;
				}
				
				var btn:PushButton = buttons[newI];
				btn.toggleOn();
				pane.scrollItemIntoView(btn);
			}
		}
		
		// Find the pressed button
		private function _findIndexActivePushButton(pButtons:Array):int {
			for(var i:int = 0; i < pButtons.length; i++){
				if((pButtons[i] as PushButton).pushed){
					return i;
				}
			}
			return -1;
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
			var tPane:ShopCategoryPane = getTabByType(itemType);
			var itemBttn:PushButton = tPane.toggleGridButtonWithData( pItemData );
			tPane.scrollItemIntoView(itemBttn);
		}

		private function _onItemToggled(pEvent:FewfEvent) : void {
			var tType:ItemType = pEvent.data.type;
			var tItemList:Vector.<ItemData> = GameAssets.getItemDataListByType(tType);
			var tInfoBar:ShopInfoBar = getInfoBarByType(tType);

			// De-select all buttons that aren't the clicked one.
			var tButtons:Array = getButtonArrayByType(tType);
			for(var i:int = 0; i < tButtons.length; i++) {
				if(tButtons[i].data.id != pEvent.data.id) {
					if (tButtons[i].pushed) { tButtons[i].toggleOff(); }
				}
			}
			
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

			var tButton:PushButton = tButtons[pEvent.data.id];
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
			
			var tTabPane = getTabByType(pType);
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
			
			var tPane:TabPane = _paneManager.getPane(pEvent.data.toString());
			if(tPane.infoBar.hasData) {
				var buttons = tPane.buttons;
				var i:int = _findIndexActivePushButton(buttons);
				if(i > -1) {
					buttons[i].toggleOff();
					buttons[i].toggleOn();
				}
			}
		}

		// private function _onRandomizeDesignClicked(pEvent:Event) : void {
		// 	for(var i:int = 0; i < ITEM.LAYERING.length; i++) {
		// 		_randomItemOfType(ITEM.LAYERING[i]);
		// 	}
		// 	_randomItemOfType(ITEM.POSE);
		// }

		private function _randomItemOfType(pType:ItemType) : void {
			var pane:TabPane = getTabByType(pType);
			// if(pane.infoBar.isRefreshLocked) { return; }
			var tLength = pane.buttons.length;
			var btn = pane.buttons[ Math.floor(Math.random() * tLength) ];
			btn.toggleOn();
			if(pane.flagOpen) pane.scrollItemIntoView(btn);
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
			private function getTabByType(pType:ItemType) : ShopCategoryPane {
				return _paneManager.getPane(pType.toString()) as ShopCategoryPane;
			}

			private function getInfoBarByType(pType:ItemType) : ShopInfoBar {
				return getTabByType(pType).infoBar;
			}

			private function getButtonArrayByType(pType:ItemType) : Array {
				return getTabByType(pType).buttons;
			}

			private function getCurItemID(pType:ItemType) : int {
				return getTabByType(pType).selectedButtonIndex;
			}

			private function setCurItemID(pType:ItemType, pID:int) : void {
				getTabByType(pType).selectedButtonIndex = pID;
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
				GameAssets.copyColor(tItem, getButtonArrayByType(pType)[ getCurItemID(pType) ].Image );
				GameAssets.copyColor(tItem, getInfoBarByType( pType ).Image );
				GameAssets.copyColor(tItem, _paneManager.getPane(COLOR_PANE_ID).infoBar.Image);
				/*var tMC:MovieClip = this.character.getItemFromIndex(this.currentlyColoringType);
				if (tMC != null)
				{
					GameAssets.colorDefault(tMC);
					GameAssets.copyColor( tMC, getButtonArrayByType(pType)[ getCurItemID(pType) ].Image );
					GameAssets.copyColor(tMC, getInfoBarByType(pType).Image);
					GameAssets.copyColor(tMC, _paneManager.getPane(COLOR_PANE_ID).infoBar.Image);
					
				}*/
			}
			
			private function _refreshButtonCustomizationForItemData(data:ItemData) : void {
				if(!data) { return; }
				if(data.isBitmap()) { return; } // Bitmaps have no customization
				
				var pane:ShopCategoryPane = getTabByType(data.type);
				var i:int = GameAssets.getItemIndexFromTypeID(data.type, data.id);
				
				var tItem:MovieClip = GameAssets.getColoredItemImage(data);
				GameAssets.copyColor(tItem, pane.buttons[i].Image );
			}

			private function _colorButtonClicked(pType:ItemType) : void {
				if(this.character.getItemData(this.currentlyColoringType) == null) { return; }

				var tData:ItemData = getInfoBarByType(pType).data;
				_paneManager.getPane(COLOR_PANE_ID).infoBar.addInfo( tData, GameAssets.getItemImage(tData) );
				this.currentlyColoringType = pType;
				(_paneManager.getPane(COLOR_PANE_ID) as ColorPickerTabPane).init( tData.uniqId(), tData.colors, tData.defaultColors );
				_paneManager.openPane(COLOR_PANE_ID);
				_refreshSelectedItemColor();
			}

			private function _onColorPickerBackClicked(pEvent:Event):void {
				_paneManager.openPane(_paneManager.getPane(COLOR_PANE_ID).infoBar.data.type.toString());
			}

			private function _eyeDropButtonClicked(pType:ItemType) : void {
				if(this.character.getItemData(pType) == null) { return; }

				var tData:ItemData = getInfoBarByType(pType).data;
				var tItem:MovieClip = GameAssets.getColoredItemImage(tData);
				var tItem2:MovieClip = !tData.isBitmap() ? GameAssets.getColoredItemImage(tData) : (tData as BitmapItemData).getLargeOutfitImageAsMovieClip();
				_paneManager.getPane(COLOR_FINDER_PANE_ID).infoBar.addInfo( tData, tItem );
				this.currentlyColoringType = pType;
				(_paneManager.getPane(COLOR_FINDER_PANE_ID) as ColorFinderPane).setItem(tItem2);
				_paneManager.openPane(COLOR_FINDER_PANE_ID);
			}

			private function _onColorFinderBackClicked(pEvent:Event):void {
				_paneManager.openPane(_paneManager.getPane(COLOR_FINDER_PANE_ID).infoBar.data.type.toString());
			}
		//}END Color Tab
	}
}
