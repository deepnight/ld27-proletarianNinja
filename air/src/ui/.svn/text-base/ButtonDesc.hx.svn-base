package ui;

import flash.display.Bitmap;
import flash.display.BitmapData;
import mt.MLib;
import mt.Metrics;

class ButtonDesc extends Button {
	var desc		: Bitmap;
	
	public function new(p, str:String, descStr:String, cb:Void->Void) {
		super(p, str, cb);
		
		var tf = Mode.CURRENT.createField(descStr);
		tf.alpha = 0.7;
		tf.filters = [ new flash.filters.DropShadowFilter(1,90, 0x0,0.3, 0,0) ];
		desc = flattenWithGlobalScale(tf);
		content.addChild(desc);
		
		label.scaleX = label.scaleY = 2;
	}
	
	override function destroy() {
		super.destroy();
		desc.bitmapData.dispose();
	}
	
	override function getContentWidth() {
		return MLib.fmax( super.getContentWidth(), desc.width );
	}
	
	override function getContentHeight() {
		return super.getContentHeight() + desc.height;
	}
	
	override function renderContent(w,h) {
		super.renderContent(w,h);
		label.x = 0;
		label.y = 0;
		desc.x = 4;
		desc.y = label.height - 5;
	}
}