package app.ui
{
	import app.data.*;
	import app.ui.*;
	import app.ui.buttons.*;
	import app.ui.common.FancySlider;
	import app.ui.common.FrameBase;
	import com.fewfre.display.RoundRectangle;
	import com.fewfre.events.FewfEvent;
	import com.fewfre.utils.Fewf;
	import com.fewfre.utils.FewfDisplayUtils;
	import ext.ParentApp;
	import flash.display.*;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.*;
	import flash.utils.setTimeout;
	
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
		private var _downloadButton  : GameButton;
		private var _clipboardButton : GameButton;
		
		private var _scaleSlider        : FancySlider;
		private var _defaultScaleButton : GameButton;
		
		// Properties
		public function get scaleSlider() : FancySlider { return _scaleSlider; }
		
		// Constructor
		public function Toolbox() {
			var bg:RoundRectangle = new RoundRectangle(365, 35).toOrigin(0.5).drawAsTray().appendTo(this);
			
			/********************
			* Download Button
			*********************/
			var tDownloadTray:FrameBase = new FrameBase(66, 66).move(-bg.width*0.5 + 33, 9).appendTo(this);
			
			_downloadButton = new GameButton(46).setImage(new $LargeDownload()).setOrigin(0.5)
				.onButtonClick(dispatchEventHandler(SAVE_CLICKED))
				.appendTo(tDownloadTray.root) as GameButton;
			
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
			
			new GameButton(tButtonSize).setImage(new $Link(), 0.45).setOrigin(0.5).appendTo(tTray)
				.move(xx+tButtonXInc*tButtonsOnLeft, yy)
				.onButtonClick(dispatchEventHandler(SHARE_CLICKED));
			tButtonsOnLeft++;
			
			if(Fewf.isExternallyLoaded) {
				_clipboardButton = new GameButton(tButtonSize).setImage(new $CopyIcon(), 0.415).setOrigin(0.5).appendTo(tTray)
					.move(xx+tButtonXInc*tButtonsOnLeft, yy)
					.onButtonClick(dispatchEventHandler(CLIPBOARD_CLICKED))
					.appendTo(tTray) as GameButton;
				tButtonsOnLeft++;
			}
			
			// ### Right Side Buttons ###
			xx = tTrayWidth*0.5-(tButtonSize*0.5 + tButtonSizeSpace);

			// Dice icon based on https://www.iconexperience.com/i_collection/icons/?icon=dice
			new GameButton(tButtonSize).setImage(new $Dice()).setOrigin(0.5).appendTo(tTray)
				.move(xx-tButtonXInc*tButtonOnRight, yy)
				.onButtonClick(dispatchEventHandler(RANDOM_CLICKED));
			tButtonOnRight++;
			
			/********************
			* Scale slider
			*********************/
			var tTotalButtons:Number = tButtonsOnLeft+tButtonOnRight;
			var tSliderWidth:Number = tTrayWidth - tButtonXInc*(tTotalButtons) - 20;
			xx = -tSliderWidth*0.5+(tButtonXInc*((tButtonsOnLeft-tButtonOnRight)*0.5))-1;
			_scaleSlider = new FancySlider(tSliderWidth).move(xx, yy)
				.setSliderParams(1, 4, ConstantsApp.DEFAULT_CHARACTER_SCALE)
				.appendTo(tTray)
				.on(FancySlider.CHANGE, dispatchEventHandler(SCALE_SLIDER_CHANGE));
			
			(_defaultScaleButton = new GameButton(100, 14)).setText('btn_color_defaults').setOrigin(0.5).move(xx+tSliderWidth/2, yy-16.5).appendTo(tTray).setAlpha(0)
				.onButtonClick(dispatchEventHandler(DEFAULT_SCALE_CLICKED));
				
			scaleSlider.on(MouseEvent.MOUSE_OVER, function():void{ _defaultScaleButton.alpha = 0.8; });
			_defaultScaleButton.on(MouseEvent.MOUSE_OVER, function():void{ _defaultScaleButton.alpha = 0.8; });
			scaleSlider.on(MouseEvent.MOUSE_OUT, function():void{ _defaultScaleButton.alpha = 0; });
			_defaultScaleButton.on(MouseEvent.MOUSE_OUT, function():void{ _defaultScaleButton.alpha = 0; });
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
			_clipboardButton.setImage(normal ? new $CopyIcon() : elseYes ? new $Yes() : new $No());
		}
		
		///////////////////////
		// Private
		///////////////////////
		private function dispatchEventHandler(pEventName:String) : Function {
			return function(e):void{ dispatchEvent(new Event(pEventName)); };
		}
	}
}
