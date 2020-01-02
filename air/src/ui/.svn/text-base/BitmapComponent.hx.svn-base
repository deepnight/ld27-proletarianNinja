package ui;

import flash.display.Bitmap;
import flash.display.BitmapData;
import mt.MLib;
import mt.Metrics;

class BitmapComponent extends mt.deepnight.mui.Component {
	public function new(p) {
		super(p);
	}

	function getGlobalScale() {
		var s = wrapper.scaleX;
		var p = parent;
		while( p!=null ) {
			s*=p.wrapper.scaleX;
			p = p.parent;
		}
		return s;
	}

	function flattenWithGlobalScale(o:flash.display.DisplayObject) {
		var s = getGlobalScale()+1;
		var base = mt.deepnight.Lib.flatten(o);
		var bmp = new Bitmap( new BitmapData(MLib.ceil(s*base.width), MLib.ceil(s*base.height), true, 0x0) );
		var m = new flash.geom.Matrix();
		m.scale(s,s);
		bmp.bitmapData.draw(base.bitmapData, m);
		base.bitmapData.dispose();
		return bmp;

	}
}