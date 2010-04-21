package net.smartsocket.smartlobby.lobby.components
{
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.ui.Keyboard;
	
	import net.smartsocket.smartlobby.tools.*;
	import net.smartsocket.smartlobby.SmartLobby;
	
	public class Chat extends MovieClip
	{
		
		public function Chat()
		{
			tab.label.text = "Chat";
			in_txt.text = "Welcome to Tactics of War!";
			
			out_txt.addEventListener(KeyboardEvent.KEY_DOWN, handle_keydown);
		}
		
		private function handle_keydown(e:KeyboardEvent) {
			
			if(e.keyCode == Keyboard.ENTER) {
				
				if(out_txt.text != "") {
					SmartLobby.customListeners["server"].sendRoom(out_txt.text);
					out_txt.text = "";
				}
			}
			
		}

	}
}