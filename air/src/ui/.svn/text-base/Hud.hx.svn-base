package ui;

import Const;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.text.TextField;
import mt.Metrics;
import mt.deepnight.T;
import mt.deepnight.slb.BSprite;
import ui.Button;

class Hud {
	var destroyed			: Bool;
	var game				: m.Game;
	public var bufferWrapper: Sprite;
	public var uiWrapper	: Sprite;
	var chrono1				: TextField;
	var chrono2				: TextField;
	var score				: TextField;
	public var menuBt		: PauseButton;
	public var curMenu		: Null<Window>;
	var ammoWrapper			: Sprite;
	var ammoIcons			: Array<BSprite>;


	public function new() {
		game = m.Game.ME;
		destroyed = false;
		ammoIcons = [];

		bufferWrapper = new Sprite();
		game.buffer.dm.add(bufferWrapper, Const.DP_INTERF);

		uiWrapper = new Sprite();
		game.root.addChild(uiWrapper);

		ammoWrapper = new Sprite();
		bufferWrapper.addChild(ammoWrapper);

		menuBt = new PauseButton(uiWrapper, onMenu);

		chrono1 = game.createField("00");
		bufferWrapper.addChild(chrono1);
		chrono1.scaleX = chrono1.scaleY = 2;

		chrono2 = game.createField("00");
		bufferWrapper.addChild(chrono2);
		chrono2.blendMode = flash.display.BlendMode.ADD;

		if( game.mode!=Timed ) {
			chrono1.visible = false;
			chrono2.visible = false;
		}

		score = game.createField("-1",false);
		bufferWrapper.addChild(score);
		score.width = 100;
		score.height = 10;
		score.visible = game.hasScore();

		onResize();
	}

	public function onResize() {
		var bw = game.buffer.width;
		var bh = game.buffer.height;

		menuBt.x = Const.WID - menuBt.getWidth() + 15;
		menuBt.y = -15;
		menuBt.scale(Const.UPSCALE);

		score.y = 1;
	}


	function updateAmmo() {
		for(s in ammoIcons)
			s.dispose();
		ammoIcons = [];

		for(i in 0...game.hero.getAmmo()) {
			var s = game.tiles.get("shurikenUI");
			ammoWrapper.addChild(s);
			s.setCenter(0, 0);
			s.scaleX = s.scaleY = 2;
			s.x = i*18;
			ammoIcons.push(s);
		}

		ammoWrapper.x = Std.int(game.buffer.width*0.5 - ammoWrapper.width*0.5);
		ammoWrapper.y = -8;
	}


	public function hideMenu() {
		if( curMenu!=null ) {
			curMenu.destroy();
			curMenu = null;
		}
	}

	public function onMenu() {
		if( curMenu!=null )
			curMenu.destroy();

		game.pause();


		var w = new Window(uiWrapper, 100);
		curMenu = w;
		w.minWidth = 200;

		function close(?cb) {
			w.destroy();
			game.resume();
			curMenu = null;
			if( cb!=null )
				cb();
		}

		w.setOnClickTrap( close.bind() );

		new Label(w, T.get("Game paused..."));
		var b = new Button(w, T.get("RESUME"), close.bind());
		b.setHeight(50);
		new Button(w, T.get("Restart level"), close.bind( game.onReset ) );
		new Separator(w);
		new Button(w, T.get("Abandon"), close.bind( game.onQuit ) );
		#if debug
		new Separator(w);
		new Button(w, T.get("Editor"), close.bind( game.onEditor ) );
		#end
	}

	//public function showRanker() {
		//if( curMenu!=null )
			//curMenu.destroy();
//
		//game.pause();
//
		//var w = new Window(uiWrapper, 100);
		//curMenu = w;
		//w.minWidth = 200;
//
		//function close(?cb) {
			//w.destroy();
			//game.resume();
			//curMenu = null;
			//if( cb!=null )
				//cb();
		//}
//
		//function setDiff(d) {
			//game.setDiff(d);
		//}
//
		//new Label(w, T.get("Rank this level"));
		//var g = w.hgroup(true);
		//g.label("Easy");
		//for(d in 0...5) {
			//new Button(g, Std.string(d), setDiff.bind(d));
		//}
		//g.label("Hard");
	//}

	public function destroy() {
		if( curMenu!=null )
			curMenu.destroy();

		for(s in ammoIcons)
			s.dispose();
		ammoIcons = null;

		destroyed = true;
		menuBt.destroy();
		bufferWrapper.parent.removeChild(bufferWrapper);
		uiWrapper.parent.removeChild(uiWrapper);
	}

	public function update() {
		if( destroyed )
			return;

		var t = game.getRemainingTime();
		if( t<=0 )
			t = 0;
		var t = DateTools.parse(t*1000/Const.FPS);

		var bw = game.buffer.width;

		// Ammo
		if( game.hero.getAmmo()!=ammoIcons.length )
			updateAmmo();

		if( game.mode==Timed ) {
			var low = t.seconds<=3;
			chrono1.text = Std.string(t.seconds);
			chrono1.textColor = low ? 0xFFAC00 : 0xFFFFFF;
			chrono1.x = -1;
			chrono1.y = -5;

			chrono2.text = mt.deepnight.Lib.leadingZeros(Std.int(t.ms/10), 2);
			chrono2.textColor = low ? 0xFF5300 : 0x628B9B;
			chrono2.x = chrono1.x + chrono1.textWidth*chrono1.scaleX + 2;
			chrono2.y = chrono1.y+4;
		}

		if( game.hasScore() && score.text!=Std.string(game.globalScore) ) {
			score.text = Std.string(game.globalScore);
			score.x = Std.int(bw - score.textWidth*score.scaleX - 16);
		}

		//var w = shurikenBar.bitmapData.width;
		//var h = shurikenBar.bitmapData.height;
		//var r = (1-game.hero.cd.get("shoot")/Const.SHURIKEN_CD);
		//shurikenBar.bitmapData.fillRect( new flash.geom.Rectangle(2,2, w-4, h-4), 0x0 );
		//shurikenBar.bitmapData.fillRect( new flash.geom.Rectangle(2,2, (w-4)*r, h-4), r<1 ? 0x9F0000 : 0xFFB417 );
	}
}