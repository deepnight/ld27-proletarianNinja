import mt.deepnight.slb.BSprite;
import mt.deepnight.Lib;
import mt.deepnight.Bresenham;
import flash.display.Sprite;

class Entity {
	public static var ALL : Array<Entity> = [];
	public static var KILL_LIST : Array<Entity> = [];
	static var UNIQ = 0;
	public static var SEED = 0;

	public var game				: m.Game;
	public var spr				: BSprite;
	public var shadow			: Sprite;
	public var uid				: Int;
	var path					: Array<{x:Int, y:Int}>;
	var rseed					: mt.Rand;

	public var xx				: Float;
	public var yy				: Float;
	public var zz				: Float;
	public var dx				: Float;
	public var dy				: Float;
	public var dz				: Float;
	public var cx				: Int;
	public var cy				: Int;
	public var xr				: Float;
	public var yr				: Float;
	public var speed			: Float;
	public var frict			: Float;
	public var gravity			: Float;
	public var cd				: mt.Cooldown;
	var jumpCounter				: Int;

	public var collides			: Bool;
	public var destroyed		: Bool;
	public var stable			: Bool;
	public var canBeFrozen		: Bool;

	public var life				: Int;
	public var maxLife			: Int;


	public function new() {
		game = m.Game.ME;
		canBeFrozen = true;
		uid = UNIQ++;
		rseed = new mt.Rand(0);
		rseed.initSeed( (SEED++) + game.seed );
		path = [];
		xx = yy = zz = 0;
		xr = yr = 0.5;
		dx = dy = dz = 0;
		cx = cy = 5;
		speed = 0.06;
		frict = 0.65;
		gravity = 0.6;
		jumpCounter = 0;
		destroyed = false;
		collides = true;
		stable = false;
		ALL.push(this);
		setLife(1);
		cd = new mt.Cooldown();

		spr = new BSprite(game.tiles);
		game.sdm.add(spr, Const.DP_MOB);
		spr.setCenter(0.5,1);
	}

	public function setShadow(b:Bool, ?alpha=1.0) {
		if( b && shadow==null ) {
			shadow = new Sprite();
			game.sdm.add(shadow, Const.DP_BG);
			shadow.graphics.beginFill(Const.SHADOW, 0.5*alpha);
			shadow.graphics.drawCircle(0,0,Const.GRID*0.4);
			shadow.scaleY = 0.5;
			updateSprite();
		}
		if( !b && shadow!=null ) {
			shadow.parent.removeChild(shadow);
			shadow = null;
		}
	}

	public function goto(tcx,tcy) {
		path = game.level.pfGround.getPath({x:cx, y:cy}, {x:tcx, y:tcy});
		if( path.length>0 && path[0].x==cx && path[0].y==cy )
			path.shift();
	}

	public function stop() {
		path = [];
		dx = dy = dz = 0;
		zz = 0;
	}

	inline function rnd(min,max,?sign) { return rseed.range(min,max,sign); }
	inline function irnd(min,max,?sign) { return rseed.irange(min,max,sign); }

	public function setLife(n) {
		life = maxLife = n;
	}

	public inline function isDead() {
		return life<=0 || destroyed;
	}

	public function hit(d) {
		if( destroyed || life<0 )
			return;
		life-=d;
		if( life<=0 ) {
			life = 0;
			onDie();
		}
	}

	public function sightCheck(e:Entity) {
		return Bresenham.checkThinLine(cx,cy, e.cx,e.cy, function(x,y) {
			return getHeight(x,y) < Const.H_HIGH;
		});
	}

	public function sightCheckCoord(x,y) {
		return Bresenham.checkThinLine(cx,cy, x,y, function(x,y) {
			return getHeight(x,y) < Const.H_HIGH;
		});
	}

	public function onDie() {
		destroy();
		game.fx.blood(this);
		game.fx.bloodGround(xx,yy, game.hero);
		new en.Cadaver(cx,cy);
	}

	public function distance(e:Entity) {
		return Lib.distance(xx,yy, e.xx,e.yy);
	}

	public function setPos(x,y) {
		cx = x;
		cy = y;
	}

	public function setPosPixel(x:Float,y:Float) {
		cx = Std.int(x/Const.GRID);
		cy = Std.int(y/Const.GRID);
		xr = (x - cx*Const.GRID)/Const.GRID;
		yr = (y - cy*Const.GRID)/Const.GRID;
		updateSprite();
	}

