package en;
import mt.flash.Key;
import flash.ui.Keyboard;
import mt.deepnight.Lib;
import mt.deepnight.Bresenham;
import mt.deepnight.slb.BSprite;
import mt.deepnight.T;
import mt.flash.Sfx;
import Const;

class Hero extends Entity {
	static var BLOOD_STEPS = 40;
	public static var LIGHTING_RADIUS = 5;
	public var dir		: Int;
	var lighting		: flash.display.Bitmap;
	var bloodSteps		: Int;

	var target			: Null<Mob>;
	var ammo			: Int;
	var lastShootTarget	: Null<en.Mob>;
	//var ammoSpr			: BSprite;

	public function new() {
		super();
		dir = 1;
		canBeFrozen = false;
		setLife(3);
		setPos(20,2);
		frict = 0.3;
		speed*= game.mode==TurnBased ? 3 : 6;
		game.sdm.add(spr, Const.DP_HERO);
		bloodSteps = 0;
		ammo = 0;
		setShadow(true);

		//ammoSpr = game.tiles.get("shuriken");
		//ammoSpr.setCenter(0.5, 1);
		//game.sdm.add(ammoSpr, Const.DP_HERO);

		spr.a.registerStateAnim("ninjaJump", 10, function() return !stable);
		spr.a.registerStateAnim("ninjaRun", 1, function() return path.length>0 && jumpCounter<=0 );
		spr.a.registerStateAnim("ninjaStand", 0, function() return true);
		spr.a.applyStateAnims();

		lighting = new flash.display.Bitmap( new flash.display.BitmapData(Const.GRID*(LIGHTING_RADIUS*2+1), Const.GRID*(LIGHTING_RADIUS*2+1), true, 0x0) );
		lighting.blendMode = ADD;
		lighting.filters = [ new flash.filters.BlurFilter(8,8) ];
		lighting.alpha = 0.5;
		game.sdm.add(lighting, Const.DP_BG);

		updateLighting();
		updateSprite();
	}

	public function attackTarget(e:Mob) {
		if( canShoot(e) )
			shoot(e);
		else {
			target = e;
			cd.unset("targetTracking");
			goto(e.cx, e.cy);
		}
	}

	public inline function clearTarget() {
		target = null;
	}

	public inline function hasTarget() {
		return target != null;
	}

	override function hit(d) {
		super.hit(d);
		game.fx.flashBang(0xFF0000, 0.7, 500);
	}

	override function goto(x,y) {
		if( getHeight(x,y)>=10 ) {
			for(d in [{dx:0,dy:1}, {dx:0,dy:-1}, {dx:-1,dy:0}, {dx:1,dy:0}])
				if( getHeight(x+d.dx, y+d.dy)<10 ) {
					x = x+d.dx;
					y = y+d.dy;
					break;
				}
		}
		var sees = Bresenham.checkThinLine(cx,cy,x,y, function(x,y) {
			return getHeight(x,y)<=10;
		});
		if( sees ) {
			path = Bresenham.getThinLine(cx,cy, x,y);
			if( path[0].x!=cx || path[0].y!=cy )
				path.reverse();
			Fx.ME.moveMarker(x,y, target!=null);
		}
		else {
			super.goto(x,y);
			if( path.length>0 )
				Fx.ME.moveMarker(x,y, target!=null);
		}
	}

	override function destroy() {
		if( destroyed )
			return;

		lighting.parent.removeChild(lighting);
		lighting.bitmapData.dispose();
		lighting.bitmapData = null;

		//ammoSpr.destroy();

		super.destroy();
	}


	inline function canShoot(e:Entity) {
		return
			ammo>0 && !cd.has("shoot") && !game.gameOver &&
			distance(e)<=Shuriken.REACH &&
			sightCheck(e) &&
			!en.Shuriken.hasOneTargetting(e);
	}

	public function shoot(e:en.Mob) {
		cd.set("shoot",Const.SHURIKEN_CD);
		game.cd.set("skipTurn", Const.seconds(0.3));
		ammo--;
		new en.Shuriken(this, e);
	}


