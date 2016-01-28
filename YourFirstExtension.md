# Introduction #
This example makes use of the Java port of SmartSocket.

With SmartSocket you can skip past developing all of the socket server essentials and go straight into your application logic.

SmartSocket uses JSON-RPC style protocol by default. The following will demonstrate a very simple Hello World application to get you started.

Before you start, be sure that the SmartSocket.jar is in your classpath, wherever that may be. In Netbeans, you can simply drag and drop SmartSocket.jar into your libraries folder and it will do all of the classpath work for you.

# Example #

```
package example;
import net.smartsocket.ThreadHandler;
import net.smartsocket.protocols.json.ClientCall;
import org.json.simple.JSONObject;

public class Example {
    //# Your main function that is called as your extension is initialized
    public static void main(String[] args) {
        //# We want to initialize SmartSocket and tell it that this class is the extension and 8888 is the target port to listen on.
	net.smartsocket.Main.main(Example.class, 8888);
    }

    /*
     * The extension's application logic will go down here.
     *
     * When the ThreadHandler object for the client receives data, it will parse the JSON
     * and will call the corresponding method named after the JSONArray's first key name
     * and pass the second object as parameters.
     *
     *
     * Simple JSON Example:
     *	["helloWorld",{
     *	    "paramName" : "hello",
     *	    "anotherParam" : "world"
     *	    }
     *	]
     *
     * would call
     *
     * public void helloWorld(ThreadHandler thread, JSONObject json) { //# Method logic here }
     *
     */


    //# 'thread' represents the client that is sending the data to the server.
    //# 'json' represents the JSON parameters being sent. In this case thats paramName and anotherParam.
    public void helloWorld(ThreadHandler thread, JSONObject json) {
	System.out.println("Received data from client: "+json.toJSONString());
	
	String paramName = json.get("paramName").toString();
	String anotherParam = json.get("anotherParam").toString();

	System.out.println("paramName=>"+paramName+" / anotherParam=>"+anotherParam);
	//# If using the above example JSON data prints
	//# paramName=>hello / anotherParam=>world

        //# Let's send the message back to the client for testing.
        thread.send("The server received :"+json+" from you.");

        //# Let's make our own server greeting!
        ClientCall clientCall = new ClientCall("helloBackAtYou");
        clientCall.put("serverGreeting", "Hello back at ya!");
        thread.send(clientCall);
    }
}

```

On the client side, you have several options at your disposal. You can also create code that parses JSON data on the client to route commands in the same fashion. The built in SmartLobby extension has a Flash API that does just that.