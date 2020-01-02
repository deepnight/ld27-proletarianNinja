@:bitmap("assets/guide.png") class GfxGuide extends flash.display.BitmapData {}
@:bitmap("assets/intro.png") class GfxIntro extends flash.display.BitmapData {}
@:bitmap("assets/introBg.png") class GfxIntroBg extends flash.display.BitmapData {}
@:bitmap("assets/tiles.png") class GfxTiles extends flash.display.BitmapData {}

class Const { //}

	public static var WID = Std.int(flash.Lib.current.stage.stageWidth);
	public static var HEI = Std.int(flash.Lib.current.stage.stageHeight);
	public static var IHEI = 150;
	public static var UPSCALE : Float = 3;
	public static var GRID = 10;
	public static var FPS = 30;
	//public static var WARMUP_DURATION = #if debug 0 #else 2*FPS #end;
	public static var WARMUP_DURATION = 2*FPS;
	//public static var ROUND_DURATION_NORMAL = seconds(20);
	public static var ROUND_DURATION_HARD = seconds(10);
	public static var SHADOW = 0x21122d;
	public static var SHURIKEN_CD = 0;
	public static var SAVE_VERSION = 7;
	public static var LEVEL_DATA_VERSION = 2;
	public static var COMBO_TIME = Const.seconds(0.6); // 0.4

	public static var H_WALL = 99;
	public static var H_HIGH = 50;
	public static var H_LOW = 4;

	public static inline function seconds(v:Float) return Std.int(FPS*v);
	public static inline function ms(f:Int) return 1000 * f/FPS;

	private static var uniq = 0;
	public static var DP_BG = uniq++;
	public static var DP_TBMASK = uniq++;
	public static var DP_MOB = uniq++;
	public static var DP_ITEM = uniq++;
	public static var DP_FMASK = uniq++;
	public static var DP_FX = uniq++;
	public static var DP_FX_FLASH = uniq++;
	public static var DP_HERO = uniq++;
	public static var DP_INTERF = uniq++;

	public static inline function isTouch() {
		return flash.system.Capabilities.touchscreenType!=NONE;
	}
}

enum GameMode {
	Easy;
	TurnBased;
	Timed;
}


typedef ModeCookie = {
	var lastLevel	: Int;
}

typedef GameCookie = {
	var lang	: String;
	var sounds	: Int;
	var modes	: Map<GameMode, ModeCookie>;
}

