package scripts
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;

	
	import mx.collections.ArrayCollection;

	[Bindable]
	public class OutputObject
	{
		public var mass:String;
		public var time:String;
		public var speed:String;
		public var elementVectors:ArrayCollection;
		private var mouseDownEvent:MouseEvent;
		
		public var target:OrbitalSimulator;
		public function OutputObject(specs:Object=null)
		{
			if (specs) {
				mass = specs.mass;
				
				time = specs.time;
				speed = specs.speed;
			}
		}
		public function observe(target:OrbitalSimulator):void
		{
			this.target = target;
			// Create vectors to output position, acclr, etc on current object
			// update every few cycles
			elementVectors = new ArrayCollection();
			elementVectors.addItem(new MyVector(target.numDim));
			elementVectors.addItem(new MyVector(target.numDim));
			elementVectors.addItem(new MyVector(target.numDim));
			
			target.listen("periodicUpdate", setElementVectors);
			setElementVectors(new Event("dummyVal"));
			
			// ZOOM and PAN
			// zoom on scroll
			target.canvas.parent.addEventListener(MouseEvent.MOUSE_WHEEL, function(event:MouseEvent):void {
				var scrollFactor:Number = event.delta > 0 ? 1.25 : 0.8;
				target.zoom *= scrollFactor;
				event.stopPropagation();
			});
			
			// MOUSE EVENTS
			target.canvas.parent.addEventListener(MouseEvent.MOUSE_DOWN, function(event:MouseEvent):void {
				mouseDownEvent = event;
				trace(event);
				
				if (event.ctrlKey) {
					// Place Object
					target.currentElement = target.addElement(target.placeColor, [event.stageX, event.stageY]);
					target.currentElement.disabled = true;
					target.placeObject = true;
				} else {
					// Pan
					target.placeObject = false;
				}
			});
			
			target.canvas.parent.addEventListener(MouseEvent.MOUSE_MOVE, function(event:MouseEvent):void {
				if (mouseDownEvent) {
					trace(event);
					if (target.placeObject) {
						// mouseDownEvent still points at original click
						trace("Place object");
						target.currentElement.velocity = MyVector.create(target.numDim, [event.stageX - mouseDownEvent.stageX, event.stageY - mouseDownEvent.stageY, 0, 0]);
					} else {
						trace("Panning");
						target.pan.add([event.stageX - mouseDownEvent.stageX, event.stageY - mouseDownEvent.stageY], true);
						mouseDownEvent = event;	// Reset to point at last position (allows pan)
					}
				}
			});
			
			target.canvas.parentDocument.addEventListener(MouseEvent.MOUSE_UP, function(event:MouseEvent):void {
				if (mouseDownEvent) {
					trace("MOUSEUP");
					if (target.placeObject) {
						target.currentElement.velocity = MyVector.create(target.numDim, [event.stageX - mouseDownEvent.stageX, event.stageY - mouseDownEvent.stageY, 0, 0]);
						target.currentElement.disabled = false;
					} else {
						target.pan.add([event.stageX - mouseDownEvent.stageX, event.stageY - mouseDownEvent.stageY], true);
					}
					target.placeObject = false;
					mouseDownEvent = null;
				}
			});
			
			
			target.listen("timeChanged", outputTime);
			target.listen("speedChanged", outputSpeed);
			outputSpeed(new Event("dummy"));
			outputTime(new Event("dummy"));
		};
		private function setElementVectors(event:Event):void
		{
			var i:int;
			var pos:MyVector = new MyVector(target.numDim, 0);
			var vel:MyVector = new MyVector(target.numDim, 0);
			var acclr:MyVector = new MyVector(target.numDim, 0);
			pos.name = "Position";
			vel.name = "Velocity";
			acclr.name = "Acceleration";
			for(i = 0; i < target.numDim; i++) {
				pos[i] = target.currentElement.position[i].toFixed(2);
				vel[i] = target.currentElement.velocity[i].toFixed(2);
				acclr[i] = target.currentElement.acceleration[i].toFixed(2);
			}
			elementVectors.setItemAt(pos, 0);
			elementVectors.setItemAt(vel, 1);
			elementVectors.setItemAt(acclr, 2);
		};
		// TIME
		private function outputTime(event:Event):void 
		{
			time = String((target.timeElapsed/1000).toFixed(2)); // 2 decimal places
		}
		
		// Speed
		private function outputSpeed(event:Event):void 
		{
			speed = String(target.simulationSpeed.toFixed(2));
		}
	}
}