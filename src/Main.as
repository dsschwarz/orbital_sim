// ActionScript file
import flash.events.Event;
import flash.events.FocusEvent;

import mx.collections.ArrayCollection;
import mx.controls.Alert;

import scripts.Element;
import scripts.MyUtils;
import scripts.MyVector;
import scripts.OrbitalSimulator;

import spark.components.DropDownList;
import spark.components.gridClasses.GridColumn;
import spark.events.GridItemEditorEvent;
import spark.events.IndexChangeEvent;
import spark.events.TextOperationEvent;

[Bindable]
public var sim:OrbitalSimulator;

/**
 * STRUCTURE
 * All code directly bound to the UI is in Main.as
 * The orbital simulator holds the elements (planets, etc), and is a self contained simulator
 * 	It contains a single Bindable output object, which the UI can bind to
 * 	The elements are each updated once per loop. Elements update and draw themselves
 * 
 * The MyVector class is GORGEOUS
 * It creates arrays with additional functionality for interacting with other arrays/operating on itself
 * They can be added, subtracted, multiplied, divided, normalized, and converted to a single scalar length.
 * They're used extensively throughout this project
 * 
 */
public function init():void 
{
	trace("Initializing");
	
	sim = new OrbitalSimulator(mainStage);
	sim.start();
	sim.listen("updateZoom", function (event:Event):void {
		zoomSlider.value = sim.zoom;
	});
	objListDropDown.selectedIndex = 0;
	
	
	sim.listen("setCurrentElement", function (event:Event):void {
		objListDropDown.selectedItem = sim.currentElement;
	});
}
public function resetSim():void {
	sim.destroy();
	init();
}
public function objListChange(event:IndexChangeEvent):void
{
	sim.currentElement = sim.objects.getItemAt(event.newIndex) as Element;
}

public function setSimulationSpeed(event:Event):void
{
	sim.simulationSpeed = Math.pow(10, event.target.value); 
}

public function simSpeedDataTip(val:String):String
{
	var scaleAmount:Number = Math.pow(10, Number(val));
	return "Speed x" + String(MyUtils.roundTo(scaleAmount, 2));
}
public function changeSpeedByStep(increase:Boolean=true, steps:int=1):void
{
	var dir:int = increase ? 1 : -1;
	speedSlider.value += speedSlider.stepSize * dir * steps;
	speedSlider.dispatchEvent(new Event(Event.CHANGE));
}

public function preventEdit(event:GridItemEditorEvent):void {
	if (event.rowIndex >= 2) {
		event.preventDefault();
	}
}
protected function objectEdit_saveHandler(event:GridItemEditorEvent):void
{
	trace("Save");
	var item:Element = sim.currentElement;
	if (!item) {
		return;
	}
	var column:String = event.column.dataField;
	var row:int = event.rowIndex;
	var value:Number = event.target.dataProvider.getItemAt(row)[column];
	if (isNaN(value)) {
		Alert.show("Please enter a valid number")
		return; 
	}
	var rowName:String;
	if (row == 0) {
		rowName = "position";
	} else if (row == 1) {
		rowName = "velocity";
	} else {
		trace("Not a valid row");
		return;
	}
	
	item[rowName][int(column)] = value;
}

protected function radiusText_changeHandler(event:FocusEvent):void
{
	var val:Number = Number(event.target.text);
	if (isNaN(val) || val <= 0) {
		Alert.show("Enter a valid number");
		return;
	}
	
	sim.currentElement.radius = val;
}
protected function massText_changeHandler(event:FocusEvent):void
{
	var val:Number = Number(event.target.text);
	if (isNaN(val) || val <= 0) {
		Alert.show("Enter a valid number");
		return;
	}
	
	sim.currentElement.mass = val;
}
protected function dimText_changeHandler(event:FocusEvent):void
{
	var val:int = int(event.target.text);
	if (isNaN(val) || val <= 0) {
		Alert.show("Enter a valid number");
		return;
	}
	
	sim.numDim = val;
	// And the grid
}