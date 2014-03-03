package scripts
{	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;

	public dynamic class MyVector extends Proxy
	{
		private var eventDispatcher:EventDispatcher;
		private var _array:Array;
		public var name:String;
		public function MyVector(numElements:int=0, defVal:*=null)
		{
			eventDispatcher = new EventDispatcher();
			_array = new Array(numElements);
			for (var i:int = 0; i < numElements; i++) {
				_array[i] = defVal;
			}
		}
		// Create a Vector from an array/vector
		public static function create(numDim:int, array:Array, defVal:*=0):MyVector {
			var v:MyVector = new MyVector(numDim);
			for (var i:int = 0; i< numDim; i++) {
				v[i] = array[i] || defVal;
			}
			return v;
		}
		private function eachEl(op:String, b:*, inPlace:Boolean=false):MyVector {
			var workingVector:MyVector; // The vector apply operations to and return
			if (inPlace) {
				workingVector = this;
			} else {
				// Create a clone
				workingVector = new MyVector(this.length);
			}
				
			for(var i:int = 0; i < this.length; i++) {
				var el:*;
				if (b is Array || b is MyVector) {
					// Prevent out of index errors
					if (i >= b.length) {
						return workingVector;
					}
					el = b[i];
				} else {
					el = b;
				}
				
				switch(op) {
					case "add":
						workingVector[i] = this[i] + el;
						break;
					case "sub":
						workingVector[i] = this[i] - el;
						break;
					case "mult":
						workingVector[i] = this[i] * el;
						break;
					case "div":
						workingVector[i] = this[i] /el;
						break;
					default:
						trace("eachEl - unknown operator:  " + op) 
				}
			}
			return workingVector;
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
		
		
		public function normalize(inPlace:Boolean=false):MyVector {
			var returnArray:MyVector;
			if (inPlace) {
				returnArray = this;
			} else {
				returnArray = new MyVector(this.length);
			}
			
			this.forEach(function(el:*, index:int, array:*):void {
				returnArray[index] = (el/this.mag());
			}, this);
			
			return returnArray;
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
			return roundTo(6);
		}
		public function roundTo(digits:Number):String {
			var string:String = "";
			this.forEach(function(el:*, index:int, array:*):void {
				if (index != 0) {
					string += ", ";
				}
				if (el is Number && el != 0) {
					var factor:Number = Math.pow(10.0, digits - Math.ceil(Math.log(Math.abs(el)) / Math.log(10)));
					var roundedVal:Number = Math.round(el * factor) / factor; 
					string += roundedVal;
				} else {
					string += el;
				}
			});	
			return string;
		}
		
		override flash_proxy function setProperty(name:*, value:*):void {
			eventDispatcher.dispatchEvent(new Event("vectorChanged"));
			_array[name] = value;
		}
		override flash_proxy function getProperty(name:*):* {
			return _array[name];
		}
		override flash_proxy function callProperty(name:*, ...rest):* {
			return _array[name].apply(this, rest);
		}
		public function listen(...args):void
		{
			eventDispatcher.addEventListener.apply(this, args);
		}
	}
}