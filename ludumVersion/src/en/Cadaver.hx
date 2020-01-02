package en;

class Cadaver extends Entity {
	public static var ALL : Array<Cadaver> = [];
	
	public function new(x,y) {
		super();
		setPos(x,y);
		
		game.buffer.dm.add(spr, Const.DP_BG);
		ALL.push(this);
		spr.setGroup("cadaver");
		spr.setCenter(0.5,0.7);
	}
	
	override function unregister() {
		super.unregister();
		ALL.remove(this);
	}
}
