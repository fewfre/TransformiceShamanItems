package app.ui.buttons
{
	import com.fewfre.display.*;
	import com.fewfre.utils.*;
	import app.data.*;
	import app.ui.*;
	import flash.display.*;
	import flash.events.MouseEvent;
	import flash.text.*;
	import flash.geom.*;
	
	public class PushButton extends GameButton
	{
		// Constants
		public static const STATE_CHANGED_BEFORE:String="state_changed_before";
		public static const STATE_CHANGED_AFTER:String="state_changed_after";
		
		// Storage
		public var id:int;
		public var pushed:Boolean;
		public var allowToggleOff:Boolean; // Only controls the behavior on internal click controls.
		public var Text:TextTranslated;
		public var Image:DisplayObject;
		
		// Constructor
		// pArgs = { x:Number, y:Number, (width:Number, height:Number OR size:Number), ?obj:DisplayObject, ?obj_scale:Number, ?text:String, ?id:int, ?allowToggleOff:Boolean=true }
		public function PushButton(pArgs:Object)
		{
			super(pArgs);
			if(pArgs.id) { id = pArgs.id; }
			
			if(pArgs.text) {
				this.Text = new TextTranslated({ text:pArgs.text, x:pArgs.width*(0.5 - _bg.originX), y:pArgs.height*(0.5 - _bg.originY) }).appendTo(this);
			}
			
			if(pArgs.obj) {
				ChangeImage(pArgs.obj, pArgs.obj_scale || -1);
			}
			
			this.allowToggleOff = pArgs.allowToggleOff == null ? true : pArgs.allowToggleOff;
			this.pushed = false;
			_renderUnpressed();
		}

		public function ChangeImage(pMC:DisplayObject, pScale:Number=-1) : void
		{
			if(this.Image != null) { removeChild(this.Image); }
			pScale = pScale >= 0 ? pScale : 1;
			
			var tBounds:Rectangle = pMC.getBounds(pMC);
			var tOffset:Point = tBounds.topLeft;
			
			FewfDisplayUtils.fitWithinBounds(pMC, this.Width * 0.9, this.Height * 0.9, this.Width * 0.5, this.Height * 0.5);
			pMC.x = this.Width * (0.5 - _bg.originX) - (tBounds.width / 2 + tOffset.x)*pScale * pMC.scaleX;
			pMC.y = this.Height * (0.5 - _bg.originY) - (tBounds.height / 2 + tOffset.y)*pScale * pMC.scaleY;
			pMC.scaleX *= pScale;
			pMC.scaleY *= pScale;
			addChild(this.Image = pMC);
		}
		
		protected function _renderUnpressed() : void
		{
			super._renderUp();
			if(this.Text) { this.Text.color = 0xC2C2DA; }
		}

		protected function _renderPressed() : void
		{
			_bg.draw(ConstantsApp.COLOR_BUTTON_MOUSE_DOWN, 7, 0x5D7A91, 0x5D7A91, 0x6C8DA8);
			if(this.Text) { this.Text.color = 0xFFD800; }
		}

		public function toggle(pOn=null, pFireEvent:Boolean=true) : void
		{
			if(pFireEvent) _dispatch(STATE_CHANGED_BEFORE);
			
			this.pushed = pOn != null ? pOn : !this.pushed;
			if(this.pushed) {
				_renderPressed();
			} else {
				_renderUnpressed();
			}
			
			if(pFireEvent) _dispatch(STATE_CHANGED_AFTER);
		}
		
		public function toggleOn(pFireEvent:Boolean=true) : void {
			toggle(true, pFireEvent);
		}

		public function toggleOff(pFireEvent:Boolean=false) : void {
			toggle(false, pFireEvent);
		}
		
		override protected function _onMouseUp(pEvent:MouseEvent) : void {
			if(!_flagEnabled) { return; }
			var pOn = null;
			if(!this.allowToggleOff && this.pushed) { pOn = true; }
			toggle(pOn);
			super._onMouseUp(pEvent);
		}
		
		override protected function _renderUp() : void {
			if (this.pushed == false) {
				super._renderUp();
			}
		}
		
		override protected function _renderDown() : void {
			if (this.pushed == false) {
				if(this.Text) this.Text.color = 0xC2C2DA;
				super._renderDown();
			}
		}
		
		override protected function _renderOver() : void {
			if (this.pushed == false) {
				if(this.Text) this.Text.color = 0x012345;
				super._renderOver();
			}
		}
		
		override protected function _renderOut() : void {
			if(this.pushed == false) {
				if(this.Text) this.Text.color = 0xC2C2DA;
				super._renderOut();
			}
		}
	}
}
