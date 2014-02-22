package scripts
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
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
		public var G:Number = 10000;
		public var numDim:int = 4;
		public static var updateFrequency:int = 300;
		public var updateTimer:int = 0;
		[Bindable]
		public var zoom:Number = 1;
		public var pan:MyVector;    			// Top left position of screen
		public var simulationSpeed:Number = 1; // factor to adjust speed by
		
		[Bindable]
		public var objects:ArrayList = new ArrayList();
		public var canvas:Group;
		public var currentElement:Element;
				
		private var eventDispatcher:EventDispatcher;
		private var timer:Timer;
		private var timeElapsed:Number = 0;
		private var _reverseTime:Boolean = false;
		
		public function OrbitalSimulator(mainStage:Group)
		{
			canvas = new Group();
			canvas.width = 10;
			
			pan = new MyVector(numDim, 0);
			pan.listen("vectorChanged", function(event:Event):void {
				canvas.x = pan[0];
				canvas.y = pan[1];
			});
			BindingUtils.bindSetter(function(newVal:Number):void {
				canvas.scaleX = newVal;
				canvas.scaleY = newVal;
			}, this,"zoom");
			
			eventDispatcher = new EventDispatcher(this);
			timer = new Timer(25);
			timer.addEventListener(TimerEvent.TIMER, getTick(25));
			
			currentElement = this.addElement(0xF0aF50, [200, 100, 0, 0], [-20, -10, 0, 0]);
			this.addElement(0x502FF0, [120, 200, 0, 0], [20, 10, 0, 0]);
			mainStage.addElement(canvas);
		}
		public function update(ms:Number):void 
		{
			updateTimer += ms;
			if (updateTimer > updateFrequency) {
				updateTimer = 0;
				eventDispatcher.dispatchEvent(new Event("periodicUpdate"));
			}
			
			// Set to sim speed (WARNING - take care with this)
			var scaled_ms:Number = ms * simulationSpeed;
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
					var distance:MyVector = obj2.position.sub(obj1.position); // Distance vector from first obj to second
					
					// Calculate the absolute distance between the two objects
					var absDistSq:Number = 0;
					for (axis = 0; axis < numDim; axis++) {
						absDistSq += Math.pow(distance[axis], 2);
					}
					
					// Add acceleration due to this gravity to total acceleration of each object
					if (absDistSq > 0) {
						// acceleration on 1 due to 2 = G * m2 / d
						var acclrOn1:Number = G*obj2.mass/absDistSq;
						obj1.acceleration.add( distance.normalize().mult(acclrOn1), true );
						
						var acclrOn2:Number = G*obj1.mass/absDistSq;
						obj2.acceleration.add( distance.normalize().mult(-acclrOn2), true ); // Negative, so vector points towards first obj
						
					}
					
				
				}
			}
			for (i = 0; i < objects.length; i++) {
				objects.getItemAt(i).update(scaled_ms);
			}
		}
		
		// Pass it a an array of length numDim for pos and vel
		public function addElement(color:uint, position:*=0, velocity:*=0):Element
		{
			var el:Element = new Element(this, color);
			el.position.add(position, true);
			el.velocity.add(velocity, true);
			this.objects.addItem(el);
			return el;
		}
		
		// Draw additional objects such as particles
		public function draw():void {
			
		}
		
		private function getTick(interval:Number):Function
		{
			return function tick():void
			{
				update(interval);
			}
		}
		
		public function listen(...args):void
		{
			eventDispatcher.addEventListener.apply(this, args);
		}
		
		public function start():void
		{
			timer.start();
		}
		
		public function stop():void
		{
			timer.stop()
		}
		
		public function getTimeElapsed():Number
		{
			return timeElapsed;
		}
		
		public function resetTime():void
		{
			timeElapsed = 0;
		}
		public function reverseTime():void
		{
			_reverseTime = true;
		}
		
		// Will implement as soon as I solve the three-body problem
		public function setTimeElapsed():void
		{
		}
	}
}