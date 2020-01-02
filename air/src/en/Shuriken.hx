package en;

class Shuriken extends Entity {
	public static var ALL : Array<Shuriken> = [];
	public static var REACH = Const.GRID*30;

	var sub				: mt.deepnight.slb.BSprite;
	var target			: Entity;

	public function new(e:Entity, t:Entity) {
		super();
		ALL.push(this);
		target = t;
		canBeFrozen = false;
		collides = false;
		setPosPixel(e.xx, e.yy);
		speed*=20;
		frict = 1;
		setLife(2);
		zz = 5;
		var a = Math.atan2( t.yy-yy, t.xx-xx );
		dx = Math.cos(a)*speed;
		dy = Math.sin(a)*speed;
		setShadow(true, 0.5);
		BaseProcess.SBANK.throw01(1);
		BaseProcess.SBANK.throw02(1);

		game.sdm.add(spr, Const.DP_HERO);
		sub = game.tiles.get("shuriken");
		spr.addChild(sub);
		sub.setCenter(0.5,0.5);
		spr.scaleX = spr.scaleY = 1.3;
		spr.scaleY *= 0.7;
	}

	public static function hasOneTargetting(e:Entity) {
		for(s in ALL)
			if( s.target==e )
				return true;

		return false;
	}

	override function unregister() {
		super.unregister();
		ALL.remove(this);
	}

	override function update() {
		super.update();

		if( game.time%2==0 )
			Fx.ME.shurikenTrail(this);

		sub.rotation+=10;

		if( mt.deepnight.Lib.angularDistanceRad(Math.atan2(dy,dx), Math.atan2(target.yy-yy, target.xx-xx)) >= 2) {
			mt.flash.Sfx.playOne([BaseProcess.SBANK.attack01, BaseProcess.SBANK.attack02, BaseProcess.SBANK.attack03, BaseProcess.SBANK.attack04], 0.4);
			target.hit(1);
			destroy();
		}
	}
}