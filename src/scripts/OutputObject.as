package scripts
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	
	import spark.components.DropDownList;
	import spark.components.gridClasses.GridColumn;

	[Bindable]
	public class OutputObject
	{
		// Bound to target.currentElement
		public var elementVectors:ArrayCollection;
		
		public var mass:Number;
		public var radius:Number;
		public var time:String;
		public var speed:String;
		public var simulating:Boolean;
		public var selectedIndex:int;
		private var mouseDownEvent:MouseEvent;
		
		public var colList:ArrayCollection = new ArrayCollection();
		
		public var target:OrbitalSimulator;
		private var placeObject:Element; // Element being placed
		public function observe(target:OrbitalSimulator):void
		{
			this.target = target;
			setGridColumns();
			target.listen("changeNumDim", setGridColumns);
			// Create vectors to output position, acclr, etc on current object
			// update every few cycles
			elementVectors = new ArrayCollection();
			elementVectors.addItem(new MyVector(target.numDim));
			elementVectors.addItem(new MyVector(target.numDim));
			elementVectors.addItem(new MyVector(target.numDim));
			
			target.listen("periodicUpdate", setElementVectors);
			target.listen("setCurrentElement", outputCurrElement);
			outputCurrElement();
			
			// ZOOM and PAN
			// zoom on scroll
			target.canvas.parent.addEventListener(MouseEvent.MOUSE_WHEEL, function(event:MouseEvent):void {
				var scrollFactor:Number = event.delta > 0 ? 1.25 : 0.8;
				target.setZoom(target.zoom * scrollFactor);
			});
			
			// MOUSE EVENTS
			target.canvas.parent.addEventListener(MouseEvent.MOUSE_DOWN, function(event:MouseEvent):void {
				var position:MyVector
				mouseDownEvent = event;
				if (placeObject) {
					// object didn't get placed!!
					placeObject.disabled = false; // we'll just add it on and forget it for now, add destructors later
				}
				if (target.placeObject) { // Place an existing object
					// Place Object
					position = MyVector.create(target.numDim, [event.stageX - target.canvas.x, event.stageY - target.canvas.y]);
					position.sub(target.pan, true).div(target.zoom, true);
					
					placeObject = target.placeObject;
					placeObject.disabled = true;
					target.currentElement = placeObject;
					target.placeObject = null;
				} else if (event.ctrlKey) {
					// Place Object
					position = MyVector.create(target.numDim, [event.stageX - target.canvas.x, event.stageY - target.canvas.y]);
					position.sub(target.pan, true).div(target.zoom, true);
					
					placeObject = target.addElement(target.placeColor, position);
					placeObject.disabled = true;
					target.currentElement = placeObject;
				}
			});
			
			target.canvas.parent.addEventListener(MouseEvent.MOUSE_MOVE, function(event:MouseEvent):void {
				if (target.placeObject) {
					// Follows mouse
					var position:MyVector = MyVector.create(target.numDim, [event.stageX - target.canvas.x, event.stageY - target.canvas.y]);
					position.sub(target.pan, true).div(target.zoom, true);
					target.placeObject.position = position;
				}
				if (mouseDownEvent) {
					if (placeObject) {
						// mouseDownEvent still points at original click
						placeObject.velocity = MyVector.create(target.numDim, [event.stageX - mouseDownEvent.stageX, event.stageY - mouseDownEvent.stageY]);
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
						placeObject.velocity = MyVector.create(target.numDim, [event.stageX - mouseDownEvent.stageX, event.stageY - mouseDownEvent.stageY]);
						placeObject.disabled = false;
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
			
			FlexGlobals.topLevelApplication.addEventListener(KeyboardEvent.KEY_DOWN, function(event:KeyboardEvent):void {
				if (event.keyCode == 32) {
					trace("Spaaaaace")
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
		private function outputCurrElement(event:Event=null):void {
			setElementVectors(event);
			if (target.currentElement) {
				mass = target.currentElement.mass;
				radius = target.currentElement.radius;
				FlexGlobals.topLevelApplication.massTextInput.text = mass;
				FlexGlobals.topLevelApplication.radiusTextInput.text = radius;
			} else {
				mass = 0;
				radius = 0;
			}
		}
		private function setElementVectors(event:Event=null):void
		{
			var i:int;
			var pos:MyVector = new MyVector(target.numDim, 0);
			var vel:MyVector = new MyVector(target.numDim, 0);
			var acclr:MyVector = new MyVector(target.numDim, 0);
			pos.name = "Position";
			vel.name = "Velocity";
			acclr.name = "Acceleration";
			if (target.currentElement) {
				for(i = 0; i < target.numDim; i++) {
					pos[i] = target.currentElement.position[i].toFixed(2);
					vel[i] = target.currentElement.velocity[i].toFixed(2);
					acclr[i] = target.currentElement.acceleration[i].toFixed(2);
				}
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
		public function setGridColumns(event:Event=null):ArrayCollection
		{
			colList.removeAll();
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