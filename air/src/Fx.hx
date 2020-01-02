import flash.display.BlendMode;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;

import mt.deepnight.Color;
import mt.deepnight.T;
import mt.deepnight.FParticle;
import mt.deepnight.Lib;
import mt.deepnight.slb.BSprite;
import mt.MLib;

import Const;

class Fx {
	public static var ME : Fx;

	var lastSlash		: Null<{x:Float, y:Float}>;
	var pt0				: flash.geom.Point;
	var mode			: BaseProcess;
	var pool			: mt.deepnight.BitmapDataPool;

	public function new(m:BaseProcess) {
		ME = this;
		pt0 = new flash.geom.Point(0,0);
		mode = m;
		pool = new mt.deepnight.BitmapDataPool();


		var s = new Sprite();
		var col = 0xFF0000;
		s.graphics.beginFill(col,1);
		s.graphics.drawRect(0,0, 20,2);
		s.graphics.beginFill(col,0.6);
		s.graphics.drawRect(0,4, 20,1);
		s.filters = [
			new flash.filters.BlurFilter(16,0),
			new flash.filters.GlowFilter(col,0.6, 8,8,4),
		];
		pool.addDisplayObject("shurikenTrail", s, 16);

		pool.addBitmapData("bang", new BitmapData(100,100,true, 0x0));
	}

	public function clear() {
		FParticle.clearAll();
	}

	public function register(p:FParticle, ?b:BlendMode) {
		m.Game.ME.sdm.add(p, Const.DP_FX);
		p.blendMode = b!=null ? b : BlendMode.ADD;
	}

	inline function rnd(min,max,?sign) { return Lib.rnd(min,max,sign); }
	inline function irnd(min,max,?sign) { return Lib.irnd(min,max,sign); }


	public function onResize() {
	}

	public function destroy() {
		pool.destroy();
	}

	inline function getFreezeTimer() {
		return mode.cd.get("freeze");
	}


	public function flashBang(col:Int, a:Float, ms:Float) {
		var p = new mt.deepnight.FParticle(0,0);
		p.blendMode = ADD;
		var bmp = p.useBitmapData( pool.get("bang"), false);
		bmp.x = bmp.y = 0;
		bmp.width = mode.buffer.width;
		bmp.height = mode.buffer.height;
		bmp.bitmapData.fillRect(bmp.bitmapData.rect, Color.addAlphaF(col,a));
		p.life = 0;
		p.fadeOutSpeed = 1 / (Const.FPS * ms/1000);
		mode.buffer.dm.add(p, Const.DP_FX_FLASH);
	}


	public function alarmReason(x:Float,y:Float) {
		var p = new FParticle(x,y-5);
		p.useBitmapData( pool.getOrCreate("alarm", function() {
			var s = new Sprite();
			s.graphics.lineStyle(2,0xFFFF00,1);
			s.graphics.drawCircle(0,0,18);
			s.filters = [ new flash.filters.GlowFilter(0xFF8000,1, 8,8,2) ];
			return [s];
		}, 8), false );

		p.scaleX = p.scaleY = 1;
		p.ds = -0.1;
		p.life = 30;
		p.onUpdate = function() {
			p.ds*=0.8;
		}

		register(p);
	}

