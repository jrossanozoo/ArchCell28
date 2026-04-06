Define Class ColaboradorOutlook As zoosession Of zoosession.prg

	oEntidadToleranciaHS = null
	oCrearCita = null
	nDiasALaFechaDeHoy = 0

	*-----------------------------------------------------------------------------------------
	Function ObtenerUsuario() As String
		Local lcCurServer As String , lcSQL As String , lcUsuario As String
		lcUsuario = Alltrim(  goServicios.seGURIDAD.culTIMOUSUARIOLOGUEADO )
		Return lcUsuario
	Endfunc

	*-----------------------------------------------------------------------------------------
	function CrearCita( toEntidadCitas as Object ) as String
		local lcResultadoCreacionCita as String, loEntidadCitas as Object, loCitaInstanciaOrigen as Object, loCitaInstanciaDestino as Object,;
			loCitaInstanciaSala as Object, loCitaObjeto as Object, loError as Object, lcFecha as String, lcStart as String, lcEnd as String,;
			lcDestinoMail as String, lcEmailFrom as String, lcEmailTo as String

		loEntidadCitas = toEntidadCitas
		try
			loCitaInstanciaOrigen = this.oCrearCita.ObtenerInstancia()
			loCitaInstanciaDestino = this.oCrearCita.ObtenerInstancia()
			loCitaInstanciaSala = this.oCrearCita.ObtenerInstancia()
			loCitaObjeto = this.oCrearCita.ObtenerObjetoMeeting()

			lcFecha = str( year( loEntidadCitas.FechaProgramada ), 4 ) + strtran( str( month( loEntidadCitas.FechaProgramada ), 2 ), " ", "0" ) + strtran( str( day( loEntidadCitas.FechaProgramada ), 2 ), " ", "0" )
			lcStart = lcFecha + "T" + strtran( loEntidadCitas.HoraProgramacion_pk, " ", "0" ) + strtran( loEntidadCitas.MinutoProgramacion_pk, " ", "0" ) + "00"
        	lcEnd = lcFecha + "T" + strtran( loEntidadCitas.HoraFinPrograma_pk, " ", "0" ) + strtran( loEntidadCitas.MinutoFinProgra_pk, " ", "0" ) + "00"

            with loCitaObjeto
				lcEmailFrom = alltrim( lower( loEntidadCitas.Regpor_pk ) ) + "@zoologic.com.ar"
				.EmailFrom = alltrim( lcEmailFrom )
*				.EmailFrom = "cnebuloni@zoologic.com.ar"
				.Subject = alltrim( loEntidadCitas.Asunto ) + " (Asignada a: " + alltrim( upper( loEntidadCitas.Asignada_pk ) ) + ")"
				.Location = iif(alltrim( loEntidadCitas.Ubicacion ) = "", alltrim( loEntidadCitas.Sala.Descripcion ), alltrim( loEntidadCitas.Ubicacion ) )
				.Body = this.ObtenerBodyCita( loEntidadCitas )
				.Start = lcStart
				.End = lcEnd
				.NumberID = "Cita_De_ZL_Numero_" + alltrim( str( loEntidadCitas.Numero ) )
				.TypeMeeting = "PUBLISH"

				if loEntidadCitas.EnvAlOrganizador and ( loEntidadCitas.EsNuevo() or loEntidadCitas.EsEdicion() )
					lcDestinoMail = "Organizador"
					lcEmailTo = alltrim( lower( loEntidadCitas.Regpor_pk ) ) + "@zoologic.com.ar"
					.EmailTo = lcEmailTo
