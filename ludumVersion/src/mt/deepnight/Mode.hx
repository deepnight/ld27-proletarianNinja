package mt.deepnight;

import flash.display.Sprite;
import flash.display.DisplayObjectContainer;

class Mode {
	public static var DEFAULT_ROOT_PARENT : DisplayObjectContainer = flash.Lib.current;
	
	static var ALL : Array<Mode> = [];
	static var KILL_LIST : Array<Mode> = [];
	
	var fps					: Float;
	public var root			: Sprite;
	public var tw			: Tweenie;
	public var cd			: Cooldown;
	public var delayer		: mt.Delayer;
	
	public var time(default,null)		: Int;
	public var rendering(default,null)	: Bool;
	public var paused(default,null)		: Bool;
	public var destroyed(default,null)	: Bool;
	
	
	public function new( ?parent:DisplayObjectContainer, ?fps=30 ) {
		ALL.push(this);
		this.fps = fps;
		paused = false;
		destroyed = false;
		time = 0;
		
		root = new Sprite();
		if( parent!=null )
			parent.addChild(root);
		else
			DEFAULT_ROOT_PARENT.addChild(root);
		
		delayer = new Delayer(fps);
		tw = new Tweenie(fps);
		cd = new Cooldown();
	}
	
	
	public function destroy() {
		if( !destroyed ) {
			pause();
			destroyed = true;
			root.parent.removeChild(root);
			KILL_LIST.push(this);
		}
	}
	
	public function pause() {
		paused = true;
	}
	public function resume() {
		paused = false;
	}
	
	
	private function preUpdate() {
		delayer.update();
		tw.update();
		cd.update();
	}
	
	private function update() {
	}
	
	private function postUpdate() {
	}
	
	private function render() {
	}

	public static function updateAll(?render=true) {
		for(m in ALL)
			if( !m.paused && !m.destroyed ) {
				m.rendering = render;
				m.preUpdate();
				m.update();
				m.postUpdate();
				if( render )
					m.render();
				m.time++;
			}
			
		for(m in KILL_LIST)
			ALL.remove(m);
		KILL_LIST = [];
	}
	
	
}
