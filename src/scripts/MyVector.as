package scripts
{	
	public dynamic class MyVector extends Array
	{
	
		public function MyVector(numElements:int)
		{
			super(numElements);
		}
		private function eachEl(op:String, b:*, inPlace:Boolean=false):MyVector {
			var returnArray:MyVector = new MyVector(this.length);
			for(var i:int = 0; i < this.length; i++) {
				var el:*;
				if (b is Array || b is MyVector) {
					el = b[i];
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
	}
}