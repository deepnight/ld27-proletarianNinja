package ui;

import mt.MLib;
//import mt.Metrics;

class PauseButton extends Button {
	public function new(p, cb:Void->Void) {
		super(p, "?", cb);
		hasBackground = false;

		label.bitmapData.dispose();
		var s = BaseProcess.CURRENT.tiles.get("pause");
		s.setCenter(0,0);
		label.bitmapData = mt.deepnight.Lib.flatten(s, 5).bitmapData;
		s.dispose();

		scale(0);
	}

	public function scale(s) {
		label.scaleX = label.scaleY = s;
	}
}