package m;

import Const;

import mt.flash.Sfx;
import mt.deepnight.SpriteLibBitmap;
import mt.deepnight.Lib;
import mt.flash.Key;
import flash.ui.Keyboard;
import flash.display.Sprite;

class Game extends Mode { //}
	public static var ME : Game;

	public var hero			: en.Hero;
	public var tiles		: SpriteLibBitmap;
	public var level		: Level;
	public var fx			: Fx;
	public var cm			: mt.deepnight.Cinematic;
	
	public var seed			: Int;
	public var combo		: Int;
	public var score		: Int;
	public var globalScore	: Int;
	public var hud			: Hud;
	public var chrono		: Int;
	public var cursor		: Sprite;
	public var lid			: Int;
	
	public var running		: Bool;
	public var gameOver		: Bool;
	var offFilter			: flash.filters.BitmapFilter;
	var curMessage			: Null<Sprite>;
	var guide				: Null<{bg:Sprite, s:BSprite}>;
	
	public function new() {
		super();
		ME = this;
		score = 0;
		globalScore = 0;
		combo = 0;
		lid = 0;
		#if debug
		//lid = Const.LAST_LEVEL;
		#end
		seed = 1866;
		gameOver = false;
		running = false;
		offFilter = mt.Color.getSaturationFilter(-0.7);
		cm = new mt.deepnight.Cinematic(Const.FPS);
		
		tiles = new SpriteLibBitmap( new GfxTiles(0,0) );
		tiles.setSliceGrid(10,10);
		tiles.sliceGrid("ninjaStand",0,0, 3);
		tiles.defineAnim("0(45), 1(1), 2(20), 1(1)");
		
		tiles.sliceGrid("ninjaRun",3,0, 2);
		tiles.defineAnim("ninjaRun", "0(1), 1(3)");
		
		tiles.sliceGrid("ninjaJump",5,0, 4);
		tiles.defineAnim("ninjaJump", "0-3(1)");
		
		tiles.sliceGrid("ninjaCaught",9,0, 2);
		tiles.defineAnim("0-1(3)");
		
		tiles.sliceGrid("ninjaWin",11,0, 4);
		tiles.defineAnim("0(12), 1(15), 2(15), 3(2), 1");
		
		tiles.sliceGrid("shuriken", 0,1);
		tiles.slice("slash", 0,20, 20,20, 2);
		tiles.slice("blood", 40,20, 20,20);
		tiles.slice("bloodLine", 60,20, 40,20);
		tiles.sliceGrid("ground0",0,4, 6);
		tiles.sliceGrid("ground1",6,4, 5);
		tiles.sliceGrid("ground2",11,4, 3);
		tiles.sliceGrid("ground3",14,4, 3);
		tiles.sliceGrid("ground4",17,4, 3);
		tiles.sliceGrid("wall",0,5, 4);
		tiles.sliceGrid("window",0,6, 4);
		tiles.slice("windowLight",0,7*10, 10,20);
		tiles.slice("table",0,9*10, 30,50, 2);
		tiles.slice("drawer",6*10,9*10, 30,30);
		tiles.slice("fireplace",9*10,9*10, 30,30);
		tiles.slice("shelf",12*10,9*10, 40,30);
		
		tiles.slice("bourgeois1",0,14*10, 20,20, 4);
		tiles.slice("bourgeois2",0,16*10, 20,20, 4);
		tiles.slice("bourgeois3",0,18*10, 20,20, 4);
		tiles.sliceGrid("head",9,15, 3);
		tiles.sliceGrid("smoke",8,14, 3);
		tiles.defineAnim("0-2(10), 1(10)");
		tiles.sliceGrid("wine",11,14);
		//tiles.defineAnim("0(99)");
		tiles.sliceGrid("beer",12,14);
		tiles.sliceGrid("cane",13,14);
		//tiles.defineAnim("0(99)");
		tiles.sliceGrid("hat",8,15);
		tiles.slice("cadaver",8*10,16*10, 20,20);
		
		tiles.slice("guide",0,24*10, 250,140);
		
		fx = new Fx();
		
		level = new Level();
		level.draw();
		
		hud = new Hud();
		
		cursor = new Sprite();
		buffer.dm.add(cursor, Const.DP_BG);
		cursor.graphics.lineStyle(1,0xFF0000,0.5);
		cursor.graphics.drawRect(1,1,Const.GRID-2,Const.GRID-2);
		cursor.visible = false;
		
		root.addEventListener(flash.events.Event.ADDED_TO_STAGE, onStageReady);
		root.addEventListener(flash.events.MouseEvent.MOUSE_MOVE, onMouseMove);
		root.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, onLeftClick);
		root.addEventListener(flash.events.MouseEvent.RIGHT_CLICK, onRightClick);
		
		root.alpha = 0;
		tw.create(root, "alpha", 1, 1000);
		
		startRound(true);
		
