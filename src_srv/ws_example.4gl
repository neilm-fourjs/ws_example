
IMPORT com

GLOBALS
  DEFINE 
    myService_in RECORD
      aString STRING
    END RECORD,
    myService_out RECORD
      myReply STRING,
			myVer STRING
    END RECORD
END GLOBALS

DEFINE serverURL STRING

MAIN
	DEFINE ret SMALLINT

  IF num_args() = 2 and arg_val(1) = "-W" THEN
		LET serverURL = arg_val(2)
		CALL CreateMyService(true)
		EXIT PROGRAM
  ELSE 
    IF num_args() = 2 and arg_val(1) = "-S" THEN
      CALL fgl_setenv("FGLAPPSERVER",arg_val(2))
      DISPLAY "My service startup"
    END IF
  END IF
  #
  # Create My service
  #
  CALL CreateMyService(false)

  #
  # Start the server
  # Starts the server on the port number specified by the FGLAPPSERVER environment variable
  #  (EX: FGLAPPSERVER=8090)
  #
  DISPLAY SFMT("Starting server on %1 ... ", fgl_getEnv("FGLAPPSERVER") )
  CALL com.WebServiceEngine.Start()
  DISPLAY "The server is listening."

	WHILE TRUE
		LET ret = com.WebServiceEngine.ProcessServices(-1)
		CASE ret
			WHEN 0
				DISPLAY "Request processed." 
			WHEN -1
				DISPLAY "Timeout reached."
			WHEN -2
				DISPLAY "Disconnected from application server."
				EXIT PROGRAM   # The Application server has closed the connection
			WHEN -3
				DISPLAY "Client Connection lost."
			WHEN -4
				DISPLAY "Server interrupted with Ctrl-C."
			WHEN -10
				DISPLAY "Internal server error."
		END CASE
		IF int_flag<>0 THEN
			LET int_flag=0
			EXIT WHILE
		END IF     
	END WHILE
	DISPLAY "Server stopped."

END MAIN
--------------------------------------------------------------------------------
#
# Create My RPC/Literal service
#
FUNCTION CreateMyService(generateWSDL)
  DEFINE serv         com.WebService       # WebService
  DEFINE op           com.WebOperation     # Operation of a WebService
  DEFINE serviceNS    STRING
  DEFINE generateWSDL SMALLINT
  DEFINE ret          INTEGER

  LET serviceNS       = "http://tempuri.org/"

  TRY
  
    # Create My Web Service
    LET serv = com.WebService.CreateWebService("ws_example",serviceNS)
    --CALL serv.setFeature("Soap1.1",TRUE)
    CALL serv.setFeature("Soap1.2",TRUE)
    LET op = com.WebOperation.CreateRPCStyle("myfunc","myFunction",myService_in,myService_out)
    CALL serv.publishOperation(op,NULL)
    IF generateWSDL THEN # Generate WSDL
      LET ret = serv.saveWSDL(serverURL)
      IF ret=0 THEN
        DISPLAY "WSDL saved"      
      ELSE
        DISPLAY "ERROR: Unable to save WSDL"
      END IF
    ELSE # Register service  
      CALL com.WebServiceEngine.RegisterService(serv)  
      DISPLAY "MyService Service registered"
    END IF
    
  CATCH
    DISPLAY "Unable to create 'MyService' Web Service :"||STATUS
    EXIT PROGRAM
  END TRY
    
END FUNCTION
--------------------------------------------------------------------------------
FUNCTION myfunc()
	DEFINE d om.DomDocument
	DEFINE r, n,cc om.DomNode
	DEFINE rec RECORD
		fgldir STRING,
		informixdir STRING,
		logo STRING,
		myint INTEGER
	END RECORD

	LET rec.fgldir = base.Application.getFglDir()
	LET rec.informixdir = fgl_getEnv("INFORMIXDIR")
--	LET rec.logo = ui.Interface.filenameToURI("logo.png")
	LET rec.myint = 69

	LET d = om.DomDocument.create("MyVer")
	LET r = d.getDocumentElement()
	LET n = r.createChild("FGL")
	CALL n.setAttribute("fgldir",base.Application.getFglDir())
	LET n = r.createChild("DB")
	LET cc = d.createChars( fgl_getEnv("INFORMIXDIR") )
	CALL n.appendChild( cc )
	LET n = r.createChild("Logo")
	LET cc = d.createChars( rec.logo )
	CALL n.appendChild( cc )

--	LET r = base.TypeInfo.create( rec )

	LET myService_out.myReply = SFMT("you sent '%1'", myService_in.aString)
	LET myService_out.myVer = r.toString()
	DISPLAY base.TypeInfo.create(rec)
END FUNCTION