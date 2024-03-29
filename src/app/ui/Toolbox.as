package app.ui
{
	import com.fewfre.display.ButtonBase;
	import com.fewfre.utils.Fewf;
	import com.fewfre.utils.ImgurApi;
	import app.data.*;
	import app.ui.*;
	import app.ui.buttons.*;
	import app.ui.common.*;
	import flash.display.*;
	import flash.net.*;
	import ext.ParentApp;
	import com.fewfre.utils.FewfDisplayUtils;
	import app.world.elements.CustomItem;
	import flash.utils.setTimeout;
	
	public class Toolbox extends MovieClip
	{
		// Storage
		private var _downloadTray	: FrameBase;
		private var _bg				: RoundedRectangle;
		private var _character		: CustomItem;
		
		public var scaleSlider		: FancySlider;
		public var animateButton	: SpriteButton;
		public var imgurButton		: SpriteButton;
		
		// Constructor
		// pData = { character:Character, onSave:Function, onAnimate:Function, onRandomize:Function, onShare:Function, onScale:Function }
		public function Toolbox(pData:Object) {
			_character = pData.character;
			
			var btn:ButtonBase;
			
			_bg = addChild(new RoundedRectangle({ width:365, height:35, origin:0.5 })) as RoundedRectangle;
			_bg.drawAsTray();
			
			/********************
			* Download Button
			*********************/
			_downloadTray = addChild(new FrameBase({ x:-_bg.Width*0.5 + 33, y:9, width:66, height:66, origin:0.5 })) as FrameBase;
			/*_downloadTray.drawSimpleGradient(ConstantsApp.COLOR_TRAY_GRADIENT, 15, ConstantsApp.COLOR_TRAY_B_1, ConstantsApp.COLOR_TRAY_B_2, ConstantsApp.COLOR_TRAY_B_3);*/
			
			btn = _downloadTray.addChild(new SpriteButton({ width:46, height:46, obj:new $LargeDownload(), origin:0.5 })) as SpriteButton;
			btn.addEventListener(ButtonBase.CLICK, pData.onSave);
			
			/********************
			* Toolbar Buttons
			*********************/
			var tTray = _bg.addChild(new MovieClip());
			var tTrayWidth = _bg.Width - _downloadTray.Width;
			tTray.x = -(_bg.Width*0.5) + (tTrayWidth*0.5) + (_bg.Width - tTrayWidth);
			
			var tButtonSize = 28, tButtonSizeSpace=5, tButtonXInc=tButtonSize+tButtonSizeSpace;
			var tX = 0, tY = 0, tButtonsOnLeft = 0, tButtonOnRight = 0;
			
			// ### Left Side Buttons ###
			tX = -tTrayWidth*0.5 + tButtonSize*0.5 + tButtonSizeSpace;
			
			btn = tTray.addChild(new SpriteButton({ x:tX+tButtonXInc*tButtonsOnLeft, y:tY, width:tButtonSize, height:tButtonSize, obj_scale:0.45, obj:new $Link(), origin:0.5 }));
			btn.addEventListener(ButtonBase.CLICK, pData.onShare);
			tButtonsOnLeft++;
			
			if(!Fewf.isExternallyLoaded) {
				btn = imgurButton = tTray.addChild(new SpriteButton({ x:tX+tButtonXInc*tButtonsOnLeft, y:tY, width:tButtonSize, height:tButtonSize, obj_scale:0.45, obj:new $ImgurIcon(), origin:0.5 })) as SpriteButton;
				btn.addEventListener(ButtonBase.CLICK, function(e:*){
					ImgurApi.uploadImage(_character);
					imgurButton.disable();
				});
				tButtonsOnLeft++;
			} else {
				btn = imgurButton = tTray.addChild(new SpriteButton({ x:tX+tButtonXInc*tButtonsOnLeft, y:tY, width:tButtonSize, height:tButtonSize, obj_scale:0.415, obj:new $CopyIcon(), origin:0.5 })) as SpriteButton;
				btn.addEventListener(ButtonBase.CLICK, function(e:*){
					try {
						FewfDisplayUtils.copyToClipboard(_character);
						imgurButton.ChangeImage(new $Yes());
					} catch(e) {
						imgurButton.ChangeImage(new $No());
					}
					setTimeout(function(){ imgurButton.ChangeImage(new $CopyIcon()); }, 750)
				});
				tButtonsOnLeft++;
			}
			
			// ### Right Side Buttons ###
			tX = tTrayWidth*0.5-(tButtonSize*0.5 + tButtonSizeSpace);

			/*btn = tTray.addChild(new SpriteButton({ x:tX-tButtonXInc*tButtonOnRight, y:tY, width:tButtonSize, height:tButtonSize, obj_scale:0.5, obj:new $Refresh(), origin:0.5 }));
			btn.addEventListener(ButtonBase.CLICK, pData.onRandomize);
			tButtonOnRight++;
			
			animateButton = tTray.addChild(new SpriteButton({ x:tX-tButtonXInc*tButtonOnRight, y:tY, width:tButtonSize, height:tButtonSize, obj_scale:0.5, obj:new MovieClip(), origin:0.5 }));
			animateButton.addEventListener(ButtonBase.CLICK, pData.onAnimate);
			toggleAnimateButtonAsset(_character.animatePose);
			tButtonOnRight++;*/
			
			/********************
			* Scale slider
			*********************/
			var tTotalButtons:Number = tButtonsOnLeft+tButtonOnRight;
			var tSliderWidth:Number = tTrayWidth - tButtonXInc*(tTotalButtons) - 20;
			tX = -tSliderWidth*0.5+(tButtonXInc*((tButtonsOnLeft-tButtonOnRight)*0.5))-1;
			scaleSlider = new FancySlider(tSliderWidth).setXY(tX, tY)
				.setSliderParams(1, 4, _character.outfit.scaleX)
				.appendTo(tTray);
			scaleSlider.addEventListener(FancySlider.CHANGE, pData.onScale);
			
			/********************
			* Share Code Input
			*********************/
			addChild(new PasteShareCodeInput({ x:18, y:33, onChange:pData.onShareCodeEntered }));
			
			/********************
			* Events
			*********************/
			Fewf.dispatcher.addEventListener(ImgurApi.EVENT_DONE, _onImgurDone);
			
			pData = null;
		}
		public function setXY(pX:Number, pY:Number) : Toolbox { x = pX; y = pY; return this; }
		public function appendTo(target:Sprite): Toolbox { target.addChild(this); return this; }
		
		public function toggleAnimateButtonAsset(pOn:Boolean) : void {
			animateButton.ChangeImage(pOn ? new $PauseButton() : new $PlayButton());
		}
		
		private function _onImgurDone(e:*) : void {
			imgurButton.enable();
		}
	}
}
