package app.ui.panes
{
	import com.fewfre.display.*;
	import com.fewfre.utils.Fewf;
	import com.fewfre.utils.FewfDisplayUtils;
	import com.fewfre.events.FewfEvent;
	import app.data.*;
	import app.ui.*;
	import app.ui.buttons.*;
	import app.world.elements.*;
	import flash.display.*;
	import flash.events.*;
	import flash.display.MovieClip;
	import flash.utils.ByteArray;
	import flash.net.FileReference;
	import flash.net.FileFilter;
	import flash.utils.setTimeout;
	import app.world.data.ItemData;
	
	public class OutfitManagerTabPane extends TabPane
	{
		// Storage
		private var _character : CustomItem;
		
		private var _deleteBtnGrid		: Grid;
		private var _onUserLookClicked	: Function;
		private var _exportButton	: SpriteButton;
		private var _importButton	: SpriteButton;
		
		// Constructor
		public function OutfitManagerTabPane(pCharacter:CustomItem, pOnUserLookClicked:Function) {
			super();
			_character = pCharacter;
			_onUserLookClicked = pOnUserLookClicked;
			
			this.addInfoBar( new ShopInfoBar({ showBackButton:true, showGridManagementButtons:true }) );
			this.addGrid( new Grid(385, 5).setXY(15,5) );
			_deleteBtnGrid = addItem(new Grid(385, 5).setXY(15,5)) as Grid;
			this.infoBar.hideImageCont();
			
			this.grid.reverse(); // Start reversed so that new outfits get added to start of list
			_deleteBtnGrid.reverse();
			this.infoBar.randomizeButton.addEventListener(ButtonBase.CLICK, function(){ selectRandomOutfit(); });
			this.infoBar.reverseButton.addEventListener(ButtonBase.CLICK, function(){
				grid.reverse(); _deleteBtnGrid.reverse();
				_renderOutfits(); // Have to manually re-render since otherwise "add" button doesn't stick to top left
			});
			
			// Custom infobar buttons
			var size = 40, xx = ConstantsApp.PANE_WIDTH - size - 5, yy = 6;
			
			_importButton = new SpriteButton({ x:xx, y:yy, width:size, height:size, obj:new $Folder() });
			_importButton.addEventListener(MouseEvent.CLICK, _onImportClicked);
			addChild(_importButton);
			
			xx -= size + 5;
			
			_exportButton = new SpriteButton({ x:xx, y:yy, width:size, height:size, obj:new $SimpleDownload(), obj_scale:0.7 });
			_exportButton.addEventListener(MouseEvent.CLICK, _onExportClicked);
			addChild(_exportButton);
			
			UpdatePane();
		}
		
		/****************************
		* Public
		*****************************/
		public override function open() : void {
			super.open();
			
			_renderOutfits();
		}
		
		public function addNewLook(lookCode:String) : void {
			trace('addNewLook', lookCode);
			var looks:Array = Fewf.sharedObject.getData(ConstantsApp.SHARED_OBJECT_KEY_OUTFITS) || [];
			looks.push(lookCode);
			Fewf.sharedObject.setData(ConstantsApp.SHARED_OBJECT_KEY_OUTFITS, looks);
			
			_renderOutfits();
		}
		
		public function deleteLookByIndex(i:int) : void {
			var looks:Array = Fewf.sharedObject.getData(ConstantsApp.SHARED_OBJECT_KEY_OUTFITS) || [];
			looks.splice(i, 1);
			Fewf.sharedObject.setData(ConstantsApp.SHARED_OBJECT_KEY_OUTFITS, looks);
			
			_renderOutfits();
		}
		
		public function selectRandomOutfit() : void {
			var btn = buttons[ Math.floor(Math.random() * buttons.length) ];
			btn.toggleOn();
			if(this.flagOpen) this.scrollItemIntoView(btn);
		}
		
		/****************************
		* Private
		*****************************/
		private function _renderOutfits() : void {
			var looks:Array = Fewf.sharedObject.getData(ConstantsApp.SHARED_OBJECT_KEY_OUTFITS) || [];
			
			if(looks.length > 0) {
				_exportButton.enable().alpha = 1;
			} else {
				_exportButton.disable().alpha = 0;
			}
			
			grid.reset();
			_deleteBtnGrid.reset();
			buttons = [];
			
			if(!grid.reversed) { _addNewOutfitButton(); }
			
			for(var i:int = 0; i < looks.length; i++) {
				var look = looks[i];
				_addLookButton(look, i);
			}
			
			if(grid.reversed) { _addNewOutfitButton(); }
			
			UpdatePane();
		}
		
		public function _addLookButton(lookCode:String, i:int) : void {
			var lookMC = new CustomItem(null, lookCode, true);
			
			var btn:PushButton = new PushButton({ width:grid.cellSize, height:grid.cellSize, obj:lookMC, id:i }) as PushButton;
			btn.addEventListener(PushButton.STATE_CHANGED_AFTER, function(){
				_onUserLookClicked(lookCode, false);
				
				_untoggleAll(buttons, btn);
			});
			buttons.push(btn);
			grid.add(btn);
			
			var actionsHolder = new Sprite(); actionsHolder.alpha = 0;
			
			// Corresponding Delete Button
			var deleteBtn = actionsHolder.addChild(new ScaleButton({ x:grid.cellSize-5, y:5, obj:new $Trash(), obj_scale:0.4 }));
			deleteBtn.addEventListener(MouseEvent.CLICK, function(e){ deleteLookByIndex(i); });
			_deleteBtnGrid.add(actionsHolder);
			
			// Corresponding GoTo Button
			var gtcpIconHolder = new Sprite();
			var gtcpIcon = new $BackArrow();
			gtcpIcon.scaleX = -1;
			gtcpIconHolder.addChild(gtcpIcon);
			var goToCatPaneBtn = actionsHolder.addChild(new ScaleButton({ x:grid.cellSize-6, y:grid.cellSize-6, obj:gtcpIconHolder, obj_scale:0.5 }));
			goToCatPaneBtn.addEventListener(MouseEvent.CLICK, function(e){
				_onUserLookClicked(lookCode, true);
				_untoggleAll(buttons, btn);
			});
			
			// Sub-button alpha
			deleteBtn.addEventListener(MouseEvent.MOUSE_OVER, function(e){ actionsHolder.alpha = 1; });
			deleteBtn.addEventListener(MouseEvent.MOUSE_OUT, function(e){ actionsHolder.alpha = 0; });
			
			goToCatPaneBtn.addEventListener(MouseEvent.MOUSE_OVER, function(e){ actionsHolder.alpha = 1; });
			goToCatPaneBtn.addEventListener(MouseEvent.MOUSE_OUT, function(e){ actionsHolder.alpha = 0; });
			
			btn.addEventListener(MouseEvent.MOUSE_OVER, function(e){ actionsHolder.alpha = 1; });
			btn.addEventListener(MouseEvent.MOUSE_OUT, function(e){ actionsHolder.alpha = 0; });
		}
		
		private function _addNewOutfitButton() : void {
			var holder = new Sprite();
			var tNewOutfitBtn = holder.addChild(new ScaleButton({ x:grid.cellSize*0.5, y:grid.cellSize*0.5, width:grid.cellSize, height:grid.cellSize, obj:new $OutfitAdd() }));
			tNewOutfitBtn.addEventListener(MouseEvent.CLICK, function(e){ addNewLook(_character.getShareCodeFewfreSyntax()) });
			this.grid.add(holder);
			_deleteBtnGrid.add(new Sprite()); // empty spot since no delete button for this
			// this.buttons.push(tNewOutfitBtn);// DO NOT ADD TO BUTTONS! only add to grid; this avoids issue when clicking "random" button
		}

		private function _untoggleAll(pList:Array, pExcepotButton:PushButton=null) : void {
			for(var i:int = 0; i < pList.length; i++) {
				if (pList[i].pushed && pList[i] != pExcepotButton) {
					pList[i].toggleOff();
				}
			}
		}
		
		/****************************
		* Events
		*****************************/
		private function _onExportClicked(e:MouseEvent) : void {
			var looks:Array = Fewf.sharedObject.getData(ConstantsApp.SHARED_OBJECT_KEY_OUTFITS) || [];
			var csv:String = looks.join('\n');
			
			var bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes(csv);
			( new FileReference() ).save( bytes, "saved-outfits-backup.csv" );
		}
		
		private function _onImportClicked(e:MouseEvent) : void {
			var fileRef : FileReference = new FileReference();
			fileRef.addEventListener(Event.SELECT, function(){ fileRef.load(); });
			fileRef.addEventListener(Event.COMPLETE, _onImportSelected);
			
			fileRef.browse([new FileFilter("Saved Outfits File", "*.csv")]);
		}
		
		private function _onImportSelected(e:Event) : void {
			try {
				var importedLooks = e.target.data.toString().split('\n');
				var oldLooks:Array = Fewf.sharedObject.getData(ConstantsApp.SHARED_OBJECT_KEY_OUTFITS) || [];
				for(var i:int = importedLooks.length-1; i >= 0; i--) {
					// Don't allow an import file with invalid code
					if(this._character.parseShareCode(importedLooks[i]) === false) {
						throw 'Invalid code in list';
					}
					// Remove duplicates being imported
					if(oldLooks.indexOf(importedLooks[i]) > -1) {
						importedLooks.splice(i, 1);
					}
				}
				var final = oldLooks.concat(importedLooks);
				Fewf.sharedObject.setData(ConstantsApp.SHARED_OBJECT_KEY_OUTFITS, final);
				
				_renderOutfits();
			} catch(e) {
				trace('Import Error: ', e);
				_importButton.ChangeImage(new $No());
				setTimeout(function(){
					_importButton.ChangeImage(new $Folder());
				}, 2000);
			}
		}
	}
}
