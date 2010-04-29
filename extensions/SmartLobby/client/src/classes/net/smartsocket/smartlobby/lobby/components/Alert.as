package net.smartsocket.smartlobby.lobby.components
{
	import com.greensock.TweenLite;
	import com.greensock.easing.*;
	
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.text.TextField;
	
	import net.smartsocket.smartlobby.tools.*;
	
	public class Alert extends MovieClip {
		
		var baseW;
		var baseH;
		
		public function Alert(type:String, value:*, title:String=null, draggable:Boolean=false)	{
								
			var src:*;
			switch(type) {
				
				case "TextField":
				src = createTextField(0,0,380,20);
				src.autoSize = "left";
				src.multiline = true;
				src.wordWrap = true;
				src.htmlText = value;
				break;
				
				case "MovieClip":
				src = value;
				break;
				
				default:
				break;
			}
			
			this["tab"].label.text = title;
			this["cpane_mc"].source = src;

			this.x = 760/2;
			this.y = 760/2;
			
			addEventListener(Event.ADDED_TO_STAGE, animate_in);
			
		}
		
		
		private function createTextField(x:Number, y:Number, width:Number, height:Number):TextField {
			var r:TextField = new TextField();
			r.x = x;
			r.y = y;
			r.width = width;
			r.height = height;
			return r;
		}
	
		private function animate_in(e:Event):void {
			TweenLite.from(this, 1, {alpha: 0, scaleY: 0, ease: Elastic.easeInOut, onUpdate: revalidateButtons, onComplete:animate_in_buttons});
			
		}
	
		public function animate_out():void {
			trace("Trying to use an ease out animation!");
			TweenLite.to(this, 1, {alpha: 0, scaleX: 0, scaleY: 0, ease: Elastic.easeInOut, onComplete: removeMe});
		}
		
		private function removeMe() {
			try {
				parent.removeChild(this);
				trace("Alert removed");
			}catch(e) {
				trace("Alert not removed "+e);
			}
		}
		
		
		
		private function animate_in_buttons():void {
			TweenLite.from(ok, 1, {alpha: 0, scaleY: 0, ease: Elastic.easeInOut});
			ok.visible = true;
		}
		
		private function revalidateButtons() {
			ok.visible = false;
		}
	}	
}