import flash.external.ExternalInterface;

class Main { //}
	
	static function main() {
		haxe.Log.setColor(0xFFFF00);

		var g = flash.Lib.current.graphics;
		g.beginFill(Const.SHADOW,1);
		g.drawRect(0,0,Const.WID,Const.HEI);
		
		flash.Lib.current.addEventListener( flash.events.Event.ENTER_FRAME, update );
		var url : String = ExternalInterface.call("window.location.href.toString");
		if( url.indexOf("file://")<0 && url.indexOf("http://deepnight.net")<0 ) {
			flash.Lib.getURL( new flash.net.URLRequest("http://deepnight.net") );
			return;
		}
		else {
			#if debug
			new m.Game();
			#else
			new m.Intro();
			#end
		}
	}
	
	static function update(_) {
		mt.deepnight.Mode.updateAll();
	}
	
}
