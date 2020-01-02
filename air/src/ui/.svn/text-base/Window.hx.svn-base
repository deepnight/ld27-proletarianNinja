package ui;

import mt.deepnight.Lib;
import mt.MLib;
import mt.Metrics;

class Window extends mt.deepnight.mui.Window {
	var globalMargin		: Int;

	public function new(p, gmargin:Int) {
		super(p);

		globalMargin = gmargin;
		padding = 5;
		color = 0x1A1324;
		setClickTrap(Const.SHADOW, 0.7);
	}

	override function prepareRender() {
		//upscale();
		bestFit();
		super.prepareRender();
	}

	function bestFit() {
		var w = getWidth();
		var h = getHeight();
		var gw = Metrics.w();
		var gh = Metrics.h();

		var tw : Float = gw-globalMargin;
		var th : Float = gh-globalMargin;
		var r = th/tw;

		var cm_w = Metrics.px2cm(tw);
		var cm_h = Metrics.px2cm(th);

		if( cm_w>=20 ) {
			tw = Metrics.cm2px(20);
			th = tw*r;
		}
		//trace(gw+" x "+gh);
		//trace(tw+" x "+th);
		//trace("cm="+Lib.prettyFloat(cm_w)+" x "+Lib.prettyFloat(cm_h));

		var sx = tw / w;
		var sy = th / h;
		var s = MLib.fmin(sx,sy);

		setScale(s);
	}

	//function upscale() {
		//var w = getWidth();
		//var bestWid = MLib.fmax( Metrics.cm2px(8), MLib.fmin( Metrics.w()*0.7, w ) );
//
		//trace("upscale --------------");
		//trace(w);
		//trace(Metrics.cm2px(8));
		//trace(bestWid);
//
		//var s = bestWid>w ? Std.int(bestWid/w) : 1;
//
		//var h = getHeight();
//
		//while( s>1 && h*s>Const.HEI*0.95 )
			//s--;
//
		//setScale(s);
//
		//trace(scale);
	//}
}