define class ColaboradorNotificaciones as ZooSession of ZooSession.prg

	cUsuario = ''
	
	*-------------------------------------------------------------------
	Function SeteosPrivados() as VOID 
		dodefault()
		this.cUsuario = goServicios.Seguridad.cUltimoUsuarioLogueado
	endfunc

	*-----------------------------------------------------------------------------------------
	function EnviarNotificacion( tcNombreSP as string, tnNumero as int, tcEntidad as String ) as Void
		local lcSQL as String 
		text to lcSQL textmerge noshow
			declare @Param nvarchar(195) = '<<alltrim(tcNombreSP)>> <<transform(tnNumero)>>,"<<alltrim(tcEntidad)>>"'
			declare @Handle uniqueidentifier
			begin dialog conversation @Handle
			from service [ZooLogic_Notificaciones_serviceInitiator]
			to service 'ZooLogic_Notificaciones_serviceTarget'
			on contract [ZooLogic_Notificaciones_contract]
			with encryption = off;
			send on conversation @Handle
			message type [ZooLogic_Notificaciones_message](@Param)
		endtext 
		goDatos.EjecutarSQL( lcSQL, "", this.DataSessionId )
	endfunc

enddefine
