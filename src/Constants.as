package {

	public class Constants {
			
		private var GRAVITY:int = 1;
		private var FRICTION:Number = 0.8;
				
		public function Constants() { super(); }
		
		// Getters
		public function getGravity():Number { return GRAVITY; }
		public function getFriction():Number { return FRICTION; }
	}
}