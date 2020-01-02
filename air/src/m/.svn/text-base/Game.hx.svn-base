package m;

import Const;

import mt.flash.Sfx;
import mt.deepnight.slb.BSprite;
import mt.deepnight.Lib;
import mt.deepnight.T;
import mt.deepnight.mui.*;
import mt.deepnight.Color;
import mt.MLib;
import mt.Metrics;
import mt.flash.Key;
import flash.ui.Keyboard;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;


class Game extends BaseProcess { //}
	public static var ME : Game;

	public var scroller		: Sprite;
	public var sdm			: mt.flash.DepthManager;
	public var hero			: en.Hero;
	public var level		: Level;
	public var cm			: mt.deepnight.Cinematic;

	var gameOverDelayer		: mt.Delayer;

	public var seed			: Int;
	public var combo		: Int;
	public var roundScore	: Int;
	public var globalScore	: Int;
	public var hud			: ui.Hud;
	public var chrono		: Int;
	public var roundDuration: Int;
	public var cursor		: Sprite;
	public var lid			: Int;
	public var mode			: GameMode;

	public var viewport		: {x:Float, y:Float, wid:Int, hei:Int, dx:Float, dy:Float};

	public var running		: Bool;
	public var gameOver		: Bool;
	var curMessage			: Null<{bmp:Bitmap, bg:Sprite}>;
	var guide				: Null<{bg:Sprite, bmp:Bitmap}>;
	var fmask				: Bitmap;
	var tbMask				: Bitmap;
	//var drag				: Null<{x:Float, y:Float, active:Bool}>;

	public function new(startLevel:Int, m:GameMode) {
		super();

		mode = m;
		ME = this;
		roundScore = 0;
		globalScore = 0;
		combo = 0;
		lid = startLevel;
		seed = 1866;
		gameOver = false;
		gameOverDelayer = new mt.Delayer(Const.FPS);
		running = false;
		cm = new mt.deepnight.Cinematic(Const.FPS);

		roundDuration = Const.ROUND_DURATION_HARD;
		//roundDuration = switch( diff ) {
			//case Normal : Const.ROUND_DURATION_NORMAL;
			//case Hard : Const.ROUND_DURATION_HARD;
		//}

		viewport = {x:0, y:0, wid:buffer.width, hei:buffer.height, dx:0, dy:0}

		scroller = new Sprite();
		buffer.dm.add(scroller, Const.DP_BG);
		sdm = new mt.flash.DepthManager(scroller);

		level = new Level(lid);
		sdm.add(level.wrapper, Const.DP_BG);
		level.renderGame();

		// UI
		hud = new ui.Hud();

		// Cursor
		cursor = new Sprite();
		sdm.add(cursor, Const.DP_BG);
		cursor.graphics.lineStyle(1,0xFF0000,0.5);
		cursor.graphics.drawRect(1,1,Const.GRID-2,Const.GRID-2);
		cursor.visible = false;

		// Freeze mask
		fmask = new Bitmap( new BitmapData(300,200, false, 0x5769BD) );
		buffer.dm.add(fmask, Const.DP_FMASK);
		fmask.blendMode = MULTIPLY;
		var bd = new BitmapData(300,200,false,0x0);
		bd.perlinNoise(64,32, 3, 1866, false, true, 1,true);
		bd.applyFilter(bd, bd.rect, pt0, Color.getContrastFilter(0.3));
		fmask.bitmapData.draw(bd, flash.display.BlendMode.OVERLAY);
		bd.dispose();
		bd = null;
		fmask.visible = false;

		// Turn based mask
		tbMask = new Bitmap( new BitmapData(300,200, false, 0x4B525C) );
		sdm.add(tbMask, Const.DP_TBMASK);
		var bd = new BitmapData(300,200,false,0x0);
		bd.perlinNoise(64,32, 3, 1866, false, true, 1,true);
		bd.applyFilter(bd, bd.rect, pt0, Color.getContrastFilter(0.4));
		tbMask.bitmapData.draw(bd, new flash.geom.ColorTransform(1,1,1, 0.7), flash.display.BlendMode.OVERLAY );
		bd.dispose();
		bd = null;
		tbMask.visible = mode==TurnBased;


		// ATTENTION : penser au removeEvent dans destroy() !!!
		root.addEventListener(flash.events.MouseEvent.MOUSE_MOVE, onMouseMove);
		root.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, onMouseDown);
		root.stage.addEventListener(flash.events.MouseEvent.MOUSE_UP, onMouseUp);
		root.stage.addEventListener(flash.events.Event.MOUSE_LEAVE, onLeave);
		root.stage.addEventListener(flash.events.MouseEvent.RELEASE_OUTSIDE, onLeave);

