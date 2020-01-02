package m;

import Const;
import Level;

import flash.display.Sprite;
import flash.ui.Keyboard;
import mt.MLib;
import mt.flash.Key;
import mt.deepnight.mui.*;

enum EditorTool {
	TPaint;
	TErase;
}

class Editor extends BaseProcess {
	var lid			: Int;
	var level		: Level;
	var cursor		: Sprite;
	var selection	: Sprite;
	var curTool		: Null<EditorTool>;
	var curAsset	: LevelAsset;
	var drag		: Null<{rect:Bool, startX:Int, startY:Int, cx:Int, cy:Int}>;

	//var wrapper		: Sprite;
	//var sdm			: mt.flash.DepthManager;
	var menu			: Group;
	var tools			: Group;
	var tbuttons		: Map<LevelAsset, Radio>;
	var curOrganizer	: Null<Window>;

	public function new(l:Int) {
		super();
		lid = l;
		curTool = null;
		tbuttons = new Map();

		buffer.resize(Const.WID/2, Const.HEI/2, 2);

		//wrapper = new Sprite();
		//root.addChild(wrapper);
		//sdm = new mt.flash.DepthManager(wrapper);

		selectLevel(lid);

		cursor = new Sprite();
		buffer.dm.add(cursor, Const.DP_INTERF);
		cursor.graphics.lineStyle(1,0xFFFF00,0.5);
		cursor.graphics.drawRect(1,1,Const.GRID-2,Const.GRID-2);

		selection = new Sprite();
		buffer.dm.add(selection, Const.DP_INTERF);
		selection.graphics.lineStyle(1,0xFFFF00,0.5, true, flash.display.LineScaleMode.NONE);
		selection.graphics.drawRect(0,0,100,100);
		selection.visible = false;

		// Attention: unregister sur destroy() !!
		buffer.render.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, onLeftDown);
		root.stage.addEventListener(flash.events.MouseEvent.MOUSE_UP, onLeftUp);
		//buffer.render.addEventListener(flash.events.MouseEvent.MOUSE_UP, onLeftUp);
		buffer.render.addEventListener(flash.events.MouseEvent.RIGHT_MOUSE_DOWN, onRightDown);
		root.stage.addEventListener(flash.events.MouseEvent.RIGHT_MOUSE_UP, onRightUp);
		//buffer.render.addEventListener(flash.events.MouseEvent.RIGHT_MOUSE_UP, onRightUp);
		root.stage.addEventListener(flash.events.Event.MOUSE_LEAVE, onLeave);

		menu = new HGroup(root);
		menu.removeBorders();
		menu.margin = 2;

		// Main menu
		menu.button("Save", onSave);
		var g = menu.hgroup();
		g.label("Test:");
		g.button("Easy", onTest.bind(Easy));
		g.button("Timed", onTest.bind(Timed));
		g.button("TurnBased", onTest.bind(TurnBased));
		menu.button("Organizer", function() showOrganizer(lid-2));
		menu.button("Empty current", confirm.bind(function() {
			level.data = level.makeEmptyLevel();
			level.editorRefresh();
		}));

		// Difficulty
		menu.separator();
		menu.label("Difficulty");
		var g = menu.hgroup();
		for(d in 0...5) {
			var r = g.radio(Std.string(d), d==level.data.diff, function(v) if(v) level.data.diff=d);
			r.setWidth(20);
			r.watchValue( function() return level.data.diff==d );
		}
		menu.separator();

		// Tool buttons
		tools = new VGroup(root);
		var keys = Lambda.array(Type.getEnumConstructs(LevelAsset));
		keys.sort( function(a,b) return Reflect.compare(a,b) );
		for(k in keys) {
			var a = Type.createEnum(LevelAsset, k);
			var b = tools.radio(k, function(v) {
				if( v )
					selectAsset(a);
			});
			tbuttons.set(a, b);
		}

		tools.x = 650;

