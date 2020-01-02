package en;

import mt.deepnight.SpriteLibBitmap;
import flash.display.Sprite;

class Mob extends Entity {
	public static var ALL : Array<Mob> = [];
	public static var CONE_COLOR = mt.Color.brightness(Const.SHADOW, 0.5);
	
	public var skin			: Int;
	public var lookAng		: Float;
	public var targetLookAng: Float;
	public var viewCone		: Sprite;
	public var viewConeGraph: Sprite;
	public var sightLen		: Int;
	
	public var toBeKilled	: Bool;
	var acc					: BSprite;
	
	public function new(x,y) {
		super();
		sightLen = 5;
		setPos(x,y);
		frict = 0.6;
		speed*=0.3;
		toBeKilled = true;
		setLife(1);
		setShadow(true);
		ALL.push(this);
		
		game.buffer.dm.add(spr, Const.DP_MOB);
		skin = irnd(1,3);
		spr.setGroup("bourgeois"+skin);
		spr.scaleX = rseed.sign();
		//spr.graphics.beginFill(0xFF0000,1);
		//spr.graphics.drawCircle(0,-Const.GRID*0.5,Const.GRID*0.5);
		
		viewCone = new Sprite();
		game.buffer.dm.add(viewCone, Const.DP_BG);
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
		viewCone.alpha = 0.5;
		
		setLook(0);
		
		var a = ["smoke", "wine", "beer", "cane"];
		acc = game.tiles.getAndPlay( a[Std.random(a.length)] );
		spr.addChild(acc);
		acc.x = -11;
		acc.y = -12;
	}
	
	public static function getTargets() {
		return ALL.filter(function(e) return !e.destroyed && e.toBeKilled);
	}

	public function setLook(a:Float, ?delayed=false) {
		a = Math.round(a/(Math.PI*0.5)) * Math.PI*0.5;
		targetLookAng = normalizeAng(a);
		
		var dir = Math.round(a/(Math.PI*0.5)) + 1;
		if( spr.scaleX<0 ) {
			if( dir==1 ) dir = 3;
			else if( dir==3 ) dir = 1;
		}
		
		if( delayed )
			game.delayer.add(function() spr.setFrame(dir), 130);
		else
			spr.setFrame(dir);
	}
	
	override function unregister() {
		super.unregister();
		ALL.remove(this);
	}
	
	override function onDie() {
		super.onDie();
		new Gib(xx,yy, "hat");
		new Gib(xx,yy, "head", skin-1);
		if( getTargets().length==0 )
			game.fx.flashBang(0xFF0000, 0.7, 1500);
		else
			game.fx.flashBang(0xFF0000, 0.5, 600);
			
		mt.flash.Sfx.playOne([Mode.SBANK.kill01, Mode.SBANK.kill02, Mode.SBANK.kill03], 0.4);
			
		game.frag(this);
	}
	
	override function destroy() {
		if( destroyed )
			return;
		viewCone.parent.removeChild(viewCone);
		acc.destroy();
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
			var pts = [];
			mt.deepnight.Lib.bresenham(cx,cy, tcx,tcy, function(x,y) pts.push({cx:x,cy:y}));
			if( pts[0].cx!=cx || pts[0].cy!=cy )
				pts.reverse();
				
			var len = 0;
			var wasTable = false;
			for(pt in pts) {
				if( game.level.isWall(pt.cx,pt.cy) )
					break;
				else if( getHeight(pt.cx, pt.cy)>zz )
					wasTable = true;
				else if( wasTable )
					break;
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
	
	public function canSee(e:Entity) {
		if( !game.running || e.destroyed )
			return false;
		if( e.cx==cx && e.cy==cy )
			return false;
		var heroAng = Math.atan2(e.yy-yy, e.xx-xx);
		var scheck = mt.deepnight.Lib.bresenhamCheck(cx,cy, e.cx,e.cy, function(x,y) {
			return !( zz<getHeight(x,y) && e.zz<getHeight(x,y) );
		});
		return
			mt.deepnight.Lib.distance(cx,cy,e.cx,e.cy)<=sightLen &&
			Math.abs(angDiff(lookAng, heroAng))<=0.3 &&
			scheck;
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
		Mode.SBANK.alarm01(1);
		game.fx.pop(this, "!!!");
		game.fx.pop(reason, "!");
		game.fx.alarmReason(reason.xx, reason.yy);
		game.fx.flashBang(CONE_COLOR, 0.2, 2000);
		game.announce(desc, 0xFF0000);
		targetLookAng = lookAng;
		viewCone.transform.colorTransform = mt.Color.getColorizeCT(0xFF9300, 1);
		viewCone.filters = [ new flash.filters.GlowFilter(0xFF0000,1, 16,16) ];
		viewCone.alpha = 1;
		
		game.onGameOver();
	}
	
	override function update() {
		// Look tweening
		var d = angDiff(lookAng, targetLookAng);
		lookAng = normalizeAng(lookAng + d*0.2);
		targetLookAng+=Math.cos(game.time*0.15)*0.007;
			
		// Attacked by player
		if( mt.deepnight.Lib.distance(xx,yy, game.hero.xx, game.hero.yy)<=Const.GRID*1.2 ) {
			if( getTargets().length>1 )
				game.fx.pop(this, "Argh!");
			game.fx.multiHits(this);
			mt.flash.Sfx.playOne([Mode.SBANK.attack01, Mode.SBANK.attack02, Mode.SBANK.attack03, Mode.SBANK.attack04], 0.7);
			onDie();
			game.hero.onAttack();
			return;
		}
		

		if( canSee(game.hero) )
			alarm(game.hero, "Spotted!");
			
		for(e in Cadaver.ALL)
			if( canSee(e) ) {
				alarm(e, "Corpse discovered");
				break;
			}
				
		super.update();
	}
}