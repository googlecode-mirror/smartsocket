package net.smartsocket.protocols.json
{
	dynamic public class ServerCall extends Array
	{
		private var properties:Object = {};
		
		public function ServerCall(method:String)
		{
			push(method);
			push(properties);
			
		}
		
		public function put(key:Object, value:Object):void {
			properties[key] = value;
		}
	}
}