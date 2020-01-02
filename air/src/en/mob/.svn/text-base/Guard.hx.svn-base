package en.mob;

import mt.MLib;
import mt.deepnight.Color;

class Guard extends en.Mob {
	static var TURN = Const.seconds(1); // 1

	public var clockwise	: Bool;
	public var turnDirs		: Array<Int>;
	public var curDir		: Int;
	var turnTimer			: Float;

	public function new(x,y) {
		super(x,y);
		turnDirs = [0,1,2,3];
		clockwise = rseed.random(2)==0;
		turnTimer = rnd(0, Const.seconds(2));
		initDir();
	}

	public function initDir() {
		if( turnDirs.filter(function(d) return d==3).length==0 )
			spr.scaleX = -1;

		curDir = rseed.random(turnDirs.length);
		lookAng = targetLookAng = dirToAng( turnDirs[curDir] );
		setLook(targetLookAng);

		if( turnDirs.length==1 )
			viewCone.transform.colorTransform = Color.getColorizeCT(0x0C5E7C,1);
	}

	override function setLook(a, ?delayed) {
		super.setLook(a,delayed);

		var dir = MLib.round( a/(MLib.PI*0.5) ) + 1;
		if( spr.scaleX<0 ) {
			if( dir==1 ) dir = 3;
			else if( dir==3 ) dir = 1;
		}

		if( delayed )
			game.delayer.add(function() spr.setFrame(dir), 130);
		else
			spr.setFrame(dir);
	}

	override function isSleeping() {
		return super.isSleeping() || turnDirs.length==0;
	}

	public function blockDir(d) {
		turnDirs.remove(d);
	}

	public inline function dirToAng(d:Int) {
		return -1.57 + 1.57*d;
	}

	override function update() {
		if( canPlay() && !game.isFrozen() && game.running && !isSleeping() ) {
			turnTimer--;
			if( turnTimer<=0 ) {
				turnTimer = TURN;
				curDir+=clockwise ? 1 : -1;
				if( curDir<0 ) curDir = turnDirs.length-1;
				if( curDir>=turnDirs.length ) curDir = 0;
				setLook( dirToAng(turnDirs[curDir]) );
			}
		}

		super.update();
	}
}
