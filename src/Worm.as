package  {
	
	import flash.display.MovieClip;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	
	public class Worm extends MovieClip {

		private var GRAVITY:int;
		private var FRICTION:Number;
		
		private var speed:Number = 0.04;
		private var direction:int;
		private var xVel:Number = 0.0;
		private var yVel:Number = 0.0;
		private var ground:MovieClip;
		private var cloudPlatform:MovieClip;
		private var constants:Constants;
		public var enemies:Array = new Array();
		
		// Declare points that serves as colliders of the player
		private var downArr:Array = new Array(-19, 0, 19);	// x positions of the points below the player.		
		private var upArr:Array = new Array(-3, 0, 3);		// x positions of the point above the playerPoints above the player.
		private var vertArr:Array = new Array(-20, -30);	// y positions of the points in the side of the player.
		private var horArr:Array = new Array(-21, 21);		// x positions of the points in the side of the player.
		private var headPoint:int = 40;
		public var isVisible:Boolean = false;
		
		public function Worm(xPos:int, yPos:int, ground:MovieClip, cloudPlatform:MovieClip, direction:int):void {
			super();
			this.ground = ground;
			this.cloudPlatform = cloudPlatform;
			
			// Initialize constants.
			constants = new Constants();
			GRAVITY = constants.getGravity();
			FRICTION = constants.getFriction();
			
			// Initialize position.	
			this.x = xPos;
			this.y = yPos;
			
			this.direction = direction;
			this.scaleX = direction;
		}
		
		public function move():void {
			this.x += this.xVel;
			xVel *= FRICTION;
			this.y += this.yVel;
			yVel += GRAVITY;
			
			this.xVel += speed * direction;

			if(isVisible) {
				upPush();
				upPushCloud();
			} else {
				yVel = 0;
			}
			
			leftPush();
			rightPush();
		}
		
		private function leftPush():void {
			while(ground.hitTestPoint(this.x - 150, this.y - 10, true)) {
				this.x++;
				xVel = 0;
				this.direction = 1;
				this.scaleX = 1;
			}
		}
		
		private function rightPush():void {
			while(ground.hitTestPoint(this.x + 150, this.y - 10, true)) {
				this.x--;
				xVel = 0;
				this.direction = -1;
				this.scaleX = -1;
			}
		}
		
		private function upPushCloud():void {
			while(cloudPlatform.hitTestPoint(this.x, this.y, true)) {
				this.y--;
				yVel = 0;
			}
		}
		
		private function upPush():void {
			while(ground.hitTestPoint(this.x, this.y, true)) {
				this.y--;
				yVel = 0;
			}
		}
	}
	
}