		#if !debug
		cm.create({
			message("The year is 1930. You are the Proletarian Ninja X, you fight Capitalism with murder and violence.") > end;
			message("Peace is for the weak.", 0x790000) > end;
			message("Problem is: you really have many many people on your Kill List.") > end;
			message("Consequently, you definitely cannot spend more than 10 SECONDS on each contract.", 0x004993) > end;
			message("But hey. You're a ninja, remember?") > end;
			message("Stay out of sight. Kill everyone within 10s!",0x790000) > end;
			showGuide() > end;
		});
		#end
	}
	
	public function onGameOver(?d=1000) {
		if( gameOver )
			return;
			
		gameOver = true;
		running = false;
		hero.onCaught();
		delayer.add(function() startRound(), d);
	}
	
	override function destroy() {
		super.destroy();
		level.destroy();
		for(e in Entity.ALL)
			e.destroy();
		while(Entity.KILL_LIST.length>0)
			Entity.KILL_LIST.splice(0,1)[0].unregister();
		tiles.destroy();
	}
	
	public function onWin() {
		if( gameOver )
			return;
			
		announce("Level complete");
		gameOver = true;
		running = false;
		hero.onWin();
		delayer.add(function() {
			var t = getRemainingTime();
			addScore(hero.cx, hero.cy, Math.pow(t, 1.5));
		}, 1000);
		delayer.add(function() {
			globalScore+=score;
			score = 0;
			nextLevel();
		}, 3000);
	}
	
	public function nextLevel() {
		if( lid==Const.LAST_LEVEL ) {
			destroy();
			var m = new m.Outro();
			flash.Lib.current.addChild(m.root);
		}
		else {
			lid++;
			level.destroy();
			level = new Level();
			level.draw();
			startRound();
		}
	}
	
	public function getRemainingTime() {
		return Const.ROUND_DURATION - chrono;
	}
	
	public function showGuide() {
		var bg = new Sprite();
		buffer.dm.add(bg, Const.DP_INTERF);
		bg.graphics.beginFill(Const.SHADOW,0.75);
		bg.graphics.drawRect(0,0,buffer.width,buffer.height);

		var bs = Game.ME.tiles.get("guide");
		buffer.dm.add(bs, Const.DP_INTERF );
		bs.alpha = 0;
		tw.create(bs, "alpha", 1, 300);
		bs.x = 40;
		bs.y = 30;
		
		guide = {s:bs, bg:bg}
	}
	
	
	public function startRound(?first=false) {
		cd.set("warmUp", Const.WARMUP_DURATION * (first?1:0.4) );
		announce("Ready...", 0x4B5EB4);
		gameOver = false;
		running = false;
		
		chrono = 0;
		
		for(e in Entity.ALL)
			e.destroy();
		Entity.SEED = 0;
			
		score = 0;
		hero = new en.Hero();
		level.reset();
		level.addEntities();
		hero.spr.visible = false;
	}
	
	public function onStartRound() {
		fx.flashBang(0xFFFF00,0.4, 600);
		running = true;
		
		announce("Kill'em ALL!");
		Mode.SBANK.intro03().play(0.7);
		
		hero.spr.visible = true;
		hero.stable = false;
		hero.spr.playAnim("ninjaJump");
		hero.zz = 30;
		hero.updateSprite();
		hero.updateLightning();
	}
	
	function onStageReady(_) {
		root.stage.addEventListener(flash.events.Event.MOUSE_LEAVE, onLeave);
		root.stage.addEventListener(flash.events.MouseEvent.RELEASE_OUTSIDE, onLeave);
	}
	
	public function frag(e:Entity) {
		var t = getRemainingTime();
		var val = 10 * Math.round(Math.pow(t,1.5) / 100);
		combo++;
		addScore( e.cx,e.cy, val*combo*combo );
		if( combo>1 )
			fx.score(e.cx, e.cy+1, 'Combo ${combo}x');
		cd.set("combo", 13);
	}
	
	public function addScore(cx:Int,cy:Int, s:Float) {
		var s = Std.int(s);
		score+=s;
		fx.score(cx,cy, s);
	}
	
	public function onLeftClick(_) {
		if( guide!=null ) {
			guide.s.destroy();
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
		var m = getMouseInBuffer();
		if( !hero.cd.has("stun") )
			hero.goto(m.cx, m.cy);
	}
	
	public function onRightClick(_) {
		if( !running )
			return;
		var m = getMouseInBuffer();
		hero.stop();
		hero.shoot(m.x, m.y);
	}
	
	public function onMouseMove(_) {
		cursor.visible = true;
	}
	
	public function onLeave(_) {
		cursor.visible = false;
	}
	
	public inline function getMouse() {
		return {
			x	: root.mouseX,
			y	: root.mouseY,
		}
	}
	
	public inline function getMouseInBuffer() {
		var m = getMouse();
		var x = Std.int((m.x-buffer.render.x)/Const.UPSCALE);
		var y = Std.int((m.y-buffer.render.y)/Const.UPSCALE);
		return {
			x	: x,
			y	: y,
			cx	: Std.int(x/Const.GRID),
			cy	: Std.int(y/Const.GRID),
		}
	}
	
	public function createField(str:Dynamic, ?fit=true) {
		var f = new flash.text.TextFormat();
		f.font = "def";
		f.size = 8;
		f.color = 0xffffff;
		
		var tf = new flash.text.TextField();
		tf.width = fit ? 500 : 300;
		tf.height = 50;
		tf.mouseEnabled = tf.selectable = false;
		tf.defaultTextFormat = f;
		//tf.antiAliasType = flash.text.AntiAliasType.ADVANCED;
		//tf.sharpness = 800;
		tf.embedFonts = true;
		tf.htmlText = Std.string(str);
		tf.multiline = tf.wordWrap = true;
		if( fit ) {
			tf.width = tf.textWidth+5;
			tf.height = tf.textHeight+5;
		}
		return tf;
	}
	
	public function hasMessage() {
		return guide!=null || curMessage!=null;
	}
	
	public function hideMessage() {
		if( curMessage==null )
			return;
			
		Mode.SBANK.menu01(1);
		var s = curMessage;
		tw.create(s, "alpha", 0, 300).onEnd = function() {
			s.parent.removeChild(s);
		}
		curMessage = null;
	}
	
	public function message(str:String, ?c=0x893D0A) {
		hideMessage();
		var wrapper = new Sprite();
		buffer.dm.add(wrapper, Const.DP_INTERF);
		
		var bg = new Sprite();
		wrapper.addChild(bg);
		
		var tf = createField(str);
		wrapper.addChild(tf);
		tf.width = 100;
		tf.height = tf.textHeight+5;
		tf.filters = [ new flash.filters.DropShadowFilter(1,90, 0x0,0.3, 0,0,1) ];
		
		bg.graphics.beginFill(c,1);
		bg.graphics.drawRect(0,0, 103, tf.textHeight+3);
		bg.filters = [
			new flash.filters.DropShadowFilter(1,90, 0x0,0.1, 0,0,1, 1,true),
			new flash.filters.GlowFilter(0xFFFFFF,1, 2,2,10),
			new flash.filters.GlowFilter(0x0,05, 32,32,2, 2),
		];
		
		wrapper.x = Std.int(buffer.width*0.5-wrapper.width*0.5 + Lib.irnd(0,20,true));
		wrapper.y = Std.int(buffer.height*0.5-wrapper.height*0.5 + Lib.irnd(0,20,true));
		
		curMessage = wrapper;
	}
	
	
	public function announce(str:String, ?col=0xEE6911) {
		var tf = createField(str);
		tf.textColor = col;
		
		var sc = str.length>=14 ? 3 : 4;
		
		var bmp = mt.deepnight.Lib.flatten(tf);
		buffer.dm.add(bmp, Const.DP_INTERF);
		bmp.blendMode = flash.display.BlendMode.ADD;
		bmp.x = 3;
		bmp.y = Std.int(buffer.height*0.5 - bmp.height*7*0.5);
		tw.create(bmp, "y", Std.int(buffer.height*0.5 - bmp.height*sc*0.5), 150);
		
		bmp.scaleX = bmp.scaleY = 7;
		tw.create(bmp, "scaleX", sc, 150).onUpdate = function() {
			bmp.scaleY = bmp.scaleX;
		}
		delayer.add(function() {
			tw.create(bmp, "alpha", 0, 500).onEnd = function() {
				bmp.parent.removeChild(bmp);
				bmp.bitmapData.dispose();
			}
		}, 700);
	}
	
	
	override function update() {
		super.update();
		
		cm.update();
		
		if( !hasMessage() && !running && !gameOver && !cd.has("warmUp") )
			onStartRound();
		
		var m = getMouseInBuffer();
		cursor.x = m.cx*Const.GRID;
		cursor.y = m.cy*Const.GRID;
		
		if( !cd.has("combo") )
			combo = 0;
		
		if( running ) {
			if( Key.isToggled(Keyboard.ESCAPE) || Key.isToggled(Keyboard.R) ) {
				fx.flashBang(0xFFFFFF,0.3, 1500);
				fx.pop(hero, "Abort mission!");
				onGameOver();
			}
			//#if debug
			if( Key.isToggled(Keyboard.N) )
				nextLevel();
			//#end
				
			chrono++;
			if( chrono>=Const.ROUND_DURATION ) {
				onGameOver(2000);
				announce("Time out!");
				Mode.SBANK.alarm02(0.7);
				fx.flashBang(0x00FFFF, 0.8, 2000);
			}
			
			if( en.Mob.getTargets().length==0 )
				onWin();
		}
		
		for(e in Entity.ALL)
			e.update();
		while(Entity.KILL_LIST.length>0)
			Entity.KILL_LIST.splice(0,1)[0].unregister();
			
	}
	
	override function postUpdate() {
		super.postUpdate();
		
		hud.update();
		fx.update();
		BSprite.updateAll();
		
	}
	
	override function render() {
		if( !running && !gameOver )
			buffer.postFilters = [offFilter];
		else
			buffer.postFilters = [];
			
		super.render();
	}
}
