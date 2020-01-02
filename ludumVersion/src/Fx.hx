import flash.display.BlendMode;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;

import mt.deepnight.Particle;
import mt.deepnight.Lib;
import mt.deepnight.SpriteLibBitmap;
import mt.Color;

import Const;

class Fx {
	public static var ME : Fx;
	var game			: m.Game;
	var pt0				: flash.geom.Point;
	
	public function new() {
		ME = this;
		game = m.Game.ME;
		pt0 = new flash.geom.Point(0,0);
	}

	public function register(p:Particle, ?b:BlendMode) {
		game.buffer.dm.add(p, Const.DP_FX);
		p.blendMode = b!=null ? b : BlendMode.ADD;
	}
	
	inline function rnd(min,max,?sign) { return Lib.rnd(min,max,sign); }
	inline function irnd(min,max,?sign) { return Lib.irnd(min,max,sign); }
	
	public function flashBang(col:Int, a:Float, ms:Float) {
		var s = new Sprite();
		game.buffer.dm.add(s, Const.DP_FX);
		s.graphics.beginFill(col,a);
		s.graphics.drawRect(0,0,game.buffer.width,game.buffer.height);
		s.blendMode = BlendMode.ADD;
		game.tw.create(s, "alpha", 0, ms).onEnd = function() {
			s.parent.removeChild(s);
		}
	}
	
	public function alarmReason(x:Float,y:Float) {
		var p = new Particle(x,y-5);
		p.graphics.lineStyle(1,0xFFFF00,1);
		p.graphics.drawCircle(0,0,9);
		p.scaleX = p.scaleY = 2;
		p.ds = -0.2;
		p.life = 30;
		p.onUpdate = function() {
			p.ds*=0.8;
		}
		p.filters = [ new flash.filters.GlowFilter(0xFF8000,1, 8,8,2) ];
		register(p);
	}
	
