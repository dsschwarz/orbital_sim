package scripts
{
	public dynamic class MyVector extends Array
	{
		public function MyVector(numElements:int)
		{
			super(numElements);
		}
		
		private function eachEl(op:String, b:*, inPlace:Boolean=false):MyVector {
			var isArray:Boolean;
			var returnArray:MyVector = new MyVector(this.length);
			if (!(b is Array)) {
				isArray = false;
			} else {
				if (b.length != this.length) {
					throw Error("Vector add() - not the same length");
				}
				isArray = true;
			}
			for(var i:int = 0; i < this.length; i++) {
				var el:*;
				if (isArray) {
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
		
		public function add(b:*):MyVector {
			return eachEl("add", b);
		}
		
		public function sub(b:*):MyVector {
			return eachEl("sub", b);
		}
		
		public function mult(b:*):MyVector {
			return eachEl("mult", b);
		}
		
		public function div(b:*):MyVector {
			return eachEl("div", b);
		}
		
		
		// In Place ops
		public function addIp(b:*):void {
			eachEl("add", b, true);
		}
		
		public function subIp(b:*):void {
			eachEl("sub", b, true);
		}
		
		public function multIp(b:*):void {
			eachEl("mult", b, true);
		}
		
		public function divIp(b:*):void {
			eachEl("div", b, true);
		}
		
		public function normalize():MyVector {
			var length:Number = 0;
			var newArray:MyVector = new MyVector(this.length);
			this.forEach(function(el:*, index:int, array):void {
				length += el * el;
			});
			this.forEach(function(el:*, index:int, array):void {
				newArray[index] = (el/length);
			})
			return newArray;
		}
		
		// Add cross product (mult is dot product)
	}
}