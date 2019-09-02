package en;
import mt.flash.Key;
import flash.ui.Keyboard;
import mt.deepnight.Lib;
import mt.flash.Sfx;
import Const;

class Hero extends Entity {
	static var BLOOD_STEPS = 40;
	public static var LIGHTNING_RADIUS = 5;
	public var dir		: Int;
	var lightning		: flash.display.Bitmap;
	var bloodSteps		: Int;
	public var ammo		: Int;
	
	public function new() {
		super();
		dir = 1;
		setLife(3);
		setPos(20,2);
		frict = 0.3;
		speed*=6;
		game.buffer.dm.add(spr, Const.DP_HERO);
		spr.playAnim("ninjaJump");
		bloodSteps = 0;
		setShadow(true);
		ammo = 3;
		
		lightning = new flash.display.Bitmap( new flash.display.BitmapData(Const.GRID*(LIGHTNING_RADIUS*2+1), Const.GRID*(LIGHTNING_RADIUS*2+1), true, 0x0) );
		lightning.blendMode = flash.display.BlendMode.OVERLAY;
		lightning.filters = [ new flash.filters.BlurFilter(16,16) ];
		game.buffer.dm.add(lightning, Const.DP_BG);
		
		updateLightning();
		updateSprite();
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
		var pts = [];
		var sees = Lib.bresenhamCheck(cx,cy,x,y, function(x,y) {
			pts.push({x:x,y:y});
			return getHeight(x,y)<=10;
		});
		if( sees ) {
			if( pts[0].x!=cx || pts[0].y!=cy )
				pts.reverse();
			path = pts;
			Fx.ME.moveMarker(x,y);
		}
		else {
			super.goto(x,y);
			if( path.length>0 )
				Fx.ME.moveMarker(x,y);
		}
	}
	
	override function destroy() {
		if( destroyed )
			return;
			
		lightning.parent.removeChild(lightning);
		lightning.bitmapData.dispose();
		super.destroy();
	}
	
	
	public function shoot(x:Float,y:Float) {
		if( ammo>0 && !cd.has("shoot") ) {
			var tcx = Std.int(x/Const.GRID);
			var tcy = Std.int(y/Const.GRID);
			var sees = Lib.bresenhamCheck(cx,cy,tcx,tcy, function(x,y) {
				return getHeight(x,y)<=10;
			});
			if( !sees )
				game.fx.incorrect(tcx,tcy);
			else {
				cd.set("shoot",Const.SHURIKEN_CD);
				ammo--;
				new en.Shuriken(this,x,y);
				jump(0.4);
			}
		}
	}
	
	
	public function onRuleOverride() {
		if( cd.has("ruleImmunity") )
			return;
			
		cd.set("ruleImmunity", Const.FPS*1.5);
		hit(1);
	}
	
	public function onAttack() {
		stop();
		jump(0.7);
		bloodSteps = BLOOD_STEPS;
	}
	
	
	override function jump(?p:Float) {
		super.jump(p);
		spr.playAnim("ninjaJump");
	}
	
	
	override function updateSprite() {
		super.updateSprite();
		spr.scaleX = dir;
		if( lightning!=null ) {
			lightning.x = (cx-LIGHTNING_RADIUS)*Const.GRID;
			lightning.y = (cy-LIGHTNING_RADIUS)*Const.GRID;
		}
	}
	
	public function updateLightning() {
		lightning.alpha = 0.5;
		var bd = lightning.bitmapData;
		bd.fillRect(bd.rect,0x0);
		for(dx in -LIGHTNING_RADIUS...LIGHTNING_RADIUS+1)
			for(dy in -LIGHTNING_RADIUS...LIGHTNING_RADIUS+1)
				if( Lib.distance(cx,cy, cx+dx,cy+dy)<=LIGHTNING_RADIUS && sightCheckCoord(cx+dx,cy+dy) )
					bd.fillRect( new flash.geom.Rectangle((LIGHTNING_RADIUS+dx)*Const.GRID, (LIGHTNING_RADIUS+dy)*Const.GRID, Const.GRID, Const.GRID), 0xffFFFFFF);
	}
	
	public function onCaught() {
		stop();
		spr.playAnim("ninjaCaught",1);
	}
	
	public function onWin() {
		stop();

		spr.playAnim("ninjaStand");
		game.delayer.add(function() {
			spr.playAnim("ninjaWin", 1);
			game.fx.pop(this, "Take that, bourgeois.");
		}, 500);
	}
	
	override function onLand() {
		super.onLand();
		Mode.SBANK.land01(0.7);
	}
	
	override function update() {
		var old = {cx:cx,cy:cy}
		super.update();
		
		if( !cd.has("stun") ) {
			var next = path[0];
			if( next!=null ) {
				if( stable )
					if( jumpCounter<=0 )
						spr.playAnim("ninjaRun");
					else
						spr.playAnim("ninjaStand");
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
					Sfx.playOne([Mode.SBANK.step01, Mode.SBANK.step03], 0.7);
				}
			}
			else
				if( stable && !game.gameOver)
					spr.playAnim("ninjaStand");
		}
				
		if( cx!=old.cx || cy!=old.cy ) {
			updateLightning();
		}
	}
}

