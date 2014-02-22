package scripts
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	import mx.collections.ArrayList;
	import mx.events.PropertyChangeEvent;
	
	import spark.components.Group;
	import spark.components.Label;
	import spark.components.TextInput;
	import spark.components.VGroup;
	
	public class OrbitalSimulator
	{
		public var G:Number = 100;
		[Bindable]
		public var objects:ArrayList = new ArrayList();
		public static var numDim:int = 4;
		public var canvas:Group;
		private var currentObjIndex:int = 0;
		[Bindable("propertyChange")]
		public var myV:MyVector;
		public function OrbitalSimulator(mainStage:Group)
		{
			canvas = new Group();
			canvas.width = 10;
			
			var p1:Element = new Element(canvas, 0x20aaF0);
			var p2:Element = new Element(canvas, 0xF0aF50);
			
			p1.velocity.add([4, 2, 0, 0], true);
			p2.position.add([80, 30, 0, 0], true);
			objects.addItem(p1);
			objects.addItem(p2);
			
			p1.position.add([100, 20, 0, 0], true);
			mainStage.addElement(canvas);
		}
		public function update(ms:Number):void 
		{
			var i:int, j:int, axis:int;
			// Reset acceleration
			for (i = 0; i < objects.length; i ++)
			{
				for (axis = 0; axis < numDim; axis++) {
					objects.getItemAt(i).acceleration[axis] = 0;
				}
			}
			// Handle gravity on all objects
			for (i = 0; i < objects.length - 1; i ++)
			{
				for (j = i + 1; j < objects.length; j++)
				{
					var obj1:Object = objects.getItemAt(i);
					var obj2:Object = objects.getItemAt(j);
					var distance:MyVector = obj2.position.sub(obj1.position); // vector from first obj to second
					
					var absDistSq:Number = 0;
					for (axis = 0; axis < numDim; axis++) {
						absDistSq += Math.pow(distance[axis], 2);
					}
					if (absDistSq > 0) {
						var acclrOn1:Number = G*obj2.mass/Math.sqrt(absDistSq);
						obj1.acceleration.add( distance.normalize().mult(acclrOn1), true );
						
						var acclrOn2:Number = G*obj1.mass/Math.sqrt(absDistSq);
						obj2.acceleration.add( distance.normalize().mult(-acclrOn2), true ); // Negative, so vector points towards first obj
						
					}
					
				
				}
			}
			for (i = 0; i < objects.length; i++) {
				objects.getItemAt(i).update(ms);
			}
		}
		public function currentObject():Object
		{
			return objects.getItemAt(currentObjIndex);
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