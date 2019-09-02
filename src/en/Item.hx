package en;

class Item extends Entity {
	public function new(x,y) {
		super();
		setPos(x,y);
		game.buffer.dm.add(spr, Const.DP_HERO);
		spr.graphics.beginFill(0x80FF00,1);
		spr.graphics.drawCircle(0,-Const.GRID*0.3,Const.GRID*0.3);
		spr.filters = [ new flash.filters.GlowFilter(0x80FF00,0.8, 16,16,2, 2) ];
	}
	
	public function onPickUp() {
		destroy();
	}
	
	override function update() {
		super.update();
		if( !destroyed && cx==game.hero.cx && cy==game.hero.cy )
			onPickUp();
	}
	
}