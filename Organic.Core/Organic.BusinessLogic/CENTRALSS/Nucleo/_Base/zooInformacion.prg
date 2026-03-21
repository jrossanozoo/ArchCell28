define class ZooInformacion as ZooColeccion of ZooColeccion.prg

	#IF .f.
		Local this as ZooInformacion of ZooInformacion.prg
	#ENDIF

	*-----------------------------------------------------------------------------------------
	function AgregarInformacion( tcInformacion as String, tnNumero as Integer, txInfoExtra as Variant ) as Void
		local loItemInfo as Custom

		loItemInfo = newobject( "ItemInformacion" )
		with loItemInfo
			do case
			case pcount() = 1
				.cMensaje = tcInformacion
			case pcount() = 2
				.cMensaje = tcInformacion
				.nNumero = tnNumero
			case pcount() = 3
				.cMensaje = tcInformacion
				.nNumero = tnNumero
				.xInfoExtra = txInfoExtra
			otherwise
				assert pcount() = 0 message "Llamaron al AgregarInformacion con parametros incorrectos"
			endcase

		endwith

		This.agregar( loItemInfo )

	endfunc 

	*-----------------------------------------------------------------------------------------
	function Limpiar() as Void
		This.Remove( -1 )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function HayInformacion() as Boolean
		return This.Count > 0
	endfunc 

	*-----------------------------------------------------------------------------------------
	function SerializarInformacion() as String
		local lcRetorno as String, lnInfo as Integer, loInfo as iteminformacion of zooinformacion.prg
		
		lcRetorno = ""
		if this.HayInformacion()
			for lnInfo = 1 to this.count
				loInfo = this.item[ lnInfo ]
				lcRetorno = lcRetorno + chr(13) + chr(10) + "Item:" + transform( lnInfo ) + " Mensaje:" + alltrim( loInfo.cMensaje ) + chr(13) + chr(10) + ;
					"     Numero:" + transform( loInfo.nNumero ) + ;
					iif( isnull( loInfo.xInfoExtra ), " Sin Info Extra", " Con Info Extra" )
			endfor
		endif
		
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ExisteMensaje( tcMensaje as String ) as boolean
		local loMensaje as ItemInformacion of ZooInformacion.prg, llRetorno as Boolean
		llRetorno = .f.
		
		for each loMensaje in this
			if loMensaje.cMensaje == tcMensaje
				llRetorno = .T.
			endif
		endfor

		return llRetorno
	endfunc 

Enddefine

*-----------------------------------------------------------------------------------------
define class ItemInformacion as custom
	cMensaje = ""
	nNumero = 0
	xInfoExtra = null
enddefine

