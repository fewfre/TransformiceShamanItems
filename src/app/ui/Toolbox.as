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
	import flash.events.Event;
	
	public class Toolbox extends MovieClip
	{
		// Constants
		public static const SAVE_CLICKED         = "save_clicked";
		
		public static const SHARE_CLICKED        = "share_clicked";
		public static const CLIPBOARD_CLICKED    = "clipboard_clicked";
		public static const IMGUR_CLICKED        = "imgur_clicked";
		
		public static const SCALE_SLIDER_CHANGE  = "scale_slider_change";
		
		public static const RANDOM_CLICKED       = "random_clicked";
		
		// Storage
		private var _downloadTray   : FrameBase;
		private var _bg             : RoundedRectangle;
		
		public var scaleSlider       : FancySlider;
		private var _downloadButton  : ButtonBase;
		private var _imgurButton     : SpriteButton;
		private var _clipboardButton : SpriteButton;
		
		// Constructor
		// onShareCodeEntered: (code, (state:String)=>void)=>void
		public function Toolbox(pCharacter:CustomItem, onShareCodeEntered:Function) {
			_bg = new RoundedRectangle(365, 35, { origin:0.5 }).drawAsTray().appendTo(this);
			
			/********************
			* Download Button
			*********************/
			_downloadTray = addChild(new FrameBase({ x:-_bg.Width*0.5 + 33, y:9, width:66, height:66, origin:0.5 })) as FrameBase;
			
			_downloadButton = new SpriteButton({ size:46, obj:new $LargeDownload(), origin:0.5 })
				.on(ButtonBase.CLICK, dispatchEventHandler(SAVE_CLICKED))
				.appendTo(_downloadTray);
			
			/********************
			* Toolbar Buttons
			*********************/
			var tTray = _bg.addChild(new MovieClip());
			var tTrayWidth = _bg.Width - _downloadTray.Width;
			tTray.x = -(_bg.Width*0.5) + (tTrayWidth*0.5) + (_bg.Width - tTrayWidth);
			
			var tButtonSize = 28, tButtonSizeSpace=5, tButtonXInc=tButtonSize+tButtonSizeSpace;
			var tX = 0, yy = 0, tButtonsOnLeft = 0, tButtonOnRight = 0;
			
			// ### Left Side Buttons ###
			tX = -tTrayWidth*0.5 + tButtonSize*0.5 + tButtonSizeSpace;
			
			new SpriteButton({ size:tButtonSize, obj_scale:0.45, obj:new $Link(), origin:0.5 }).appendTo(tTray)
				.setXY(tX+tButtonXInc*tButtonsOnLeft, yy)
				.on(ButtonBase.CLICK, dispatchEventHandler(SHARE_CLICKED));
			tButtonsOnLeft++;
			
			if(!Fewf.isExternallyLoaded) {
				_imgurButton = new SpriteButton({ size:tButtonSize, obj_scale:0.45, obj:new $ImgurIcon(), origin:0.5 })
					.setXY(tX+tButtonXInc*tButtonsOnLeft, yy)
					.on(ButtonBase.CLICK, dispatchEventHandler(IMGUR_CLICKED))
					.appendTo(tTray) as SpriteButton;
				tButtonsOnLeft++;
			} else {
				_clipboardButton = new SpriteButton({ size:tButtonSize, obj_scale:0.415, obj:new $CopyIcon(), origin:0.5 })
					.setXY(tX+tButtonXInc*tButtonsOnLeft, yy)
					.on(ButtonBase.CLICK, dispatchEventHandler(CLIPBOARD_CLICKED))
					.appendTo(tTray) as SpriteButton;
				tButtonsOnLeft++;
			}
			
			// ### Right Side Buttons ###
			tX = tTrayWidth*0.5-(tButtonSize*0.5 + tButtonSizeSpace);

			// // Dice icon based on https://www.iconexperience.com/i_collection/icons/?icon=dice
			// new SpriteButton({ size:tButtonSize, obj_scale:1, obj:new $Dice(), origin:0.5 }).appendTo(tTray)
			// 	.setXY(tX-tButtonXInc*tButtonOnRight, yy)
			// 	.on(ButtonBase.CLICK, dispatchEventHandler(RANDOM_CLICKED));
			
			/********************
			* Scale slider
			*********************/
			var tTotalButtons:Number = tButtonsOnLeft+tButtonOnRight;
			var tSliderWidth:Number = tTrayWidth - tButtonXInc*(tTotalButtons) - 20;
			tX = -tSliderWidth*0.5+(tButtonXInc*((tButtonsOnLeft-tButtonOnRight)*0.5))-1;
			scaleSlider = new FancySlider(tSliderWidth).setXY(tX, yy)
				.setSliderParams(1, 4, pCharacter.outfit.scaleX)
				.appendTo(tTray);
			scaleSlider.addEventListener(FancySlider.CHANGE, dispatchEventHandler(SCALE_SLIDER_CHANGE));
			
			/********************
			* Under Toolbox
			*********************/
			addChild(new PasteShareCodeInput({ x:18, y:33, onChange:onShareCodeEntered }));
		}
		public function setXY(pX:Number, pY:Number) : Toolbox { x = pX; y = pY; return this; }
		public function appendTo(target:Sprite): Toolbox { target.addChild(this); return this; }
		public function on(type:String, listener:Function): Toolbox { this.addEventListener(type, listener); return this; }
		public function off(type:String, listener:Function): Toolbox { this.removeEventListener(type, listener); return this; }
		
		///////////////////////
		// Public
		///////////////////////
		public function downloadButtonEnable(pOn:Boolean) : void {
			if(pOn) _downloadButton.enable(); else _downloadButton.disable();
		}
		
		public function imgurButtonEnable(pOn:Boolean) : void {
			if(pOn) _imgurButton.enable(); else _imgurButton.disable();
		}
		
		public function updateClipboardButton(normal:Boolean, elseYes:Boolean=true) : void {
			if(!_clipboardButton) return;
			_clipboardButton.ChangeImage(normal ? new $CopyIcon() : elseYes ? new $Yes() : new $No());
		}
		
		///////////////////////
		// Private
		///////////////////////
		private function dispatchEventHandler(pEventName:String) : Function {
			return function(e):void{ dispatchEvent(new Event(pEventName)); };
		}
	}
}
