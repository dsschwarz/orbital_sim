package scripts
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.core.Container;
	import mx.graphics.SolidColor;
	
	import spark.components.Group;
	import spark.primitives.Ellipse;
	
	public class OrbitalSimulator
	{
		public var G:Number = 100;
		public var objects:Vector.<Element> = new Vector.<Element>();
		public static var numDim:int = 4;
		public var canvas:Group;
		public function OrbitalSimulator(canvas:Group)
		{
			this.canvas = canvas;
			var p1 = new Element(canvas, 0x20aaF0);
			var p2 = new Element(canvas, 0xF0aF50);
			p1.position.addIp([100, 20, 0, 0]);
			p1.velocity.addIp([4, 2, 0, 0]);
			p2.position.addIp([80, 30, 0, 0]);
			objects.push(p1);
			objects.push(p2);
		}
		public function update(ms:Number):void 
		{
			// Reset acceleration
			for (var i:int = 0; i < objects.length; i ++)
			{
				for (var axis:int = 0; axis < numDim; axis++) {
					objects[i].acceleration[axis] = 0;
				}
			}
			// Handle gravity on all objects
			for (var i:int = 0; i < objects.length - 1; i ++)
			{
				for (var j:int = i + 1; j < objects.length; j++)
				{
					var distance:MyVector = objects[j].position.sub(objects[i].position); // vector from first obj to second
					
					var absDistSq:Number = 0;
					for (var axis:int = 0; axis < numDim; axis++) {
						absDistSq += Math.pow(distance[axis], 2);
					}
					if (absDistSq > 0) {
						var acclrOn1:Number = G*objects[j].mass/Math.sqrt(absDistSq);
						objects[i].acceleration.addIp( distance.normalize().mult(acclrOn1) );
						
						var acclrOn2:Number = G*objects[i].mass/Math.sqrt(absDistSq);
						objects[j].acceleration.addIp( distance.normalize().mult(-acclrOn2) ); // Negative, so vector points towards first obj
						
					}
					
				
				}
			}
			objects.forEach(function(obj:Element, index:int, vector:Vector.<Element>):void {
				obj.update(ms);
			})
		}
		private function draw():void
		{
		}
		
		private function getTick(interval:Number):Function
		{
			return function tick():void
			{
				update(interval);
				draw();
			}
		}
		
		public function start():void
		{
			var timer:Timer = new Timer(25);
			timer.addEventListener(TimerEvent.TIMER, getTick(25));
			timer.start();
		}
	}
}