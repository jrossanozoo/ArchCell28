define class ZooXML as ZooSession of ZooSession.prg

	#IF .f.
		Local this as ZooXML of ZooXML.prg
	#ENDIF

	datasession = 1
	
	*-----------------------------------------------------------------------------------------
	function CursorAXML( tcNombreCursor) as String
		Local lcRetorno as String
		
		cursortoxml(tcNombreCursor,"lcRetorno",3,4, 0, "1")
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function XmlACursor( tcXml as String, tcNombreCursor as String ) as Void
		xmltocursor( tcXml, tcNombreCursor ) 
	endfunc 

enddefine

