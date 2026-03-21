Define Class AccesoDatos as ZooCustom of ZooCustom.prg
&&As "ZooSession" Of "ZooSession.prg"

*DataSession  = 1

*!*		Function Init

*!*		Endfunc

	lNoCheckSessionOpen = .f. && para omitir el objeto del analisis de sessiones abiertas de test de foxunit
	
	*-----------------------------------------------------------------------------------------
	Function AbrirTabla( tcNombre As String, tlExclusivo As boolean, tcRuta As String,  ;
			tcAlias As String , tlAgain As Boolean ) As boolean
		Local lcComando As String,llRetorno As Boolean, lcRuta As  String, lcAlias As String


		llRetorno = .T.

		If Empty( tcRuta )
			lcRuta = ""
		Else
			lcRuta = Addbs( Alltrim( tcRuta ) )
		Endif

		If File( lcRuta + This.NombreDbf( tcNombre ) )
			lcComando = "Use in 0 " + lcRuta + tcNombre
		Else
			llretorno = .F.
		Endif

		If llRetorno
			If Empty( tcAlias )
				If Used( tcNombre )
					llretorno = .F.
				Endif
			Else
				If Used( tcAlias )
					llretorno = .F.
				Else
					lcComando = lcComando + " Alias " + tcAlias
				Endif
			Endif
		Endif

		If llretorno
			If tlExclusivo
				lcComando = lcComando + " Exclusive "
			Else
				lcComando = lcComando + " Shared "
			Endif
		Endif

		If llretorno
			If tlAgain
				lcComando = lcComando + " Again"
			Endif
		Endif

		If llretorno
			Try
				&lcComando
				llRetorno = .T.
			Catch
				llRetorno = .F.
			Endtry
		Endif
		Return llRetorno
	Endfunc


	*-----------------------------------------------------------------------------------------
	Function CerrarTabla( tcLisAlias As String ) As boolean

		Local lcAlias

		tcLisAlias = Strtran( tcLisAlias, " ", "" )

		If !(Right(tcLisAlias,1)=",")
			tcLisAlias=tcLisAlias+","
		Endif

		Do While !Empty( tcLisAlias )
			lcAlias  = Substr( tcLisAlias,1,At(",",tcLisAlias)-1)
			tcLisAlias = Substr( tcLisAlias,At(",",tcLisAlias)+1)
			If Used( lcAlias )
				Use In ( lcAlias )
			Endif
		Enddo

		Return
	Endfunc


	*-----------------------------------------------------------------------------------------
	Function EstaAbierta( tcAlias As String ) As boolean
		Return Iif( Used( tcAlias ), .T., .F. )
	Endfunc


	*-----------------------------------------------------------------------------------------
	Hidden  Function NombreDbf( tcNombre As String ) As String

		Local lcRetorno As String

		lcRetorno = Strtran( Alltrim( Upper( tcNombre ) ), ".DBF" , "" ) + ".DBF"

		Return lcRetorno
	Endfunc

Enddefine
