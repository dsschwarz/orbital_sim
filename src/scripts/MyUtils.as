package scripts
{
	public class MyUtils
	{
		public function MyUtils()
		{
		}
		
		public static function roundTo(value:Number, digits:int):Number
		{
			if (value == 0) {
				return value;
			}
			var factor:Number = Math.pow(10.0, digits - Math.ceil(Math.log(Math.abs(value)) / Math.log(10)));
			return Math.round(value * factor) / factor; 
		}
		public static function toPercent(value:Number):String
		{
			return String(roundTo(value * 100, 2)) + "%";
		}
	}
}