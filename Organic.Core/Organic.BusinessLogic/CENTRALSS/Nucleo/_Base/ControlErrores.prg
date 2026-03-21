#include registry.h

define class ControlErrores as zooSession of zooSession.prg

	#IF .f.
		Local this as ControlErrores of ControlErrores.prg
	#ENDIF

	*-----------------------------------------------------------------------------------------
	function EsErrorControlado( toEx as zooException of zooException.prg ) as boolean
		return inlist( toEx.nZooErrorNo, 10, 20, 9001 )
	endfunc

	*-----------------------------------------------------------------------------------------
	function ControlarError( toEx as zooException of zooException.prg ) as boolean
		local llRetorno as Boolean, loError as Exception, loEx as zooException of zooException.prg &&loRegistry as registry of registry.vcx
		llRetorno = .t.
		
		Try
			do case
				case toEx.nZooErrorNo = 10 or toEx.nZooErrorNo = 20
					goMensajes.Enviar( "Se ha detectado que faltan archivos necesarios para que el sistema funcione correctamente." + chr(13) + ;
						"Por favor reinstale la aplicación o comuníquese con Mesa de Ayuda." + chr(13) +;
						"Por consultas de teléfonos de contacto y horarios de atención ingrese a nuestro sitio web en www.zoologic.com.ar" )
				case toEx.nZooErrorNo = 9001
					goMensajes.advertir( toEx )
				
				otherwise
					llRetorno = .f.
			endcase
		Catch To loError
			loEx = Newobject( "ZooException", "ZooException.prg" )
			With loEx
				.Grabar( loError )
				gomensajes.enviar( loEx )
			endwith
		Finally
		EndTry
		
		return llRetorno
	endfunc 

enddefine
