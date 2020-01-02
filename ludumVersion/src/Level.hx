import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.geom.Matrix;
import flash.geom.ColorTransform;
import mt.Color;
import mt.deepnight.Lib;

@:bitmap("assets/level.png") class GfxLevels extends BitmapData {}

class Level {
	var game				: m.Game;
	var source				: BitmapData;
	public var wid			: Int;
	public var hei			: Int;
	var map					: Array<Array<Int>>;
	var wrapper				: Sprite;
	public var groundBmp	: Bitmap;
	var alphaMap			: BitmapData;
	public var pfGround		: PathFinder;
	//public var pfJump		: PathFinder;
	public var spots		: Map<String, Array<{cx:Int, cy:Int}>>;
	
	public function new() {
		game = m.Game.ME;
		wid = 30;
		hei = 20;
		spots = new Map();
		
		var bd = new GfxLevels(0,0);
		source = new BitmapData(wid,hei,false,0x0);
		source.copyPixels(bd, new flash.geom.Rectangle(0,game.lid*hei,wid,hei), new flash.geom.Point(0,0));
		bd.dispose();
		
		wrapper = new Sprite();
		game.buffer.dm.add(wrapper, Const.DP_BG);
		
		groundBmp = new Bitmap( new BitmapData(wid*Const.GRID, hei*Const.GRID, true, 0x0) );
		wrapper.addChild(groundBmp);
		alphaMap = groundBmp.bitmapData.clone();
		
		map = new Array();
		for(x in 0...wid) {
			map[x] = new Array();
			for(y in 0...hei) {
				var p = source.getPixel(x,y);
				if( p==0xFFFFFF )
					map[x][y] = 99;
					
				if( p==0x96643b )
					map[x][y] = 4;
					
				if( p==0xff4e00 )
					addSpot("guard", x,y);
					
				if( p==0x608dac )
					addSpot("blockAng", x,y);
					
				if( p==0x96643b && source.getPixel(x-1,y)!=0x96643b && source.getPixel(x,y-1)!=0x96643b && source.getPixel(x,y+3)==0x96643b )
					addSpot("table", x,y);
					
				if( p==0x00ff00 )
					addSpot("start", x,y);
					
				if( p==0x1c9692 || p==0x919191 || p==0x8a4696 )
					map[x][y] = 50;
					
				if( p==0x1c9692 && source.getPixel(x-1,y)==0x0 )
					addSpot("drawer", x,y);
					
				if( p==0x8a4696 && source.getPixel(x-1,y)==0x0 )
					addSpot("shelf", x,y);
					
				if( p==0x919191 && source.getPixel(x-1,y)==0x0 )
					addSpot("fireplace", x,y);
					
			}
		}
		
		pfGround = new PathFinder(wid,hei, false);
		pfGround.moveCost = function(fx,fy, tx,ty) {
			var fh = getHeight(fx,fy);
			var th = getHeight(tx,ty);
			if( fh>=th-4 ) return 1;
			if( th>=99 ) return -1;
			return -1;
		}
		//pfJump = new PathFinder(wid,hei, false);
		//pfJump.moveCost = function(fx,fy, tx,ty) {
			//if( getHeight(tx,ty)>=99 )
				//return -1;
			//else
				//return 1;
		//}
	}
	
	public function reset() {
		groundBmp.bitmapData.copyPixels(alphaMap, alphaMap.rect, new flash.geom.Point(0,0));
	}
	
	public function cropMap() {
		var gbd = groundBmp.bitmapData;
		gbd.copyChannel(alphaMap, alphaMap.rect, new flash.geom.Point(0,0), flash.display.BitmapDataChannel.ALPHA, flash.display.BitmapDataChannel.ALPHA);
	}
	
	public function addSpot(k:String,cx,cy) {
		if( !spots.exists(k) )
			spots.set(k, []);
		spots.get(k).push({cx:cx, cy:cy});
	}
	
	public function getSpots(k) {
		return spots.exists(k) ? spots.get(k) : [];
	}
	
	public function hasSpot(k,cx,cy) {
		for(pt in getSpots(k))
			if( pt.cx==cx && pt.cy==cy )
				return true;
		return false;
	}
	
	public function addEntities() {
		for(pt in getSpots("guard")) {
			var e = new en.mob.Guard(pt.cx,pt.cy);
			if( hasSpot("blockAng", pt.cx, pt.cy-1) ) e.blockDir(0);
			if( hasSpot("blockAng", pt.cx, pt.cy+1) ) e.blockDir(2);
			if( hasSpot("blockAng", pt.cx-1, pt.cy) ) e.blockDir(3);
			if( hasSpot("blockAng", pt.cx+1, pt.cy) ) e.blockDir(1);
			
			e.initDir();
		}
		var pt = getSpots("start")[0];
		game.hero.setPos(pt.cx, pt.cy);
	}
	
	public inline function isWall(cx,cy) {
		return getHeight(cx,cy)>=99;
	}
	
	//public function hasCollision(cx,cy) {
		//if( cx<0 || cx>=wid || cy<0 || cy>=hei )
			//return true;
		//else
			//return map[cx][cy];
	//}
	
