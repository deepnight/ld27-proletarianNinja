package en;

class Shuriken extends Entity {
	var sub				: mt.deepnight.SpriteLibBitmap.BSprite;
	public function new(e:Entity, tx:Float,ty:Float) {
		super();
		collides = false;
		setPosPixel(e.xx, e.yy);
		speed*=12;
		frict = 1;
		setLife(2);
		zz = 5;
		var a = Math.atan2( ty-yy, tx-xx );
		dx = Math.cos(a)*speed;
		dy = Math.sin(a)*speed;
		setShadow(true, 0.5);
		Mode.SBANK.throw01(1);
		Mode.SBANK.throw02(1);
		
		game.buffer.dm.add(spr, Const.DP_HERO);
		sub = game.tiles.get("shuriken");
		spr.addChild(sub);
		sub.setCenter(0.5,0.5);
		spr.scaleX = spr.scaleY = 1.3;
		spr.scaleY *= 0.7;
		spr.filters = [
			new flash.filters.GlowFilter(0x94f5ff,1, 8,8,2, 1),
			new flash.filters.GlowFilter(0x51BEFF,1, 16,16,3, 2),
		];
	}
	
	override function update() {
		super.update();
		if( hasCollision(cx,cy) )
			destroy();
			
		sub.rotation+=10;
			
		for(e in Mob.ALL) {
			if( !e.destroyed && distance(e)<=Const.GRID*1.2 ) {
				mt.flash.Sfx.playOne([Mode.SBANK.attack01, Mode.SBANK.attack02, Mode.SBANK.attack03, Mode.SBANK.attack04], 0.4);
				e.hit(1);
			}
		}
	}
}