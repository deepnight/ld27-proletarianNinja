package mt;

class Cooldown 
{
	public var defaultAllowLower	: Bool;
	var cdList						: Array<{k:String, v:Float, cb:Null<Void->Void>}>;
	var fastCheck					: Map<String, Bool>;
	
	public function new()
	{
		defaultAllowLower = true;
		reset();
	}
	
	public inline function reset() 
	{
		cdList = new Array();
		fastCheck = new Map();
	}
	
	public inline function get(k) : Int 
	{
		var cd = getCdObject(k);
		return cd == null ? -1 : Math.ceil(cd.v);
	}
	
	public inline function getFloat(k) : Float 
	{
		var cd = getCdObject(k);
		return cd == null ? -1 : cd.v;
	}
	
	// only called once when cooldown reaches 0, then CB destroyed
	public inline function onComplete(k, onceCB:Void->Void) 
	{ 
		var cd = getCdObject(k);
		if( cd == null )
			throw "cannot bind onComplete("+k+"): cooldown "+k+" isn't running";
		cd.cb = onceCB;
	}
	
	function getCdObject(k:String) 
	{
		for (cd in cdList)
		{
			if( cd.k == k )
				return cd;
		}
		return null;
	}
	
	public inline function set(k:String, v:Float, ?allowLower:Bool) 
	{
		var cur = getCdObject(k);
		if ( cur == null || allowLower == true || defaultAllowLower || v > cur.v ) 
		{
			if ( v <= 0 ) 
			{
				if( cur != null )
					unsetObject(cur);
			}
			else 
			{
				fastCheck.set(k, true);
				if( cur != null )
					cur.v = v;
				else
					cdList.push({k:k, v:v, cb:null});
			}
		}
		return this;
	}
	
	public inline function unset(k:String) 
	{
		for (cd in cdList)
		{
			if ( cd.k == k )
			{
				unsetObject(cd);
				break;
			}
		}
	}
	
	inline function unsetObject(cd) 
	{
		cdList.remove(cd);
		cd.v = 0;
		fastCheck.set(cd.k, false);
	}
	
	// supprime tous les cooldowns dont la clé contient "search"
	public inline function unsetAll(search:String) 
	{ 
		for ( cd in cdList )
		{
			if( cd.k.indexOf(search) >= 0 )
				unsetObject(cd);
		}
	}
	
	public inline function has(k) 
	{
		return fastCheck.get(k);
	}
	
	public inline function hasSet(k, v:Float) 
	{
		return		if ( has(k) )
					{
						true;
					} 
					else 
					{
						set(k, v);
						false;
					}
	}
	
	public function update(?tmod = 1.0) 
	{
		for ( cd in cdList )
		{
			if ( cd.v - tmod <= 0 )
			{
				unsetObject(cd);
				if( cd.cb!=null ) {
					var cb = cd.cb;
					cd.cb = null;
					cb();
				}
			}
			else
			{
				cd.v -= tmod;
			}
		}
	}
}
