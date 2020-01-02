import mt.Color;

@:bitmap("assets/title.png") class GfxTitle extends flash.display.BitmapData {}
@:bitmap("assets/tiles.png") class GfxTiles extends flash.display.BitmapData {}

class Const { //}
	
	public static var WID = Std.int(flash.Lib.current.stage.stageWidth);
	public static var HEI = Std.int(flash.Lib.current.stage.stageHeight);
	public static var UPSCALE = 3;
	public static var GRID = 10;
	public static var FPS = 30;
	public static var WARMUP_DURATION = #if debug 0 #else 2*FPS #end;
	public static var ROUND_DURATION = 10*FPS;
	public static var SHADOW : ColorCode = 0x21122d;
	public static var SHURIKEN_CD = FPS*2;
	public static var LAST_LEVEL = 8;
	public static var MUSIC_VOLUME = 0.4;
	
	private static var uniq = 0;
	public static var DP_BG = uniq++;
	public static var DP_MOB = uniq++;
	public static var DP_HERO = uniq++;
	public static var DP_FX = uniq++;
	public static var DP_INTERF = uniq++;
}
