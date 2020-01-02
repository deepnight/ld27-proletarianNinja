import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;

import Const;
import mt.deepnight.T;
import mt.deepnight.Lib;
import mt.deepnight.Buffer;
import mt.deepnight.slb.BLib;
import mt.flash.Sfx;
import mt.flash.Key;
import mt.MLib;
import mt.Metrics;

class BaseProcess extends mt.deepnight.FProcess {
	public static var CURRENT : BaseProcess;

	public static var SBANK = Sfx.importDirectory("assets/sfx");

	public var fx			: Fx;
	public var buffer		: Buffer;
	public var tiles		: BLib;

	public var doubleBuffer	: Null<Bitmap>;
	var dbMatrix			: flash.geom.Matrix;
	var enableDoubleBuffer	: Bool;
	var cookie				: GameCookie;


	public function new() {
		super();

		loadCookie();

		CURRENT = this;
		enableDoubleBuffer = false;

		//enableDoubleBuffer = Lib.isAndroid();


		tiles = new BLib( new GfxTiles(0,0) );
		tiles.setSliceGrid(10,10);
		tiles.sliceGrid("ninjaStand",0,0, 3);
		tiles.defineAnim("0(45), 1(1), 2(20), 1(1)");

		tiles.sliceGrid("ninjaRun",3,0, 2);
		tiles.defineAnim("ninjaRun", "0(3), 1(3)");

		tiles.sliceGrid("ninjaJump",5,0, 4);
		tiles.defineAnim("ninjaJump", "0-3(1)");

		tiles.sliceGrid("ninjaCaught",9,0, 2);
		tiles.defineAnim("0-1(3)");

		tiles.sliceGrid("ninjaWin",11,0, 4);
		tiles.defineAnim("0(12), 1(15), 2(15), 3(2), 1");

		tiles.slice("shuriken", 100,20, 20,20);
		tiles.slice("time", 120,20, 20,20);
		tiles.slice("shurikenHero", 140,20, 20,20);
		tiles.slice("shurikenUI", 160,20, 20,20);
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
		tiles.slice("windowLight",0,70, 10,20);
		tiles.slice("tableV4",0, 90, 20,40, 2);
		tiles.slice("tableV3",40, 90, 20,30, 2);
		tiles.slice("drawer",190,90, 20,20);
		tiles.slice("shelf2",210, 90, 20,20);
		tiles.slice("shelf1",230, 90, 10,20);
		tiles.slice("fireplace", 110, 90, 30,20);
		tiles.slice("tableH3", 140, 90, 30,20);
		tiles.slice("tableH2", 170, 90, 20,20);
		tiles.slice("door", 190, 110, 10,10);
		tiles.slice("windowFrame", 110, 70, 60,10, 1,2);

		tiles.slice("bourgeois1",0,14*10, 20,20, 5);
		tiles.slice("bourgeois2",0,16*10, 20,20, 5);
		tiles.slice("bourgeois3",0,18*10, 20,20, 5);

		tiles.slice("dog",19*10, 14*10, 20,20, 5);
		tiles.sliceAnim("dogWalk",3, 19*10, 16*10, 20,20, 9);

		tiles.sliceGrid("head",11,15, 3);
		tiles.sliceGrid("smoke",10,14, 3);
		tiles.defineAnim("0-2(10), 1(10)");
		tiles.sliceGrid("wine",13,14);
		tiles.sliceGrid("beer",14,14);
		tiles.sliceGrid("cane",15,14);
		tiles.sliceGrid("hat",10,15);
		tiles.slice("cadaver",10*10,16*10, 20,20);

		tiles.slice("walker1",0,24*10, 20,20, 3);
		tiles.defineAnim("0(5), 1(7), 2(5)");
		tiles.slice("walker2",0,26*10, 20,20, 3);
		tiles.defineAnim("0(5), 1(7), 2(5)");
		tiles.slice("walker3",0,28*10, 20,20, 3);
		tiles.defineAnim("0(5), 1(7), 2(5)");

		tiles.slice("levelButton", 0,200, 40,40, 4);
		tiles.slice("titleGlow", 0,330, 130, 50);
		tiles.slice("fire", 0,380, 10*4, 10*3, 4);
		tiles.slice("fireSpark", 0,410, 10*2, 10*2, 3);
		tiles.slice("pause", 0,300, 10,10);
		tiles.slice("star", 10,300, 10,10, 3);

		tiles.initBdGroups();


		buffer = new Buffer(300,200, Const.UPSCALE, false, Const.SHADOW);
		root.addChild(buffer.render);
		buffer.drawQuality = LOW;

		if( enableDoubleBuffer ) {
			root.removeChild(buffer.render);

			var s = 1.5;
			doubleBuffer = new Bitmap();
			root.addChild(doubleBuffer);
			doubleBuffer.scaleX = doubleBuffer.scaleY = s;

			dbMatrix = new flash.geom.Matrix();
			dbMatrix.scale(Const.UPSCALE/doubleBuffer.scaleX, Const.UPSCALE/doubleBuffer.scaleY);
		}

		root.stage.quality = flash.display.StageQuality.LOW;
		root.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;

		fx = new Fx(this);

		#if debug
		Sfx.disable();
		#end

		onResize();
	}

