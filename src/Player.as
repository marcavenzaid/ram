package  {
	
	import flash.display.MovieClip;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	
	public class Player extends MovieClip {
		
		private var GRAVITY:int;
		private var FRICTION:Number;
		
		private var speed:Number = 0.7;
		private var dashSpeed:Number = 0.9;
		private var jumpPower:Number = 15;
		private var springPower:Number = 25;
		private var onGround:Boolean = false;
		private var xVel:Number = 0.0;
		private var yVel:Number = 0.0;
		private var ground:MovieClip;
		private var cloudPlatform:MovieClip;
		private var constants:Constants;
		
		// Declare points that serves as colliders of the player
		private var downArr:Array = new Array(-19, 0, 19);	// x positions of the points below the player.		
		private var upArr:Array = new Array(-3, 0, 3);		// x positions of the point above the playerPoints above the player.
		private var vertArr:Array = new Array(-20, -30);	// y positions of the points in the side of the player.
		private var horArr:Array = new Array(-21, 21);		// x positions of the points in the side of the player.
		private var headPoint:int = 40;						// y position of the point above the head of the player.
		
		private var attacking:Boolean = false;
		private var attackDur:Number = 30.0;
		private var attackDurCounter:Number = 0.0;
		
		private var jumpCount:int = 0;
		
		public function Player(ground:MovieClip, cloudPlatform:MovieClip) {
			// Initialize characteristics.
			super();			
			this.ground = ground;
			this.cloudPlatform = cloudPlatform;
			
			// Initialize constants.
			constants = new Constants();
			GRAVITY = constants.getGravity();
			FRICTION = constants.getFriction();
			
			// Initialize position.			
			this.x = -420;
			this.y = 500;			
		}
		
		// idle state of the player.
		public function idle():void {
			if(onGround && !attacking && jumpCount == 0) {
				this.gotoAndStop("idle");
			}			
		}

		// Move and face player to the right.
		public function moveLeft():void {
			if(!attacking) {
				xVel -= speed;
				this.scaleX = -1;
				if(onGround && jumpCount == 0){
					this.gotoAndStop("walk");
				}
			}					
		}
				
		// Move and face player to the left.
		public function moveRight():void {
			if(!attacking) {
				xVel += speed;
				this.scaleX = 1;
				if(onGround && jumpCount == 0){
					this.gotoAndStop("walk");
				}
			}			
		}
		
		// Dashes the character to the left.
		public function dashLeft():void {
			xVel -= dashSpeed;   // Dashes the player to where it is facing.
		}
		
		// Dashes the character to the right.
		public function dashRight():void {
			xVel += dashSpeed;   // Dashes the player to where it is facing.
		}
		
		// Jump the player if on ground.
		public function jump():void {						
			if(jumpCount >= 2) {
				onGround = false;				
			}
			
			if(onGround) {				
				jumpCount++;
				yVel = -jumpPower;
				if(jumpCount == 1) {
					this.gotoAndStop("jump");
				} else {
					this.gotoAndStop("spin");
				}
			}
		}
		
		// If player is hit by enemy.
		public function hit():void {
			yVel = -10;
			xVel = -20 * this.scaleX;
		}
		
		// Make the player attack.
		public function attack():void {
			if(!attacking) {
				attacking = true;
				this.gotoAndStop("attack");
			}
		}
		
		// Push player upwards, if player stepped on spring/mushroom.
		public function spring():void {
			yVel = -springPower;
			jumpCount = 1;
			this.gotoAndStop("jump");
		}
		
		// Handle physics of the player
		public function physics():void {
			// Influence the player with the friction and gravity.
			this.x += xVel;
			this.y += yVel;
			
			xVel *= FRICTION;
			yVel += GRAVITY;
			
			// Restrict downward velocity.
			if(yVel > 100) {
				yVel = 100;
			}
			
			// If player is falling, then player is no longer on the ground. ex. walking off a platform.
			/*if(yVel > 1) {
				onGround = false;
			}*/
			
			// Call functions that prevents the player from passing through objects.
			downPush();
			upPush();
			upPushCloudPlatform();
			leftPush();
			rightPush();
			
			// Handle priorities.
			priorities();			
		}
		
		private function priorities():void {
			// Handle attacking.
			if(attacking && attackDurCounter < attackDur) {
				attackDurCounter++;
				attack();
			} else {
				attackDurCounter = 0.0;
				attacking = false;
			}
		}
		
		
		// Prevent player from falling down the ground.
		private function upPush():void {
			for(var i:int = 0; i < downArr.length; i++) {
				var pointPos:int = downArr[i];
				var xPos:Number = this.x + pointPos;
				var yPos:Number = this.y;
				
				while(ground.hitTestPoint(xPos, yPos, true)) {
					jumpCount = 0;
					onGround = true;
					this.y--;  // Before frame updates, subtract y position by 1 until player gets to the top of the object.
					yPos--;
					yVel = 0;   // Set y velocity to 0 to prevent the player from falling by the same velocity.				
				}
			}
		}
		
		// Enable player from jumping up through a cloud Platform behavior and stand above it.
		private function upPushCloudPlatform():void {
			if(yVel > 0) {
				for(var i:int = 0; i < downArr.length; i++) {
					var pointPos:int = downArr[i];
					var xPos:Number = this.x + pointPos;
					var yPos:Number = this.y;
					
					while(cloudPlatform.hitTestPoint(xPos, yPos, true)) {
						jumpCount = 0;
						onGround = true;
						this.y--;  // Before frame updates, subtract y position by 1 until player gets to the top of the object.
						yPos--;
						yVel = 0;   // Set y velocity to 0 to prevent the player from falling by the same velocity.				
					}
				}
			}						
		}
		
		// Prevent player from passing through objects on its left.
		private function leftPush():void {
			var pointPosHor:int = horArr[0];
			
			for(var i:int = 0; i < vertArr.length; i++) {
				var pointPosVert:int = vertArr[i];				
				var xPos:Number = this.x + pointPosHor + xVel;   // Take into account the xVel to look ahead of the character it is heading.
				var yPos:Number = this.y + pointPosVert;
				
				while(ground.hitTestPoint(xPos, yPos, true)) {
					this.x++;  // Before frame updates, add x position by 1 until player gets to the top of the object.
					xPos++;
					xVel = 0;   // Set x velocity to 0 to prevent the player from falling by the same velocity.				
				}
			}
		}
		
		// Prevent player from passing through objects on its right.
		private function rightPush():void {
			var pointPosHor:int = horArr[1];
			
			for(var i:int = 0; i < vertArr.length; i++) {
				var pointPosVert:int = vertArr[i];				
				var xPos:Number = this.x + pointPosHor + xVel;   // Take into account the xVel to look ahead of the character it is heading.
				var yPos:Number = this.y + pointPosVert;
				
				while(ground.hitTestPoint(xPos, yPos, true)) {
					this.x--;  // Before frame updates, subtract x position by 1 until player gets to the top of the object.
					xPos--;
					xVel = 0;   // Set y velocity to 0 to prevent the player from falling by the same velocity.				
				}
			}
		}
		
		private function downPush():void {
			for(var i:int = 0; i < upArr.length; i++) {
				var pointPos:int = upArr[i];
				var xPos:Number = this.x + pointPos;
				var yPos:Number = this.y - headPoint;
				
				while(ground.hitTestPoint(xPos, yPos, true)) {
					this.y++;  // Before frame updates, subtract y position by 1 until player gets to the top of the object.
					yPos++;
					yVel = 1;   // Set y velocity to 1 to bounce the player back to the ground when it hit an object above its head.	
				}
			}
		}
	}
}
