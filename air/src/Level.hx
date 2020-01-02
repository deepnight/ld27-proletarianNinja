import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.geom.Matrix;
import flash.geom.ColorTransform;
import mt.deepnight.Lib;
import mt.deepnight.Color;

enum LevelAsset {
	@col(0xA32323) AWall;

	@col(0xFF0000) AMobGuard;
	@col(0xFF00B3) AMobWalker;
	@col(0x80FF00) AHero;
	@col(0x6A0000) ABlockSight;
	@col(0xCE8ED7) ADog;
	@col(0xCE8ED7) ADogWalker;

	ATableV4;
	ATableV3;
	ATableH3;
	ATableH2;
	ADrawer;
	AShelf1;
	AShelf2;
	@col(0xB3B5CC) AFirePlace;
	@col(0x00FFFF) AWindow;
	ADoor;

	@col(0xFF00FF) APathTarget;
	@col(0xFF0000) APathBlocker;

	@col(0x808080) AItemAmmo;
	@col(0x453FC0) AItemTime;
}

@:bitmap("assets/level.png") class GfxLevels extends BitmapData {}

typedef LevelData = {
	var assets		: Map<LevelAsset, Array<{cx:Int, cy:Int}>>;
	var diff		: Int;
}

class Level {
	public static var ALL : Array<LevelData> = unserialize( haxe.Resource.getString("levelData") );

	var source				: BitmapData;
	var lid					: Int;
	public var wid			: Int;
	public var hei			: Int;
	public var pixelWid		: Int;
	public var pixelHei		: Int;

	public var data			: LevelData;
	var heightMap			: Array<Array<Int>>;

	public var wrapper		: Sprite;
	public var groundBmp	: Bitmap;
	var alphaMap			: BitmapData;

	public var pfGround		: PathFinder;

	public function new(l:Int) {
		lid = l;
		data = getData(lid);
		wid = 30;
		hei = 20;
		pixelWid = wid*Const.GRID;
		pixelHei = hei*Const.GRID;

		var bd = new GfxLevels(0,0);
		source = new BitmapData(wid,hei,false,0x0);
		source.copyPixels(bd, new flash.geom.Rectangle(0,lid*hei,wid,hei), new flash.geom.Point(0,0));
		bd.dispose();

		wrapper = new Sprite();

		groundBmp = new Bitmap( new BitmapData(wid*Const.GRID, hei*Const.GRID, true, 0x0) );
		wrapper.addChild(groundBmp);
		alphaMap = groundBmp.bitmapData.clone();

		heightMap = new Array();
		for(x in 0...wid) {
			heightMap[x] = new Array();
			for(y in 0...hei)
				heightMap[x][y] = 0;
		}


		pfGround = new PathFinder(wid,hei, false);
		pfGround.moveCost = function(fx,fy, tx,ty) {
			var fh = getHeight(fx,fy);
			var th = getHeight(tx,ty);
			if( fh>=th-Const.H_LOW ) return 1;
			if( th>=Const.H_WALL ) return -1;
			return -1;
		}

		initHeightMap();
	}

	public static function unserialize(raw:String) : Array<LevelData> {
		if( raw==null || raw.length==0 )
			return [];

		var hj = new mt.deepnight.HaxeJson(Const.LEVEL_DATA_VERSION);
		try {
			hj.unserialize(raw);
			hj.patch(1,2, function(o:Array<LevelData>) {
				for( l in o )
					l.diff = 0;
			});
			return hj.getUnserialized();
		} catch(e:Dynamic) {
			trace(e);
			return [];
		}
	}

	public static function serialize() {
		var hj = new mt.deepnight.HaxeJson(Const.LEVEL_DATA_VERSION);
		hj.serialize(ALL);
		return hj.getSerialized();
	}

	public function saveData() {
		ALL[lid] = data;
	}

	public function getData(lid) {
		if( ALL[lid]==null )
			return makeEmptyLevel();
		else
			return ALL[lid];
	}

	public function makeEmptyLevel() {
		var data : LevelData = {
			assets		: new Map(),
			diff		: 0,
		}

		data.assets.set(AWall, []);
		for(cx in 0...wid)
			for(cy in 0...hei)
				data.assets.get(AWall).push({ cx:cx, cy:cy });

		return data;
	}

