package net.smartsocket.smartlobby.lobby.components
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import net.smartsocket.smartlobby.tools.*;
	
	public class UserList extends MovieClip
	{
		public function UserList()
		{
			tab.label.text = "User List";
			this.addEventListener(MouseEvent.DOUBLE_CLICK, startPM);
		}
		
		public function startPM(e:MouseEvent) {
			
			Globals.lobby.pm.visible = true;
			var o:Object = {Target:_list.selectedItem.label, uid:_list.selectedItem.data};
			Globals.lobby.pm.startPM(o);
		}

	}
}