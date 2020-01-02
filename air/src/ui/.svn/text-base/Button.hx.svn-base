package ui;

import flash.display.Bitmap;
import flash.display.BitmapData;
import mt.MLib;
import mt.Metrics;

class Button extends BitmapComponent {
	var label			: Bitmap;
	var subLabel		: Null<Bitmap>;

	public function new(p, str:String, ?size=8, cb:Void->Void) {
		super(p);

		color = 0xb62132;
		wrapper.buttonMode = wrapper.useHandCursor = true;
		mouseOverable = false;

		var tf = BaseProcess.CURRENT.createField(str, size);
		tf.filters = [ new flash.filters.DropShadowFilter(1,90, 0x0,0.3, 0,0) ];
		label = flattenWithGlobalScale(tf);
		content.addChild(label);

		wrapper.addEventListener( flash.events.MouseEvent.CLICK, function(_) {
			addState("clicked");
			cb();
		});
	}

	public function addSubLabel(str:String) {
		var tf = BaseProcess.CURRENT.createField(str, 8);
		//tf.multiline = tf.wordWrap = true;
		//tf.width = 150;
		tf.width = tf.textWidth+10;
		//tf.height = tf.textHeight+4;
		tf.filters = [ new flash.filters.DropShadowFilter(1,90, 0x0,0.3, 0,0) ];
		tf.alpha = 0.7;
		subLabel = flattenWithGlobalScale(tf);
		content.addChild(subLabel);
	}

	public function replaceLabel(o:flash.display.DisplayObject) {
		content.addChild(o);
	}

	override function applyStates() {
		super.applyStates();

		if( hasState("clicked") )
			color = 0xef8e00;
		else
			color = 0xb62132;

		if( hasState("over") )
			bg.filters = [
				new flash.filters.GlowFilter(0xFFFF80, 1, 2,2,4 ),
				new flash.filters.GlowFilter(0xFF9300, 1, 16,16,1 )
			];
		else
			bg.filters = [];
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
		label.y = Std.int(getHeight()*0.5 - label.height*0.5 +1 );

		if( subLabel!=null ) {
			subLabel.x = Std.int(getWidth()*0.5 - subLabel.width*0.5 + 2);
			label.y -= 20;
			subLabel.y = label.y + label.height - 5;
		}
	}
}