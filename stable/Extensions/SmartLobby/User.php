<?php
class User {
	public $room;
	public $socket_id;
	public $ip;
	public $username;
	public $id;
	
	public function User($username, $id, $socket) {
		$this->username = (string)$username;
		$this->id = (int)$id;
		$this->socket_id = $socket;
		$this->ip = stream_socket_get_name($socket, true);
	}
	
	//############### LISTING FEATURES
	/**
	 * Obtain an XML formatted list of rooms.
	 * @param $socket
	 * @param $xml
	 * @return unknown_type
	 */
	public function getRoomList($socket, $xml) {
		Logger::log(__CLASS__, $this->cd(__CLASS__, __FUNCTION__." was called."));

	}

	/**
	 * Obtain an XML formatted list of users in the current room.
	 * @param $socket
	 * @param $xml
	 * @return unknown_type
	 */
	public function getUserList($socket, $xml) {
		Logger::log(__CLASS__, $this->cd(__CLASS__, __FUNCTION__." was called."));

	}

	//############### ROOM CONTROL
	/**
	 * Create a room with specified parameters.
	 * @param $socket
	 * @param $xml
	 * @return unknown_type
	 */
	public function createRoom($socket, $xml) {
		Logger::log(__CLASS__, $this->cd(__CLASS__, __FUNCTION__." was called."));

	}
	
}
?>
	
