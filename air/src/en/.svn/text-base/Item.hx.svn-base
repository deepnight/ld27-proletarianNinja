package en;

import mt.MLib;

class Item extends Entity {
	public function new(x,y) {
		super();

		game.sdm.add(spr, Const.DP_ITEM);
		setPos(x,y);
	}

	public function onPickUp() {
		destroy();
	}

	override function update() {
		super.update();
		var d = Const.GRID*1.6;
		if( !destroyed && game.running && game.hero.zz<=10 && MLib.fabs(xx-game.hero.xx)<=d && MLib.fabs(yy-game.hero.yy)<=d && sightCheck(game.hero) )
			onPickUp();
	}
}
