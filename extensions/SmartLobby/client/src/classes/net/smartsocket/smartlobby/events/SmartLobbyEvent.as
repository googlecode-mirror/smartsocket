package net.smartsocket.smartlobby.events
{
	import flash.events.Event;
	
	public class SmartLobbyEvent extends Event
	{
		public static const onCreateRoom:String = "onCreateRoom";
		public static const onMessagePrivate:String = "onMessagePrivate";
		public static const onMessageRoom:String = "onMessageRoom";
		public static const onRoomAdd:String = "onRoomAdd";
		public static const onRoomCountUpdate:String = "onRoomCountUpdate";
		public static const onRoomDelete:String = "onRoomDelete";
		public static const onRoomJoin:String = "onRoomJoin";
		public static const onRoomLeave:String = "onRoomLeave";
		public static const onRoomList:String = "onRoomList";
		public static const onTeamList:String = "onTeamList";
		public static const onTeamListChange:String = "onTeamListChange";
		public static const onTeamReadyStatusChange:String = "onTeamReadyStatusChange";
		public static const onUserJoin:String = "onUserJoin";
		public static const onUserLeave:String = "onUserLeave";
		public static const onUserList:String = "onUserList";
		
		public var data:*;
		
		public function SmartLobbyEvent(type:String, d:*)
		{
			this.data = d;
			super(type);
			trace("Event constructor: "+type);			
		}
		
		override public function clone():Event {
			trace("Clone worked");
			return new SmartLobbyEvent(type, this.data);
		}
	}
}