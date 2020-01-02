package en;

import mt.deepnight.slb.BSprite;
import mt.deepnight.T;
import mt.deepnight.Lib;
import mt.MLib;
import mt.deepnight.Color;
import flash.display.Sprite;

class Mob extends Entity {
	public static var ALL : Array<Mob> = [];
	public static var CONE_COLOR = Color.brightnessInt(Const.SHADOW, 0.5);

	public var toBeKilled	: Bool;
	public var skin			: Int;
	public var lookAng		: Float;
	public var targetLookAng: Float;
	public var viewCone		: Sprite;
	public var viewConeGraph: Sprite;
	public var sightLen		: Int;

	var acc					: BSprite; // accessory
	#if debug
	var debug				: Sprite;
	#end

	public function new(x,y) {
		super();
		sightLen = 5;
		setPos(x,y);
		frict = 0.6;
		speed*=0.3;
		setLife(1);
		setShadow(true);
		ALL.push(this);
		toBeKilled = true;
		targetLookAng = lookAng = 0;

		game.sdm.add(spr, Const.DP_MOB);
		skin = irnd(1,3);
		spr.set("bourgeois"+skin);
		spr.scaleX = rseed.sign();

		viewCone = new Sprite();
		game.sdm.add(viewCone, Const.DP_BG);
		viewConeGraph = new Sprite();
		viewCone.addChild(viewConeGraph);
		var g = viewConeGraph.graphics;
		var m = new flash.geom.Matrix();
		m.createGradientBox(100,80, 0, -50,-40);
		g.beginGradientFill(
			flash.display.GradientType.RADIAL,
			[CONE_COLOR,CONE_COLOR], [1,0], [0,255], m
		);
		g.moveTo(0,0);
		g.moveTo(0,0);
		g.lineTo(50,-10);
		g.lineTo(50,10);
		viewCone.blendMode = flash.display.BlendMode.ADD;
		viewCone.alpha = 0.7;

		setLook(0);

		var a = ["smoke", "wine", "beer", "cane"];
		acc = game.tiles.getAndPlay( a[Std.random(a.length)] );
		spr.addChild(acc);
		acc.x = -11;
		acc.y = -12;

		#if debug
		debug = new Sprite();
		game.sdm.add(debug, Const.DP_INTERF);
		#end
	}

	public static function getTargets() {
		return ALL.filter( function(e) return !e.destroyed && e.toBeKilled );
	}

	public function setLook(a:Float, ?delayed=false) {
		a = Math.round(a/(Math.PI*0.5)) * Math.PI*0.5;
		targetLookAng = normalizeAng(a);
	}

	override function unregister() {
		super.unregister();
		ALL.remove(this);
	}

	override function hit(d) {
		if( !game.gameOver )
			super.hit(d);
	}

	function specialGibs() {
		new Gib(xx,yy, "hat");
		new Gib(xx,yy, "head", skin-1);
	}

	override function onDie() {
		super.onDie();

		specialGibs();

		if( getTargets().length==0 )
			game.fx.flashBang(0xFF0000, 0.4, 1500);
		else
			game.fx.flashBang(0xFF0000, 0.2, 400);

		mt.flash.Sfx.playOne([BaseProcess.SBANK.kill01, BaseProcess.SBANK.kill02, BaseProcess.SBANK.kill03], 0.4);

		game.frag(this);
	}

	override function destroy() {
		if( destroyed )
			return;
		viewCone.parent.removeChild(viewCone);
		acc.dispose();
		#if debug
		debug.parent.removeChild(debug);
		#end
		super.destroy();
	}


	override function updateSprite() {
		super.updateSprite();
		if( viewCone!=null ) {
			viewCone.x = spr.x;
			viewCone.y = spr.y-5;
			var a = normalizeAng(lookAng);
			viewCone.rotation = normalizeAng(lookAng)*180/3.14;

			var tcx = Std.int( cx + Math.cos(a)*sightLen );
			var tcy = Std.int( cy + Math.sin(a)*sightLen );
			var pts = mt.deepnight.Bresenham.getThinLine(cx,cy, tcx,tcy);
			if( pts[0].x!=cx || pts[0].y!=cy )
				pts.reverse();

			var len = 0;
			var wasTable = false;
			for(pt in pts) {
				if( game.level.getHeight(pt.x, pt.y)>=Const.H_HIGH )
					break;
				//else if( getHeight(pt.x, pt.y)>zz )
					//wasTable = true;
				//else if( wasTable )
					//break;
				len++;
				if( len>=sightLen )
					break;
			}
			var w = (len-0.5)*Const.GRID;
			viewConeGraph.width = viewConeGraph.width + (w-viewConeGraph.width)*0.4;
			viewConeGraph.scaleY = viewCone.scaleX;
		}
	}

