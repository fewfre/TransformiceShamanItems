package app.ui
{
	import com.fewfre.utils.Fewf;
	import app.data.*;
	import app.ui.*;
	import app.ui.buttons.*;
	import flash.display.*;
	import flash.net.*;
	import ext.ParentApp;
	import com.fewfre.utils.FewfDisplayUtils;
	import app.world.elements.CustomItem;
	import flash.utils.setTimeout;
	import flash.events.Event;
	import com.fewfre.display.RoundRectangle;
	import app.ui.common.FrameBase;
	import app.ui.common.FancySlider;
	import com.fewfre.events.FewfEvent;
	import flash.events.MouseEvent;
	
	public class Toolbox extends MovieClip
	{
		// Constants
		public static const SAVE_CLICKED          = "save_clicked";
		
		public static const SHARE_CLICKED         = "share_clicked";
		public static const CLIPBOARD_CLICKED     = "clipboard_clicked";
		
		public static const SCALE_SLIDER_CHANGE   = "scale_slider_change";
		public static const DEFAULT_SCALE_CLICKED = "default_scale_clicked";
		
		public static const RANDOM_CLICKED        = "random_clicked";
		
		// Storage
		private var _downloadButton  : SpriteButton;
		private var _clipboardButton : SpriteButton;
		
		private var _scaleSlider        : FancySlider;
		private var _defaultScaleButton : SpriteButton;
		
		// Properties
		public function get scaleSlider() : FancySlider { return _scaleSlider; }
		
		// Constructor
		// onShareCodeEntered: (code, (state:String)=>void)=>void
		public function Toolbox(pCharacter:CustomItem, onShareCodeEntered:Function) {
			var bg:RoundRectangle = new RoundRectangle(365, 35).toOrigin(0.5).drawAsTray().appendTo(this);
			
			/********************
			* Download Button
			*********************/
			var tDownloadTray:FrameBase = new FrameBase(66, 66).move(-bg.width*0.5 + 33, 9).appendTo(this);
			
			_downloadButton = new SpriteButton({ size:46, obj:new $LargeDownload(), origin:0.5 })
				.onButtonClick(dispatchEventHandler(SAVE_CLICKED))
				.appendTo(tDownloadTray.root) as SpriteButton;
			
			/********************
			* Toolbar Buttons
			*********************/
			var tTray:Sprite = bg.addChild(new Sprite()) as Sprite;
			var tTrayWidth = bg.width - tDownloadTray.width;
			tTray.x = -(bg.width*0.5) + (tTrayWidth*0.5) + (bg.width - tTrayWidth);
			
			var tButtonSize = 28, tButtonSizeSpace=5, tButtonXInc=tButtonSize+tButtonSizeSpace;
			var xx = 0, yy = 0, tButtonsOnLeft = 0, tButtonOnRight = 0;
			
			// ### Left Side Buttons ###
			xx = -tTrayWidth*0.5 + tButtonSize*0.5 + tButtonSizeSpace;
			
			new SpriteButton({ size:tButtonSize, obj_scale:0.45, obj:new $Link(), origin:0.5 }).appendTo(tTray)
				.move(xx+tButtonXInc*tButtonsOnLeft, yy)
				.onButtonClick(dispatchEventHandler(SHARE_CLICKED));
			tButtonsOnLeft++;
			
			if(Fewf.isExternallyLoaded) {
				_clipboardButton = new SpriteButton({ size:tButtonSize, obj_scale:0.415, obj:new $CopyIcon(), origin:0.5 })
					.move(xx+tButtonXInc*tButtonsOnLeft, yy)
					.onButtonClick(dispatchEventHandler(CLIPBOARD_CLICKED))
					.appendTo(tTray) as SpriteButton;
				tButtonsOnLeft++;
			}
			
			// ### Right Side Buttons ###
			xx = tTrayWidth*0.5-(tButtonSize*0.5 + tButtonSizeSpace);

			// // Dice icon based on https://www.iconexperience.com/i_collection/icons/?icon=dice
			// new SpriteButton({ size:tButtonSize, obj_scale:1, obj:new $Dice(), origin:0.5 }).appendTo(tTray)
			// 	.move(tX-tButtonXInc*tButtonOnRight, yy)
			// 	.onButtonClick(dispatchEventHandler(RANDOM_CLICKED));
			
			/********************
			* Scale slider
			*********************/
			var tTotalButtons:Number = tButtonsOnLeft+tButtonOnRight;
			var tSliderWidth:Number = tTrayWidth - tButtonXInc*(tTotalButtons) - 20;
			xx = -tSliderWidth*0.5+(tButtonXInc*((tButtonsOnLeft-tButtonOnRight)*0.5))-1;
			_scaleSlider = new FancySlider(tSliderWidth).move(xx, yy)
				.setSliderParams(1, 4, pCharacter.outfit.scaleX)
				.appendTo(tTray)
				.on(FancySlider.CHANGE, dispatchEventHandler(SCALE_SLIDER_CHANGE));
			
			_defaultScaleButton = SpriteButton.rect(100, 14);
			_defaultScaleButton.setText('btn_color_defaults').toOrigin(0.5).move(xx+tSliderWidth/2, yy-16.5).appendTo(tTray)
				.onButtonClick(dispatchEventHandler(DEFAULT_SCALE_CLICKED));
			_defaultScaleButton.alpha = 0;
				
			scaleSlider.on(MouseEvent.MOUSE_OVER, function():void{ _defaultScaleButton.alpha = 0.8; });
			_defaultScaleButton.on(MouseEvent.MOUSE_OVER, function():void{ _defaultScaleButton.alpha = 0.8; });
			scaleSlider.on(MouseEvent.MOUSE_OUT, function():void{ _defaultScaleButton.alpha = 0; });
			_defaultScaleButton.on(MouseEvent.MOUSE_OUT, function():void{ _defaultScaleButton.alpha = 0; });
			
			/********************
			* Under Toolbox
			*********************/
				new PasteShareCodeInput().appendTo(this).move(18, 34)
					.on(PasteShareCodeInput.CHANGE, function(e:FewfEvent):void{ onShareCodeEntered(e.data.code, e.data.update); });
		}
		public function move(pX:Number, pY:Number) : Toolbox { x = pX; y = pY; return this; }
		public function appendTo(pParent:Sprite): Toolbox { pParent.addChild(this); return this; }
		public function on(type:String, listener:Function): Toolbox { this.addEventListener(type, listener); return this; }
		public function off(type:String, listener:Function): Toolbox { this.removeEventListener(type, listener); return this; }
		
		///////////////////////
		// Public
		///////////////////////
		public function downloadButtonEnable(pOn:Boolean) : void {
			if(pOn) _downloadButton.enable(); else _downloadButton.disable();
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
