// ActionScript file
import flash.events.Event;

import scripts.Element;
import scripts.MyUtils;
import scripts.MyVector;
import scripts.OrbitalSimulator;

import spark.components.gridClasses.GridColumn;
import spark.events.IndexChangeEvent;

[Bindable]
public var sim:OrbitalSimulator;

public function init():void 
{
	trace("Initializing");
	
	sim = new OrbitalSimulator(mainStage);
	sim.start();
	sim.listen("updateZoom", function (event:Event):void {
		zoomSlider.value = sim.zoom;
	});
	objListDropDown.selectedIndex = 0;
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