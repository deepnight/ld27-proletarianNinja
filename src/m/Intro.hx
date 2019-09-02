package m;

import Const;

import mt.deepnight.SpriteLibBitmap;
import mt.flash.Key;
import flash.ui.Keyboard;
import flash.display.Sprite;

@:bitmap("assets/title.png") class GfxTitle extends flash.display.BitmapData {}

class Intro extends Mode { //}
	var title				: flash.display.Bitmap;
	
	public function new() {
		super();
		Key.init();
		
		title = new flash.display.Bitmap( new GfxTitle(0,0) );
		buffer.dm.add(title, Const.DP_INTERF );
		
		
		title.alpha = 0;
		tw.create(title, "alpha", 1, 600);
		flashBang(0xFFFF80,1, 1500);
		Mode.SBANK.intro02(0.4);
		
		root.addEventListener( flash.events.MouseEvent.CLICK, onClick );
	}
	
	
	function onClick(_) {
		if( cd.has("click") )
			return;
		cd.set("click", 9999999);
		Mode.SBANK.intro01(0.7);
		flashBang(0xF42500, 0.8, 700);
		tw.create(root, "alpha", 0, 700).onEnd = function() {
			destroy();
			new Game();
		}
	}
	
	override function destroy() {
		super.destroy();
		title.bitmapData.dispose();
	}
	
}
