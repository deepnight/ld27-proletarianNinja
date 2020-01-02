package m;

import Const;

import mt.flash.Key;
import flash.ui.Keyboard;
import flash.display.Sprite;
import flash.display.Bitmap;

class Outro extends BaseProcess { //}
	var bg					: Bitmap;

	var cm					: mt.deepnight.Cinematic;
	var lines				: Int;
	var done				: Bool;

	public function new(score:Int) {
		super();
		lines = 0;

		cm = new mt.deepnight.Cinematic();

		bg = new Bitmap( new GfxIntroBg(0,0) );
		buffer.dm.add(bg, Const.DP_BG);
		tw.create(bg.alpha, 0>1, 600);

		fx.flashBang(0xFFFF80,1, 1500);
		BaseProcess.SBANK.intro02(0.4);

		root.addEventListener( flash.events.MouseEvent.CLICK, onClick );

		cm.create({
			2000;
			credit("Your final score: "+score, 0xFFFFFF) > 3000;
			blank();
			credit("A 48h Ludum Dare game by Sebastien Benard") > 1000;
			credit("Theme: '10 seconds'") > 3000;
			blank();
			credit("Visit blog.deepnight.net", 0xFFFFFF) > 1000;
			credit("Thank you for playing! :)") > 1000;
			done = true;
		});

		onResize();
	}


	override function onResize() {
		super.onResize();
		if( bg!=null ) {
			bg.width = buffer.width;
			bg.height = buffer.height;
		}
	}


	public function blank() {
		lines++;
	}

	public function credit(str:String, ?col=0xDDD2AE) {
		var tf = createField(str);
		buffer.dm.add(tf, Const.DP_INTERF);
		tf.filters = [ new flash.filters.GlowFilter(0x0, 1, 2,2, 1) ];
		tf.textColor = col;
		tf.x = Std.int(buffer.width*0.5-tf.width*0.5);
		tf.y = 50 + lines * 10;
		tw.create(tf.alpha, 0>1, 1000);

		lines++;
	}



	function onClick(_) {
		if( !done )
			return;

		BaseProcess.SBANK.intro01(0.7);
		fx.flashBang(0xF42500, 0.8, 700);
		tw.create(root.alpha, 0, 700).onEnd = function() {
			destroy();
			new m.Intro();
		}
	}

	override function unregister() {
		super.unregister();
		bg.bitmapData.dispose();
	}

	override function update() {
		super.update();
		cm.update();
	}
}