	override function onResize() {
		super.onResize();

		Const.WID = Metrics.w();
		Const.HEI = Metrics.h();
		Const.UPSCALE = (Const.HEI/Const.IHEI);
		//Const.UPSCALE = MLib.round( (Const.HEI/Const.IHEI) );

		if( enableDoubleBuffer ) {
			if( doubleBuffer.bitmapData!=null )
				doubleBuffer.bitmapData.dispose();

			doubleBuffer.bitmapData = new BitmapData(MLib.ceil(Const.WID/doubleBuffer.scaleX), MLib.ceil(Const.HEI/doubleBuffer.scaleY), false, Const.SHADOW);
			dbMatrix = new flash.geom.Matrix();
			dbMatrix.scale(Const.UPSCALE/doubleBuffer.scaleX, Const.UPSCALE/doubleBuffer.scaleY);
		}

		buffer.resize(Const.WID/Const.UPSCALE, Const.HEI/Const.UPSCALE, Const.UPSCALE);
		fx.onResize();

		//#if debug
		//trace("ONRESIZE:");
		//trace(Metrics.dpi()+" DPI");
		//trace( Metrics.px2cm( Const.WID )+"cm x"+Metrics.px2cm( Const.HEI ) +"cm" );
		//trace("stage="+Const.WID+"x"+Const.HEI+" buffer="+buffer);
		//if( enableDoubleBuffer )
			//trace("double="+doubleBuffer.bitmapData.width+"x"+doubleBuffer.bitmapData.height+"x"+doubleBuffer.scaleX);
		//#end
	}

	public function createField(str:Dynamic, ?fit=true, ?size=8) {
		var f = new flash.text.TextFormat();
		f.font = "def";
		f.size = size;
		f.color = 0xffffff;

		var tf = new flash.text.TextField();
		tf.width = fit ? 500 : 300;
		tf.height = 50;
		tf.mouseEnabled = tf.selectable = false;
		tf.defaultTextFormat = f;
		tf.embedFonts = true;
		tf.htmlText = Std.string(str);
		tf.multiline = tf.wordWrap = true;
		if( fit ) {
			tf.width = tf.textWidth+5;
			tf.height = tf.textHeight+5;
		}
		return tf;
	}

	public function makeNewCookie() : GameCookie {
		var c : GameCookie = {
			lang	: "en",
			sounds	: 1,
			modes	: new Map(),
		}
		for(k in Type.getEnumConstructs(GameMode)) {
			var e = Type.createEnum(GameMode, k);
			c.modes.set(e, { lastLevel:0 });
		}
		return c;
	}

	public function loadCookie() {
		cookie =  makeNewCookie();

		var raw : String = Lib.getCookie("proletarian", "save", null);
		if( raw!=null ) {
			var reset = false;
			var hj = new mt.deepnight.HaxeJson(Const.SAVE_VERSION);
			hj.unserialize(raw);
			if( hj.getCurrentUnserializedDataVersion()<7 ) {
				// Reset old data
				cookie = makeNewCookie();
				saveCookie();
			}
			else {
				// Retrieves data
				cookie = hj.getUnserialized();
			}

			// Patch missing modes
			for(k in Type.getEnumConstructs(GameMode)) {
				var e = Type.createEnum(GameMode, k);
				if( !cookie.modes.exists(e) ) {
					cookie.modes.set(e, {
						lastLevel	: 0,
					});
					saveCookie();
				}
			}
		}
	}

	public function saveCookie() {
		var hj = new mt.deepnight.HaxeJson(Const.SAVE_VERSION);
		hj.serialize(cookie);
		Lib.setCookie("proletarian", "save", hj.getSerialized());
	}

	public function getModeCookie(m:GameMode) : ModeCookie {
		return cookie.modes.get(m);
	}

	public function quitApp() {
		try flash.desktop.NativeApplication.nativeApplication.exit() catch(e:Dynamic) {
			destroy();
			new m.Intro();
		}
	}

	override function onActivate() {
		super.onActivate();
		resume();
	}

	override function onDeactivate() {
		super.onDeactivate();
		pause();
	}

	public function killSave() {
		Lib.resetCookie("proletarian");
	}

	override function unregister() {
		super.unregister();

		tiles.destroy();
		buffer.destroy();
		fx.destroy();
	}

	override function update() {
		super.update();

		if( Key.isToggled(flash.ui.Keyboard.S) ) {
			Sfx.toggleMuteChannel(0);
			BaseProcess.SBANK.menu01().play();
			fx.flashBang(0x0080FF,0.5, 300);
		}
	}

	public function onBackKey() {
	}

	public function onMenuKey() {
	}

	override function render() {
		super.render();

		tiles.updateChildren();
		fx.update();
		buffer.update();

		if( enableDoubleBuffer && !buffer.destroyed() && doubleBuffer.bitmapData!=null )
			doubleBuffer.bitmapData.draw(buffer.getBitmapData(), dbMatrix);
	}
}