	public function initHeightMap() {
		for(cx in 0...wid)
			for(cy in 0...hei)
				heightMap[cx][cy] = 0;

		for(a in data.assets.keys())
			for(pt in data.assets.get(a))
				applyAssetHeight(a, pt.cx, pt.cy);
	}

	function applyAssetHeight(a:LevelAsset, cx,cy) {
		var none = 0;
		var low = Const.H_LOW;
		var high = Const.H_HIGH;
		var wall = Const.H_WALL;

		var z = 0;
		var w = 1;
		var h = 1;
		switch( a ) {
			case AWall : z=wall;
			case AFirePlace : z=high; w=3; h=2; cy--;
			case AShelf1 : z=high; w=1; h=2; cy--;
			case AShelf2 : z=high; w=2; h=2; cy--;
			case ADrawer : z=high; w=2; h=2; cy--;
			case ATableV4 : z=low; w=2; h=4;
			case ATableV3 : z=low; w=2; h=3;
			case ATableH2 : z=low; w=2; h=2;
			case ATableH3 : z=low; w=3; h=2;
			default :
		}

		for(x in cx...cx+w)
			for(y in cy...cy+h)
				if( heightMap[x][y] < z )
					heightMap[x][y] = z;
	}

	public function resetBlood() {
		groundBmp.bitmapData.copyPixels(alphaMap, alphaMap.rect, new flash.geom.Point(0,0));
	}

	public function cropMap() {
		var gbd = groundBmp.bitmapData;
		gbd.copyChannel(alphaMap, alphaMap.rect, new flash.geom.Point(0,0), flash.display.BitmapDataChannel.ALPHA, flash.display.BitmapDataChannel.ALPHA);
	}

	public function addAsset(k:LevelAsset,cx,cy) {
		if( !data.assets.exists(k) )
			data.assets.set(k, []);
		data.assets.get(k).push({cx:cx, cy:cy});
	}

	public inline function getAssets(k) {
		return data.assets.exists(k) ? data.assets.get(k) : [];
	}

	public function hasAsset(k,cx,cy) {
		for(pt in getAssets(k))
			if( pt.cx==cx && pt.cy==cy )
				return true;
		return false;
	}

	public function removeAllAssets(cx,cy) {
		for(s in data.assets) {
			var i = 0;
			while( i<s.length ) {
				if( s[i].cx==cx && s[i].cy==cy )
					s.splice(i,1);
				else
					i++;
			}
		}
	}

	public function addEntities() {
		// Guards
		for(pt in getAssets(AMobGuard)) {
			var e = new en.mob.Guard(pt.cx,pt.cy);
			if( hasAsset(ABlockSight, pt.cx, pt.cy-1) ) e.blockDir(0);
			if( hasAsset(ABlockSight, pt.cx, pt.cy+1) ) e.blockDir(2);
			if( hasAsset(ABlockSight, pt.cx-1, pt.cy) ) e.blockDir(3);
			if( hasAsset(ABlockSight, pt.cx+1, pt.cy) ) e.blockDir(1);

			e.initDir();
		}

		// Dogs
		for(pt in getAssets(ADog)) {
			var e = new en.mob.Dog(pt.cx,pt.cy);
			if( hasAsset(ABlockSight, pt.cx, pt.cy-1) ) e.blockDir(0);
			if( hasAsset(ABlockSight, pt.cx, pt.cy+1) ) e.blockDir(2);
			if( hasAsset(ABlockSight, pt.cx-1, pt.cy) ) e.blockDir(3);
			if( hasAsset(ABlockSight, pt.cx+1, pt.cy) ) e.blockDir(1);

			e.initDir();
		}

		// Dog walkers
		for(pt in getAssets(ADogWalker))
			new en.mob.DogWalker(pt.cx,pt.cy);

		// Walkers
		for(pt in getAssets(AMobWalker))
			new en.mob.Walker(pt.cx,pt.cy);

		// Item: shuriken
		for(pt in getAssets(AItemAmmo))
			new en.it.Ammo(pt.cx, pt.cy);

		// Item: time freeze
		if( m.Game.ME.hasChrono() )
			for(pt in getAssets(AItemTime))
				new en.it.TimeFreeze(pt.cx, pt.cy);

		// Hero
		var pt = getAssets(AHero)[0];
		if( pt==null )
			pt = {cx:5, cy:5}
		m.Game.ME.hero.setPos(pt.cx, pt.cy);
	}

