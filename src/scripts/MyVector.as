package scripts
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	import mx.collections.ArrayCollection;
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;
	
	[Bindable("propertyChange")]
	public dynamic class MyVector extends Proxy implements IEventDispatcher
	{
		private var _array:Array;
		private var eventDispatcher:EventDispatcher;
	
		public function MyVector(numElements:int)
		{
			_array = new Array(numElements);
			eventDispatcher = new EventDispatcher(this);
		}
		private function eachEl(op:String, b:*, inPlace:Boolean=false):MyVector {
			var returnArray:MyVector = new MyVector(this.length);
			for(var i:int = 0; i < this.length; i++) {
				var el:*;
				if (b is Array || b is MyVector) {
					el = b[i];
				} else if (b is ArrayCollection){
					el = b.getItemAt();
				} else {
					el = b;
				}
				if (inPlace) {
					switch(op) {
						case "add":
							this[i] += el;
							break;
						case "sub":
							this[i] -= el;
							break;
						case "mult":
							this[i] *= el;
							break;
						case "div":
							this[i] /= el;
							break;
						default:
							trace("eachEl - unknown operator:  " + op) 
					}
				} else {
					switch(op) {
						case "add":
							returnArray[i] = this[i] + el;
							break;
						case "sub":
							returnArray[i] = this[i] - el;
							break;
						case "mult":
							returnArray[i] = this[i] * el;
							break;
						case "div":
							returnArray[i] = this[i] /el;
							break;
						default:
							trace("eachEl - unknown operator:  " + op) 
					}
				}
			}
			return returnArray;
		}
		
		public function add(b:*, inPlace:Boolean=false):MyVector {
			return eachEl("add", b, inPlace);
		}
		
		public function sub(b:*, inPlace:Boolean=false):MyVector {
			return eachEl("sub", b, inPlace);
		}
		
		public function mult(b:*, inPlace:Boolean=false):MyVector {
			return eachEl("mult", b, inPlace);
		}
		
		public function div(b:*, inPlace:Boolean=false):MyVector {
			return eachEl("div", b, inPlace);
		}
		
		
		public function normalize():MyVector {
			var newArray:MyVector = new MyVector(this.length);
			
			this.forEach(function(el:*, index:int, array:*):void {
				newArray[index] = (el/this.mag());
			}, this);
			return newArray;
		}
		
		public function mag():Number
		{
			var length:Number = 0;
			this.forEach(function(el:*, index:int, array:*):void {
				length += el * el;
			});
			return Math.sqrt(length);
		}
		// Add cross product (mult is dot product)override flash_proxy function setProperty(name:*, value:*):void {
		
		
		public function toString():String
		{
			var string:String = "";
			this.forEach(function(el:*, index:int, array:*):void {
				if (index != 0) {
					string += ", ";
				}
				if (el is Number && el != 0) {
					var factor:Number = Math.pow(10.0, 6 - Math.ceil(Math.log(Math.abs(el)) / Math.log(10)));
					var roundedVal:Number = Math.round(el * factor) / factor; 
					string += roundedVal;
				} else {
					string += el;
				}
			});	
			return string;
		}
		
		// Proxy Overrides
		override flash_proxy function setProperty(name:*, value:*):void {
			var oldValue:* = _array[name];
			_array[name] = value;
			var kind:String = PropertyChangeEventKind.UPDATE;
			dispatchEvent(new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE, false, false, kind, name, oldValue, value, this));
		}
		
		override flash_proxy function getProperty(name:*):* {
			return _array[name];
		}
		
		override flash_proxy function callProperty(name:*, ...rest):* {			
			return _array[name].apply(_array, rest);
		}
		
		// Event Dispatcher functions
		public function hasEventListener(type:String):Boolean
		{
			return eventDispatcher.hasEventListener(type);
		}
		
		public function willTrigger(type:String):Boolean
		{
			return eventDispatcher.willTrigger(type);
		}
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0.0, useWeakReference:Boolean=false):void
		{
			eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			eventDispatcher.removeEventListener(type, listener, useCapture);
		}
		
		public function dispatchEvent(event:Event):Boolean
		{
			return eventDispatcher.dispatchEvent(event);
		}
	}
}