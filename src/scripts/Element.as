package scripts
{
	import mx.graphics.SolidColor;
	
	import spark.components.Group;
	import spark.primitives.Ellipse;

	public class Element
	{
		public var position:MyVector;
		public var velocity:MyVector;
		public var acceleration:MyVector;
		public var mass:Number = 10;
		public var radius:Number = 20;
		public var image:Ellipse;
		public function Element(canvas:Group, color:uint)
		{
			this.position = new MyVector(OrbitalSimulator.numDim);
			this.velocity = new MyVector(OrbitalSimulator.numDim);
			this.acceleration = new MyVector(OrbitalSimulator.numDim);
			for (var i:int = 0; i < OrbitalSimulator.numDim; i++) {
				this.position[i] = 0;
				this.velocity[i] = 0;
				this.acceleration[i] = 0;
			}
			this.image = new Ellipse();
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
			velocity.addIp(acceleration.mult(ms/1000));
			position.addIp(velocity.mult(ms/1000));
		}
	}
}