	public inline function isWall(cx,cy) {
		return getHeight(cx,cy)>=Const.H_WALL;
	}

	public inline function inBounds(cx,cy) {
		return cx>=0 && cx<wid && cy>=0 && cy<hei;
	}

	public function getHeight(cx,cy) {
		if( !inBounds(cx,cy) )
			return 9999;
		else
			return heightMap[cx][cy];
	}

	public function destroy() {
		groundBmp.bitmapData.dispose();
		alphaMap.dispose();
		source.dispose();
		wrapper.parent.removeChild(wrapper);
	}


	function getAssetColor(a:LevelAsset) {
		var meta = Reflect.field( haxe.rtti.Meta.getFields(LevelAsset), Std.string(a) );
		if( meta==null )
			return 0x0080FF;
		else
			return Std.parseInt(meta.col[0]);
	}

	function getAssetShortName(a:LevelAsset) {
		return switch( a ) {
			case AWall, AWindow : "";
			case APathTarget : "P";
			case APathBlocker : "PB";
			case ADog : "D";
			case ADogWalker : "Dw";
			case AItemAmmo : "Am";
			case AItemTime : "Ti";
			default : Std.string(a).substr(1,2);
		}
	}

	public function editorRefresh(?thumb=false) {
		initHeightMap();
		renderGame(true);

		var bd = groundBmp.bitmapData;

		var sa = new Sprite();
		var tf = BaseProcess.CURRENT.createField("??");
		sa.addChild(tf);

		for( a in data.assets.keys() ) {
			var col = getAssetColor(a);

			if( !thumb ) {
				sa.graphics.clear();
				sa.graphics.lineStyle(1, col, 0.7, true, flash.display.LineScaleMode.NONE);
				sa.graphics.drawRect(1,1,Const.GRID-2,Const.GRID-2);

				tf.text = getAssetShortName(a);
				tf.textColor = Color.brightnessInt(col, 0.5);
			}

			for( pt in data.assets.get(a) ) {
				sa.x = pt.cx*Const.GRID;
				sa.y = pt.cy*Const.GRID;
				bd.draw(sa, sa.transform.matrix);
			}
		}
	}

