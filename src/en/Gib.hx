package en;

class Gib extends Entity {
	var dr				: Float;
	
	public function new(x,y, k:String, ?f=0) {
		super();
		rseed.initSeed(Std.random(999999));
		
		setPosPixel(x,y);
		dz = 6;
		dr = rnd(9,20,true);
		gravity*=0.7;
		frict = 0.85;
		setShadow(true);
		dx = rnd(0.1, 0.7, true);
		dy = rnd(0.3, 0.7, true);
		
		spr.setGroup(k,f);
		spr.setCenter(0.5,1);
		spr.scaleX = rseed.sign();
		spr.alpha = 0.7;
	}
	
	override function update() {
		super.update();
		if( !stable )
			spr.rotation += dr;
		else {
			spr.alpha = 1;
			spr.rotation = 0;
		}
	}
}