	public inline function normalizeAng(a:Float) {
		var pi = Math.PI;
		return a - Math.round(a/(pi*2))*pi*2;
	}

	public inline function angDiff(a,b) {
		var d = normalizeAng(b)-normalizeAng(a);
		if( d>=3.14 )
			d-=6.28;
		if( d<=-3.14 )
			d+=6.28;
		return d;
	}

	public function isSleeping() {
		return false;
	}

	public function canSee(e:Entity) {
		if( !game.running || e.destroyed || isSleeping() || game.isFrozen() )
			return false;

		if( e.cx==cx && e.cy==cy )
			return false;
		var heroAng = Math.atan2(e.yy-yy, e.xx-xx);
		//var scheck = mt.deepnight.Bresenham.checkThinLine(cx,cy, e.cx,e.cy, function(x,y) {
			//return !( zz<getHeight(x,y) && e.zz<getHeight(x,y) );
		//});
		return
			mt.deepnight.Lib.distance(cx,cy,e.cx,e.cy)<=sightLen &&
			Math.abs(angDiff(lookAng, heroAng))<=0.3 &&
			sightCheck(e);
	}

	override function onPathStep() {
		super.onPathStep();
		if( path.length>0 ) {
			var next = path[0];
			setLook( Math.atan2(next.y-cy, next.x-cx) );
		}
	}

	public function alarm(reason:Entity, desc:String) {
		if( game.gameOver )
			return;

		BaseProcess.SBANK.alarm01(1);
		game.fx.popMessage(this, "!!!");
		game.fx.popMessage(reason, "!");
		game.fx.alarmReason(reason.xx, reason.yy);
		game.fx.flashBang(CONE_COLOR, 0.2, 2000);
		game.announce(desc, 0xFF0000);
		targetLookAng = lookAng;
		viewCone.transform.colorTransform = Color.getColorizeCT(0xFF9300, 1);
		viewCone.filters = [ new flash.filters.GlowFilter(0xFF0000,1, 16,16) ];
		viewCone.alpha = 1;

		game.onGameOver();
	}


	inline function canPlay() {
		return game.mobsCanPlay();
	}


	override function update() {
		// Look tweening
		var d = Lib.normalizeRad( targetLookAng-lookAng );
		lookAng += d*0.3;

		// Attacked by player
		var d = toBeKilled ? Const.GRID*1.2 : Const.GRID*0.7;
		if( !game.gameOver && mt.deepnight.Lib.distance(xx,yy, game.hero.xx, game.hero.yy)<=d ) {
			if( getTargets().length>1 )
				game.fx.popMessage(this, T.get("Argh!") );
			game.fx.multiHits(this);
			mt.flash.Sfx.playOne([BaseProcess.SBANK.attack01, BaseProcess.SBANK.attack02, BaseProcess.SBANK.attack03, BaseProcess.SBANK.attack04], 0.7);
			onDie();
			game.hero.onAttack();
			return;
		}


		// Sleeping fx
		if( isSleeping() && !cd.has("sleep") ) {
			spr.setFrame(4);
			cd.set("sleep", rnd(40,50));
			Fx.ME.sleep(xx,yy);
		}

		if( canSee(game.hero) )
			alarm(game.hero, T.get("Spotted!") );

		for(e in Cadaver.ALL)
			if( canSee(e) ) {
				alarm(e, T.get("Cadaver found") );
				break;
			}

		#if debug
		debug.x = spr.x;
		debug.y = spr.y;
		//var g = debug.graphics;
		//g.clear();
		//g.lineStyle(1, 0xFFFF00, 0.5, true, flash.display.LineScaleMode.NONE);
		//g.moveTo(0,-10);
		//g.lineTo(Math.cos(targetLookAng)*20, Math.sin(targetLookAng)*20 - 10);
		#end

		if( canPlay() )
			super.update();


		viewCone.visible = !isSleeping();
		viewCone.alpha = game.isFrozen() ? 0.3 : 1;
	}
}