	public function renderGame(?pretty=true) {
		// Clear
		groundBmp.bitmapData.fillRect(groundBmp.bitmapData.rect, 0x0);

		var tiles = BaseProcess.CURRENT.tiles;

		var rseed = new mt.Rand(lid);

		var gskin = lid % 5;
		var wskin = lid % tiles.countFrames("wall");
		//if( !pretty )
			//gskin = wskin = 0;

		var pt0 = new flash.geom.Point(0,0);
		var gbd = groundBmp.bitmapData;
		var wbd = new BitmapData(wid*Const.GRID, hei*Const.GRID, true, 0x0);

		var bwid = wid*Const.GRID;
		var bhei = hei*Const.GRID;
		for(cx in 0...wid)
			for(cy in 0...hei) {
				var x = cx*Const.GRID;
				var y = cy*Const.GRID;
				if( !isWall(cx,cy) )
					tiles.drawIntoBitmapRandom(gbd, x,y, "ground"+gskin, rseed.random);
				var h = getHeight(cx,cy);
				if( isWall(cx,cy) && !isWall(cx,cy+1) )
					tiles.drawIntoBitmap(wbd, x,y, "wall", wskin);
			}

		var ps = 2;
		var perlin = new BitmapData(Math.ceil(bwid/ps), Math.ceil(bhei/ps), false, 0x0);
		if( pretty ) {
			gbd.applyFilter(gbd, gbd.rect, pt0, new flash.filters.GlowFilter(Const.SHADOW,0.6, 32,32,2, 2,true)); // inner glow
			gbd.applyFilter(gbd, gbd.rect, pt0, new flash.filters.DropShadowFilter(4,80,Const.SHADOW,0.5, 0,0,1, 2,true)); // wall dropshadows (on ground)
			wbd.applyFilter(wbd, wbd.rect, pt0, new flash.filters.DropShadowFilter(1,-90,Const.SHADOW,1, 0,8,1, 2,true)); // wall gradients

			// perlin shadows
			alphaMap.copyPixels(gbd, gbd.rect, pt0);
			var mperlin = new Matrix();
			mperlin.scale(ps,ps);
			perlin.perlinNoise(64,32, 4, lid, false, true, 1, true);
			gbd.draw(perlin, mperlin, new ColorTransform(1,1,1, 0.4), BlendMode.OVERLAY);

			// Clean up alpha
			gbd.copyChannel(alphaMap, gbd.rect, pt0, flash.display.BitmapDataChannel.ALPHA, flash.display.BitmapDataChannel.ALPHA);

			// Flatten wall
			gbd.copyPixels(wbd, wbd.rect, pt0, true);

			// Outside walls
			var c = switch(gskin) {
				case 1 : 0x65403F;
				default : 0x482635;
			}
			gbd.applyFilter(gbd, gbd.rect, pt0, new flash.filters.DropShadowFilter(1,90,Color.brightnessInt(c,0.1),1, 0,0,1));
			gbd.applyFilter(gbd, gbd.rect, pt0, new flash.filters.GlowFilter(c,1, 2,2,100));
			gbd.applyFilter(gbd, gbd.rect, pt0, new flash.filters.GlowFilter(Color.brightnessInt(c, -0.05),1, 3,3,100));
			gbd.applyFilter(gbd, gbd.rect, pt0, new flash.filters.GlowFilter(c,1, 2,2,100));
		}


		// Assets with drop shadow
		var abd = new BitmapData(gbd.width, gbd.height, true, 0x0);
		for(pt in getAssets(ATableV4))
			tiles.drawIntoBitmapRandom(abd, pt.cx*Const.GRID, pt.cy*Const.GRID, "tableV4", rseed.random);

		for(pt in getAssets(ATableV3))
			tiles.drawIntoBitmapRandom(abd, pt.cx*Const.GRID, pt.cy*Const.GRID, "tableV3", rseed.random);

		for(pt in getAssets(ADrawer))
			tiles.drawIntoBitmap(abd, pt.cx*Const.GRID, (pt.cy-1)*Const.GRID, "drawer");

		for(pt in getAssets(AShelf2))
			tiles.drawIntoBitmap(abd, pt.cx*Const.GRID, (pt.cy-1)*Const.GRID, "shelf2");

		for(pt in getAssets(AShelf1))
			tiles.drawIntoBitmap(abd, pt.cx*Const.GRID, (pt.cy-1)*Const.GRID, "shelf1");

		for(pt in getAssets(AFirePlace))
			tiles.drawIntoBitmap(abd, pt.cx*Const.GRID, (pt.cy-1)*Const.GRID, "fireplace");

		for(pt in getAssets(ATableH3))
			tiles.drawIntoBitmap(abd, pt.cx*Const.GRID, (pt.cy)*Const.GRID, "tableH3");

		for(pt in getAssets(ATableH2))
			tiles.drawIntoBitmap(abd, pt.cx*Const.GRID, (pt.cy)*Const.GRID, "tableH2");

		abd.applyFilter(abd, abd.rect, pt0, new flash.filters.DropShadowFilter(4,15, Const.SHADOW,0.25, 0,0));
		gbd.draw(abd);

		// Assets WITHOUT drop shadow
		for(pt in getAssets(ADoor))
			tiles.drawIntoBitmap(gbd, pt.cx*Const.GRID, (pt.cy)*Const.GRID, "door");

		// Windows
		var s = tiles.get("windowLight");
		for(pt in getAssets(AWindow)) {
			tiles.drawIntoBitmap(gbd, pt.cx*Const.GRID, pt.cy*Const.GRID, "window", lid % tiles.countFrames("window"));

			var m = new Matrix();
			m.translate(pt.cx*Const.GRID, (pt.cy+1)*Const.GRID);
			s.filters = [ new flash.filters.GlowFilter(0xffffff, 1,16,16) ];
			gbd.draw(s, m, new ColorTransform(1,1,1, Lib.rnd(0.4, 0.6)), BlendMode.OVERLAY);
		}

		perlin.dispose();
		wbd.dispose();
		alphaMap.copyPixels(gbd, gbd.rect, pt0);
	}
}

