package en.it;

import mt.deepnight.T;

class Ammo extends en.Item {
	public function new(x,y) {
		super(x,y);
		spr.set("shuriken");
		spr.setCenter(0.5, 0.5);
	}

	override function onPickUp() {
		super.onPickUp();
		var n = 3;
		game.hero.addAmmo(n);
		Fx.ME.popMessage(this, T.get("Shuriken x")+n);
		Fx.ME.flashBang(0xFF9300, 0.5, 200);
	}

	override function update() {
		super.update();
		if( game.time%2==0 )
			Fx.ME.itemGlow(this, 0xFF0000);
	}
}
