package scripts
{
	import mx.collections.ArrayCollection;

	[Bindable]
	public class OutputObject
	{
		public var mass:String;
		public var time:String;
		public var speed:String;
		public var elementVectors:ArrayCollection;
		public function OutputObject(specs:Object=null)
		{
			if (specs) {
				mass = specs.mass;
				
				time = specs.time;
				speed = specs.speed;
			}}
	}
}