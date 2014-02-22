package scripts
{
	[Bindable]
	public class TextOutput
	{
		public var pos:String;
		public var vel:String;
		public var acclr:String;
		public var mass:String;
		public function TextOutput(specs:Object=null)
		{
			if (specs) {
				pos = specs.pos;
				vel = specs.vel;
				acclr = specs.acclr;
				mass = specs.mass;

				
			}}
	}
}