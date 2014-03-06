package scripts
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.ui.Keyboard;
	import flash.utils.Timer;
	
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.events.PropertyChangeEvent;
	
	import spark.components.Group;
	import spark.components.Label;
	import spark.components.TextInput;
	import spark.components.VGroup;
	
	public class OrbitalSimulator
	{
		public var G:Number = 6.67384E-11;
		private var _numDim:int = 4;
		public static var updateFrequency:int = 300;
		public var updateTimer:int = 0;
		[Bindable]
		public var zoom:Number = 1;
		public var pan:MyVector;    			// Top left position of screen
		private var _simSpeed:Number = 1; // factor to adjust speed by
		[Bindable]
		public var collisionsEnabled:Boolean = true;
		[Bindable]
		public var stickyCollisions:Boolean = false; // If objects stick together after collision
		public var eRatio:Number = 1; // Ratio of energy after to energy before
		
		[Bindable]
		public var objects:ArrayList = new ArrayList();
		public var canvas:Group;
		private var mainStage:Group;
		private var _currentElement:Element;
		public var placeObject:Element;
		[Bindable]
		public var outputObject:OutputObject;
		public var placeColor:uint = 0x30b080;
		public var idCounter:int = 1; // Resets for a new instance
				
		private var eventDispatcher:EventDispatcher;
		private var timer:Timer;
		private var _timeElapsed:Number = 0;
		private var _reverseTime:int = 1;
		
		public function OrbitalSimulator(mainStage:Group)
		{
			canvas = new Group();
//			canvas.autoLayout = false;
			
			pan = new MyVector(numDim, 0);
			
			eventDispatcher = new EventDispatcher(this);
			timer = new Timer(25);
			timer.addEventListener(TimerEvent.TIMER, getTick(25));
			
			currentElement = this.addElement(0xF0aF50, [300, 200], [-14, 0]);
			this.addElement(0x502FF0, [300, 300], [14, 0]);
			
			this.mainStage = mainStage;
			mainStage.addElement(canvas);
			outputObject = new OutputObject();
			outputObject.observe(this);
		}
		
		public function update(ms:Number):void 
		{
			if (objects.length == 0) {
				return;
			}
			updateTimer += ms;
			if (updateTimer > updateFrequency) {
				updateTimer = 0;
				eventDispatcher.dispatchEvent(new Event("periodicUpdate"));
			}
			
			// Set to sim speed (WARNING - take care with this)
			var scaled_ms:Number = ms * simulationSpeed * _reverseTime;
			timeElapsed += scaled_ms;
			var i:int, j:int, axis:int;
			// Reset acceleration
			for (i = 0; i < objects.length; i ++)
			{
				objects.getItemAt(i).acceleration = new MyVector(numDim, 0);
			}
			// Handle gravity on all objects
			for (i = 0; i < objects.length - 1; i ++)
			{
				var obj1:Element = objects.getItemAt(i) as Element;
				if (obj1.disabled) {
					trace("disabled")
					continue;
				}
				for (j = i + 1; j < objects.length; j++)
				{
					var obj2:Element = objects.getItemAt(j) as Element;
					if (obj2.disabled) {
						trace("disabled")
						continue;
					}
					var distance:MyVector = obj2.position.sub(obj1.position); // Distance vector from first obj to second
					
					// Calculate the absolute distance between the two objects
					var absDistSq:Number = 0;
					for (axis = 0; axis < numDim; axis++) {
						absDistSq += Math.pow(distance[axis], 2);
					}
					
					// Detect collision
					if (collisionsEnabled && (absDistSq < Math.pow(obj1.radius + obj2.radius, 2))) {
						trace("Collision detected");
						var m1:Number = obj1.mass;
						var m2:Number = obj2.mass;
						var uDist:MyVector = distance.normalize(); // Unit vector from obj 1 to 2
						var finalDist:MyVector = uDist.mult(obj1.radius + obj2.radius); // distance so that objects are touching
						
						var u1:MyVector = obj1.velocity.mult(uDist); // Dot product to get velocity before collision in direction towards other sphere
						var u2:MyVector = obj2.velocity.mult(uDist);
						
						var v1:MyVector;
						var v2:MyVector;
						
						if (stickyCollisions) {
							// https://en.wikipedia.org/wiki/Inelastic_collision#Perfectly_inelastic_collision
							v1 = u1.mult(m1).add(u2.mult(m2)).div(m1+m2);
							v2 = v1.add(0); // Clone it for safety
						} else {
							var energyRatio:Number = Math.pow(eRatio, _reverseTime); // Gains energy when going backwards in time (1/C)
							// Velocity after collision (in normal direction still)
							// https://en.wikipedia.org/wiki/Inelastic_collision#Formula
							v1 = u2.sub(u1).mult(m2 * energyRatio).add(u1.mult(m1)).add(u2.mult(m2)).div(m1+m2);
							v2 = u1.sub(u2).mult(m1 * energyRatio).add(u1.mult(m1)).add(u2.mult(m2)).div(m1+m2);
						}
						// Adjust obj1's total post collision velocity
						obj1.velocity.add(v1.sub(u1).mult(uDist), true);
						obj2.velocity.add(v2.sub(u2).mult(uDist), true);
						
						// Adjust position so objects are touching
						obj1.position.sub(finalDist.sub(distance).div(2), true);
						obj2.position.add(finalDist.sub(distance).div(2), true);
						
					// NOTE: only calc acceleration if objects didn't collide this frame
					} else {
					
					// Add acceleration due to this gravity to total acceleration of each object
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
		
		// Draw elements, and additional objects such as particles
		public function draw():void {
			for (var i:int = 0; i < objects.length; i++) {
				objects.getItemAt(i).draw();
			}
		}
		// convert a position vector to an x and y location on screen
		public function positionMember(member:Object, posVector:MyVector, radius:Number = 0):void {
			var screenLocation:MyVector = posVector.sub(radius).sub(pan).mult(zoom);
			member.scaleX = zoom;
			member.scaleY= zoom;
			member.x = screenLocation[0];
			member.y = screenLocation[1];
		}
		public function positionLine(line:Object, posVector:MyVector, directionVector:*, lineScaleFactor:Number=1):void {
			var fromVector:MyVector = posVector.sub(pan).mult(zoom);
			var toVector:MyVector = fromVector.add(directionVector.mult(lineScaleFactor*zoom));
			line.xFrom = fromVector[0];
			line.xTo = toVector[0];
			line.yFrom = fromVector[1];
			line.yTo = toVector[1];
		}
		// Emits an event
		public function setZoom(val:Number):void {
			zoom = val;
			draw();
			eventDispatcher.dispatchEvent(new Event("updateZoom"));
		}
		
		[Bindable("changeNumDim")]
		public function get numDim():int
		{
			return _numDim;
		}
		
		public function set numDim(value:int):void
		{
			_numDim = value;
			// Every objects vectors must be updated
			for (var i:int=0; i < objects.length; i++) {
				var obj:Element = objects.getItemAt(i) as Element;
				obj.newDim(numDim);
			}
			eventDispatcher.dispatchEvent(new Event("changeNumDim"));
		}
		
		[Bindable(name="setCurrentElement")]
		public function get currentElement():Element
		{
			return _currentElement;
		}
		
		public function set currentElement(value:Element):void
		{
			_currentElement = value;
			eventDispatcher.dispatchEvent(new Event("setCurrentElement"));
		}
		private function getTick(interval:Number):Function
		{
			return function tick():void
			{
				update(interval);
				draw();
			}
		}
		
		public function listen(...args):void
		{
			eventDispatcher.addEventListener.apply(this, args);
		}
		
		
		//////////
		// TIME //
		//////////
		
		// Begin update loop
		public function start():void
		{
			// WARNING: timer stops automatically after maxInt + 1 cycles
			// TODO: look into seamlessly restarting timer
			eventDispatcher.dispatchEvent(new Event("timerStart"));
			timer.start();
		}
		
		// Stop updating
		public function stop():void
		{
			eventDispatcher.dispatchEvent(new Event("periodicUpdate"));
			eventDispatcher.dispatchEvent(new Event("timerStop"));
			timer.stop()
		}
		
		public function get timeElapsed():Number
		{
			return _timeElapsed;
		}
		
		public function set timeElapsed(value:Number):void
		{
			_timeElapsed = value;
			eventDispatcher.dispatchEvent(new Event("timeChanged"));
		}
		
		public function resetTime():void
		{
			timeElapsed = 0;
		}
		
		public function reverseTime():void
		{
			_reverseTime *= -1;
		}
		
		public function set simulationSpeed(value:Number):void
		{
			_simSpeed = value;
			eventDispatcher.dispatchEvent(new Event("speedChanged"));
		}
		
		public function get simulationSpeed():Number
		{
			return _simSpeed;
		}
		public function removeElement(element:Element):void {
			if (element == null) {
				return;
			}
			element.destroy();
			objects.removeItem(element);
			if (element == currentElement && objects.length > 0) {
				currentElement = objects.getItemAt(0) as Element;
			} else {
				currentElement = null;
			}
		}
		public function destroy():void {
//			for (var i:int = 0; i < objects.length; i++) {
//				objects[i].destroy();
//			}
			objects.removeAll();
			outputObject.destroy();
			canvas.removeAllElements();
			mainStage.removeElement(canvas);
			eventDispatcher = null;
			timer.reset();
			timer = null;
			canvas = null;
			
			
		}
	}
}