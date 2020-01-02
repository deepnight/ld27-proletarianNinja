package en;

class Cadaver extends Entity {
	public static var ALL : Array<Cadaver> = [];

	public function new(x,y) {
		super();
		setPos(x,y);

		game.sdm.add(spr, Const.DP_BG);
		ALL.push(this);
		spr.set("cadaver");
		spr.setCenter(0.5,0.7);
	}

	override function unregister() {
		super.unregister();
		ALL.remove(this);
	}
}
