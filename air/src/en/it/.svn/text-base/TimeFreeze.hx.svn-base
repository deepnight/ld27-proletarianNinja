package en.it;

import mt.deepnight.T;

class TimeFreeze extends en.Item {
	public function new(x,y) {
		super(x,y);
		spr.set("time");
		spr.setCenter(0.5, 0.5);
	}

	override function onPickUp() {
		super.onPickUp();
		game.freezeTime( Const.seconds(2.5) );
		Fx.ME.popMessage(this, T.get("Freeze!"));
		Fx.ME.flashBang(0x8829D6, 0.9, 1000);
	}

	override function update() {
		super.update();
		if( game.time%2==0 )
			Fx.ME.itemGlow(this, 0xAE84D0);
	}
}
