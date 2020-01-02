import flash.display.Sprite;

import mt.deepnight.Buffer;
import mt.flash.Sfx;
import mt.flash.Key;

class Mode extends mt.deepnight.Mode {
	public static var SBANK = Sfx.importDirectory("sfx");
	
	public var buffer		: Buffer;
	
	public function new() {
		super();
		Key.init();
		buffer = new Buffer(300,200, Const.UPSCALE, false, Const.SHADOW);
		root.addChild(buffer.render);
		buffer.setTexture( Buffer.makeMosaic2(Const.UPSCALE), 0.1, true );
	}
	
	public function flashBang(col:Int, a:Float, ms:Float) {
		var s = new Sprite();
		buffer.dm.add(s, Const.DP_INTERF);
		s.graphics.beginFill(col,a);
		s.graphics.drawRect(0,0,buffer.width,buffer.height);
		s.blendMode = flash.display.BlendMode.ADD;
		tw.create(s, "alpha", 0, ms).onEnd = function() {
			s.parent.removeChild(s);
		}
	}
	
	override function destroy() {
		super.destroy();
		buffer.destroy();
	}
	
	override function update() {
		super.update();
		
		if( Key.isToggled(flash.ui.Keyboard.S) ) {
			Sfx.toggleMuteChannel(0);
			Mode.SBANK.menu01().play();
			flashBang(0x0080FF,0.5, 300);
		}
	}
	
	override function render() {
		super.render();
		buffer.update();
	}
}