		root.alpha = 0;
		tw.create(root.alpha, 1, 1000);

		initRound(true);

		onResize();
	}

	public function focusViewport(e:Entity) {
		var s = 1.5;
		e.updateSprite();

		var vx = viewport.x + viewport.wid*0.5;
		var vy = viewport.y + viewport.hei*0.5;

		var tx = e.xx;
		var ty = e.yy;

		if( en.Mob.ALL.length>0 ) {
			var mx = 0.;
			var my = 0.;
			for(e in en.Mob.ALL) {
				mx+=e.xx;
				my+=e.yy;
			}
			mx/=en.Mob.ALL.length;
			my/=en.Mob.ALL.length;
			tx = (e.xx*2 + mx*1) / 3;
			ty = (e.yy*2 + my*1) / 3;
		}


		var d = Lib.distanceSqr(tx, ty, vx ,vy);
		if( d >= MLib.pow( 10, 2 ) ) {
			var a = Math.atan2( ty - vy, tx - vx );
			viewport.dx += Math.cos(a)*s;
			viewport.dy += Math.sin(a)*s;
			//viewport.x = (e.cx+0.5)*Const.GRID - viewport.wid*0.5;
			//viewport.y = (e.cy+0.5)*Const.GRID - viewport.hei*0.5;
			//viewport.dx = viewport.dy = 0;
		}
	}

	public function focusViewportImmediatly(e:Entity) {
		viewport.x = (e.cx+0.5)*Const.GRID - viewport.wid*0.5;
		viewport.y = (e.cy+0.5)*Const.GRID - viewport.hei*0.5;
		viewport.dx = viewport.dy = 0;
	}

	public function onGameOver(?d=1000, ?bypass=false) {
		if( gameOver && !bypass )
			return;

		endFreeze();
		gameOver = true;
		running = false;
		hero.onCaught();
		gameOverDelayer.cancelEverything();
		gameOverDelayer.add(function() initRound(), d);
	}

	override function onResize() {
		super.onResize();

		if( viewport!=null ) {
			viewport.wid = buffer.width;
			viewport.hei = buffer.height;

			hud.onResize();

			fmask.width = buffer.width+6;
			fmask.height = buffer.height+6;
		}
	}

	override function unregister() {
		root.stage.removeEventListener(flash.events.Event.MOUSE_LEAVE, onLeave);
		root.stage.removeEventListener(flash.events.MouseEvent.RELEASE_OUTSIDE, onLeave);
		root.stage.removeEventListener(flash.events.MouseEvent.MOUSE_UP, onMouseUp);

		super.unregister();

		level.destroy();

		hud.destroy();
		fmask.bitmapData.dispose(); fmask.bitmapData = null;
		tbMask.bitmapData.dispose(); tbMask.bitmapData = null;

		for(e in Entity.ALL)
			e.destroy();

		while(Entity.KILL_LIST.length>0)
			Entity.KILL_LIST.splice(0,1)[0].unregister();
	}

	public function onReset() {
		fx.flashBang(0xFFFFFF,0.3, 1500);
		onGameOver(200, true);
	}

	public function onQuit() {
		pause();
		destroy();
		new Intro();
	}

	public function onEditor() {
		destroy();
		new Editor(lid);
	}

	override function onMenuKey() {
		super.onMenuKey();
		hud.onMenu();
	}

	override function onActivate() {
		super.onActivate();
		hud.hideMenu();
	}


	override function onBackKey() {
		super.onBackKey();
		hud.onMenu();
	}

	public function onWin() {
		if( gameOver )
			return;

		announce( T.get("Level complete") );
		gameOver = true;
		running = false;
		hero.onWin();

		var time = getRemainingTimeMs();

		// Save progress
		var mcookie = getModeCookie(mode);
		if( mcookie.lastLevel==lid ) {
			mcookie.lastLevel++;
			saveCookie();
		}


		// Time bonus
		var tb = Std.int(time/1000) * 1000;
		if( tb>0 )
			gameOverDelayer.add(function() {
				addScore(hero.cx, hero.cy, tb, true);
			}, 1000);

		// Score update
		gameOverDelayer.add(function() {
			globalScore+=roundScore;
			roundScore = 0;
		}, 2400);

		// Next level
		gameOverDelayer.add(function() {
			nextLevel();
		}, 3000);
	}

	public function nextLevel() {
		if( lid==Level.ALL.length-1 ) {
			destroy();
			new m.Outro(globalScore);
		}
		else {
			fx.clear();
			lid++;
			level.destroy();
			level = new Level(lid);
			sdm.add(level.wrapper, Const.DP_BG);
			level.renderGame();
			initRound();
		}
	}


	public function setDiff(d:Int) {
		level.data.diff = d;
		level.saveData();
		mt.deepnight.Lib.saveFile("data.json", Level.serialize(), function() {
			fx.flashBang(0x80FF00, 0.3, 600);
		});
	}


	public function getRemainingTime() {
		return MLib.max(0, roundDuration - chrono);
	}
	public inline function getRemainingTimeMs() {
		return getRemainingTime()*1000/Const.FPS;
	}


	public function initRound(?first=false) {
		cd.set("warmUp", Const.WARMUP_DURATION * (first?1:0.4) );
		cd.set("skipTurn", Const.seconds(0.3));
		gameOver = false;
		running = false;
		chrono = 0;

		tbMask.width = level.wrapper.width;
		tbMask.height = level.wrapper.height;

		for(e in Entity.ALL)
			e.destroy();
		Entity.SEED = 0;

		roundScore = 0;
		hero = new en.Hero();
		level.resetBlood();
		level.addEntities();
		hero.spr.visible = false;

		focusViewportImmediatly(hero);

		// Texts
		if( lid==0 )
			cm.create({
				message( T.get("The year is 1930. You are the Proletarian Ninja X. You fight Capitalism with murder and violence.") ) > end;
				message( T.get("Peace is for the weak."), 0xA60000) > end;
				if( mode==Timed ) {
					message( T.get("Problem is: you really have many many people on your Kill List.") ) > end;
					message( T.get("Consequently, you definitely cannot spend more than 10 SECONDS on each contract.") , 0x16447C) > end;
					message( T.get("But hey. You're a ninja, remember?") ) > end;
				}
			});
		else if( lid==1 ) {
			if( mode==Timed )
				message( T.get("RULE: Kill everyone QUICKLY\n\nThe way of the Proletarian Ninja is of Vengeance. Kill everyone who is richer than you within 10 seconds."), true );
			else
				message( T.get("RULE: Kill everyone\n\nThe way of the Proletarian Ninja is of Vengeance. Kill everyone who is richer than you."), true );
		}
		else if( lid==2 )
			message( T.get("RULE: Stay out of sight\n\nThe way of the Ninja lies beneath the veil of darkness. No one can spot a Ninja."), true );
		else if( lid==3 )
			message( T.get("RULE: Don't kill dogs\n\nPuppies are soup ingredient, not targets."), 0xAE0000, true );
		else
			announce( T.get("Level ")+lid, 0x4385E7);
	}

	public function start() {
		fx.flashBang(0xFFFF00,0.4, 600);
		running = true;

		announce( T.get("Kill'em ALL!"), 0xFF0000 );
		BaseProcess.SBANK.intro03().play(0.7);

		hero.spr.visible = true;
		hero.stable = false;
		//hero.spr.a.playAndLoop("ninjaJump");
		hero.zz = 30;
		hero.updateSprite();
		hero.updateLighting();
	}

	public function frag(e:Entity) {
		var t = getRemainingTime();
		var val = Std.int(getRemainingTimeMs()/1000)*100;
		combo++;
		addScore( e.cx,e.cy, val*combo*combo );
		if( hasScore() && combo>1 )
			fx.combo(e.cx, e.cy+1, combo);
		cd.set("combo", Const.COMBO_TIME);
	}

	public function hasScore() {
		return mode==Timed;
	}

	public function hasChrono() {
		return mode==Timed;
	}

	public function addScore(cx:Int,cy:Int, s:Float, ?timeBonus=false) {
		var s = Std.int(s);
		if( s>10 )
			s = MLib.round(s/10)*10;
		roundScore+=s;
		if( hasScore() )
			if( timeBonus )
				fx.timeBonus(s);
			else
				fx.score(cx,cy, s, s>1500);
	}

	public function onMouseDown(_) {
		if( paused )
			return;

		onLeftClick();

		//var m = getMouse();
		//drag = {x:m.sx, y:m.sy, active:false};
	}

	public function onMouseUp(_) {
		if( paused )
			return;

		//if( drag!=null && !drag.active )
			//onLeftClick();
//
		//drag = null;
	}


	public function onLeftClick() {
		if( guide!=null ) {
			guide.bmp.bitmapData.dispose();
			guide.bmp.parent.removeChild(guide.bmp);
			guide.bg.parent.removeChild(guide.bg);
			guide = null;
			return;
		}

		if( hasMessage() ) {
			hideMessage();
			cm.signal();
			return;
		}

		if( !running )
			return;

		var m = getMouse();
		// Move/Attack
		var cx = m.cx;
		var cy = m.cy;

		// Snap to mobs
		var snapped = false;
		var possibles = [];
		var snapDist = Math.pow( hero.hasAmmo() ? Const.GRID*3.5 : Const.GRID*1.7, 2 );
		for(e in en.Mob.ALL)
			if( e.toBeKilled && Lib.distanceSqr(m.sx, m.sy, e.xx, e.yy-Const.GRID*0.5) <= snapDist )
				possibles.push(e);

		if( possibles.length==0 ) {
			if( mode==TurnBased && Lib.distanceSqr(cx,cy, hero.cx,hero.cy)<=1*1 ) {
				hero.stop();
				cd.set("skipTurn", Const.seconds(0.3));
			}
			else
				hero.goto(cx, cy);
			hero.clearTarget();
		}
		else {
			possibles.sort( function(a,b) return Reflect.compare(Lib.distanceSqr(m.sx,m.sy, a.xx,a.yy), Lib.distanceSqr(m.sx,m.sy, b.xx,b.yy)) );
			hero.attackTarget(possibles[0]);
		}
	}


	public inline function mobsCanPlay() {
		return !running || mode!=TurnBased || hero.isMoving() || cd.has("skipTurn");
	}

	//public function onRightClick(_) {
		//if( !running )
			//return;
		//var m = getMouse();
		//hero.stop();
		//hero.shoot(m.sx, m.sy);
	//}

	public function onMouseMove(_) {
		if( !Const.isTouch() )
			cursor.visible = true;
	}

	public function onLeave(_) {
		cursor.visible = false;
		onMouseUp(null);
	}

	public inline function getMouse() {
		var sx = Std.int((root.mouseX-buffer.render.x)/Const.UPSCALE - scroller.x);
		var sy = Std.int((root.mouseY-buffer.render.y)/Const.UPSCALE - scroller.y);
		return {
			gx	: root.mouseX,
			gy	: root.mouseY,
			sx	: sx,
			sy	: sy,
			cx	: Std.int(sx/Const.GRID),
			cy	: Std.int(sy/Const.GRID),
		}
	}

	public function freezeTime(d:Float) {
		tw.terminateWithoutCallbacks(fmask.alpha);

		cd.set("freeze", d);
		cd.onComplete("freeze", endFreeze);
		fmask.visible = true;
		fmask.alpha = 0;
		tw.create(fmask.alpha, 1, 200);

		for(e in en.Mob.ALL)
			fx.freezeGhost(e, d);
	}

	function endFreeze() {
		cd.unset("freeze");
		tw.terminateWithoutCallbacks(fmask.alpha);
		tw.create(fmask.alpha, 0, 500).onEnd = function() {
			fmask.visible = false;
		}
	}

	public inline function isFrozen() {
		return cd.has("freeze");
	}

	public function hasMessage() {
		return guide!=null || curMessage!=null;
	}

	public function hideMessage() {
		if( curMessage==null )
			return;

		BaseProcess.SBANK.menu01(1);
		var m = curMessage;
		tw.create(m.bmp.alpha, 0, 300).onEnd = function() {
			m.bmp.parent.removeChild(m.bmp);
			m.bmp.bitmapData.dispose();
			m.bmp.bitmapData = null;
		}
		m.bg.parent.removeChild(m.bg);
		curMessage = null;
	}

	public function message(str:String, ?c=0x702B23, ?niceWindow=false) {
		hideMessage();
		var w = niceWindow ? 140 : 100;
		if( niceWindow )
			c = 0x1B1D30;


		var mask = new Sprite();
		buffer.dm.add(mask, Const.DP_INTERF);
		mask.graphics.beginFill(0x711122,0.5);
		mask.graphics.drawRect(0,0,buffer.width, buffer.height);

		var wrapper = new Sprite();

		var bg = new Sprite();
		wrapper.addChild(bg);

		if( niceWindow ) {
			var lines = str.split("\n");
			str = "";
			var i = 0;
			var c = Color.intToHex( Color.changeHslInt(c, 0.8, 0.3) );
			for(l in lines) {
				if( i==0 )
					str+=l+"\n";
				else
					str+="<font color='"+c+"'>"+l+"</font>\n";
				i++;
			}
		}
		var tf = createField(str);
		wrapper.addChild(tf);
		tf.width = w;
		tf.height = tf.textHeight+5;
		tf.filters = [ new flash.filters.DropShadowFilter(1,90, 0x0,0.3, 0,0,1) ];

		bg.graphics.beginFill(c,1);
		bg.graphics.drawRect(0,0, w+3, tf.textHeight+3);
		if( niceWindow ) {
			bg.graphics.beginFill( 0x0, 0.2 );
			bg.graphics.drawRect(0,0, w+3, 12);
		}
		bg.filters = [
			new flash.filters.DropShadowFilter(1,90, 0x0,0.1, 0,0,1, 1,true),
			new flash.filters.GlowFilter(0x0,1, 2,2,10),
			new flash.filters.GlowFilter(0xFFFFFF,1, 2,2,10),
			new flash.filters.GlowFilter(0x0,1, 2,2,10),
			new flash.filters.GlowFilter(0x0,0.5, 32,32,2, 2),
		];

		var bmp = Lib.flatten(wrapper,32);
		buffer.dm.add(bmp, Const.DP_INTERF);
		bmp.x = Std.int(buffer.width*0.5-bmp.width*0.5 + Lib.irnd(0,20,true));
		bmp.y = Std.int(buffer.height*0.5-bmp.height*0.5 + Lib.irnd(0,20,true));
		curMessage = {bmp:bmp, bg:mask};
		//s.destroy();


		if( niceWindow ) {
			tiles.drawIntoBitmap(bmp.bitmapData, bmp.width*0.5, 31, "windowFrame", 0, 0.5,1);
			tiles.drawIntoBitmap(bmp.bitmapData, bmp.width*0.5, bmp.height-32, "windowFrame", 1, 0.5,0);
		}
	}


	public function announce(str:String, ?col=0xFFAC00) {
		var tf = createField(str.toUpperCase());
		tf.textColor = col;
		var dark = mt.deepnight.Color.setLuminosityInt(col, 0.4);
		dark = mt.deepnight.Color.hueInt(dark, -0.02);
		tf.filters = [
			new flash.filters.DropShadowFilter(1,90, dark,1, 0,0,1),
			new flash.filters.GlowFilter(0x0,1, 2,2,10),
		];
		var btf = mt.deepnight.Lib.flatten(tf, 3);

		var sc = str.length>=14 ? 2 : 3;

		var bmp = mt.deepnight.Lib.flatten(tf);
		buffer.dm.add(bmp, Const.DP_INTERF);
		bmp.x = 3;
		bmp.y = Std.int(buffer.height*0.25 - bmp.height*7*0.5);
		tw.create(bmp.y, Std.int(buffer.height*0.25 - bmp.height*sc*0.5), 150);

		bmp.scaleX = bmp.scaleY = sc;
		//bmp.scaleX = bmp.scaleY = 7;
		//tw.create(bmp, "scaleX", sc, 150).onUpdate = function() {
			//bmp.scaleY = bmp.scaleX;
		//}
		delayer.add(function() {
			tw.create(bmp.alpha, 0, 500).onEnd = function() {
				bmp.parent.removeChild(bmp);
				bmp.bitmapData.dispose();
			}
		}, 700);
	}


	override function update() {
		super.update();

		cm.update();

		if( !hasMessage() && !running && !gameOver && !cd.has("warmUp") )
			start();

		var m = getMouse();
		if( !Const.isTouch() ) {
			cursor.x = m.cx*Const.GRID;
			cursor.y = m.cy*Const.GRID;
		}

		if( !cd.has("combo") )
			combo = 0;

		#if debug
		if( Key.isToggled(Keyboard.E) ) {
			onEditor();
			return;
		}
		#end

		if( running ) {

			if( Key.isToggled(Keyboard.ESCAPE) || Key.isToggled(Keyboard.R) )
				onReset();

			#if debug
			if( Key.isToggled(Keyboard.N) )
				nextLevel();
			#end

			// Time advance
			if( !isFrozen() ) {
				chrono++;
				if( chrono>=roundDuration && hasChrono() ) {
					onGameOver(2000);
					announce( T.get("Time out!") );
					BaseProcess.SBANK.alarm02(0.7);
					fx.flashBang(0x00FFFF, 0.8, 2000);
				}
			}

			if( en.Mob.getTargets().length==0 && !cd.has("winDelay") ) {
				cd.set("winDelay",2);
				cd.onComplete("winDelay", function() {
					if( running )
						onWin();
				});
			}
		}

		for(e in Entity.ALL)
			e.update();
		while(Entity.KILL_LIST.length>0)
			Entity.KILL_LIST.splice(0,1)[0].unregister();

			
		var m = getMouse();
		// Long press
		//if( drag!=null ) {
			// Dead zone
			//if( !cd.has("superKill") && !drag.active && Lib.distanceSqr(m.sx, m.sy, drag.x, drag.y) >= 10*10 ) {
				//cd.set("slashDuration", 9999);
				//drag.active = true;
				//fx.clearSlash();
				//fx.slash(drag.x, drag.y, true);
			//}

			// Slash
			/*
			if( drag.active && cd.has("slashDuration") ){
				fx.slash(m.sx, m.sy, true);

				if( !cd.has("superKill") ) {
					var radius2 = MLib.pow(Const.GRID, 2);
					var x = drag.x;
					var y = drag.y;
					var a = Math.atan2(m.sy-drag.y, m.sx-drag.x);
					var d = Lib.distance(drag.x, drag.y, m.sx, m.sy);
					var step = Const.GRID;
					var nsteps = MLib.ceil( d / step );
					while( nsteps>0 ) {
						fx.marker(x,y);

						for(e in en.Mob.ALL)
							if( Lib.distanceSqr(e.xx, e.yy-Const.GRID, x, y) <= radius2 ) {
								hero.shoot(e.xx, e.yy);
								//e.hit(1);
								nsteps = 0;
								//cd.set("superKill", Const.seconds(2));
								cd.set("slashDuration", 3);
								break;
							}

						x+=Math.cos(a)*step;
						y+=Math.sin(a)*step;
						nsteps--;
					}
				}

				drag.x = m.sx;
				drag.y = m.sy;
			}
			*/
		//}

		// Viewport / scrolling update
		viewport.x += viewport.dx;
		viewport.y += viewport.dy;
		viewport.x = MLib.fmax( 0, MLib.fmin(level.pixelWid-viewport.wid, viewport.x) );
		viewport.y = MLib.fmax( 0, MLib.fmin(level.pixelHei-viewport.hei, viewport.y) );
		var frict = 0.6;
		viewport.dx*=frict;
		viewport.dy*=frict;
		focusViewport(hero);

		scroller.x = Std.int( -viewport.x );
		scroller.y = Std.int( -viewport.y );
		//trace(viewport.x+" "+viewport.y+" "+hero.xx+" "+hero.yy);

		if( fmask.visible ) {
			fmask.x = -3 + Math.cos(time*0.08)*3;
			fmask.y = -3 + Math.sin(time*0.07)*3;
		}

		// Turn based mask
		if( tbMask.visible ) {
			if( mobsCanPlay() && tbMask.alpha>0 )
				tbMask.alpha-=0.04;

			var max = 0.3;
			if( !mobsCanPlay() && tbMask.alpha<max )
				tbMask.alpha+=0.1;

			tbMask.alpha = MLib.fclamp(tbMask.alpha, 0, max);
		}

		hud.update();
	}

	override function preUpdate() {
		super.preUpdate();
		gameOverDelayer.update();
	}

	override function render() {
		super.render();
	}
}
