package ui;

import flash.display.Bitmap;
import flash.display.BitmapData;
import mt.MLib;
import mt.Metrics;


class Label extends BitmapComponent {
	var label			: Bitmap;

	public function new(p, ?alpha=1.0, str:String, ?size:Int) {
		super(p);

		hasBackground = false;

		var tf = BaseProcess.CURRENT.createField(str, size);
		if( tf.width>150 ) {
			tf.multiline = tf.wordWrap = true;
			tf.width = 150;
			tf.height = tf.textHeight + 5;
		}
		tf.filters = [ new flash.filters.DropShadowFilter(1,90, 0x0,0.5, 0,0) ];
		tf.alpha = alpha;
		label = flattenWithGlobalScale(tf);
		content.addChild(label);
	}

	override function destroy() {
		super.destroy();
		label.bitmapData.dispose();
	}

	override function getContentWidth() {
		return super.getContentWidth() + label.width;
	}

	override function getContentHeight() {
		return super.getContentHeight() + label.height;
	}

	override function renderContent(w,h) {
		super.renderContent(w,h);
		label.x = Std.int(getWidth()*0.5 - label.width*0.5 + 2);
		label.y = Std.int(getHeight()*0.5 - label.height*0.5 );
	}
}