	public function getHeight(cx,cy) {
		if( cx<0 || cx>=wid || cy<0 || cy>=hei )
			return 9999;
		else
			return map[cx][cy];
	}
	
	public function destroy() {
		groundBmp.bitmapData.dispose();
		alphaMap.dispose();
		source.dispose();
		wrapper.parent.removeChild(wrapper);
	}
	
	public function draw() {
		var gskin = game.lid % 5;
		var skin = game.lid % game.tiles.countFrames("wall");
		var pt0 = new flash.geom.Point(0,0);
		var gbd = groundBmp.bitmapData;
		var wbd = new BitmapData(wid*Const.GRID, hei*Const.GRID, true, 0x0);
		
		var bwid = wid*Const.GRID;
		var bhei = hei*Const.GRID;
		var windows = [];
		for(cx in 0...wid)
			for(cy in 0...hei) {
				var x = cx*Const.GRID;
				var y = cy*Const.GRID;
				if( !isWall(cx,cy) )
					game.tiles.drawIntoBitmapRandom(gbd, x,y, "ground"+gskin);
				var h = getHeight(cx,cy);
				if( isWall(cx,cy) && !isWall(cx,cy+1) ) {
					if( cx%3==0 && isWall(cx,cy-2) && isWall(cx+1,cy) ) {
						windows.push({cx:cx, cy:cy});
						game.tiles.drawIntoBitmap(wbd, x,y, "window", skin);
					}
					else
						game.tiles.drawIntoBitmap(wbd, x,y, "wall", skin);
				}
			}
			

		gbd.applyFilter(gbd, gbd.rect, pt0, new flash.filters.GlowFilter(Const.SHADOW,0.8, 32,32,1, 2,true)); // inner glow
		gbd.applyFilter(gbd, gbd.rect, pt0, new flash.filters.DropShadowFilter(4,80,Const.SHADOW,0.5, 0,0,1, 2,true)); // wall dropshadows (on ground)
		wbd.applyFilter(wbd, wbd.rect, pt0, new flash.filters.DropShadowFilter(1,-90,Const.SHADOW,1, 0,8,1, 2,true)); // wall gradients
		
		// perlin shadows
		alphaMap.copyPixels(gbd, gbd.rect, pt0);
		var s = 2;
		var perlin = new BitmapData(Math.ceil(bwid/s), Math.ceil(bhei/s), false, 0x0);
		var mperlin = new Matrix();
		mperlin.scale(s,s);
		perlin.perlinNoise(64,32, 4, game.seed, false, true, true);
		gbd.draw(perlin, mperlin, new ColorTransform(1,1,1, 0.4), BlendMode.OVERLAY);
		
		// Window lights
		var s = game.tiles.get("windowLight");
		for(pt in windows) {
			var m = new Matrix();
			m.translate(pt.cx*Const.GRID, (pt.cy+1)*Const.GRID);
			s.filters = [ new flash.filters.GlowFilter(0xffffff, 1,16,16) ];
			gbd.draw(s, m, new ColorTransform(1,1,1, Lib.rnd(0.2, 0.6)), BlendMode.OVERLAY);
		}
		
		// Clean up alpha
		gbd.copyChannel(alphaMap, gbd.rect, pt0, flash.display.BitmapDataChannel.ALPHA, flash.display.BitmapDataChannel.ALPHA);
		
		// Flatten wall
		gbd.copyPixels(wbd, wbd.rect, pt0, true);
		
		// Outside walls
		var c : ColorCode = switch(skin) {
			case 1 : 0x65403F;
			default : 0x482635;
		}
		gbd.applyFilter(gbd, gbd.rect, pt0, new flash.filters.DropShadowFilter(1,90,Color.brightness(c,0.1),1, 0,0,1));
		gbd.applyFilter(gbd, gbd.rect, pt0, new flash.filters.GlowFilter(c,1, 2,2,100));
		gbd.applyFilter(gbd, gbd.rect, pt0, new flash.filters.GlowFilter(Color.brightness(c, -0.05),1, 3,3,100));
		gbd.applyFilter(gbd, gbd.rect, pt0, new flash.filters.GlowFilter(c,1, 2,2,100));

		// Furnitures
		for(pt in getSpots("table"))
			game.tiles.drawIntoBitmapRandom(gbd, pt.cx*Const.GRID, pt.cy*Const.GRID, "table");
		for(pt in getSpots("drawer"))
			game.tiles.drawIntoBitmap(gbd, pt.cx*Const.GRID, (pt.cy-1)*Const.GRID, "drawer");
		for(pt in getSpots("shelf"))
			game.tiles.drawIntoBitmap(gbd, pt.cx*Const.GRID, (pt.cy-1)*Const.GRID, "shelf");
		for(pt in getSpots("fireplace"))
			game.tiles.drawIntoBitmap(gbd, pt.cx*Const.GRID, (pt.cy-2)*Const.GRID, "fireplace");

		perlin.dispose();
		wbd.dispose();
		alphaMap.copyPixels(gbd, gbd.rect, pt0);
	}
}