	public function dirToMove(d:Int) {
		return switch( d ) {
			case 0 : {dx:0, dy:-1};
			case 1 : {dx:1, dy:0};
			case 2 : {dx:0, dy:1};
			case 3 : {dx:-1, dy:0};
			default : {dx:0, dy:0};
		}
	}

	public function toString() {
		return '${Type.getClass(this)}_$uid@$cx,$cy';
	}

	public function unregister() {
		ALL.remove(this);
		spr.dispose();
	}

	public function destroy() {
		if( destroyed )
			return;

		destroyed = true;
		spr.parent.removeChild(spr);
		KILL_LIST.push(this);
		setShadow(false);
	}


	public function updateSprite() {
		xx = (cx+xr) * Const.GRID;
		yy = (cy+yr) * Const.GRID;
		spr.x = Std.int(xx);
		spr.y = Std.int(yy-zz);
		if( shadow!=null ) {
			shadow.x = Std.int(xx);
			shadow.y = Std.int(yy-game.level.getHeight(cx,cy));
			shadow.visible = spr.visible;
		}
	}

	public function jump(?pow=1.0) {
		if( stable ) {
			jumpCounter = 0;
			dz = 4.5*pow;
			stable = false;
		}
	}


	public inline function getHeight(x,y) {
		return game.level.getHeight(x,y);
	}

	public inline function hasCollision(x,y) {
		return getHeight(x,y) > zz;
	}

	public function onPathStep() {
	}

	public function onLand() {
	}

	public inline function isMoving() {
		return dx!=0 || dy!=0; // || dz!=0 || !stable;
	}

	public function update() {
		if( !canBeFrozen || !game.isFrozen() ) {
			// Pathfinding
			if( game.running ) {
				while( path.length>0 && path[0].x==cx && path[0].y==cy ) {
					path.shift();
					onPathStep();
				}
				if( path.length>0 ) {
					var pt = path[0];
					if( getHeight(pt.x,pt.y)>getHeight(cx,cy) ) {
						if( jumpCounter++>=2 )
							jump();
					}
					else
						jumpCounter = 0;

					var s = (stable ? 1 : 0.6) * speed;
					var a = Math.atan2((pt.y+0.5)*Const.GRID - yy, (pt.x+0.5)*Const.GRID - xx);
					dx+=Math.cos(a)*s;
					dy+=Math.sin(a)*s;
				}
			}

			var wrepel = 0.07;

			// X management
			xr+=dx;
			dx*=frict;
			if( Math.abs(dx)<=0.0001 )
				dx = 0;

			if( collides ) {
				if( hasCollision(cx-1,cy) && xr<0.4 ) {
					if( xr<0.2 ) {
						dx = 0;
						xr = 0.2;
					}
					dx+=wrepel;
				}
				if( hasCollision(cx+1,cy) && xr>0.6 ) {
					if( xr>0.8 ) {
						dx = 0;
						xr = 0.8;
					}
					dx-=wrepel;
				}
			}
			while(xr>1) {
				xr--;
				cx++;
			}
			while(xr<0) {
				xr++;
				cx--;
			}

			// Y management
			yr+=dy;
			dy*=frict;
			if( Math.abs(dy)<=0.0001 )
				dy = 0;

			if( collides ) {
				if( hasCollision(cx,cy-1) && yr<0.3 ) {
					if( yr<0.2 ) {
						dy = 0;
						yr = 0.2;
					}
					dy+=wrepel;
				}
				if( hasCollision(cx,cy+1) && yr>0.6 ) {
					if( yr>0.7 ) {
						dy = 0;
						yr = 0.7;
					}
					dy-=wrepel;
				}
			}
			while(yr>1) {
				yr--;
				cy++;
			}
			while(yr<0) {
				yr++;
				cy--;
			}

			// Z management
			if( collides ) {
				var h = game.level.getHeight(cx,cy);
				if( dz!=0 || zz>h )
					stable = false;
				zz+=dz;
				if( !stable )
					dz-=gravity;
				dz*=0.9;
				if( dz<0 && zz<h ) {
					onLand();
					dz = 0;
					zz = h;
					stable = true;
				}
			}
		}

		updateSprite();
		if( game.running )
			cd.update();
	}
}