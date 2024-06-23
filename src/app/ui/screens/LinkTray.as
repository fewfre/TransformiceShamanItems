package app.ui.screens
{
	import com.fewfre.display.*;
	import com.adobe.images.*;
	import app.data.*;
	import app.ui.*;
	import app.ui.buttons.*;
	import app.ui.common.*;
	import app.world.data.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.text.*;
	import flash.system.System;
	import fl.transitions.Tween;
	import fl.transitions.easing.*;
	
	public class LinkTray extends MovieClip
	{
		// Storage
		private var _bg				: RoundedRectangle;
		public var _text			: TextField;
		public var _textCopiedMessage: TextBase;
		public var _textCopyTween	: Tween;
		
		// Constructor
		// pData = { x:Number, y:Number }
		public function LinkTray(pData:Object) {
			this.x = pData.x;
			this.y = pData.y;
			
			/****************************
			* Click Tray
			*****************************/
			var tClickTray = addChild(new Sprite());
			tClickTray.x = -5000;
			tClickTray.y = -5000;
			tClickTray.graphics.beginFill(0x000000, 0.2);
			tClickTray.graphics.drawRect(0, 0, -tClickTray.x*2, -tClickTray.y*2);
			tClickTray.graphics.endFill();
			tClickTray.addEventListener(MouseEvent.CLICK, _onCloseClicked);
			
			/****************************
			* Background
			*****************************/
			var tWidth:Number = 500, tHeight:Number = 200;
			_bg = new RoundedRectangle({ width:tWidth, height:tHeight, origin:0.5 }).appendTo(this).drawAsTray();
			
			/****************************
			* Header
			*****************************/
			addChild(new TextBase({ text:"share_header", size:25, y:-63 }));
			
			/****************************
			* #1 - Selectable text field + Copy Button and message
			*****************************/
			_text = _newCopyInput({ x:0, y:0 }, this);
			
			var tCopyButton:SpriteButton = addChild(new SpriteButton({ x:tWidth*0.5-75+25, y:52, text:"share_copy", width:50, height:25, origin:0.5 })) as SpriteButton;
			tCopyButton.addEventListener(ButtonBase.CLICK, function(){ _copyToClipboard(); });
			
			_textCopiedMessage = addChild(new TextBase({ text:"share_link_copied", size:17, originX:1, x:tCopyButton.x - 40, y:tCopyButton.y, alpha:0 })) as TextBase;
			
			/****************************
			* Close Button
			*****************************/
			var tCloseIcon = new MovieClip();
			var tSize:Number = 10;
			tCloseIcon.graphics.beginFill(0x000000, 0);
			tCloseIcon.graphics.drawRect(-tSize*2, -tSize*2, tSize*4, tSize*4);
			tCloseIcon.graphics.endFill();
			tCloseIcon.graphics.lineStyle(8, 0xFFFFFF, 1, true);
			tCloseIcon.graphics.moveTo(-tSize, -tSize);
			tCloseIcon.graphics.lineTo(tSize, tSize);
			tCloseIcon.graphics.moveTo(tSize, -tSize);
			tCloseIcon.graphics.lineTo(-tSize, tSize);
			
			var tCloseButton:ScaleButton = addChild(new ScaleButton({ x:tWidth*0.5 - 5, y:-tHeight*0.5 + 5, obj:tCloseIcon })) as ScaleButton;
			tCloseButton.addEventListener(ButtonBase.CLICK, _onCloseClicked);
			
		}
		
		public function open(pURL:String) : void {
			_text.text = pURL;
			_clearCopiedMessages();
		}
		
		private function _onCloseClicked(pEvent:Event) : void {
			dispatchEvent(new Event(Event.CLOSE));
		}
		
		private function _clearCopiedMessages() : void {
			if(_textCopyTween) _textCopyTween.stop();
			_textCopiedMessage.alpha = 0;
		}
		
		private function _copyToClipboard() : void {
			_clearCopiedMessages();
			_text.setSelection(0, _text.text.length)
			System.setClipboard(_text.text);
			_textCopiedMessage.alpha = 0;
			if(_textCopyTween) _textCopyTween.start(); else _textCopyTween = new Tween(_textCopiedMessage, "alpha", Elastic.easeOut, 0, 1, 1, true);
		}
		
		private function _newCopyInput(pData:Object, pParent:Sprite) : TextField {
			var tTFWidth:Number = _bg.width-50, tTFHeight:Number = 18, tTFPaddingX:Number = 5, tTFPaddingY:Number = 5;
			var tTextBackground:RoundedRectangle = new RoundedRectangle({ x:pData.x, y:pData.y, width:tTFWidth+tTFPaddingX*2, height:tTFHeight+tTFPaddingY*2, origin:0.5 })
				.appendTo(pParent).draw(0xFFFFFF, 7, 0x444444);
			
			var tTextField:TextField = tTextBackground.addChild(new TextField()) as TextField;
			tTextField.type = TextFieldType.DYNAMIC;
			tTextField.multiline = false;
			tTextField.width = tTFWidth;
			tTextField.height = tTFHeight;
			tTextField.x = tTFPaddingX - tTextBackground.Width*0.5;
			tTextField.y = tTFPaddingY - tTextBackground.Height*0.5;
			tTextField.addEventListener(MouseEvent.CLICK, function(pEvent:Event):void{
				_clearCopiedMessages();
				tTextField.setSelection(0, tTextField.text.length);
			});
			return tTextField;
		}
	}
}
