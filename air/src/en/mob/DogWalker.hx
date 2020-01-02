package en.mob;

import mt.deepnight.Color;
import mt.deepnight.T;

class DogWalker extends en.mob.Walker {

	public function new(x,y) {
		super(x,y);
		toBeKilled = false;
		acc.visible = false;
		spr.a.playAndLoop("dogWalk");
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

	override function updateScaleDir() {
		super.updateScaleDir();

		if( path.length>0 && path[0].y!=cy )
			spr.scaleX = spr.scaleX<0 ? -0.9 : 0.9;
	}

	override function update() {
		super.update();
	}
}