*					.EmailTo = "cnebuloni@zoologic.com.ar"
					loCitaInstanciaOrigen.Enviar( loCitaObjeto )
				endif
				lcDestinoMail = "Destinatario"
				lcEmailTo = alltrim( lower( loEntidadCitas.Asignada_pk ) ) + "@zoologic.com.ar"
				.EmailTo = lcEmailTo
				.Subject = alltrim( loEntidadCitas.Asunto )
				.TypeMeeting = iif( loEntidadCitas.EsNuevo() or loEntidadCitas.EsEdicion(), "REQUEST", "CANCEL" )
				loCitaInstanciaDestino.Enviar( loCitaObjeto )

				if loEntidadCitas.Sala_pk <> 0
					lcDestinoMail = "Mail de la Sala"
					lcEmailTo = alltrim( loEntidadCitas.Sala.Email )
					.EmailTo = alltrim( lcEmailTo )
					loCitaInstanciaSala.Enviar( loCitaObjeto )
				endif
            endwith

			do case
				case loEntidadCitas.EsNuevo()
					lcResultadoCreacionCita = "Se ha enviado la cita al Outlook del usuario " + alltrim( upper( loEntidadCitas.Asignada_pk ) ) + "."
				case loEntidadCitas.EsEdicion()
					lcResultadoCreacionCita = "Se ha enviado la modificación de la cita al Outlook del usuario " + alltrim( upper( loEntidadCitas.Asignada_pk ) ) + "."
				otherwise
					lcResultadoCreacionCita = "Se ha enviado la cancelación de la cita al Outlook del usuario " + alltrim( upper( loEntidadCitas.Asignada_pk ) ) + "."
			endcase
		catch to loError
			lcResultadoCreacionCita = "Se ha producido un error y no se pudo enviar la cita al " + alltrim( lcDestinoMail ) + " de la reunión."
		finally
			store null to loCitaInstanciaOrigen, loCitaInstanciaDestino, loCitaInstanciaSala, loCitaObjeto, loEntidadCitas
		endtry

		return lcResultadoCreacionCita
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerBodyCita( toEntidadCitas ) as String
		local lcRetorno as String, loEntidadCitas as Object

		loEntidadCitas = toEntidadCitas
		lcRetorno = ""

		with loEntidadCitas
			if upper( alltrim( .cNombre ) ) = "RRHHZLCITAS" and .Candidatura_pk <> 0
				lcRetorno = lcRetorno + "Candidatura: " + alltrim( str( .Candidatura_pk ) ) + " - " + alltrim( .Candidatura.Descripcion ) + chr( 13 ) + chr( 10 )
				lcRetorno = lcRetorno + "Candidato: " + alltrim( str( .Candidato_pk ) ) + " - " + alltrim( .Candidato.Apellido ) + chr( 13 ) + chr( 10 )
				lcRetorno = lcRetorno + "Búsqueda: " + alltrim( str( .Busqueda_pk ) ) + " - " + alltrim( .Busqueda.Descripcion ) + chr( 13 ) + chr( 10 )
				lcRetorno = lcRetorno + "Puesto: " + alltrim( .Puesto_pk ) + " - " + alltrim( .Puesto.Descipcion ) + chr( 13 ) + chr( 10 )
				lcRetorno = lcRetorno + "Sector: " + alltrim( .Sector_pk ) + " - " + alltrim( .Sector.Descripcion ) + chr( 13 ) + chr( 10 )
			endif
			if upper( alltrim( .cNombre ) ) = "RRHHZLCITAS" and .Etapa_pk <> 0
				lcRetorno = lcRetorno + "Etapa: " + alltrim( str( .Etapa_pk ) ) + " - " + alltrim( .Etapa.Descripcion ) + chr( 13 ) + chr( 10 )
			endif
			if alltrim( .Observacion ) <> ""
				lcRetorno = lcRetorno + iif( lcRetorno = "", "", chr( 13 ) + chr( 10 ) ) + "Detalle: " + alltrim( .Observacion )
			endif
		endwith

		return lcRetorno
	endfunc 

	*--------------------------------------------------------------------------------------------------------
	function oCrearCita_Access() as variant
		if !this.lDestroy and ( !vartype( this.oCrearCita ) = 'O' or isnull( this.oCrearCita ) )
			this.oCrearCita = this.ObtenerComponenteMeeting()
		endif
		return this.oCrearCita
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function ObtenerComponenteMeeting() as Object
		_Screen.Zoo.AgregarReferencia( "ZooLogicSA.Meeting.dll" )
		return _Screen.Zoo.CrearObjeto( "ZooLogicSA.Meeting.MeetingFactory" )
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function oEntidadToleranciaHS_Access() as Object
		if !this.ldestroy and ( !vartype( this.oEntidadToleranciaHS ) = 'O' or isnull( this.oEntidadToleranciaHS ) )
			this.oEntidadToleranciaHS = _Screen.Zoo.InstanciarEntidad( "ToleranciaHS" )
		endif
		return this.oEntidadToleranciaHS
	endfunc

	*-----------------------------------------------------------------------------------------
	Function CrearTareaEnOutlook( toEntidadTareas ) As Object
		Local loOutlook As Object, loNameSpace As Object, loTask As Object,;
			loError As Object , lEntryID As String

		loOutlook = Createobject("Outlook.Application")
		loNameSpace = loOutlook.GetNameSpace("MAPI")
		lcResultadoCreacionTarea = ''
		*lEntryID = ''

		Try
			loTask = loOutlook.createitem(3)
			With loTask
				.Subject =  Alltrim( toEntidadTareas.ZL_Titulo )
				.StartDate = toEntidadTareas.ZL_fechaini
				.DueDate =  toEntidadTareas.ZL_fechafin
				.DateCompleted = toEntidadTareas.ZL_DateCompleted
				.Mileage = Transform( toEntidadTareas.ZL_Numero )
				.Companies = Transform( toEntidadTareas.ZL_Cliente )
				.Body = Alltrim( toEntidadTareas.ZL_notas  )
				.Status = 0
				.Save()

			Endwith
			**lcResultadoCreacionTarea  = 'Se ha creado la tarea en el Outlook.'
		Catch To loError
			**lcResultadoCreacionTarea = 'Se ha producido un error y no se pudo generar la tarea en el Outlook.'
		Finally
			*Store Null To loOutlook, loNameSpace, loTask
		Endtry

		Return loTask

	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerTareasDeOutlook() As String
		Local loOutlook As Object, loNameSpace As Object, loTask As Object,;
			lcResultadoCreacionTarea As String , loError As Object, lOutlookSession As Object  	,;
			ltasksFolder As String, ltaskFolderItems As Object, i As  Integer, ;
			lcCursorOutlookTask As String, lRetorno As String, lcFiltro As String,;
			lnDiasDeBusqueda As Number, lresultItems As Object

		lRetorno = ''
		loOutlook = Createobject("Outlook.Application")
		loNameSpace = loOutlook.GetNameSpace("MAPI")
		lcResultadoCreacionTarea  = ''
		lcCursorOutlookTask = 'C' + Sys( 2015 )
		lnDiasDeBusqueda = This.nDiasALaFechaDeHoy

		Create Cursor &lcCursorOutlookTask. ( Numero N(10), Titulo C(80), fechaini D, fechafin D, Cliente C(5),;
			Estado N(2), notas M, EntryID C(140), DateCompleted D, FMODIFW D, HMODIFW C(8) )

		Try
			lOutlookSession = loOutlook.Session
			ltasksFolder = lOutlookSession.GetDefaultFolder(13)
			ltaskFolderItems = ltasksFolder.Items
			ltaskFolderItems.Sort("[StartDate]")
			lcFiltro  =  '[StartDate]> \' + Dtoc( Date() - lnDiasDeBusqueda ) + '\'  &&    * " AND [DueDate]>=\"" +

			lresultItems  = ltaskFolderItems.Restrict( lcFiltro )

			For i = 1 To lresultItems.Count
				loTask = lresultItems.Item( i )

				If ! Isnull(loTask)
					With loTask
						Insert Into &lcCursorOutlookTask.  ;
							( Numero, Titulo , fechaini , fechafin , Cliente, Estado, notas, EntryID, DateCompleted, FMODIFW , HMODIFW ) ;
							Values	 ;
							( Val(.Mileage), .Subject, Ttod( .StartDate), Ttod(.DueDate), .Companies, .Status, .Body, .EntryID,;
							iif( loTask.Complete, Ttod( .DateCompleted ), Ctod('01-01-1900') ) ,;
							ttod(.LastModificationTime),ttoc(.LastModificationTime,2)  )
					Endwith
				Endif

			Next

		Catch To loError

		Finally
			Store Null To loOutlook, loNameSpace, loTask, ltaskFolderItems, ltasksFolder
		Endtry

		If Used( lcCursorOutlookTask ) &&And Reccount( lcCursorOutlookTask ) > 0
			lRetorno = lcCursorOutlookTask
		Endif

		Return lRetorno

	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerTareasDeZL() As String
		Local lcCursorZlTask As String, lcSQL As String, lcUsuario As String, lRetorno As String ,;
			lFechaBusqueda As String

		lRetorno  = ''
		lFechaBusqueda = Dtos(Date() - This.nDiasALaFechaDeHoy )
		lcUsuario = This.ObtenerUsuario()

		lcCursorZlTask  = 'C' + Sys( 2015 )
		TEXT to lcSQL textmerge noshow
			declare @FechaBusqueda  Datetime = '<<lFechaBusqueda>>';

			select
					T.Numero AS Numero,
					T.Ctitulo as Titulo ,
					T.fechai as fechaini ,
					Fechaf as fechaFin ,
					T.Cliente as Cliente ,
					0 as Estado ,
					isnull(T.EntryID, '')  as EntryID ,
					CONVERT( text,
					REPLACE(
					REPLACE( 
					REPLACE(
					replace( convert( varchar(max), T.obs ), CHAR(39), '' ) 
														  , CHAR(34), '' )
														  , '['     , '' )
														  , ']'     , '' )
							) as  Notas  ,
					CONVERT( text,
									rtrim(ltrim(
													REPLACE(
													REPLACE( 
													REPLACE(
													replace( convert( varchar(max), T.obs ), CHAR(39), '' ) 
																						  , CHAR(34), '' )
																						  , '['     , '' )
																						  , ']'     , '' ))) + CHAR(13) + CHAR(10) +
									isnull( 'Oportunidad número: ' + ltrim(rtrim(convert( varchar(10), DTO.Oportunidad ))) 
										+ ' - ' + rtrim(ltrim(isnull( O.Asunto, '' ))) , '' ) + CHAR(13) + CHAR(10) +
									ISNULL( 'Contacto: ' + Contactos.NombreContacto, '') + CHAR(13) + CHAR(10) +
									+ ISNULL( 'Teléfono: ' + Contactos.TelefonoContacto, '')	
							) as  NotasNuevas  ,
					Isnull( C.Fechaa, '19000101' ) as DateCompleted ,
					T.FMODIFW ,
					T.HMODIFW,
					T.ENTRYID
				from  zl.Zltask T
				left join zl.CIERRTA C on C.Numero = T.Ncierre
				left join ( select max( Codigo ) as Oportunidad , Numero as Tarea from  zl.DOPORTAR group by Numero )
						DTO on DTO.Tarea = T.Numero
				Left join ZL.Oportuns O on O.Numero = DTO.Oportunidad 
				left join zl.DCTAR CntOp on CntOp.codigo = T.Numero
				left join (
							 select     
									c.codigo  as Contacto,
									( case when zl.funciones.alltrim(c.pnom) = '' then '' 
										else zl.funciones.alltrim(c.pnom) + ' ' end
									 +case when zl.funciones.alltrim(c.snom) = '' then '' 
										else zl.funciones.alltrim(c.snom) + ' ' end 
									+zl.funciones.alltrim(c.apell)) as NombreContacto,  
								   --telefonos  
									( Select 
												 zl.funciones.alltrim(tiptel.descr) + ': ' +
												 zl.funciones.alltrim(tel.cteled)   + ' // '
													from zl.ctelfs  tel 
													left join zl.tiptel as tiptel on tiptel.ccod = tel.tipo 
												where 	 tel.codtelf = c.codigo 
												for xml path('') 				
												)  as TelefonoContacto   					
								from zl.contact as c							
							) Contactos on Contactos.Contacto =  CntOP.ccon
				where
					T.fechai > @FechaBusqueda
					AND T.Dueno = '<<lcUsuario>>' 
		ENDTEXT


		goServicios.daTOS.ejecutarsql( lcSQL , lcCursorZlTask, Set("Datasession") )

		If Used( lcCursorZlTask ) 
			lRetorno = lcCursorZlTask
		Endif

		Return lRetorno

	Endfunc

	*-----------------------------------------------------------------------------------------
	Function SincronizarTareas( tnDiasALaFechaDeHoy As Integer ) As Void
		Local lcCursorZlTask As String, lcCursorOutlookTask As String,	lcCursorSincroTask As String,;
			loEntidad As Object, lcSQL As String, lcCursorResultadoSP As String, lcUsuario As String,;
			lcTitulo As String, lfechaini As Date, lfechaFin As Date,  lcCliente As String ,;
			lEstado As Number, lcNotas As String, lNumero As Number, lEntryID As Character ,;
			lDateCompleted As Date , lFechaAltaOrigen As Date, lHoraAltaOrigen As String, ;
			loTask As Object

		This.nDiasALaFechaDeHoy =  tnDiasALaFechaDeHoy

		lcUsuario = This.ObtenerUsuario()

		lcCursorResultadoSP = 'C' + Sys(2015)

		lcCursorSincroTask = This.ObtenerSincroTareas()


		*- busco Tareas en el Outlook que no tienen Numero de tarea y las doy de alta en ZL.
		If !Empty( lcCursorSincroTask )

			Select &lcCursorSincroTask.

			Scan && for DateCompleted > ctod( '01-01-1900' )

				Do Case
					Case Alltrim( ZL_EntryID ) = Alltrim(OU_EntryID ) And !Empty( Alltrim(ZL_EntryID )  ) And !Empty( Alltrim(OU_EntryID ) ) ;
							and Ctot( Dtoc(ZL_FMODIFW )+ 'T'+ Alltrim(ZL_HMODIFW) ) <> Ctot( Dtoc(OU_FMODIFW )+ 'T'+ Alltrim(OU_HMODIFW) )

						&&ya Fue sincronizada pero hay  Diferencias . sincronizar!!!
						If 	Ctot( Dtoc(ZL_FMODIFW )+ 'T'+ Alltrim(ZL_HMODIFW) ) > Ctot( Dtoc(OU_FMODIFW )+ 'T'+ Alltrim(OU_HMODIFW) )
							&&Actualizo la de ZL
							Scatter Name loRegistro Memo
							This.ActualizarTareaZLEnOutlook(  loRegistro  )
						Else
							&&Actualizo la de Outlook
							&& Inserta en ZL Tareas de  Outlook
							lNumero		= Transform( OU_Numero )
							lcTitulo 	= Alltrim(OU_Titulo)
							lfechaini 	= Dtos(OU_fechaini)
							lfechaFin 	= Dtos(OU_fechafin)
							lcCliente 	= Alltrim(OU_Cliente)
							lEstado 	= Transform(OU_Estado)
							lcNotas 	= Alltrim(OU_notas)
							lEntryID 	= Alltrim(OU_EntryID )
							lDateCompleted = Dtos(OU_DateCompleted)
							lFechaAltaOrigen = Dtos(OU_FMODIFW )
							lHoraAltaOrigen = OU_HMODIFW

							TEXT to lcSQL textmerge noshow
								declare @NumeroTareaZL Numeric(10) = <<lNumero>>,
										@FechaIni Datetime = '<<lfechaini>>',
										@FechaFin Datetime = '<<lfechaFin>>',
										@DateCompleted Datetime = '<<lDateCompleted>>' ,
										@FechaAltaOrigen datetime = '<<lFechaAltaOrigen>>' ,
										@HoraAltaOrigen Varchar(8) = '<<lHoraAltaOrigen>>';

								exec [ZL].[ActualizarTareasEnZL]
									@NumeroTareaZL ,
									'<<lcUsuario>>' ,
									'<<lcTitulo>>' ,
									@FechaIni ,
									@FechaFin ,
									'<<lcCliente>>' ,
									<<lEstado>> ,
									'<<lcNotas>>' ,
									'<<lEntryID>>' ,
									@DateCompleted ,
									@FechaAltaOrigen ,
									@HoraAltaOrigen
							ENDTEXT

							Try
								goServicios.daTOS.ejecutarsql( lcSQL , lcCursorResultadoSP , Set("Datasession") )
							Catch To loError
							Endtry
						Endif

					Case Empty( Alltrim( ZL_EntryID )  ) And !Empty( Alltrim( OU_EntryID ) )
						&& Inserta en ZL Tareas de  Outlook
						lcTitulo 	= Alltrim(OU_Titulo)
						lfechaini 	= Dtos(OU_fechaini)
						lfechaFin 	= Dtos(OU_fechafin)
						lcCliente 	= Alltrim(OU_Cliente)
						lEstado 	= Transform(OU_Estado)
						lcNotas 	= Alltrim(OU_notas)
						lEntryID 	= Alltrim(OU_EntryID )
						lDateCompleted = Dtos(OU_DateCompleted)
						lFechaAltaOrigen = Dtos(OU_FMODIFW )
						lHoraAltaOrigen = OU_HMODIFW

						TEXT to lcSQL textmerge noshow
						declare @NumeroTareaZL Numeric(10) ,
								@FechaIni Datetime = '<<lfechaini>>',
								@FechaFin Datetime = '<<lfechaFin>>',
								@DateCompleted Datetime = '<<lDateCompleted>>' ,
								@FechaAltaOrigen datetime = '<<lFechaAltaOrigen>>' ,
								@HoraAltaOrigen Varchar(8) = '<<lHoraAltaOrigen>>';

						exec [ZL].[CrearTareasEnZL]
							@NumeroTareaZL output ,
							'<<lcUsuario>>' ,
							'<<lcTitulo>>' ,
							@FechaIni ,
							@FechaFin ,
							'<<lcCliente>>' ,
							<<lEstado>> ,
							'<<lcNotas>>' ,
							'<<lEntryID>>' ,
							@DateCompleted ,
							@FechaAltaOrigen ,
							@HoraAltaOrigen

						Select @NumeroTareaZL
						ENDTEXT

						Try
							goServicios.daTOS.ejecutarsql( lcSQL , lcCursorResultadoSP , Set("Datasession") )
						Catch To loError
						Endtry

						If Used( lcCursorResultadoSP ) And Reccount( lcCursorResultadoSP ) > 0
							lNumero = Evaluate( Alltrim( Field(1, lcCursorResultadoSP) ) )
							This.ActualizarNumeroDeTareaZLEnTareaOutlook( lEntryID, lNumero, lcTitulo )
						Endif


					Case Empty( Alltrim(ZL_EntryID )  ) And Empty( Alltrim(OU_EntryID ) )
						&& Inserta en Outlook Tareas de ZL que nunca fueron sincronizadas
						*- busco Tareas abiertas de ZL que no estan en el Outlook
						Scatter Name loEntidad Memo
						loTask  = This.CrearTareaEnOutlook( loEntidad )
						If !Empty( loTask.EntryID )
							This.ActalizarEntryIDEnZlTask( loTask, ZL_Numero )
						Endif


				Endcase


			Endscan

		Endif

		Use In Select ( lcCursorSincroTask )
		Use In Select ( lcCursorResultadoSP )

	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerSincroTareas() As String
		Local lcCursorSincroTask As String, lcSQL As String, lRetorno As String ,;
			lcCursorZlTask As String, lcCursorOutlookTask As String


		lcCursorZlTask = This.ObtenerTareasDeZL()
		lcCursorOutlookTask = This.ObtenerTareasDeOutlook()

		lRetorno  = ''

		lcCursorSincroTask = 'C' + Sys( 2015 )

		If Used( lcCursorZlTask ) and  Used( lcCursorOutlookTask ) ;
			And ( Reccount( lcCursorZlTask )+ reccount( lcCursorOutlookTask )) > 0
			

			Select ;
				ZLT.Numero As ZL_Numero,;
				OUT.Numero As OU_Numero,;
				ZLT.Titulo As ZL_Titulo ,;
				OUT.Titulo As OU_Titulo ,;
				ZLT.fechaini As ZL_fechaini ,;
				OUT.fechaini As OU_fechaini ,;
				ZLT.fechafin As ZL_fechafin ,;
				OUT.fechafin As OU_fechafin ,;
				ZLT.Cliente As ZL_Cliente   ,;
				OUT.Cliente As OU_Cliente   ,;
				ZLT.Estado As ZL_Estado     ,;
				OUT.Estado As OU_Estado     ,;
				nvl( ZLT.EntryID,'' )  As ZL_EntryID ,;
				nvl( OUT.EntryID,'' )  As OU_EntryID ,;
				iif( alltrim( nvl(ZLT.EntryID,'') ) = '', ZLT.notasNuevas, ZLT.notas ) As ZL_notas,;
				OUT.notas As OU_notas,;
				ZLT.DateCompleted As ZL_DateCompleted ,;
				OUT.DateCompleted As OU_DateCompleted ,;
				ZLT.FMODIFW As ZL_FMODIFW ,;
				OUT.FMODIFW As OU_FMODIFW,;
				ZLT.HMODIFW As ZL_HMODIFW,;
				OUT.HMODIFW As OU_HMODIFW ,;
				ctot( Dtoc(ZLT.FMODIFW) + ' ' + ZLT.HMODIFW ) As ZL_fhModif	,;
				ctot( Dtoc(OUT.FMODIFW) + ' ' + OUT.HMODIFW ) As OU_fhModif	 ;
				from &lcCursorZlTask. As ZLT ;
				full Join &lcCursorOutlookTask. As OUT ;
				on ZLT.EntryID = OUT.EntryID Into Cursor &lcCursorSincroTask.

			If Used( lcCursorSincroTask ) And Reccount( lcCursorSincroTask ) > 0
				lRetorno = lcCursorSincroTask
			Endif
		
		endif 
		
		Use In Select ( lcCursorZlTask )
		Use In Select ( lcCursorOutlookTask )

		Return lRetorno

	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ActualizarNumeroDeTareaZLEnTareaOutlook( tEntryID, tNumero, tSubject ) As Void
		Local loOutlook As Object, loNameSpace As Object, loTask As Object ,;
			ltasksFolder As String, ltaskFolderItems As Object, i As  Integer,;
			lcFiltro As String

		loOutlook = Createobject("Outlook.Application")
		loNameSpace = loOutlook.GetNameSpace("MAPI")
		lOutlookSession = loOutlook.Session
		ltasksFolder = lOutlookSession.GetDefaultFolder(13)
		ltaskFolderItems = ltasksFolder.Items

		Try

			lcFiltro  = "[Subject] = '" + Alltrim( tSubject ) + "'"

			loTask = ltaskFolderItems.Find( lcFiltro )
			Do While !Isnull( loTask )

				If loTask.EntryID = tEntryID And Val(loTask.Mileage)=0
					With loTask
						loTask.Mileage = Alltrim( Str( tNumero ) )
						loTask.Save()
					Endwith
					Exit
				Else
					loTask = ltaskFolderItems.FindNext()
				Endif
			Enddo

		Catch To loError

		Finally
			Store Null To loOutlook, loNameSpace, loTask, ltaskFolderItems, ltasksFolder
		Endtry

	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ActalizarEntryIDEnZlTask( toTask, tNumero ) As Void
		Local lcSQL As String , lcCursor As String , loError As Object ,;
			lEntryID , lFechaSincro , lHoraSincro, lNotas 

		lEntryID = toTask.EntryID
		lFechaSincro = Ttod( toTask.LastModificationTime )
		lHoraSincro  = ttoc( toTask.LastModificationTime, 2 )
		lNotas       = alltrim( toTask.Body )
		lcCursor = 'C' + Sys(2015)

		TEXT to lcSQL textmerge noshow
			declare @FechaAltaOrigen datetime = '<<lFechaSincro>>' ,
					@HoraAltaOrigen Varchar(8) = '<<lHoraSincro>>' ,
					@Notas varchar(max) = '<<lNotas>>';

			Update zl.zlTask Set
				EntryID = '<<lEntryID>>' ,
			    FMODIFW = @FechaAltaOrigen,
			    HMODIFW	= @HoraAltaOrigen,
			    Obs		= @Notas 
			Where Numero = <<transform(tNumero)>>
		ENDTEXT

		goServicios.daTOS.ejecutarsql( lcSQL, lcCursor, This.DataSession )

		Use In Select( '&lcCursor' )

	Endfunc

	*-----------------------------------------------------------------------------------------
	Function ActualizarTareaZLEnOutlook( toEntidadTareas ) As Void
		Local loOutlook As Object, loNameSpace As Object, loTask As Object ,;
			ltasksFolder As String, ltaskFolderItems As Object, i As  Integer,;
			lcFiltro As String

		loOutlook = Createobject("Outlook.Application")
		loNameSpace = loOutlook.GetNameSpace("MAPI")
		lOutlookSession = loOutlook.Session
		ltasksFolder = lOutlookSession.GetDefaultFolder(13)
		ltaskFolderItems = ltasksFolder.Items

		Try

			lcFiltro  = "[Subject] = '" + Alltrim( toEntidadTareas.OU_Titulo ) + "'"

			loTask = ltaskFolderItems.Find( lcFiltro )

			Do While !Isnull( loTask )

				If loTask.EntryID = toEntidadTareas.ZL_EntryID &&And Val(loTask.Mileage)=0
					With loTask
						.Subject =  Alltrim( toEntidadTareas.ZL_Titulo )
						.Mileage = Alltrim( Str( toEntidadTareas.ZL_Numero ) )
						.StartDate = toEntidadTareas.ZL_fechaini
						.DueDate =  toEntidadTareas.ZL_fechafin
						.Status  = iif( toEntidadTareas.ZL_DateCompleted > {01/01/1900},2,0)
						.DateCompleted = iif( toEntidadTareas.ZL_DateCompleted > {01/01/1900},toEntidadTareas.ZL_DateCompleted,.DateCompleted )
						.Mileage = Transform( toEntidadTareas.ZL_Numero )
						.Companies = Transform( toEntidadTareas.ZL_Cliente )
						.Body = Alltrim( toEntidadTareas.ZL_notas  )
						.Save()
					Endwith
					Exit
				Else
					loTask = ltaskFolderItems.FindNext()
				Endif
			Enddo

		Catch To loError

		Finally
			Store Null To loOutlook, loNameSpace, loTask, ltaskFolderItems, ltasksFolder
		Endtry

	Endfunc

Enddefine
