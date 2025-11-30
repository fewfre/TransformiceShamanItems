package com.fewfre.display
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;

	public class LoadedBitmapHolder extends MovieClip
	{
		// Button State
		public static const LOAD:String = "load";
	
		// Storage
		protected var _bitmap : Bitmap;
		
		// Properties
		public function get bitmap():Bitmap { return _bitmap; }
		public function get isLoaded():Boolean { return _bitmap.width > 0; }
		
		// Constructor
		public function LoadedBitmapHolder(pBitmap:Bitmap, pPlaceholder:DisplayObject=null) {
			super();
			_bitmap = pBitmap;
			
			addChild(_bitmap);
			// This checks if bitmap has been loaded; if not, then add listener waiting for it to be
			if(_bitmap && !isLoaded) {
				if(pPlaceholder) addChild(pPlaceholder)
				_bitmap.addEventListener(Event.COMPLETE, _onComplete);
			}
		}
		public function move(pX:Number, pY:Number) : LoadedBitmapHolder { this.x = pX; this.y = pY; return this; }
		public function appendTo(pParent:Sprite): LoadedBitmapHolder { pParent.addChild(this); return this; }
		public function on(type:String, listener:Function, useCapture:Boolean = false): LoadedBitmapHolder { this.addEventListener(type, listener, useCapture); return this; }
		public function onLoad(listener:Function, useCapture:Boolean = false): LoadedBitmapHolder { this.addEventListener(LOAD, listener, useCapture); return this; }
		public function off(type:String, listener:Function, useCapture:Boolean = false): LoadedBitmapHolder { this.removeEventListener(type, listener, useCapture); return this; }
		
		private function _onComplete(e:Event) : void {
			removeChildren();
			addChild(e.currentTarget as Bitmap);
			dispatchEvent(new Event(LOAD));
		}
	}
}