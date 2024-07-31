package {
	
	//import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	public class Main extends MovieClip {
				
		private var aDown:Boolean = false;
		private var dDown:Boolean = false;
		private var wDown:Boolean = false;
		private var dash:Boolean = false;
		private var attack:Boolean = false;
		private var player:Player;
		public var springers:Array = new Array();
		public var worms:Array = new Array();
		
		public function Main():void {
			super();												
		}
		
		public function start():void {
			// Initialize Listeners.			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);			
			stage.addEventListener(Event.ENTER_FRAME, cameraFollowplayeracter);
			stage.addEventListener(Event.ENTER_FRAME, update);						
			
			//Instantiate Enemy.			
			worms[0] = new Worm(1200, 632, ground, cloudPlatform, -1);
			
			// Add worms.
			for(var i = 0; i < worms.length; i++) {
				addChild(worms[i]);
			}
			
			// Instantiate player.
			player = new Player(ground, cloudPlatform);	
			addChild(player);
		}
		
		// Follow player with camera.
		private function cameraFollowplayeracter(e:Event):void {
			root.scrollRect = new Rectangle(player.x - stage.stageWidth/2 - 20, player.y - stage.stageHeight/2 - 150, stage.stageWidth + 40, stage.stageHeight);
		}
		
		// update is called once per frame.
		private function update(e:Event):void {										
			// Player controls.
			if(!aDown && !dDown) {
				player.idle();
			}
			if(aDown) {
				player.moveLeft();
			}	
			if(dDown) {
				player.moveRight();
			}
			if(wDown) {
				player.jump();
				wDown = false;
			}
			if(dash) {
				if(aDown) {
					player.dashLeft();
				} else if(dDown) {
					player.dashRight();
				}
			}
			if(attack) {
				player.attack();
			}
			
			player.physics();	// Call physics update.
			moveSprings();			
			
			// Move enemies if they are visible else stop them.
			for (var i = 0; i < worms.length; i++){
				var a = player.x - worms[i].x;
				var b = player.y - worms[i].y;
								
				var distance = Math.sqrt(Math.pow(a, 2) + Math.pow(b, 2));
				
				if(distance < 580 && b > -150) {
					worms[i].isVisible = true;
				} else {
					worms[i].isVisible = false;
				}
				worms[i].move();
			}
			
			testEnemyHit();
			flashFollowCamera();
		}
		
		private function flashHit():void {
			flashScreen.gotoAndPlay(2);
		}
		
		private function flashFollowCamera():void {
			flashScreen.x = player.x - stage.stageWidth/2 - 20;
			flashScreen.y = player.y - stage.stageHeight/2 - 150;
		}
		
		private function testEnemyHit():void {
			for(var i = 0; i < worms.length; i++) {
				var w = worms[i];
				
				if(w.hitTestObject(player.hitbox)) {
					player.hit();
					flashHit();
				}
			}
		}
		
		private function moveSprings():void {
			for(var i = 0; i < springers.length; i++) {
				var s = springers[i];
				
				//triggercd = cooldown.
				// Pause frame 2 of mushroom before resetting to frame 1.
				if(s.triggercd >= 45) {
					s.gotoAndStop(1);				
				}


				if(!s.triggered) {
					if(s.springHitbox.hitTestObject(player)) {
						s.gotoAndStop(2);
						s.triggered = true;
						s.triggercd = 0;
						player.spring();
					}
				} else {
					s.triggercd++;
					if(s.triggercd >= 120) {
						s.triggered = false;
						s.triggercd = 0;
						s.gotoAndStop(1);
					}
				}
			}
		}
		
		// Check if key is down.
		private function keyDown(e:KeyboardEvent):void {
			// Keycode: 65 = a, 37 = left arrow key.
			if(e.keyCode == 65 || e.keyCode == 37) {
				aDown = true;
			}
			// Keycode: 68 = d, 39 = right arrow key.
			if(e.keyCode == 68 || e.keyCode == 39) {
				dDown = true;
			}
			// Keycode: 87 = w, 38 = up arrow key.
			if(e.keyCode == 87 || e.keyCode == 38) {
				wDown = true;
			}
			// Keycode: 16 = shift key.
			if(e.keyCode == 16) {
				dash = true;
			}
			//Keycode: 74 = j.
			if(e.keyCode == 74) {
				attack = true;
			}
		}
		
		// Check if key is up.
		private function keyUp(e:KeyboardEvent):void {
			if(e.keyCode == 65 || e.keyCode == 37) {
				aDown = false;
			}
			if(e.keyCode == 68 || e.keyCode == 39) {
				dDown = false;
			}
			if(e.keyCode == 87 || e.keyCode == 38) {
				//wDown = false;
			}
			if(e.keyCode == 16) {
				dash = false;
			}
			if(e.keyCode == 74) {
				attack = false;
			}
		}
	}
}