		selectAsset(AWall);
	}

	function onSave() {
		saveCurrent();

		mt.deepnight.Lib.saveFile("data.json", Level.serialize(), function() {
			fx.flashBang(0x80FF00, 0.3, 600);
		});
	}

	function saveCurrent() {
		level.saveData();
	}

	function selectLevel(l) {
		lid = l;

		if( level!=null )
			level.destroy();

		level = new Level(lid);
		buffer.dm.add(level.wrapper, Const.DP_BG);
		level.wrapper.y = 50;
		level.editorRefresh();
	}

	function onTest(m:GameMode) {
		saveCurrent();

		destroy();
		new Game(lid, m);
	}

	function selectAsset(a:LevelAsset) {
		curAsset = a;
		tbuttons.get(a).select();
	}

	function moveLevel(l:Int, dir:Int) {
		var cur = Level.ALL[l];
		var to = Level.ALL[l+dir];

		if( to==null )
			return;

		Level.ALL[l] = to;
		Level.ALL[l+dir] = cur;
	}

	function hideOrganizer() {
		if( curOrganizer!=null ) {
			curOrganizer.destroy();
			curOrganizer = null;
		}
	}



	function showOrganizer(base:Int) {
		hideOrganizer();

		var max = 10;

		if( base>=Level.ALL.length-max )
			base = Level.ALL.length-max;

		if( base<0 )
			base = 0;

		saveCurrent();

		var w = new Window(root, function(w) hideOrganizer());
		curOrganizer = w;
		w.setClickTrap(Const.SHADOW, 0.7);

		var cols = w.vgroup(true);

		// Left panel
		var left = cols.hgroup();
		left.removeBorders();
		left.button("Insert new after", function() {
			Level.ALL.insert(lid+1, level.makeEmptyLevel());
			selectLevel(lid+1);
			hideOrganizer();
		});

		// Right panel
		var list = cols.hgroup();
		list.removeBorders();
		list.margin = 2;

		list.button(" << ", function() {
			selectLevel(0);
			showOrganizer(lid);
		});
		list.button(" < ", function() {
			showOrganizer(base-2);
		});


		// Level list
		for(i in base...base+max) {
			if( i>=Level.ALL.length )
				continue;

			var g = list.vgroup();
			g.removeBorders();
			g.padding = 4;
			g.margin = 2;
			if( i==lid ) {
				g.color = 0xFFA600;
				g.hasBackground = true;
			}

			// Level preview
			var l = new Level(i);
			l.renderGame(false);

			var wrapper = new Sprite();
			wrapper.addChild(l.wrapper);
			wrapper.scaleX = wrapper.scaleY = 0.4;

			var bmp = mt.deepnight.Lib.flatten(wrapper, true);
			l.destroy();

			// Level ID
			var tf = createField(Std.string(i), true);
			var f = tf.getTextFormat();
			f.size = 40;
			tf.setTextFormat(f);
			tf.width = 80;
			bmp.bitmapData.draw(tf);

			// Diff
			var tf = createField(Std.string(l.data.diff));
			var f = tf.getTextFormat();
			f.size = 40;
			f.color = switch( l.data.diff ) {
				case 0 : 0x00FF00;
				case 1 : 0xD8FE01;
				case 2 : 0xFFC600;
				case 3 : 0xFF6C00;
				case 4 : 0xFF0000;
				default : 0x0080FF;
			}
			tf.setTextFormat(f);
			//tf.filters = [ new flash.filters.GlowFilter(mt.deepnight.Color.setLuminosityInt(f.color,0.2),1, 2,2,10) ];
			tf.y = 150;
			bmp.bitmapData.draw(tf, tf.transform.matrix);

			var b = new IconButton(g, bmp, function() {
				if( lid==i )
					hideOrganizer();
				else {
					selectLevel(i);
					hideOrganizer();
				}
			}, function() bmp.bitmapData.dispose());
			b.color = 0x181C23;

			// Actions
			var actions = g.hgroup(true);
			actions.button(" < ", function() {
				moveLevel(i, -1);
				selectLevel(i-1);
				showOrganizer(base);
			});

			actions.button(" > ", function() {
				moveLevel(i, 1);
				selectLevel(i+1);
				showOrganizer(base);
			});
			actions.button("Delete", confirm.bind(function() {
				Level.ALL.splice(i,1);
				selectLevel( MLib.min(i, Level.ALL.length-1) );
				showOrganizer(base);
			}) );
		}

		list.button(" > ", function() {
			showOrganizer(base+2);
		});
		list.button(" >> ", function() {
			selectLevel(Level.ALL.length-1);
			showOrganizer(lid);
		});

	}


	function confirm( cb:Void->Void ) {
		var w = new Window(root, function(w) w.destroy());
		w.setClickTrap(Const.SHADOW, 0.7);
		w.label("Confirm action?");
		w.button("Yes", function() {
			cb();
			w.destroy();
		});
		w.button("CANCEL", w.destroy);
	}


	override function unregister() {
		root.stage.removeEventListener(flash.events.MouseEvent.MOUSE_UP, onLeftUp);
		root.stage.removeEventListener(flash.events.MouseEvent.RIGHT_MOUSE_UP, onRightUp);

		super.unregister();

		level.destroy();
		menu.destroy();
	}

	function onLeftDown(_) {
		curTool = TPaint;
		var m = getMouse();
		drag = { rect:Key.isDown(Keyboard.SHIFT), startX:m.cx, startY:m.cy, cx:m.cx, cy:m.cy }
	}

	function onLeftUp(_) {
		if( drag!=null && drag.rect ) {
			var m = getMouse();
			for(cx in drag.startX...m.cx+1)
				for(cy in drag.startY...m.cy+1)
					applyTool(curTool, cx,cy);

			level.editorRefresh();
		}

		curTool = null;
		drag = null;
		selection.visible = false;
	}

	function onRightDown(_) {
		curTool = TErase;
		var m = getMouse();
		drag = { rect:Key.isDown(Keyboard.SHIFT), startX:m.cx, startY:m.cy, cx:m.cx, cy:m.cy }
	}

	function onRightUp(_) {
		if( drag!=null && drag.rect ) {
			var m = getMouse();
			for(cx in drag.startX...m.cx+1)
				for(cy in drag.startY...m.cy+1)
					applyTool(curTool, cx,cy);

			level.editorRefresh();
		}

		curTool = null;
		drag = null;
		selection.visible = false;
	}

	function onLeave(_) {
		onLeftUp(null);
		onRightUp(null);
	}

	public inline function getMouse() {
		var sx = Std.int((root.mouseX-buffer.render.x)/buffer.upscale - level.wrapper.x);
		var sy = Std.int((root.mouseY-buffer.render.y)/buffer.upscale - level.wrapper.y);
		return {
			gx	: root.mouseX,
			gy	: root.mouseY,
			sx	: sx,
			sy	: sy,
			cx	: Std.int(sx/Const.GRID),
			cy	: Std.int(sy/Const.GRID),
		}
	}

	function pan(dx:Int, dy:Int) {
		for(alist in level.data.assets) {
			var i = 0;
			while( i<alist.length ) {
				var pt = alist[i];
				pt.cx+=dx;
				pt.cy+=dy;
				if( !level.inBounds(pt.cx, pt.cy) )
					alist.splice(i,1);
				else
					i++;
			}
		}

		if( dx!=0 )
			for(cy in 0...level.hei)
				level.addAsset(AWall, dx<0 ? level.wid-1 : 0, cy);

		if( dy!=0 )
			for(cx in 0...level.wid)
				level.addAsset(AWall, cx, dy<0 ? level.hei-1 : 0);

		level.editorRefresh();
	}

	function applyTool(t:EditorTool, cx,cy) {
		if( !level.inBounds(cx,cy) )
			return;

		switch( t ) {
			case TPaint :
				if( !level.hasAsset(curAsset, cx, cy) )
					level.addAsset(curAsset, cx, cy);

			case TErase :
				level.removeAllAssets(cx, cy);
		}
	}

	override function update() {
		super.update();

		if( Key.isToggled(Keyboard.LEFT) )	pan(-1, 0);
		if( Key.isToggled(Keyboard.RIGHT) )	pan(1, 0);
		if( Key.isToggled(Keyboard.UP) )	pan(0, -1);
		if( Key.isToggled(Keyboard.DOWN) )	pan(0, 1);

		if( Key.isToggled(Keyboard.T) )
			onTest(Timed);

		if( Key.isToggled(Keyboard.W) && lid>0 )
			selectLevel(lid-1);

		if( Key.isToggled(Keyboard.X) && lid<Level.ALL.length-1 )
			selectLevel(lid+1);

		if( Key.isToggled(Keyboard.SPACE) )	{
			if( curOrganizer!=null )
				hideOrganizer();
			else
				showOrganizer(lid-2);
		}
		if( Key.isToggled(Keyboard.ESCAPE) ) hideOrganizer();

		var m = getMouse();
		cursor.x = level.wrapper.x + m.cx*Const.GRID;
		cursor.y = level.wrapper.y + m.cy*Const.GRID;
		if( drag!=null ) {
			if( !drag.rect && Key.isDown(Keyboard.SHIFT) )
				drag.rect = true;

			if( drag.rect ) {
				selection.visible = true;
				selection.x = drag.startX*Const.GRID + level.wrapper.x;
				selection.y = drag.startY*Const.GRID + level.wrapper.y;
				selection.width = (m.cx-drag.startX+1)*Const.GRID;
				selection.height = (m.cy-drag.startY+1)*Const.GRID;
			}
			else {
				for( pt in mt.deepnight.Bresenham.getThinLine(m.cx, m.cy, drag.cx, drag.cy) )
					applyTool(curTool, pt.x, pt.y);
				level.editorRefresh();
			}

			drag.cx = m.cx;
			drag.cy = m.cy;
		}
	}
}