	public function onAttack() {
		stop();
		jump(0.7);
		bloodSteps = BLOOD_STEPS;
	}


	//override function jump(?p:Float) {
		//super.jump(p);
		////spr.a.playAndLoop("ninjaJump");
	//}


	override function updateSprite() {
		super.updateSprite();
		spr.scaleX = dir;
		if( lighting!=null ) {
			lighting.x = (cx-LIGHTING_RADIUS)*Const.GRID;
			lighting.y = (cy-LIGHTING_RADIUS)*Const.GRID;
		}

		//if( ammoSpr!=null ) {
			//ammoSpr.x = spr.x;
			//ammoSpr.y = spr.y-10;
			//ammoSpr.visible = ammo>0 && spr.visible;
			//ammoSpr.alpha = spr.alpha;
		//}
	}


	public inline function hasAmmo() {
		return ammo>0;
	}

	public inline function getAmmo() {
		return ammo;
	}

	public function addAmmo(?n=3) {
		ammo+=n;
		updateSprite();
	}

	public function updateLighting() {
		var bd = lighting.bitmapData;
		if( bd==null )
			return;

		bd.fillRect(bd.rect,0x0);

		var col = 0xFF0000;
		var r2 = LIGHTING_RADIUS * LIGHTING_RADIUS;
		var rect = new flash.geom.Rectangle(0, 0, Const.GRID, Const.GRID);

		for(dx in -LIGHTING_RADIUS...LIGHTING_RADIUS+1)
			for(dy in -LIGHTING_RADIUS...LIGHTING_RADIUS+1) {
				var d2 = Lib.distanceSqr(cx,cy, cx+dx,cy+dy);
				if( d2<=r2 && sightCheckCoord(cx+dx,cy+dy) ) {
					rect.x = (LIGHTING_RADIUS+dx)*Const.GRID;
					rect.y = (LIGHTING_RADIUS+dy)*Const.GRID;
					bd.fillRect( rect, mt.deepnight.Color.addAlphaF(col, 1-Math.sqrt(d2)/LIGHTING_RADIUS));
				}
			}
	}

	public function onCaught() {
		stop();
		dz = zz = 0;
		spr.a.play("ninjaCaught").stopOnEnd();
	}

	public function onWin() {
		stop();

		spr.a.playAndLoop("ninjaStand");
		game.delayer.add(function() {
			spr.a.play("ninjaWin").stopOnEnd();
			game.fx.popMessage(this, T.get("Take that, bourgeois."));
		}, 500);
	}

	override function onLand() {
		super.onLand();
		BaseProcess.SBANK.land01(0.7);
	}

	override function update() {
		var old = {cx:cx,cy:cy}
		super.update();

		if( target!=null && target.isDead() )
			target = null;

		if( target!=null && !cd.has("targetTracking") ) {
			cd.set("targetTracking", 10);
			goto(target.cx, target.cy);
		}


		if( target!=null && canShoot(target) ) {
			shoot(target);
			clearTarget();
			stop();
		}

		var next = path[0];
		if( next!=null ) {
			//if( stable )
				//if( jumpCounter<=0 )
					//spr.a.playAndLoop("ninjaRun");
				//else
					//spr.a.playAndLoop("ninjaStand");
			if( stable )
				game.fx.smokeStep(xx,yy);
			game.fx.ghostMark(spr.x,spr.y, spr);
			if( next.x>cx )
				dir = 1;
			if( next.x<cx )
				dir = -1;
			if( stable && bloodSteps>0 ) {
				game.fx.bloodSteps(xx,yy, bloodSteps/BLOOD_STEPS);
				bloodSteps--;
			}
			if( stable && !cd.hasSet("stepSfx", rnd(2,4)) ) {
				Sfx.playOne([BaseProcess.SBANK.step01, BaseProcess.SBANK.step03], 0.7);
			}
		}
		//else
			//if( stable && !game.gameOver)
				//spr.a.playAndLoop("ninjaStand");

		if( cx!=old.cx || cy!=old.cy )
			updateLighting();
	}
}

