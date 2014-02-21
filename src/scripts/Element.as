package scripts
{
	import mx.events.PropertyChangeEvent;
	import mx.graphics.SolidColor;
	
	import spark.components.Group;
	import spark.primitives.Ellipse;

	public class Element
	{
		[Bindable]
		public var position:MyVector;
		[Bindable]
		public var velocity:MyVector;
		[Bindable]
		public var acceleration:MyVector;
		[Bindable]
		public var mass:Number = 10;
		public var radius:Number = 20;
		public var image:Ellipse;
		public function Element(canvas:Group, color:uint)
		{
			position = new MyVector(OrbitalSimulator.numDim);
			velocity = new MyVector(OrbitalSimulator.numDim);
			acceleration = new MyVector(OrbitalSimulator.numDim);
			for (var i:int = 0; i < OrbitalSimulator.numDim; i++) {
				position[i] = 0;
				velocity[i] = 0;
				acceleration[i] = 0;
			}
			image = new Ellipse();
			image.width = radius;
			image.height = radius;
			image.fill = new SolidColor(color);
			image.x = position[0];
			image.y = position[1];
			canvas.addElement(image);
		}
		
		public function update(ms:Number):void {
			image.x = position[0];
			image.y = position[1];
			velocity.add(acceleration.mult(ms/1000), true);
			position.add(velocity.mult(ms/1000), true);
		}
	}
}