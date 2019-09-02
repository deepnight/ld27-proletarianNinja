package m;

import Const;

import mt.deepnight.SpriteLibBitmap;
import mt.flash.Key;
import flash.ui.Keyboard;
import flash.display.Sprite;

class Outro extends Mode { //}
	var title				: flash.display.Bitmap;
	var cm					: mt.deepnight.Cinematic;
	var lines				: Int;
	var done				: Bool;
	
	public function new() {
		super();
		Key.init();
		lines = 0;
		
		cm = new mt.deepnight.Cinematic();
		
		title = new flash.display.Bitmap( new GfxTitle(0,0) );
		buffer.dm.add(title, Const.DP_INTERF );
		
		
		title.alpha = 0;
		tw.create(title, "alpha", 0.3, 600);
		flashBang(0xFFFF80,1, 1500);
		Mode.SBANK.intro02(0.4);
		title.filters = [ new flash.filters.BlurFilter(4,4) ];
		
		root.addEventListener( flash.events.MouseEvent.CLICK, onClick );
		
		cm.create({
			2000;
			credit("Your final score: "+Game.ME.globalScore, 0xFFFFFF) > 3000;
			blank();
			credit("Thank you for playing! :)") > 1000;
			credit("A 48h Ludum Dare game by Sebastien Benard") > 1000;
			credit("Theme: '10 seconds'") > 1000;
			blank();
			credit("Visit blog.deepnight.net", 0xFFFFFF) > 1000;
			done = true;
		});
	}
	
	
	public function blank() {
		lines++;
	}
	
	public function credit(str:String, ?col=0xDDD2AE) {
		var tf = Game.ME.createField(str);
		buffer.dm.add(tf, Const.DP_INTERF);
		tf.filters = [ new flash.filters.GlowFilter(0x0, 1, 2,2, 1) ];
		tf.textColor = col;
		tf.x = Std.int(buffer.width*0.5-tf.width*0.5);
		tf.y = 50 + lines * 10;
		tf.alpha = 0;
		tw.create(tf, "alpha", 1, 1000);
		
		lines++;
	}
	
	
	
	function onClick(_) {
		if( !done )
			return;
			
		Mode.SBANK.intro01(0.7);
		flashBang(0xF42500, 0.8, 700);
		tw.create(root, "alpha", 0, 700).onEnd = function() {
			destroy();
			new m.Intro();
		}
	}
	
	override function destroy() {
		super.destroy();
		title.bitmapData.dispose();
	}
	
	override function update() {
		super.update();
		cm.update();
	}
}
