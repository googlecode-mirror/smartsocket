<?php
/**
 * Basic extension profile.
 * 
 * Template is an interface
 * 
 * I'm super lazy.
 */
Class SmartFuse implements Template{
	protected $s;
	protected $AuthedSockets = array();
	
	public function SmartFuse() {
		Logger::log(__CLASS__, "Extension loaded.");
		mysql_pconnect("localhost", "smartlobby", "smartlobby")or die("No Mysql");
		mysql_select_db("smarylobby") or die("No db");

		
		//# Let's try and locate a configuration file. This is useful for making your own config for your extension.
		if(@file_exists("Extensions/SmartFuse/Config.xml")) {
			$this->Config = simplexml_load_file("Extensions/SmartFuse/Config.xml");
		}else {
			Logger::log(__CLASS__, "No extension config.xml file detected. Skipping...");
		}		
		
		//# Let's create a new server instance.
		$this->s = new Server($this);
		
		//# Let's start the show.
		$this->s->Start();

	}

	public function onConnect($socket) {
		Logger::log(__CLASS__, "The extension has received a connection.");
		
		//# Let's just send them some simple handshake data to test and see if they are able to receive.
		
		$this->s->Send($socket, "<toConsole msg='Uhh... Hi.' />");
		
		if ($this->debug === true) {
			array_push($this->AuthedSockets, $socket);
			Logger::log(__CLASS__, "Debug / Test mode: Client automatically authenticated.");
			$this->s->Send($socket,"<toConsole msg='Debug / Test mode: Client automatically authenticated.' />");
		}
	}
	
	public function onReceive($socket, $raw_data) {

		Logger::log(__CLASS__, "Data Received: $socket, ".$raw_data);

		//# Let's write the received data fo a file for loging purposes.
		$file = fopen("ProtocolLog.txt", "a");
		fwrite($file, $raw_data);

		/*
		 * We are using XML here, so let's ensure that the data being sent to the server is in fact
		 * XML. If it isn't that means that someone has sent unauthorized packets and we should log
		 * their IP address, ban it, and disconnect that client.
		 */

		if(!$xml = @simplexml_load_string($raw_data)) {
			Logger::log(__CLASS__, "Invalid XML received from $socket. Disconnecting user.");
			$this->s->Send($socket,"<toConsole msg='You have not sent well formatted XML. You must now start over.' />");
			$this->s->Handler->onDisconnect($socket, $this->s->master);
			return false;
		}
		
		/*
		 * Let's see if that user is authed or not.
		 * We check to see if the client has already been authed.
		 * If it hasn't, then it will check to see if the data that this method is recieving is a key
		 * to auth them. If it isnt' then they will be disconnected and their command will be discarded.
		 * If they ARE sending an auth key, then the 
		 */
		
		if(!in_array($socket, $this->AuthedSockets)) {
			//# User has not been authed. The only command we will accept is
			//# the lock command. If the command is not the lock command, we
			//# should disconnect that user...
			if( (string)$xml->getName() != "lock" ) {
				//# Lock command not issued, let's dc them				
				Logger::log(__CLASS__, "Client not authed and not sending auth key. Disconecting...");
				$this->s->Handler->onDisconnect($socket, $this->s->master);
				return false;
			}else {
				//# Lock command was issued, let's check their key.
				echo("asdasd: ".((float)$xml["time"]+$this->SecretOffset)."\n");
				
				$KeyHoleShape = md5(((float)$xml["time"]+$this->SecretOffset)."$this->SecretWord");
				
				//# Compare Key to KeyHole
				if( (string)$xml["key"] != $KeyHoleShape ) {
					Logger::log(__CLASS__, "Client sent invalid auth key ".$xml["key"]." to $KeyHoleShape... Disconecting...");
					$this->s->Handler->onDisconnect($socket, $this->s->master);					
					return false;
				}else {
					//# Add them to the authed sockets array. We will delete them when they depart.
					array_push($this->AuthedSockets, $socket);
					//# No need to send them a message, if the client is still connected
					//# It will begin to transmit data immediately after sending the key to the server.
					Logger::log(__CLASS__, "Client sent valid auth key ".(string)$xml["key"]." to $KeyHoleShape...");
					return true;
				}
			}
			
			//# Let's go ahead and return here so make sure nothing gets though.
			return true;
		}

		/*
		 * Now we need to check that the command being sent to the server actually exists.
		 * Without this error checking, the server will crash with a FATAL error for calling a
		 * non existant method. This would not be good. Instead, we will simply disregard that command
		 * and possibly ban that client, if we know that our code is sound.
		 */
		if(!method_exists($this, (string)$xml["id"])) {
			Logger::log(__CLASS__, "Valid XML was received, however, no corresponding command exists.");
			$this->s->Send($socket, "<toConsole msg='Valid XML was received, however, no corresponding command exists. (".$xml["id"]."?)' />");
			return false;
		}else {
			$command = ( (string)$xml["id"] );
			$this->$command($socket, $xml);
		}

		//# We can send it back to the client like this
		$this->s->Send($socket, "You sent: ".$raw_data);

	}
	
	public function onDisconnect($socket) {
			Logger::log(__CLASS__, "User departed...");
			
			//# If you want some other disconnect logic here, you can create it.
	}

	//# Begin fuse port
	//############### ACCOUNT CONTROL
	/**
	 * Create a registered user using MySQL or a database of your choice.
	 * @param $socket
	 * @param $xml
	 * @return bool
	 */
	public function register( $socket, $xml ) {
		Logger::log(__CLASS__, __FUNCTION__." was called by $socket.");
		
		/*$sql = "
		SELECT `username`,`password`
		FROM `users` WHERE
		`username` = '".safe( (string)$xml["username"] )."' AND
		`password` = '".safe( $xml["password"] )."'
		LIMIT 1";
		$query = mysql_query($sql);*/

	}

	/**
	 * Login a registered user, or guest if guest accounts are enabled.
	 * @param $socket Resource
	 * @param $xml SimpleXMLElement
	 * @return bool
	 */
	public function login( $socket, $xml ) {
		Logger::log(__CLASS__, __FUNCTION__." was called.");

		$sql = "
		SELECT `username`,`password`
		FROM `users` WHERE
		`username` = '".safe( (string)$xml["username"] )."' AND
		`password` = '".safe( $xml["password"] )."'
		LIMIT 1";
		$query = mysql_query($sql);

		$sql = "
		SELECT `username`
		FROM `users_online` WHERE
		`username` = '".safe( $xml["username"] )."'
		LIMIT 1";
		$query2 = mysql_query($sql);

		if(mysql_num_rows($query) === 1 and mysql_num_rows($query2) === 0 or 1==1) {
			
			mysql_free_result($query);
			mysql_free_result($query2);
				
			$sql ="
			INSERT INTO `users_online`
			(`username`, `socket_id`)
			VALUES
			('".safe( (string)$xml['username'] )."', '".(string)$socket."')
			";
			mysql_query($sql);
			Logger::log(__CLASS__, mysql_error());
				
			$this->s->Send($socket, "<onLogin s='1' username='".(string)$xml['username']."' />");
			return true;
		}else {
			$this->s->Send($socket, "<onLogin s='0' e='Invalid login detected' />");
			return false;
		}

	}

	public function broadcast($socket, $xml) {
		//# Do stuff[...]
		$this->s->Send($socket, "<toConsole msg='Command ".__FUNCTION__.": Received request (".$xml.")' />");
	}
	
	public function join($socket, $xml) {
		$this->s->Send($socket, "<toConsole msg='Command ".__FUNCTION__.": Received request (".$xml.")' />");
	}
	
	public function leave($socket, $xml) {
		$this->s->Send($socket, "<toConsole msg='Command ".__FUNCTION__.": Received request (".$xml.")' />");
	}
	
	public function walkto($socket, $xml) {
		$this->s->Send($socket, "<toConsole msg='Command ".__FUNCTION__.": Received request (".$xml.")' />");
	}
	
	public function alert($socket, $xml) {
		$this->s->Send($socket, "<toConsole msg='Command ".__FUNCTION__.": Received request (".$xml.")' />");
	}
	
	public function kick($socket, $xml) {
		$this->s->Send($socket, "<toConsole msg='Command ".__FUNCTION__.": Received request (".$xml.")' />");
	}
	
	public function ban($socket, $xml) {
		$this->s->Send($socket, "<toConsole msg='Command ".__FUNCTION__.": Received request (".$xml.")' />");
	}
	
	public function relocate($socket, $xml) {
		$this->s->Send($socket, "<toConsole msg='Command ".__FUNCTION__.": Received request (".$xml.")' />");
	}
	
	//# MISC
	
	public function client_data($socket , &$user=null) {
		$sql = "
		SELECT *
		FROM `users_online` WHERE
		`socket_id` = '$socket'
		LIMIT 1";
		$query = mysql_query($sql);
		$user = mysql_fetch_assoc($query);
		return $user;
	}
	
}
?>