﻿package {
	import flash.net.Socket;
	import flash.events.*;
	final public class SmartLobby {
		protected var s:Socket;
		
		//############### CONNECTION CONTROL
		public var onConnect:Function;
		public var onDisconnect:Function;
		public var onError:Function;
		
		//############### ACCOUNT CONTROL
		public var onLogin:Function;
		public var onRegister:Function;

		//############### LISTING FEATURES
		public var onRoomList:Function;
		public var onUserList:Function;

		//############### ROOM CONTROL
		public var onCreateRoom:Function;
		public var onJoinRoom:Function;
		public var onLeaveRoom:Function;
		public var onUserJoin:Function;
		public var onUserLeave:Function;

		//############### CHAT CONTROL
		public var onRoomMessage:Function;
		protected var onPrivateMessage:Function;

		//############### USER OBJECT CONTROL
		public var my:Object;

		final public function SmartLobby() {
			s = new Socket();
			s.addEventListener(ProgressEvent.SOCKET_DATA, onXML);
			s.addEventListener(Event.CONNECT, onConnected);
			s.addEventListener(IOErrorEvent.IO_ERROR, onErrors);
		}
		
		public function connect(host:String, port:Number) {
			s.connect(host, port);
		}
		
		protected function onConnected(e:Event) {
			this.onConnect(e);
		}
		protected function onDisonnected(e:Event) {
			this.onDisconnect(e);
		}
		protected function onErrors(e:ErrorEvent) {
			this.onError(e);
		}
		protected function onXML(event:ProgressEvent) {
			var xml:XML = XML(s.readUTFBytes(s.bytesAvailable));
			trace("Cmd: "+xml.name());
			if (this[xml.name()](xml)) {
				trace("Cmd sent");
			}else {
				trace("Command not sent: "+this[xml.name()]);
			}
			return true;
		}
		public function send(data:String) {
			s.writeUTFBytes(data);
			s.flush();
			return true;
		}
	}
}