package m;

import Const;

import flash.ui.Keyboard;
import flash.display.Sprite;
import flash.display.Bitmap;

import mt.MLib;
import mt.Metrics;
import mt.flash.Key;
import mt.deepnight.Lib;
import mt.deepnight.Tweenie;
import mt.deepnight.T;
import mt.deepnight.slb.BSprite;

class Intro extends BaseProcess { //}
	public static var ME : Intro;

	var titleBg				: Bitmap;
	var title				: Bitmap;
	var titleGlow			: BSprite;
	var white				: flash.geom.ColorTransform;
	var mode				: GameMode;

	public function new() {
		super();
		ME = this;
		mode = Easy;
		titleBg = new Bitmap( new GfxIntroBg(0,0) );
		buffer.dm.add(titleBg, Const.DP_BG);

		title = new Bitmap( new GfxIntro(0,0) );
		buffer.dm.add(title, Const.DP_BG );
		title.visible = false;
		haxe.Timer.delay( function() {
			title.visible = true;
			tw.create(title.x, buffer.width > Std.int(buffer.width*0.5 - title.width*0.5), TEaseIn, 200).onEnd = function() {
				BaseProcess.SBANK.intro02(0.4);
				white = new flash.geom.ColorTransform(1,1,1,1, 255,255,255,0);
				title.transform.colorTransform = white;
				tw.create(white.redOffset, 0, TEase, 500).onUpdate = function() {
					white.greenOffset = white.blueOffset = white.redOffset;
					title.transform.colorTransform = white;
				}
			}
		}, 500);

		tw.create(title.alpha, 0>1, 600);
		fx.flashBang(0xFFFF80,1, 1500);

		titleGlow = tiles.get("titleGlow");
		buffer.dm.add(titleGlow, Const.DP_BG);
		titleGlow.blendMode = ADD;

		root.addEventListener( flash.events.MouseEvent.CLICK, onClick );
		onResize();
	}

	override function onBackKey() {
		super.onBackKey();
		destroy();
		new Intro();
	}


	function showMainMenu() {
		var w = new ui.Window(root, 50);
		w.setWidth(475);
		w.padding = 5;
		w.margin = 5;

		w.setOnClickTrap( function() {
			destroy();
			new Intro();
		});

		new ui.Label(w, T.get("Choose your playstyle"), 16 );

		// Easy
		var g = w.vgroup(true);
		var b = new ui.Button(g, T.get("Cool"), 16, function() {
			w.destroy();
			mode = Easy;
			showLevelList();
		});
		b.setHeight(80);
		b.addSubLabel( T.get("Kill everyone the way you want.") );

		// Timed
		var b = new ui.Button(g, T.get("Fast paced!"), 16, function() {
			w.destroy();
			mode = Timed;
			showLevelList();
		});
		b.setHeight(80);
		b.addSubLabel( T.get("You have 10 SECONDS to kill everyone!") );

		// Turn based
		var b = new ui.Button(g, T.get("Tactical"), 16, function() {
			w.destroy();
			mode = TurnBased;
			showLevelList();
		});
		b.setHeight(80);
		b.addSubLabel( T.get("The enemy will only move when you do.") );

		new ui.Separator(w);

		#if debug
		var b = new ui.Button(w, T.get("Reset save"), function() {
			cookie = makeNewCookie();
			saveCookie();
		});
		#end

		var b = new ui.Button(w, T.get("Quit game"), function() {
			quitApp();
		});
	}


	function showLevelList() {
		BaseProcess.SBANK.menu01(1);

		var w = new ui.Window(root, 5);
		var max = getModeCookie(mode).lastLevel;
		if( max<0 )
			max = 0;

		function _selectLevel(n:Int) {
			w.destroy();

			if( n>max )
				return;

			BaseProcess.SBANK.intro02(0.5);

			fx.flashBang(0xF42500, 0.8, 700);
			tw.create(root.alpha, 0, 1000).onEnd = function() {
				w.destroy();
				destroy();
				new Game(n, mode);
			}
		}

		new ui.Label(w, T.get("Select your level:"));


		var g = w.lgroup();
		g.setWidth( 40*8 + 1 );
		g.removeBorders();
		g.margin = 0;

		for(i in 0...Level.ALL.length) {
			var active = i<=max;
			var b = new ui.LevelButton(g, i, active, _selectLevel);

			if( i==max )
				b.setLast();

			//if( arr[i]!=null )
				//if( arr[i].gold )
					//b.setGoldStar();
				//else if( arr[i].silver )
					//b.setSilverStar();
		}

		// Cancel
		new ui.Separator(w);
		new ui.Button(w, T.get("Cancel"), function() {
			w.destroy();
			showMainMenu();
			BaseProcess.SBANK.menu01(1);
		});

		w.forceRenderNow();
	}

	override function onResize() {
		super.onResize();
		if( title!=null ) {
			titleBg.width = buffer.width;
			titleBg.height = buffer.height;
			title.x = Std.int(buffer.width*0.5 - title.width*0.5);
			title.y = Std.int(buffer.height*0.5 - title.height*0.5);
		}
	}


	function onClick(_) {
		if( destroyAsked )
			return;

		if( cd.has("click") )
			return;

		cd.set("click", 9999999);
		title.filters = [ new flash.filters.BlurFilter(4,4) ];
		titleBg.filters = [ new flash.filters.BlurFilter(2,2) ];
		BaseProcess.SBANK.intro01(0.7);

		fx.flashBang(0xFF0000, 0.4, 700);
		showMainMenu();
	}

	override function unregister() {
		super.unregister();

		title.bitmapData.dispose();
		titleBg.bitmapData.dispose();
		titleGlow.dispose();
	}

	override function update() {
		super.update();

		if( destroyAsked )
			return;

		Fx.ME.introFire(buffer.width, buffer.height);

		titleGlow.x = title.x+ 86;
		titleGlow.y = title.y+ 106;
		titleGlow.alpha = 0.75 + 0.25*Math.cos(time*0.12) + Lib.rnd(0, 0.1, true);
		titleGlow.alpha *= title.alpha;
		titleGlow.visible = title.visible;
	}

}
