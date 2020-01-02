package en.mob;

import Level;

class Walker extends en.Mob {
	//var target			: {cx:Int, cy:Int};
	var origin			: Null<{cx:Int, cy:Int}>;

	public function new(x,y) {
		super(x,y);
		nextTarget();
		speed*=2;
		spr.a.playAndLoop("walker"+skin);
		updateScaleDir();
	}

	function nextTarget() {
		var possibles = [];
		var level = m.Game.ME.level;
		for( d in [{dx:1, dy:0}, {dx:-1, dy:0}, {dx:0, dy:1}, {dx:0, dy:-1}, ] ) {
			var x = cx + d.dx;
			var y = cy + d.dy;
			while( level.inBounds(x,y) && level.getHeight(x,y)==0 ) {
				if( level.hasAsset(APathBlocker, x,y) )
					break;

				if( level.hasAsset(APathTarget, x,y) ) {
					possibles.push({ cx:x, cy:y });
					break;
				}
				else {
					x+=d.dx;
					y+=d.dy;
				}
			}
		}

		if( possibles.length>0 ) {
			if( possibles.length>1 && origin!=null )
				possibles = possibles.filter( function(pt) return pt.cx!=origin.cx || pt.cy!=origin.cy );

			var t = possibles[0];
			goto(t.cx, t.cy);
			targetLookAng = Math.atan2(t.cy-cy, t.cx-cx);

			if( origin==null && possibles.length>1 )
				origin = { cx:possibles[1].cx, cy:possibles[1].cy }
			else
				origin = { cx:cx, cy:cy }
		}
	}

	function updateScaleDir() {
		if( path.length==0 )
			return;

		var next = path[0];
		if( spr.scaleX<0 && next.x<cx )
			spr.scaleX = 1;

		if( spr.scaleX>0 && next.x>cx )
			spr.scaleX = -1;
	}

	override function update() {
		super.update();

		if( path.length==0 )
			nextTarget();

		updateScaleDir();
	}
}
