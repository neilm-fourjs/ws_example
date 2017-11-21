
GLOBALS "ws_example.inc"

MAIN
	DEFINE wsstatus SMALLINT
	DEFINE d om.DomDocument
	DEFINE r, n, cc om.DomNode

	LET myService_myServicePortTypeSoap12Endpoint.Address.Uri = "http://localhost/g/ws/r/tc/myService"
	DISPLAY "Attemping to call:",myService_myServicePortTypeSoap12Endpoint.Address.Uri

	LET myFunction.astring = "Hello World Again"
	CALL myFunction_g() RETURNING wsstatus
	IF wsstatus < 0 THEN
		DISPLAY "WS Call failed:",wsstatus
		DISPLAY wsError.description
	END IF
	DISPLAY myFunctionResponse.myreply

	LET d = om.DomDocument.createFromString( myFunctionResponse.myver )
	TRY
		LET r = d.getDocumentElement()
	CATCH
		DISPLAY "Failed to make domNode from ", myFunctionResponse.myver
		EXIT PROGRAM
	END TRY

	DISPLAY r.getTagName() 
	LET n = r.getFirstChild()
	DISPLAY n.getTagName(), " : ",n.getAttribute("fgldir")
	LET n = n.getNext()
	LET cc = n.getFirstChild()
	DISPLAY cc.getAttribute("@chars")
	DISPLAY r.toString()
END MAIN