	public function moveMarker(cx,cy, isTarget:Bool) {
		var p = new FParticle((cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
		p.useBitmapData( pool.getOrCreate("moveMarker"+isTarget, function() {
			var s = new Sprite();
			var col = isTarget ? 0xFF0000 : 0x80FF00;
			s.graphics.lineStyle(2, col, 0.3);
			s.graphics.drawCircle(0,0,12);
			s.filters = [ new flash.filters.GlowFilter(col,1, 8,8,2) ];
			return [s];
		}, 8), false );

		//p.graphics.lineStyle(1, 0x80FF00, 0.3);
		//p.graphics.drawCircle(0,0, 7);
		p.scaleX = p.scaleY = 0.7;
		p.ds = 0.1;
		p.life = 0;
		p.onUpdate = function() {
			p.ds*=0.8;
		}
		register(p);
	}

	public function incorrect(cx,cy) {
		var p = new FParticle((cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
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
		var p = new FParticle((cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
		p.drawCircle(5, 0xFFFF00, 0.5);
		p.life = 5;
		register(p);
	}

	public function smokeStep(x,y) {
		for(i in 0...irnd(1,3)) {
			var p = new FParticle(x+rnd(0,1,true),y+rnd(0,1,true));
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
		var sc : BSprite = s.clone();
		sc.scaleX = s.scaleX;
		var p = new FParticle(x,y);
		p.addChild(sc);
		p.alpha = 0.2;
		p.life = rnd(2,5);
		register(p, BlendMode.OVERLAY);
	}

	public function blood(e:Entity) {
		for(i in 0...irnd(20,30)) {
			var p = new FParticle(e.xx+rnd(0,4,true), e.yy);
			p.useBitmapData( pool.getOrCreate("blood", function() {
				var s = new Sprite();
				s.graphics.beginFill(0xFF0000, 1);
				s.graphics.drawRect(-1,-2, 3, 4);
				s.filters = [
					new flash.filters.DropShadowFilter(2,90, 0x6C0000,1, 0,0,1, 1,true),
					new flash.filters.GlowFilter(0x2D0000,1,2,2,4),
				];
				return [s];
			}, 3), false );
			p.drawBox(2, rnd(1,3), 0xFF0000, rnd(0.7, 1));
			if( i<=5 ) {
				p.dx = rnd(0, 2, true);
				p.dy = -rnd(12, 18);
			}
			else {
				p.dx = rnd(0, 4, true);
				p.dy = -rnd(1, 8);
			}
			p.gy = rnd(0.3, 0.4);
			p.frictX = p.frictY = 0.9;
			p.groundY = p.y+rnd(0,5,true);
			p.scaleY = rnd(0.5, 1);
			p.bounce = 0.95;
			p.dr = rnd(0,5,true);
			p.life = rnd(10,30);
			p.delay = i<5 ? 0 : getFreezeTimer();
			var once = false;
			p.onBounce = function() {
				p.dy = 0;
				p.gy = 0;
				if( !once )
					p.dx = (p.dx>0 ? 1 : -1) * rnd(0,1);
				once = true;
			}
			register(p, BlendMode.NORMAL);
		}
	}

	public function bloodGround(x,y, origin:Entity) {
		var s = m.Game.ME.tiles.get("blood");
		s.setCenter(0.5,0.5);

		var ct = new flash.geom.ColorTransform();
		ct.color = 0x5B1E35;

		var bd = m.Game.ME.level.groundBmp.bitmapData;
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
		s.dispose();

		var s = m.Game.ME.tiles.get("bloodLine");
		s.setCenter(1,0.5);
		ct.alphaMultiplier = 1;
		s.x = x;
		s.y = y;
		s.scaleX = s.scaleY = rnd(0.9, 1.5);
		s.rotation = MLib.toDeg( Math.atan2(origin.yy-y, origin.xx-x) );
		bd.draw(s, s.transform.matrix, ct, BlendMode.OVERLAY);
		s.dispose();

		m.Game.ME.level.cropMap();
	}

	public function bloodSteps(x:Float,y:Float, alpha:Float) {
		var s = new Sprite();
		s.graphics.beginFill(0x5B1E35, 1);
		s.graphics.drawRect(-1,0,2,rnd(1,2));
		s.x = m.Game.ME.time%2==0 ? x-rnd(1,2) : x+rnd(1,2);
		s.y = m.Game.ME.time%2==0 ? y-1 : y+1;
		s.rotation = rnd(0,30,true);

		var ct = new flash.geom.ColorTransform();
		ct.color = 0x5B1E35;
		ct.alphaMultiplier = rnd(0.5, 1)*alpha;

		var bd = m.Game.ME.level.groundBmp.bitmapData;
		bd.draw(s, s.transform.matrix, ct, BlendMode.OVERLAY);
	}

	public function multiHits(e:Entity) {
		var base = rnd(0,6.28);
		for(i in 0...irnd(5,8)) {
			var a = base + rnd(0, 1, true);
			var spd = rnd(3,8);
			var p = new FParticle(e.xx-Math.cos(a)*10,e.yy-Math.sin(a)*10);
			var s = m.Game.ME.tiles.getRandom("slash");
			p.addChild(s);
			s.setCenter(0.5,0.5);
			p.dx = Math.cos(a)*spd;
			p.dy = Math.sin(a)*spd;
			p.scaleX = p.scaleY = rnd(0.7, 1);
			p.frictX = p.frictY = 0.7;
			p.rotation = MLib.toDeg(a);
			p.alpha = rnd(0.5, 1);
			p.life = rnd(0,2);
			p.delay = i+rnd(1,2);
			p.filters = [ new flash.filters.GlowFilter(0xFF6C00,1, 16,16,3, 2) ];
			register(p);
		}
	}

	public function popMessage(e:Entity, str:String) {
		var p = new FParticle(e.xx, e.yy-5);
		var tf = m.Game.ME.createField(str);
		p.addChild(tf);
		tf.x = Std.int(-tf.width*0.5);
		p.dy = -rnd(4,5);
		p.life = rnd(25,35);
		p.frictX = p.frictY = 0.8;
		register(p, NORMAL);
	}

	public function shurikenTrail(e:en.Shuriken) {
		var a = Math.atan2(e.dy, e.dx);
		var p = new FParticle(e.xx-Math.cos(a)*10, e.yy-Math.sin(a)*10 - 4);
		p.useBitmapData( pool.get("shurikenTrail"), false );
		p.rotation = MLib.toDeg(a);
		p.scaleY = Lib.sign();
		p.life = 2;
		p.fadeOutSpeed = 0.25;
		register(p);
	}

	public function clearSlash() {
		lastSlash = null;
	}

	public function slash(x,y, available) {
		if( lastSlash!=null && (lastSlash.x!=x || lastSlash.y!=y) ) {
			var p = new FParticle(x,y);
			var a = Math.atan2(lastSlash.y-y, lastSlash.x-x);
			var d = Lib.distance(lastSlash.x, lastSlash.y, x,y);

			if( available )
				p.graphics.lineStyle(1, 0xFFFF00, 1, true, flash.display.LineScaleMode.NONE);
			else
				p.graphics.lineStyle(1, 0x3068CF, 1, true, flash.display.LineScaleMode.NONE);

			p.graphics.moveTo(0,0);
			p.graphics.lineTo(d,0);

			if( available )
				p.filters = [ new flash.filters.GlowFilter(0xFF6000,1, 16,16,8) ];
			else
				p.filters = [ new flash.filters.GlowFilter(0x3068CF,1, 16,16,8) ];

			p.rotation = MLib.toDeg(a);
			p.life = 2;
			register(p);
		}
		lastSlash = {x:x, y:y}
	}


	public function freezeGhost(e:en.Mob, d) {
		var bmp = Lib.flatten(e.spr);
		var bd = bmp.bitmapData;
		bmp.bitmapData = null;
		bd.applyFilter(bd, bd.rect, pt0, Color.getColorizeFilter(e.toBeKilled ? 0x00FF00 : 0xFF0000,1,0));
		bd.applyFilter(bd, bd.rect, pt0, new flash.filters.BlurFilter(4,4));
		var p = new FParticle(e.xx, e.yy);
		var bmp = p.useBitmapData(bd,true);
		bmp.y = -bmp.height;
		p.scaleX = e.spr.scaleX*1.2;
		p.scaleY = 1.2;
		p.life = d;
		register(p);
	}

	public function itemGlow(e:en.Item, col:Int) {
		if( !pool.exists("shine"+col) ) {
			var s = new Sprite();
			s.graphics.beginFill(Color.brightnessInt(col,0.5), 1);
			s.graphics.drawRect(0,0,1,1);
			s.filters = [
				new flash.filters.GlowFilter(col, 0.3, 2,2,8),
				new flash.filters.GlowFilter(col, 0.7, 8,8,2),
			];
			pool.addDisplayObject("shine"+col, s, 8);
		}

		var p = new FParticle(e.xx+rnd(0,4,true), e.yy+rnd(0,5,true));
		p.useBitmapData( pool.get("shine"+col), false );
		p.alpha = rnd(0.25, 1);
		p.gy = -rnd(0.1,0.2);
		p.dx = rnd(0, 0.4, true);
		p.frictY = 0.7;
		p.frictX = 0.95;
		p.life = rnd(10, 30);
		register(p);
	}


	public function timeBonus(v:Int) {
		var c = 0xFFFF00;
		var pt = mode.buffer.globalToLocal(5, 20);

		var p = new FParticle(pt.x-m.Game.ME.scroller.x, pt.y-m.Game.ME.scroller.y);

		var tf = m.Game.ME.createField( T.get("Speed bonus:")+" "+v );
		p.addChild(tf);
		tf.textColor = c;
		tf.filters = [ new flash.filters.GlowFilter(c, 0.5, 8,8, 3) ];

		p.life = 27;
		p.alpha = 0;
		p.da = 0.1;
		if( m.Game.ME.hasChrono() )
			p.dy = 5;
		p.frictY = 0.6;
		register(p, ADD);
	}

	public function score(cx:Int, cy:Int, str:Dynamic, big:Bool) {
		var c = 0x00ACFF;

		var p = new FParticle(Std.int(cx+0.5)*Const.GRID, Std.int(cy+0.5)*Const.GRID);

		p.useBitmapData( pool.getOrCreate("score"+str+big, function() {
			var s = new Sprite();
			var tf = m.Game.ME.createField("+"+str);
			s.addChild(tf);
			if( big )
				tf.scaleX = tf.scaleY = 2;
			tf.textColor = c;
			tf.filters = [ new flash.filters.GlowFilter(c, 0.5, 8,8, 3) ];
			tf.x = -Std.int(tf.width*0.5);
			return [s];
		}, 8), false );

		p.life = rnd(25,30);
		p.alpha = 0;
		p.da = 0.1;
		p.dy = -rnd(7,9);
		p.frictY = 0.8;
		register(p, ADD);
	}

	public function combo(cx:Int, cy:Int, n:Int) {
		var c = 0xFFFF00;

		var p = new FParticle(Std.int(cx+0.5)*Const.GRID, Std.int(cy+0.5)*Const.GRID-10);

		p.useBitmapData( pool.getOrCreate("combo"+n, function() {
			var s = new Sprite();
			var tf = m.Game.ME.createField("x"+n);
			s.addChild(tf);
			tf.textColor = c;
			tf.filters = [ new flash.filters.GlowFilter(c,0.5, 8,8, 3) ];
			tf.scaleX = tf.scaleY = 2;
			return [s];
		}, 8), false );

		p.life = rnd(25,30);
		p.alpha = 0;
		p.da = 0.1;
		p.dx = -rnd(10,15);
		p.frict = 0.8;
		register(p);
	}

	/*
	public function firePeak(s:BSprite, w,h) {
		var p = new FParticle( rnd(100,w), rnd(h+10, h+30) );
		s.setCenter(0.2,0.5);
		p.addChild(s);
		p.onKill = function() {
			s.destroy();
		}
		p.da = 0.2;
		p.alpha = 0;
		p.rotation = -rnd(20,45);
		p.scaleX = rnd(0.3, 0.5);
		p.scaleY = rnd(0.7, 1);
		p.filters = [ new flash.filters.GlowFilter(0xFF6600,1, 32,32, 2) ];
		p.blendMode = ADD;
		p.ds = rnd(0.001, 0.008, true);
		p.frict = 0.96;
		p.life = rnd(20,30);
		m.Intro.ME.buffer.dm.add(p, Const.DP_FX);
	}

	public function fireBase(s:BSprite, w,h) {
		var p = new FParticle( rnd(-50,w), rnd(h+5, h+10) );
		s.setCenter(0.2,0.5);
		p.addChild(s);
		p.onKill = function() {
			s.destroy();
		}
		p.da = 0.4;
		p.alpha = 0;
		p.rotation = rnd(5,10, true);
		p.scaleX = rnd(0.3, 0.6);
		p.scaleY = rnd(0.3, 0.6);
		p.filters = [ new flash.filters.GlowFilter(0xFF6600,1, 16,16, 2) ];
		p.blendMode = ADD;
		p.ds = rnd(0.001, 0.002);
		//p.gy = rnd(0, 0.03, true);
		p.frict = 0.96;
		p.life = rnd(20,40);
		m.Intro.ME.buffer.dm.add(p, Const.DP_FX);
	}
	*/

	public function introFire(w,h) {
		// Main
		for(i in 0...2) {
			var x = w - rnd(-50, 200);
			var y = 10 + h + (1-x/w)*30;
			var p = new FParticle(x,y);

			var s = m.Intro.ME.tiles.getRandom("fire");
			s.setCenter(0.5, 0.5);
			p.addChild(s);

			p.scaleX = p.scaleY = rnd(1, 2);
			p.rotation = 60 + rnd(0,20,true);
			p.dx = -rnd(0.2, 1);
			p.dy = -rnd(0.3, 2);
			p.frict = rnd(0.95, 0.96);
			p.alpha = 0;
			p.da = rnd(0.2, 0.3);
			p.ds = -rnd(0.020, 0.030);
			p.onKill = function() s.dispose();
			p.blendMode = ADD;
			p.life = rnd(20, 30);

			m.Intro.ME.buffer.dm.add(p, Const.DP_FX);
		}

		// Sparks
		if( Std.random(100)<15 )
			for(i in 0...irnd(1,3)) {
				var p = new FParticle(w-rnd(-50, 200), h);

				var s = m.Intro.ME.tiles.getRandom("fireSpark");
				s.setCenter(0.5, 0.5);
				p.addChild(s);

				p.dx = rnd(-4, 4);
				p.dy = -rnd(2, 8);
				p.gx = -rnd(0.04, 0.25);
				p.frictX = rnd(0.90, 0.95);
				p.frictY = rnd(0.95, 0.96);
				p.onKill = function() s.dispose();
				p.blendMode = ADD;
				p.life = rnd(5, 45);

				m.Intro.ME.buffer.dm.add(p, Const.DP_FX);
			}
	}

	public function sleep(x:Float,y:Float) {
		for( i in 0...irnd(2,4) ) {
			var p = new FParticle(x+rnd(0,2,true),y-rnd(23,27));

			p.useBitmapData( pool.getOrCreate("sleep", function() {
				var tf = mode.createField("z");
				return [tf];
			}, 8), false );

			p.alpha = rnd(0.5, 0.8);
			p.dx = rnd(0.1, 0.5);
			p.dy = -rnd(0.5, 0.8);
			p.frict = 0.96;
			p.life = rnd(10,30);
			p.delay = i*rnd(7,10) + rnd(0,1);

			register(p);
		}
	}

	public function update() {
		FParticle.update();
	}
}
