package en.mob;

import mt.deepnight.Color;
import mt.deepnight.T;

class Dog extends en.mob.Guard {

	public function new(x,y) {
		super(x,y);
		toBeKilled = false;
		acc.visible = false;
		spr.set("dog");
		initDir();
	}

	override function specialGibs() {
	}

	override function onDie() {
		super.onDie();
		game.onGameOver(2000);
		game.announce( T.get("You killed a dog!") );
		BaseProcess.SBANK.alarm02(0.7);
		Fx.ME.flashBang(0xFF0000, 0.8, 2000);
	}

	override function update() {
		super.update();
	}
}
