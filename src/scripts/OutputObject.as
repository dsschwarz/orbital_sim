package scripts
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	
	import spark.components.DropDownList;
	import spark.components.gridClasses.GridColumn;

	[Bindable]
	public class OutputObject
	{
		// Bound to target.currentElement
		public var mass:String;
		public var radius:String;
		public var elementVectors:ArrayCollection;
		
		public var time:String;
		public var speed:String;
		public var simulating:Boolean;
		private var mouseDownEvent:MouseEvent;
		
		public var target:OrbitalSimulator;
		private var placeObject:Element; // Element being placed
		public function OutputObject(specs:Object=null)
		{
			if (specs) {
				mass = specs.mass;
				radius = specs.radius;
				
				time = specs.time;
				speed = specs.speed;
			}
		}
		public function observe(target:OrbitalSimulator):void
		{
			this.target = target;
			BindingUtils.bindProperty(this, "mass", target, ["currentElement", "mass"]);
			BindingUtils.bindProperty(this, "radius", target, ["currentElement", "radius"]);
			// Create vectors to output position, acclr, etc on current object
			// update every few cycles
			elementVectors = new ArrayCollection();
			elementVectors.addItem(new MyVector(target.numDim));
			elementVectors.addItem(new MyVector(target.numDim));
			elementVectors.addItem(new MyVector(target.numDim));
			
			target.listen("periodicUpdate", setElementVectors);
			target.listen("setCurrentElement", function (event:Event):void {
				target.currentElement.radius +=1;
			});
			setElementVectors(new Event("dummyVal"));
			
			// ZOOM and PAN
			// zoom on scroll
			target.canvas.parent.addEventListener(MouseEvent.MOUSE_WHEEL, function(event:MouseEvent):void {
				var scrollFactor:Number = event.delta > 0 ? 1.25 : 0.8;
				target.setZoom(target.zoom * scrollFactor);
			});
			
			// MOUSE EVENTS
			target.canvas.parent.addEventListener(MouseEvent.MOUSE_DOWN, function(event:MouseEvent):void {
				mouseDownEvent = event;
				if (placeObject) {
					// object didn't get placed!!
					target.objects.addItem(placeObject); // we'll just add it on and forget it for now, add destructors later
				}
				if (event.ctrlKey) {
					// Place Object
					var position:MyVector = MyVector.create(target.numDim, [event.stageX - target.canvas.x, event.stageY - target.canvas.y]);
					position.sub(target.pan, true).div(target.zoom, true);
					
					placeObject = new Element(target, target.placeColor);
					placeObject.position.add(position, true);
					placeObject.draw();
					target.currentElement = placeObject;
				}
			});
			
			target.canvas.parent.addEventListener(MouseEvent.MOUSE_MOVE, function(event:MouseEvent):void {
				if (mouseDownEvent) {
					if (placeObject) {
						// mouseDownEvent still points at original click
						placeObject.velocity = MyVector.create(target.numDim, [event.stageX - mouseDownEvent.stageX, event.stageY - mouseDownEvent.stageY, 0, 0]);
						placeObject.draw();
					} else {
						target.pan.add([event.stageX - mouseDownEvent.stageX, event.stageY - mouseDownEvent.stageY], true);
						mouseDownEvent = event;	// Reset to point at last position (allows pan)
						if (!simulating) {
							target.draw();
						}
					}
				}
			});
			
			target.canvas.parentApplication.addEventListener(MouseEvent.MOUSE_UP, function(event:MouseEvent):void {
				if (mouseDownEvent) {
					if (placeObject) {
						placeObject.velocity = MyVector.create(target.numDim, [event.stageX - mouseDownEvent.stageX, event.stageY - mouseDownEvent.stageY, 0, 0]);
						target.objects.addItem(placeObject);
						placeObject.draw();
						placeObject = null;
					} else {
						target.pan.add([event.stageX - mouseDownEvent.stageX, event.stageY - mouseDownEvent.stageY], true);
						if (!simulating) {
							target.draw();
						}
					}
					mouseDownEvent = null;
				}
			});
			
			target.canvas.parentApplication.addEventListener(KeyboardEvent.KEY_DOWN, function(event:KeyboardEvent):void {
				if (event.keyCode == 32) {
					if (simulating) {
						target.stop();
					} else {
						target.start();
					}
				}
			});
			
			target.listen("timeChanged", outputTime);
			target.listen("speedChanged", outputSpeed);
			outputSpeed();
			outputTime();
			
			
			target.listen("timerStart", function():void{ simulating = true; });
			target.listen("timerStop", function():void{ simulating = false; });
		};
		private function setElementVectors(event:Event=null):void
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
		private function outputTime(event:Event=null):void 
		{
			time = String((target.timeElapsed/1000).toFixed(2)); // 2 decimal places
		}
		public function getGridColumns():ArrayCollection
		{
			var colList:ArrayCollection = new ArrayCollection();
			for (var i:int = 0; i < target.numDim; i++) {
				var col:GridColumn = new GridColumn("Axis" + (i + 1));
				col.dataField = String(i);
				colList.addItem(col);
			}
			var labelCol:GridColumn = new GridColumn();
			labelCol.dataField = "name";
			labelCol.headerText = "";
			colList.addItemAt(labelCol, 0);
			return colList;
		}
		
		// Speed
		private function outputSpeed(event:Event=null):void 
		{
			speed = String(target.simulationSpeed.toFixed(2));
		}
	}
}