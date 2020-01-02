package ui;

class Separator extends BitmapComponent {
	var shei		: Int;
	public function new(p, ?h=10) {
		super(p);
		shei = h;
		hasBackground = false;
	}
	
	override function renderContent(w,h) {
		super.renderContent(w,h);
		
		content.graphics.beginFill(0xFFFFFF, 0.1);
		content.graphics.drawRect(0, Std.int(h*0.5), w, 1);
	}
	
	
	override function getContentHeight() {
		return super.getContentHeight() + shei;
	}
}