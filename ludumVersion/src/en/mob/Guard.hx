package en.mob;

class Guard extends en.Mob {
	public var clockwise	: Bool;
	public var turnDirs		: Array<Int>;
	public var curDir		: Int;
	
	public function new(x,y) {
		super(x,y);
		turnDirs = [0,1,2,3];
		clockwise = rseed.random(2)==0;
		cd.set("turn", rnd(0,60));
		initDir();
	}
	
	public function initDir() {
		if( turnDirs.filter(function(d) return d==3).length==0 )
			spr.scaleX = -1;
		curDir = rseed.random(turnDirs.length);
		lookAng = targetLookAng = dirToAng( turnDirs[curDir] );
		setLook(targetLookAng);
		spr.setFrame(0);
		if( turnDirs.length==1 )
			viewCone.transform.colorTransform = mt.Color.getColorizeCT(0x0C5E7C,1);
	}
	
	public function blockDir(d) {
		turnDirs.remove(d);
	}
	
	public inline function dirToAng(d:Int) {
		return -1.57 + 1.57*d;
	}
	
	override function update() {
		if( game.running && !cd.hasSet("turn", Const.FPS*1) ) {
			curDir+=clockwise ? 1 : -1;
			if( curDir<0 ) curDir = turnDirs.length-1;
			if( curDir>=turnDirs.length ) curDir = 0;
			setLook( dirToAng(turnDirs[curDir]) );
		}
			
		super.update();
	}
}
