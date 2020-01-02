import Const;

import flash.display.Sprite;
import flash.text.TextField;
import mt.deepnight.SpriteLibBitmap;

class Hud {
	var game				: m.Game;
	public var wrapper		: Sprite;
	var chrono1				: TextField;
	var chrono2				: TextField;
	var score				: TextField;
	var globalScore			: TextField;
	var ammo				: Array<BSprite>;
	
	public function new() {
		game = m.Game.ME;
		wrapper = new Sprite();
		game.buffer.dm.add(wrapper, Const.DP_INTERF);
		ammo = new Array();
		
		for(i in 0...3) {
			var s = game.tiles.get("shuriken");
			wrapper.addChild(s);
			s.x = i*s.width;
			s.alpha = 0.7;
			ammo.push(s);
		}
		
		chrono1 = game.createField("00");
		wrapper.addChild(chrono1);
		chrono1.scaleX = chrono1.scaleY = 2;
		chrono1.x = -2;
		chrono1.textColor = 0xFFFFFF;
		chrono1.y = 5;
		
		chrono2 = game.createField("00");
		wrapper.addChild(chrono2);
		chrono2.x = 19;
		chrono2.y = 8;
		chrono2.textColor = 0x628B9B;
		chrono2.blendMode = flash.display.BlendMode.ADD;
		
		score = game.createField("0",false);
		wrapper.addChild(score);
		score.textColor = 0xF88007;
		score.width = 100;
		score.height = 10;
		score.scaleX = score.scaleY = 1;
		score.y = 11;
		
		globalScore = game.createField("0",false);
		wrapper.addChild(globalScore);
		globalScore.scaleX = globalScore.scaleY = 2;
		globalScore.width = 100;
		globalScore.height = 10;
		globalScore.y = -4;
	}
	
	public function update() {
		var t = game.getRemainingTime();
		if( t<=0 )
			t = 0;
		var t = DateTools.parse(t*1000/Const.FPS);
		chrono1.text = mt.deepnight.Lib.leadingZeros(t.seconds,2);
		chrono2.text = mt.deepnight.Lib.leadingZeros(Std.int(t.ms/10), 2);
		
		globalScore.text = Std.string(game.globalScore);
		globalScore.x = Std.int(game.buffer.width - globalScore.textWidth*globalScore.scaleX - 4);
		
		score.text = Std.string(game.score);
		score.x = Std.int(game.buffer.width - score.textWidth*score.scaleX-3);
		
		
		for(i in 0...3) {
			ammo[i].visible = i<game.hero.ammo;
			if( game.hero.cd.has("shoot") ) {
				var r = 1 - game.hero.cd.get("shoot")/Const.SHURIKEN_CD;
				ammo[i].transform.colorTransform = mt.Color.getColorizeCT(mt.Color.interpolate(0x930000, 0x9C9898, r),1);
			}
			else
				ammo[i].transform.colorTransform = new flash.geom.ColorTransform();
		}
	}
}