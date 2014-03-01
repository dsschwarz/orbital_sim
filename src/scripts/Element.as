package scripts
{
	import mx.events.PropertyChangeEvent;
	import mx.graphics.SolidColor;
	import mx.graphics.SolidColorStroke;
	
	import spark.components.Group;
	import spark.components.Image;
	import spark.primitives.Ellipse;
	import spark.primitives.Line;

	public dynamic class Element
	{
		public var position:MyVector;
		public var velocity:MyVector;
		public var acceleration:MyVector;
		[Bindable]
		public var mass:Number = 1;
		[Bindable]
		public var radius:Number = 50;
		public var image:Ellipse;
		public var velLine:Line;
		public var acclLine:Line;
		public var parent:OrbitalSimulator;
		public var id:int;
		public var disabled:Boolean = false;
		public function Element(sim:OrbitalSimulator, color:uint) // Tightly  coupled to sim
		{
			id = sim.idCounter++;
			parent = sim;
			position = new MyVector(sim.numDim, 0);
			velocity = new MyVector(sim.numDim, 0);
			acceleration = new MyVector(sim.numDim, 0);
			
			image = new Ellipse();
			image.width = radius*2;
			image.height = radius*2;
			image.fill = new SolidColor(color);
			image.x = position[0] - radius;
			image.y = position[1] - radius;
			sim.canvas.addElement(image);
			
			//Direction vectors
			velLine = new Line();		
			velLine.stroke = new SolidColorStroke(0xa01010);
			sim.canvas.addElement(velLine);	
			
			acclLine = new Line();
			acclLine.stroke = new SolidColorStroke(0x20a020);
			sim.canvas.addElement(acclLine);
		}
		
		public function update(ms:Number):void {
			if (disabled) {
				return;
			}
			velocity.add(acceleration.mult(ms/1000), true);
			position.add(velocity.mult(ms/1000), true);
		}
		
		public function draw():void {
			image.width = radius*2;
			image.height = radius*2;
			parent.positionMember(image, position, radius);
			// Direction Vectors
			// TODO get line lengths and weight that range between specific values
			parent.positionLine(velLine, position, velocity, 5);
			parent.positionLine(acclLine, position, acceleration, 5);
		}
		
		public function destroy():void {
			try {
				parent.canvas.removeElement(image);
				parent.canvas.removeElement(acclLine);
				parent.canvas.removeElement(velLine);
			} catch(err:Error) {
				trace("Error removing element");
				trace(err);
			}
		}
	}
}