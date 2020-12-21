package mt.gx.algo;

/**
 * ...
 * @author de
 */

class Heap<T>
{
	var buffer : Array<{ w : Float , data : T }>;
	
	public inline function getBuffer() { return buffer; }
	
	public var length(get_length, never) : Int;
	
	public function new()
	{
		buffer = [];
	}
	
	public inline function get_length()
	{
		return buffer.length;
	}
	
	
	public function heapify( e : { w : Float , data : T } )
	{
		buffer[ buffer.length ] = e;
		if ( length <= 1) return;
		
		var index = buffer.length - 1;
		var half = (index - 1) >> 1;
		while( buffer[index].w < buffer[half].w )
		{
			swap(index, half);
			index = half;
			if ( index == 0 ) return;
			half = (index - 1) >> 1;
		}
	}
	
	public inline function getMin() : { w : Float , data : T }
	{
		return buffer[0];
	}
	
	public function updateWeight( i :Int ) : Void
	{
		if ( (i > 0) && !isHeapLeaf( (i - 1) >> 1 ) )
		{
			var half = (i - 1) >> 1;
			if( half >= 0 && half != i)
			{
				swap(i, half);
				updateWeight(half);
			}
		}
		
		if ( !isHeapLeaf(i))
		{
			if ( 	i * 2 + 1 < buffer.length
			&&		i * 2 + 2 < buffer.length )
			{
				if( buffer[i * 2 + 1].w < buffer[i * 2 + 2].w  )
				{
					swap( i, i * 2 + 1);
					updateWeight(i * 2 + 1);
				}
				else
				{
					swap( i, i * 2 + 2);
					updateWeight(i * 2 + 2);
				}
			}
			else if( i * 2 + 1 < buffer.length  )
			{
				swap( i, i * 2 + 1);
				updateWeight(i * 2 + 1);
			}
			else // i * 2 + 2 < size
			{
				swap( i, i * 2 + 2);
				updateWeight(i * 2 + 2);
			}
		}
		
	}
	
	function isHeapLeaf(i) : Bool
	{
		var res = true;
		
		if ( (i * 2 + 1) < buffer.length )
		{
			if (buffer[i].w > buffer[i * 2 + 1].w) res = false;
		}
		
		if( res && ((i * 2 + 2) < buffer.length ))
		{
			if (buffer[i].w > buffer[i * 2 + 2].w) res = false;
		}
		
		return res;
	}
		
	public function delMin()
	{
		if( buffer.length == 0) return null;
		
		var min = getMin();
		if ( length <= 1 )
		{
			buffer.splice(0, 1);
			return min;
		}
		
		buffer[0] = buffer.pop();
		
		updateWeight(0);
		
		return min;
	}
	
	public inline function getEntry( i )
	{
		return buffer[i];
	}
	
	public inline function swap( i0 : Int ,i1 : Int )
	{
		var k = buffer[i0];
		buffer[i0] = buffer[i1];
		buffer[i1] = k;
	}
	
	public function checkConsistency() : Bool
	{
		for(i in 0...length >> 1)
		{
			if (i*2+1 < length)
			{
				if (buffer[i*2+1].w < buffer[i].w)
				{
					return false;
				}
			}
			
			if(i*2+2 < length)
			{
				if (buffer[i*2+2].w < buffer[i].w)
				{
					return false;
				}
			}
		}
		return true;
	}
	
	public function toString() : String
	{
		var r = "{ ";
		for( x in 0...length )
		{
			r +=  buffer[x].data + " ( w="+buffer[x].w + ") " ;
		}
		r += "}" ;
		return r;
	}
	
	public function reset()
	{
		buffer.splice( 0, buffer.length);
	}
	

}