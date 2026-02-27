package app.ui.panes
{
	import app.data.*;
	import app.ui.buttons.GameButton;
	import app.ui.common.LoadingSpinner;
	import app.ui.panes.base.SidePane;
	import app.world.data.BitmapItemData;

	import com.fewfre.display.*;
	import com.fewfre.utils.Fewf;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;

	public class OtherTabPane extends SidePane
	{
		// Constants
		public static const CARTOUCHE_CLICKED:String = "cartouche_clicked";
		public static const BADGE_CLICKED:String = "badge_clicked";
		public static const BANNER_CLICKED:String = "banner_clicked";
		
		// Constructor
		public function OtherTabPane() {
			super();
			var xx:Number = 20, yy:Number = 20, sizey:Number=60;
			
			/////////////////////////////
			// Sub Panes Section
			/////////////////////////////
			var hasBadges:Boolean = !!Config.badges, hasBanners = !!Config.banners;
			// Grid
			xx = 20;
			var grid:Grid = new Grid(ConstantsApp.PANE_WIDTH - 32, 1 + hasBadges + hasBanners).move(xx,0).appendTo(this);
			
			grid.add(makeGridCell(grid.cellSize, GameAssets.getItemImage(GameAssets.cartouches[0]), 10, 10, function(){
				return new GameButton(grid.cellSize, sizey).setOrigin(0, 0.5).setText('tab_cartouche', { size:16 })
					.onButtonClick(function(e:Event):void{ dispatchEvent(new Event(CARTOUCHE_CLICKED)); })
			}));
			
			if(hasBadges) {
				grid.add(makeGridCell(grid.cellSize, (GameAssets.badges[0] as BitmapItemData).getSmallImage(), -20, 0, function(){
					return new GameButton(grid.cellSize, sizey).setOrigin(0, 0.5).setText('tab_badge', { size:16 })
						.onButtonClick(function(e:Event):void{ dispatchEvent(new Event(BADGE_CLICKED)); });
				}));
			}
			
			if(hasBanners) {
				grid.add(makeGridCell(grid.cellSize, (GameAssets.banners[0] as BitmapItemData).getSmallImage(), -60, -5, function(){
					return new GameButton(grid.cellSize, sizey).setOrigin(0, 0.5).setText('tab_banner', { size:16 })
						.onButtonClick(function(e:Event):void{ dispatchEvent(new Event(BANNER_CLICKED)); });
				}));
			}
			
			grid.y = ConstantsApp.SHOP_HEIGHT/2 + 25;
			
		}
		
		private function makeGridCell(cellSize:Number, pImage:DisplayObject, pImageX:Number, pImageY:Number, pGetButton:Function) : DisplayObject {
			var cell : Sprite = new Sprite();
			
			var xx:Number = cellSize/2 - pImage.width/2, yy:Number = -75;
			pImage.x = xx + pImageX;
			pImage.y = yy + pImageY;
			cell.addChild(pImage);
			cell.addChild(pGetButton());
			
			_addLoaderSpinnerIfNeeded(pImage, xx, yy, cell);
			
			return cell;
		}
		
		private function _addLoaderSpinnerIfNeeded(pImage:DisplayObject, pX:Number, pY:Number, pParent:Sprite) : void {
			if(!pImage || pImage.width > 0) return;
			
			var spinner:LoadingSpinner = new LoadingSpinner().setSpeedScale(0.5).move(pX, pY+22).appendTo(pParent);
			spinner.scaleX = spinner.scaleY = 0.60;
			
			pImage.addEventListener(Event.COMPLETE, function(e:Event){
				spinner.parent.removeChild(spinner);
			});
		}
	}
}
