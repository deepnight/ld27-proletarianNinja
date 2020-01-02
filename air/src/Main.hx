import flash.external.ExternalInterface;

import flash.display.Bitmap;
import flash.display.BitmapData;

import Const;

class Main { //}
	static var bg			: Bitmap;
	static var active		: Bool;
	static var curFrame		: Float;
	static var tmod			: Float;
	static var bulletFactor	: Float;
	static var bulletFrames	: Float;

	static function main() {
		haxe.Log.setColor(0xFFFF00);
		active = true;
		curFrame = 0;
		tmod = 0.5;
		bulletFactor = 1;
		bulletFrames = 0;

		mt.deepnight.T.init("assets/texts", ["fr", "en"]);
		mt.deepnight.T.setCurrentLang("en", "en");

		bg = new Bitmap( new BitmapData(Const.WID, Const.HEI, false, Const.SHADOW) );
		flash.Lib.current.addChild(bg);

		flash.Lib.current.stage.addEventListener( flash.events.Event.DEACTIVATE, onDeactivate);
		flash.Lib.current.stage.addEventListener( flash.events.Event.ACTIVATE, onActivate);
		flash.Lib.current.stage.addEventListener( flash.events.Event.RESIZE, onResize );
		flash.Lib.current.addEventListener( flash.events.Event.ENTER_FRAME, update );

		//flash.desktop.NativeApplication.nativeApplication.addEventListener( flash.events.KeyboardEvent.KEY_DOWN, onSoftKeyDown, true );

		//var url : String = ExternalInterface.call("window.location.href.toString");
		//if( url.indexOf("file://")<0 && url.indexOf("http://deepnight.net")<0 ) {
			//flash.Lib.getURL( new flash.net.URLRequest("http://deepnight.net") );
			//return;
		//}
		//else {
			#if debug
			//new m.Editor(9);
			new m.Game(8, TurnBased);
			//new m.Intro();
			//new m.Outro(150);
			#else
			new m.Intro();
			#end
		//}

		onResize(null);
	}

	static function onSoftKeyDown(e:flash.events.KeyboardEvent) {
		switch( e.keyCode ) {
			case flash.ui.Keyboard.SEARCH :
				e.preventDefault();

			case flash.ui.Keyboard.MENU :
				e.preventDefault();
				BaseProcess.CURRENT.onMenuKey();

			case flash.ui.Keyboard.BACK :
				e.preventDefault();
				BaseProcess.CURRENT.onBackKey();
		}
	}

	static function onResize(_) {
		var s = flash.Lib.current.stage;
		bg.width = s.stageWidth;
		bg.height = s.stageHeight;
	}

	static function onActivate(_) {
		if( active )
			return;

		active = true;
		flash.Lib.current.addEventListener(flash.events.Event.ENTER_FRAME, update);
		mt.flash.Sfx.enable();
		flash.Lib.current.filters = [];
	}

	static function onDeactivate(_) {
		if( !active )
			return;

		active = false;
		flash.Lib.current.removeEventListener(flash.events.Event.ENTER_FRAME, update);
		mt.flash.Sfx.disable();
		flash.Lib.current.filters = [
			new flash.filters.BlurFilter(32,32, 2),
			mt.deepnight.Color.getSaturationFilter(-0.9),
		];
	}

	public static function bulletTime() {
		bulletFactor = 0.7;
		bulletFrames = 0.2*Const.FPS;
	}

	static function update(_) {
		mt.flash.Key.update();

		curFrame+=tmod;
		while( curFrame>=1 ) {
			mt.deepnight.Process.updateAll();
			curFrame--;
		}

		if( bulletFrames>0 ) {
			tmod += (bulletFactor-tmod)*0.3;
			bulletFrames--;
		}
		else
			tmod += (1-tmod)*0.1;

		mt.deepnight.mui.Component.updateAll();
	}

}

