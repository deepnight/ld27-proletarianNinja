package ui;

import mt.MLib;
import mt.Metrics;
import mt.deepnight.slb.BSprite;

class LevelButton extends Button {
	var bs			: BSprite;
	var star		: BSprite;
	var frame		: Int;
	var active		: Bool;
	var last		: Bool;

	public function new(p, level:Int, active:Bool, cb:Int->Void) {
		super(p, Std.string(level+1), function() {
			if( active )
				cb(level);
		});
		last = false;

		minWidth = minHeight = 40;

		this.active = active;
		frame = active ? 0 : 2;
		bs = BaseProcess.CURRENT.tiles.get("levelButton", frame);
		bg.addChild(bs);

		star = BaseProcess.CURRENT.tiles.get("star", 0);
		bg.addChild(star);
		star.blendMode = OVERLAY;
		star.alpha = 0.25;
		star.visible = active;

		if( !active )
			wrapper.buttonMode = wrapper.useHandCursor = false;

		label.alpha = active ? 1: 0.05;
		if( active )
			label.filters = [ new flash.filters.GlowFilter(0xFF9900, 1, 8,8,1) ];
	}

	public function setGoldStar() {
		star.setFrame(1);
		star.alpha = 1;
		star.blendMode = NORMAL;
		star.filters = [ new flash.filters.GlowFilter(0xFF8600,0.6, 16,8,2) ];
	}

	public function setSilverStar() {
		star.setFrame(2);
		star.blendMode = NORMAL;
		star.alpha = 1;
		star.filters = [ new flash.filters.GlowFilter(0x9B9FBD,0.8, 8,8,2) ];
	}

	public function setLast() {
		frame = 3;
		last = true;
		bs.setFrame(frame);
		bg.filters = [
			new flash.filters.GlowFilter(0xFFFF80,1, 2,2,4),
			new flash.filters.GlowFilter(0xFF8600,1, 16,16,1),
		];
	}


	override function addState(k) {
		if( active )
			super.addState(k);
	}

	override function applyStates() {
		super.applyStates();

		if( hasState("clicked") ) {
			label.y+=1;
			bs.setFrame(1);
		}
		else
			bs.setFrame(frame);

		if( last )
			bg.filters = [
				new flash.filters.GlowFilter(0xFFFF80,1, 2,2,4),
				new flash.filters.GlowFilter(0xFF8600,1, 16,16,1),
			];
	}


	override function destroy() {
		super.destroy();
		bs.dispose();
	}

	override function renderBackground(w,h) {
		bg.width = w;
		bg.height = h;
	}

	override function renderContent(w,h) {
		super.renderContent(w,h);
		star.x = Std.int(w*0.5-star.width*0.5);
		star.y = 3;
		label.y += 3;
	}
}