	public function moveMarker(cx,cy) {
		var p = new Particle((cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
		p.graphics.lineStyle(1, 0x80FF00, 0.3);
		p.graphics.drawCircle(0,0, 7);
		p.scaleX = p.scaleY = 1.3;
		p.ds = -0.1;
		p.life = 0;
		p.onUpdate = function() {
			p.ds*=0.8;
		}
		register(p);
	}
	
	public function incorrect(cx,cy) {
		var p = new Particle((cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
		p.graphics.lineStyle(2, 0xFF0000, 1);
		p.graphics.moveTo(-5,-5);
		p.graphics.lineTo(5,5);
		p.graphics.moveTo(-5,5);
		p.graphics.lineTo(5,-5);
		
		p.scaleX = p.scaleY = 1.3;
		p.ds = -0.1;
		p.life = 0;
		p.onUpdate = function() {
			p.ds*=0.8;
		}
		register(p);
	}
	
	public function marker(cx,cy) {
		var p = new Particle((cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
		p.drawCircle(5, 0xFFFF00, 0.5);
		p.life = 5;
		register(p);
	}
	
	public function smokeStep(x,y) {
		for(i in 0...irnd(1,3)) {
			var p = new Particle(x+rnd(0,1,true),y+rnd(0,1,true));
			p.drawBox(rnd(1,2), rnd(1,2), 0xE3D8BB, 1);
			p.life = rnd(6,15);
			p.gx = rnd(0.01, 0.03, true);
			p.gy = -rnd(0.02, 0.05);
			p.alpha = rnd(0.1, 0.3);
			//p.filters = [ new flash.filters.GlowFilter(0xC0C0C0, 0.7, 2,2,2) ];
			p.filters = [ new flash.filters.BlurFilter(2,2) ];
			register(p, BlendMode.NORMAL);
		}
	}

	public function ghostMark(x,y, s:BSprite) {
		var sc = s.clone();
		sc.scaleX = s.scaleX;
		var p = new Particle(x,y);
		p.addChild(sc);
		p.alpha = 0.2;
		p.life = rnd(2,5);
		register(p, BlendMode.OVERLAY);
	}
	
	public function blood(e:Entity) {
		for(i in 0...irnd(20,30)) {
			var p = new Particle(e.xx+rnd(0,4,true), e.yy);
			p.drawBox(2, rnd(1,2), 0xAA0000, rnd(0.5, 1));
			p.dy = -rnd(1, 8);
			p.gy = rnd(0.3, 0.4);
			p.frictX = p.frictY = 0.9;
			p.groundY = p.y+rnd(0,5,true);
			p.bounce = 0.95;
			p.dr = rnd(0,5,true);
			var once = false;
			p.onBounce = function() {
				p.dy = 0;
				p.gy = 0;
				if( !once )
					p.dx = rnd(0,2,true);
				once = true;
			}
			register(p, BlendMode.NORMAL);
		}
	}
	
	public function bloodGround(x,y, origin:Entity) {
		var s = game.tiles.get("blood");
		s.setCenter(0.5,0.5);
		
		var ct = new flash.geom.ColorTransform();
		ct.color = 0x5B1E35;
		
		var bd = game.level.groundBmp.bitmapData;
		for(i in 0...irnd(8,10)) {
			if( i==0 ) {
				s.x = x;
				s.y = y;
			}
			else {
				ct.alphaMultiplier = rnd(0.3,0.5);
				s.x = x + rnd(0,16,true);
				s.y = y + rnd(0,16,true);
			}
			s.rotation = rnd(0,360);
			s.scaleX = s.scaleY = rnd(0.4,1.5);
			bd.draw(s, s.transform.matrix, ct, BlendMode.OVERLAY);
		}
		s.destroy();
		
		var s = game.tiles.get("bloodLine");
		s.setCenter(1,0.5);
		ct.alphaMultiplier = 1;
		s.x = x;
		s.y = y;
		s.scaleX = s.scaleY = rnd(0.9, 1.5);
		s.rotation = Lib.deg( Math.atan2(origin.yy-y, origin.xx-x) );
		bd.draw(s, s.transform.matrix, ct, BlendMode.OVERLAY);
		s.destroy();
		
		game.level.cropMap();
	}
	
	public function bloodSteps(x:Float,y:Float, alpha:Float) {
		var s = new Sprite();
		s.graphics.beginFill(0x5B1E35, 1);
		s.graphics.drawRect(-1,0,2,rnd(1,2));
		s.x = game.time%2==0 ? x-rnd(1,2) : x+rnd(1,2);
		s.y = game.time%2==0 ? y-1 : y+1;
		s.rotation = rnd(0,30,true);
		
		var ct = new flash.geom.ColorTransform();
		ct.color = 0x5B1E35;
		ct.alphaMultiplier = rnd(0.5, 1)*alpha;
		
		var bd = game.level.groundBmp.bitmapData;
		bd.draw(s, s.transform.matrix, ct, BlendMode.OVERLAY);
	}
	
	public function multiHits(e:Entity) {
		var base = rnd(0,6.28);
		for(i in 0...irnd(5,8)) {
			var a = base + rnd(0, 1, true);
			var spd = rnd(3,8);
			var p = new Particle(e.xx-Math.cos(a)*10,e.yy-Math.sin(a)*10);
			var s = game.tiles.getRandom("slash");
			p.addChild(s);
			s.setCenter(0.5,0.5);
			p.dx = Math.cos(a)*spd;
			p.dy = Math.sin(a)*spd;
			p.scaleX = p.scaleY = rnd(0.7, 1);
			p.frictX = p.frictY = 0.7;
			p.rotation = Lib.deg(a);
			p.alpha = rnd(0.5, 1);
			p.life = rnd(0,2);
			p.delay = i+rnd(1,2);
			p.filters = [ new flash.filters.GlowFilter(0xFF6C00,1, 16,16,3, 2) ];
			register(p);
		}
	}

	public function pop(e:Entity, str:String) {
		var p = new Particle(e.xx, e.yy-5);
		var tf = game.createField(str);
		p.addChild(tf);
		tf.x = Std.int(-tf.width*0.5);
		//p.dx = rnd(0,1,true);
		p.dy = -rnd(4,5);
		p.life = rnd(25,35);
		p.frictX = p.frictY = 0.8;
		register(p);
	}

	public function score(cx:Int, cy:Int, str:Dynamic) {
		var p = new Particle(Std.int(cx+0.5)*Const.GRID, Std.int(cy+0.5)*Const.GRID);
		var tf = game.createField(str);
		p.addChild(tf);
		tf.textColor = Color.makeColor(game.time/100, 0.6, 1);
		tf.filters = [ new flash.filters.GlowFilter(0x0,1, 2,2, 4) ];
		tf.x = -Std.int(tf.textWidth*0.5);
		p.life = rnd(15,20);
		p.alpha = 0;
		p.da = 0.1;
		p.dy = 2;
		p.frictY = 0.8;
		register(p, BlendMode.NORMAL);
	}

	public function update() {
		Particle.update();
	}
}
