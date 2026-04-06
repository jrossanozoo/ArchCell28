define class FacturacionLincePercepMIPYME as ZooSession of ZooSession.prg
	RutaTablas = ""
	RutaIndices = ""
	FacturacionElectronica = ""
	ApendXLS = null
	txtFechaFac = {//}
	OrigenDeDatos = ""
	txtSuc = ""
	fNumA = 0
	fNumB = 0
	talonariofacturacion = 7 && Averiguar numero de talonario
	FechaVTO = {//}
	parIVA = 0
	lhNum = 0
	txtArtTT = ""
	txtArtDes = ""
	GeneraFacElec = .t.
	Cotiz = 1
	nTipoComprobante = 0
	MontoDeuda = 0
	MontoDeudaCupones = 0
	MontoDeudaCtaCte = 0
	
	*-----------------------------------------------------------------------------------------
	function VerificarExistenciaTablasLince( tcCamino as String ) as Void
	
		If !File(tcCamino+"FAC.DBF")
			this.AgregarInformacion( "No se encuentra el "+tcCamino+"FAC.DBF" )
		Endif
		If !File(tcCamino+"FACM.DBF")
			this.AgregarInformacion( "No se encuentra el "+tcCamino+"FACM.DBF" )
		Endif
		If !File(tcCamino+"VAL.DBF")
			this.AgregarInformacion( "No se encuentra el "+tcCamino+"VAL.DBF" )
		Endif
		If !File(tcCamino+"X.DBF")
			this.AgregarInformacion( "No se encuentra el "+tcCamino+"X.DBF" )
		Endif
		If !File(tcCamino+"IND.DBF")
			this.AgregarInformacion( "No se encuentra el "+tcCamino+"IND.DBF" )
		Endif
		If !File(tcCamino+"CTB.DBF")
			this.AgregarInformacion( "No se encuentra el "+tcCamino+"CTB.DBF" )
		Endif
		If !File(tcCamino+"ART.DBF") And !Empty( this.OrigenDeDatos )
			this.AgregarInformacion( "No se encuentra el "+tcCamino+"ART.DBF" )
		Endif
		If !File(tcCamino+"CLI.DBF") And !Empty( this.OrigenDeDatos )
			this.AgregarInformacion( "No se encuentra el "+tcCamino+"CLI.DBF" )
		Endif
		If !File(tcCamino+"IMP.DBF") And !Empty( this.OrigenDeDatos )
			this.AgregarInformacion( "No se encuentra el "+tcCamino+"IMP.DBF" )
		Endif
		If !File(tcCamino+"PERCVTA.DBF") And !Empty( this.OrigenDeDatos )
			this.AgregarInformacion( "No se encuentra el "+tcCamino+"PERCVTA.DBF" )
		Endif
		If !File(tcCamino+"ST.DBF") And !Empty( this.OrigenDeDatos )
			this.AgregarInformacion( "No se encuentra el "+tcCamino+"ST.DBF" )
		endif

*!*			If this.GeneraFacElec And !File(tcCamino+"st.DBF") And !Empty(this.OrigenDeDatos)
*!*				this.AgregarInformacion( "No se encuentra el "+tcCamino+"st.DBF" )
*!*			Endif
	
	endfunc

	*-----------------------------------------------------------------------------------------
	function AbrirYBloquearTablasLince( tcCamino ) as VOID 
		local lcCamino as String, lnPosicion as Integer 
		
		lcCamino  = iif( empty( tcCamino ), "", tcCamino )
		use in select("INFFILTR")
		create Cursor INFFILTR (;
			INFOID N(10) ,;
			FECHA D ,;
		    SCOD C(5) ,;  
		    RZNOM C(100),;
		    CLCOD C(5) ,;
		    CLNOM C(100),;
		    FACSINO N(1),;
		    TARJETA C(15),;
		    SERIE C(6) ,;
		 	SUCURSAL C(60),;
		    USONUM N( 2 ),;
		    USONOM C(20 ),;
		    CODCANT N(10, 2),;
		    ORDEN C( 2 ),; 
		   	AZ_COD C( 5 ),;
		    AZ_CODLIN C( 13 ),;
		    AZ_DES C(100),;
		    RZLPRECIO C( 1 ),;
		    PRECIO N( 8, 2) ,;
		    AZ_PRECIO1 N( 8, 2),;
		    AZ_PRECIO2 N( 8, 2),;
		    AZ_PRECIO3 N( 8, 2),;
		    AZ_PRECIO4 N( 8, 2),;
		    AZ_PRECIO5 N( 8, 2),;
		    OBS C( 60 ) ,;
		    NUMFAC C( 30 ),;
		    DIRDIR C( 80 ) ,;
		    DIRLOC  C( 80 ),;
		    DIRCP C( 8 ) ,;
		    DIRPROVINC C( 60 ) ,;
		    DIRTRATAMI C( 20 ) ,;
		    DIRPERSONA C( 80 ) ,;
		    MESES C( 60 ) ,;
		    AZ_ANTES1 C( 200 ) ,;
		    AZ_ANTES2 C( 200 ) ,;
		    AZ_DESPUES1 C( 200 ),;
		    AZ_DESPUES2 C( 200 ) ,;
		 	previo C (1) ,;
			Numreg N(6,0),;
			grupo N(3,0) ,;
			fcoTxt C(20) ,;
			Indent N(1,0) ,;
			fCCte N(16,2) ,;
			AZ_climpd C(5) ,;
			Cod_Percep C(2) ,;
			Por_Percep N( 6, 2) ,;
			Percep_Min N(16,2) )

		If !Empty(this.OrigenDeDatos)
			use in select( "InfAux" )
			Copy To InfAux For .F.
			Select 0
			Use InfAux Exclu
		Endif

		lcCodigo = This.txtArtTT
		lcDescripcion=This.txtArtDes
		ldFecha= This.txtFechaFac
		ltHora= goServicios.Librerias.Obtenerhora()

		Select 0
		Use lcCamino+"X.DBF"
		If !Flock()
			Unlock All
			this.AgregarInformacion("No puedo bloquear archivos, Facturacion cancelada")
			Return
		Endif

		If this.GeneraFacElec

			if !used( "stSuc" )
				Use lcCamino+"St.DBF" Alias stSuc In 0 Shared
			endif	

			Select stSuc
			SET INDEX TO this.RutaIndices+"st1.IDX",this.RutaIndices+"st2.IDX"

			Set Order To

			If !Flock()
				Unlock All
				this.AgregarInformacion("No puedo bloquear archivos, Facturacion cancelada")
				Return
			Endif

			Set Order To 1
 
			if this.nTipoComprobante = 3
				lnPosicion = 1
			else	
				lnPosicion = 0
			endif 

			
			Seek 4255 + ( ( This.talonariofacturacion ) * 6 ) + lnPosicion 
			This.fNumA = 4000000 + stSuc.stn1 &&Factura A

			
			Seek 4255 + ( ( This.talonariofacturacion ) * 6 ) + 3 + lnPosicion 
			This.fNumB = 3000000 + stSuc.stn1 &&Factura B

			seek 3686
			This.FechaVTO = goServicios.Librerias.ObtenerFecha() + stSuc.Stn1

		Else
			This.fNumA=X.UltFacA
			This.fNumB=X.UltFacB
		Endif
 
		lprifNumA=This.fNumA+1
		lprifNumB=This.fNumB+1
		lnIVA=X.IvaIns
		This.parIVA = lnIVA
		This.lhNum=X.hNum

		
		Select 0
		Use lcCamino+"VAL.DBF"
		SET INDEX TO this.RutaIndices+"VAL1.IDX",this.RutaIndices+"VAL2.IDX",this.RutaIndices+"VAL3.IDX",this.RutaIndices+"VAL4.IDX",this.RutaIndices+"VAL5.IDX",this.RutaIndices+"VAL6.IDX",this.RutaIndices+"VAL7.IDX"

		Set Order To
		If !Flock()
			Unlock All
			this.AgregarInformacion("No puedo bloquear archivos, Facturacion cancelada")
			Return
		Endif


		Select 0
		Use lcCamino+"FAC.DBF"
		SET INDEX TO this.RutaIndices+"FAC1.IDX",this.RutaIndices+"FAC2.IDX",this.RutaIndices+"FAC3.IDX",this.RutaIndices+"FAC4.IDX",this.RutaIndices+"FAC5.IDX",this.RutaIndices+"FAC6.IDX"

		Set Order To
		If !Flock()
			Unlock All
			this.AgregarInformacion("No puedo bloquear archivos, Facturacion cancelada")
			Return
		Endif

		Select 0
		Use lcCamino+"FACm.DBF"
		SET INDEX TO this.RutaIndices+"FACM1.IDX"

		Set Order To
		If !Flock()
			Unlock All
			this.AgregarInformacion("No puedo bloquear archivos, Facturacion cancelada")
			Return
		Endif

		Select 0
		Use lcCamino+"IMP.DBF"
		SET INDEX TO this.RutaIndices+"IMP1.IDX"

		Set Order To
		If !Flock()
			Unlock All
			this.AgregarInformacion("No puedo bloquear archivos, Facturacion cancelada")
			Return
		Endif

		If !Empty(this.OrigenDeDatos)

			Select 0
			Use lcCamino+"ART.DBF"
			SET INDEX TO this.RutaIndices+"ART1.IDX"

			Set Order To
			If !Flock()
				Unlock All
				this.AgregarInformacion("No puedo bloquear archivos, Facturacion cancelada")
				Return
			Endif

			Use lcCamino+"CLI.DBF" in select( "Cli" )
			select Cli
			SET INDEX TO this.RutaIndices+"CLI1.IDX"
			Set Order To				
			If !Flock()
				Unlock All
				this.AgregarInformacion("No puedo bloquear archivos, Facturacion cancelada")
				Return
			Endif

		Endif

		Use lcCamino+"IND.DBF" in select( "Ind" )
		select Ind
		If !Flock()
			Unlock All
			this.AgregarInformacion("No puedo bloquear archivos, Facturacion cancelada")
			Return
		Endif

		Select IND
		Locate For IND.INDCOD="U$S       " And IND.INDFCH=ldFecha
		If Found()
			this.Cotiz=IND.indval
		Else
			Locate For IND.INDCOD="U$S       " And IND.INDFCH=ldFecha-(Day(ldFecha)-1)
			If Found()
				this.Cotiz=IND.indval
			Else
				Locate For IND.INDCOD="U$S       " And IND.INDFCH=ldFecha-(Day(ldFecha)-2)
				If Found()
					this.Cotiz=IND.indval
				Else
					Locate For IND.INDCOD="U$S       " And IND.INDFCH=ldFecha-(Day(ldFecha)-3)
					If Found()
						this.Cotiz=IND.indval
					Endif
				Endif
			Endif
		Endif


		Select 0
		Use lcCamino+"CTB.DBF"
		SET INDEX TO this.RutaIndices+"CTB1.IDX",this.RutaIndices+"CTB2.IDX",this.RutaIndices+"CTB3.IDX",this.RutaIndices+"CTB4.IDX",this.RutaIndices+"CTB5.IDX"

		Set Order To
		If !Flock()
			Unlock All
			this.AgregarInformacion("No puedo bloquear archivos, Facturacion cancelada")
			Return
		Endif


		Select 0
		Use lcCamino+"CORRE.DBF"
		SET INDEX TO this.RutaIndices+"CORRE1.IDX"

		Set Order To
		If !Flock()
			Unlock All
			this.AgregarInformacion("No puedo bloquear archivos, Facturacion cancelada")
			Return
		Endif

		Select 0
		Use lcCamino+"PERCVTA.DBF"

		If !Flock()
			Unlock All
			this.AgregarInformacion("No puedo bloquear archivos, Facturacion cancelada")
			Return
		Endif

*!*			if !used( "STPercep" )
*!*				Use lcCamino+"ST.DBF" shared alias STPercep  in 0
*!*			endif
*!*			select  STPercep
*!*			SET INDEX TO this.RutaIndices+"st1.IDX",this.RutaIndices+"st2.IDX"

*!*			If !Flock()
*!*				Unlock All
*!*				this.AgregarInformacion("No puedo bloquear archivos, Facturacion cancelada")
*!*				Return
*!*			Endif

	endfunc 


*** NUEVO FUNC 9448 ********************************************************************************************************************************************
	*-----------------------------------------------------------------------------------------
	function GenerarFacturasLinceNuevo( lnTipo ) as Collection
		local lColDetalleDeComprobantes as Collection
		lColDetalleDeComprobantes = this.GenerarComprobantesLinceNuevo( lnTipo )
		return lColDetalleDeComprobantes
	endfunc

	*-----------------------------------------------------------------------------------------
	protected function GenerarComprobantesLinceNuevo( tnTipo as Integer ) as Collection
		local lcCodigo,lcDescripcion,ldFecha,ltHora,lnCotiz,lcCamino,lFiltro, lNumero,lprifNumA,lprifNumB,lnIVA, lcSeguridad,lcPerson,lcArt,lnCant, lnPrecio, ;
			lnGrupo, lcSerie,lnIndent,lcDescrip, lcCondPago, lcSugiereFE, lcLecturaIni, lbClave, lnFinal, lnTipo, lnSignoMov, loTotDBF, lColDetalleDeComprobantes, ;
			loInfoProblemasEnFac, lYaBusqueFperson, lcAZ_climpd, lnPosicion, lnDiferencia, lcFnped, lnFcae

		lYaBusqueFperson = .f.
		lColDetalleDeComprobantes = CreateObject( "Collection" )
		lcPerson = ""
		lcArt = ""
		lnCant = 0
		lnPrecio = 0.00
		lcCondPago = ""
		lnFinal = 0
		this.RutaTablas = alltrim( upper( addbs( alltrim( .txtSuc ) ) + iif( "\DBF" $ alltrim( upper( .txtSuc ) ), "", addbs( "DBF" ) ) ) )
		this.RutaIndices = alltrim( upper( addbs( left( alltrim( .RutaTablas ), len( .RutaTablas ) - 4 ) + "IDX" ) ) )
		lcCamino = this.RutaTablas
		this.Cotiz = this.ObtenerCotizacion()
		lcCodigo = this.txtArtTT
		lnCotiz = this.Cotiz
		ldFecha= this.txtFechaFac
		ltHora = goServicios.Librerias.ObtenerHora()
		lnTipo = iif( empty( tnTipo ), 1, tnTipo )
		this.nTipoComprobante = lnTipo
		lnSignoMov = iif( lnTipo = 3, -1, 1 )
		lcSeguridad = set( "Safety" )

		try
			this.VerificarExistenciaTablasLince( lcCamino )
			this.AbrirYBloquearTablasLince( lcCamino )
			this.CrearYLLenarFcAuxDeUnXLS( this.OrigenDeDatos )
			if lnTipo = 1 && Si es tipo 1 elimino las NC para que se procesen solo las FC
				delete for substr( alltrim( Fcaux.Fnped ), 1, 1) = "3" all
			else
				if lnTipo = 3 && Si es tipo 3 elimino las FC para que se procesen solo las NC
					delete for len( alltrim( Fcaux.Fnped ) ) = 0
					delete for substr( alltrim( Fcaux.Fnped ), 1, 1) <> "3" all
				endif
			endif

			lnIVA = this.parIVA

			if !empty( this.OrigenDeDatos )
				select Art
				set order to Art1
				select FcAux

				scan for !deleted()
					* Con la siguiente línea sólo permite agregar artículos a clientes que ya están en la selección para facturar
					select * from INFFILTR where alltrim( INFFILTR.scod ) == alltrim( FcAux.fperson ) into cursor TabAux
					lYaBusqueFperson = ( lcPerson = alltrim( FcAux.fperson ) )
					lcPerson = alltrim( FcAux.fperson )
					lcArt = padr( rtrim( FcAux.fart ), 13, " " )
					lnCant = FcAux.fcant * lnSignoMov
					lnPrecio = FcAux.fPrecio * lnSignoMov
					lnGrupo = FcAux.grupo
					lcSerie = FcAux.serie
					lnIndent = FcAux.Indent
					lcDescrip = FcAux.Descrip
					lcFnped = iif( alltrim( FcAux.Fnped ) = "0", "", strtran( FcAux.Fnped, ".00", "" ) )
					lnFcae = FcAux.Fcae

					go bottom
					scatter to RegAux
					lcArtLince = lcArt

					* Valido existencia del cliente y obtengo la lista de precios
					lnSelect = select()
					select Cli
					set order to Cli1
					seek lcPerson
					if found()
						lcAZ_climpd = Cli.climpd

						if Cli.ClList != 0
							lcLista = Cli.ClList
						else
							go top in X
							lcLista = X.XLISTA
						endif

						if empty( RegAux(2) )
							RegAux(2) = ldFecha
						endif
						RegAux(3) = alltrim( lcPerson )
						RegAux(4) = Cli.Clnom
						RegAux(5) = Cli.Clcod

						if upper( alltrim( CLI.Clperibru ) ) = "X"
							if alltrim( CLI.Clretibrc ) = ""
								select STPercep
								seek 3082
								if found()
									RegAux(45) = alltrim( STPercep.Stdes )
								endif
								select PERCVTA
								locate for upper( alltrim( PERCVTA.Per_cod ) ) = alltrim( RegAux(45) )
								if found()
									RegAux(46) = PERCVTA.Per_porc
									RegAux(47) = PERCVTA.Per_mimp
								endif
							else
								select PERCVTA
								locate for upper( alltrim( PERCVTA.Per_cod ) ) = upper( alltrim( CLI.Clretibrc ) )
								if found()
									RegAux(45) = upper( alltrim( CLI.Clretibrc ) )
									RegAux(46) = PERCVTA.Per_porc
									RegAux(47) = PERCVTA.Per_mimp
								endif
							endif
							select Cli
						endif
					else
						lcAZ_climpd = ""
						go top in X
						lcLista = X.XLISTA
						if lYaBusqueFperson
						else
							this.AgregarInformacion( "No se puede validar el Cliente " + alltrim( lcPerson ) )
						endif
					endif
					set order to
					select( lnSelect )
					* Fin de valido existencia del cliente y obtengo la lista de precios

					select Art
					seek lcArtLince
					if found() && Valida el dato del XLS, contra la tabla ART
						lnFinal = lnFinal + 1
						RegAux(1) = lnFinal
						RegAux(13) = lnCant
						RegAux(14) = ""
						RegAux(15) = ""
						RegAux(16) = lcArtLince
						RegAux(17) = iif( empty( lcDescrip ), Art.ArtDes, lcDescrip )

						select Art
						RegAux(18) = lcLista && Ver cuál es la lista de precios activa para el cliente
						if !empty( lnPrecio )
							RegAux(19) = lnPrecio
						else
							do case
								case lcLista = 1
									RegAux(19) = Art.Apr2
								case lcLista = 2
									RegAux(19) = Art.Apr3
								case lcLista = 3
									RegAux(19) = Art.Apr4
								case lcLista = 4
									RegAux(19) = Art.Apr5
								case lcLista = 5
									RegAux(19) = Art.Apr6
							endcase
						endif
						RegAux(20) = Art.Apr2
						RegAux(21) = Art.Apr3
						RegAux(22) = Art.Apr4
						RegAux(23) = Art.Apr5
						RegAux(24) = Art.Apr6
						RegAux(33) = ""
						RegAux(34) = ""
						RegAux(35) = ""
						RegAux(36) = ""
						RegAux(48) = lcFnped
						RegAux(49) = lnFcae

						select InfAux
						append blank
						gather from RegAux
						replace grupo with lnGrupo
						replace fcoTxt with lcSerie
						replace Indent with lnIndent
						replace AZ_climpd with lcAZ_climpd
					else && El artículo puede no estar en el Lince
						this.AgregarInformacion( "No se puede validar el artículo: " + alltrim( lcArtLince ) )
					endif
				endscan

				select Art
				set order to
				use in select( "FcAux" )
				delete file "fcaux.dbf"
			endif

			use in select( "STPercep" )
			use in select( "TabAux" )

			select INFFILTR
			if !empty( this.OrigenDeDatos )
				append from InfAux
				use in select( "InfAux" )
				select INFFILTR
				replace Numreg with recno() for alltrim( previo ) != "S"
			endif
			delete file "Infaux.dbf"

			select dtoc( Fecha, 1 ) + SIS.Clcod + scod + str( grupo ) as CLAVE, ;
				100000000 * lnTipo as fNum, ;
				Cli.Cliva as RzSitFisca, ;
				"ZOO" as fVen, ;
				ldFecha as fFch, ;
				1 as fTurno, ;
				ltHora as fHora, ;
				Cod_Percep as Fcod_pibr, ;
				Por_Percep as Fpor_pibr, ;
				(round(iif(inlist(Cli.Cliva,1,2,4,6,7),sum(round(Precio*codcant,2))*(iif(sum(round(Precio*codcant,2))>Percep_Min,Por_Percep/100,0)),sum(round(Precio*codcant,2))*(1+(lnIVA*.01))*(iif(sum(round(Precio*codcant,2))>Percep_Min,Por_Percep/100,0))),2)) as Fimp_pibr, ;
				(round(iif(inlist(Cli.Cliva,1,2,4,6,7),sum(round(Precio*codcant,2))*(1+(lnIVA*.01)) + round(sum(round(Precio*codcant,2))*(iif(sum(round(Precio*codcant,2))>Percep_Min,Por_Percep/100,0)),2),sum(round(Precio*codcant,2))*(1+(lnIVA*.01)) + round(sum(round(Precio*codcant,2))*(1+(lnIVA*.01))*(iif(sum(round(Precio*codcant,2))>Percep_Min,Por_Percep/100,0)),2)),2)) * lnSignoMov as Ftotal, ;
				lnCotiz as fCotiz, ;
				(round ( iif( inlist( Cli.Cliva, 1, 2, 6 ), sum( round( Precio * codcant, 2 ) ), sum( round( Precio * codcant, 2 ) ) * ( 1 + ( lnIVA * .01 ) ) ), 2 ) ) * lnSignoMov as FSubTot, ;
				(round ( sum( round( Precio * codcant, 2 ) ) * ( 1 + ( lnIVA * .01 ) ), 2 ) - sum( round( Precio * codcant, 2 ) ) ) * lnSignoMov as fIva1, ;
				lnIVA as fxIva1, ;
				ldFecha as Fd2, ;
				"M" as fMayomin, ;
				this.xxfN11( Cli.Cllist ) as fN11, ;
				this.xxfLista( Cli.Cllist ) as flista, ;
				this.CambiAcento( nvl( upper( Cli.Clnom ), 'Nada' ) ) as fCliente, ;
				1 as fTipo, ;
				lnIVA as fxIvaArt, ;
				100000000 * lnTipo as fNumE, ;
				ldFecha as fVto, ;
				alltrim( space( 5 ) ) + nvl( this.CambiAcento( Cli.cc051 ), '60' ) as fCorre, ;
				alltrim( space( 40 ) ) + nvl( upper( this.CambiAcento( cor.conom ) ), 'Nada' ) as fCorreTxt, ;
				1 as fAgrupy, ;
				alltrim( space( 60 ) ) + this.CambiAcento( nvl( Cli.Clentr, "" ) ) as fEntr, ;
				100000000 * lnTipo as jjNum, ;
				this.Jjt( Cli.clvcod ) as Jjt, ;
				alltrim( space( 5 ) ) + this.CambiAcento( iif( empty( nvl( Cli.clvcod, "" ) ), "C", nvl( Cli.clvcod, "" ) ) ) as jjCo, ;
				space( 5 ) as jjCo_Cup, ;
				space( 5 ) as jjCo_Cta, ;
				ldFecha as jjFe, ;
				alltrim( space( 40 ) ) + this.CambiAcento( SIS.scod ) + " " + this.CambiAcento( lcCodigo ) as jjDe, ;
				0000000000 as jjNu, ;
				(round ( iif( inlist( Cli.Cliva, 1, 2, 4, 6, 7 ), round( sum( round( Precio * codcant, 2 ) ) * ( 1 + ( lnIVA * .01 ) ), 2 ) + sum( round( Precio * codcant, 2 ) ) * ( iif( sum( round( Precio * codcant, 2 ) ) > Percep_Min, Por_Percep / 100, 0 ) ), round( sum( round( Precio * codcant, 2 ) ) * ( 1 + ( lnIVA * .01 ) ), 2 ) + sum( round( Precio * codcant, 2 ) ) * ( 1 + ( lnIVA * .01 ) ) * ( iif( sum( round( Precio * codcant, 2 ) ) > Percep_Min, Por_Percep / 100, 0 ) ) ), 2 ) ) * lnSignoMov as jjM, ;
				this.CambiAcento( SIS.scod ) as jjCli, ;
				ldFecha as jjFecha, ;
				"ZOO" as jjVen, ;
				( round( iif( inlist( Cli.Cliva, 1, 2, 4, 6, 7 ), ( round( sum( round( Precio * codcant, 2 ) ) * ( 1 + ( lnIVA * .01 ) ), 2 ) + sum( round( Precio * codcant, 2 ) ) * ( iif( sum( round( Precio * codcant, 2 ) ) > Percep_Min,Por_Percep / 100, 0 ) ) ), ( round( sum( round( Precio * codcant, 2 ) ) * ( 1 + ( lnIVA * .01 ) ), 2 ) + round( sum( round( Precio * codcant, 2 ) ) * ( 1 + ( lnIVA * .01 ) ) * ( iif( sum( round( Precio * codcant, 2 ) ) > Percep_Min, Por_Percep / 100, 0 ) ), 2 ) ) ), 2 ) ) * lnSignoMov as jjTotFac, ;
				000000000.00 as TotFac_cup, ;
				000000000.00 as TotFac_cta, ;
				alltrim( space( 5 ) ) + nvl( this.CambiAcento( Cli.cc051 ), '60' ) as jjCorre, ;
				1 as jjTurno, ;
				lnCotiz as jjCotiz, ;
				SIS.Fnped as Fnped, ;
				SIS.Fcae as Fcae ;
			from INFFILTR as SIS ;
				left join Cli on Cli.Clcod = SIS.scod and Cli.cltpo = 1 ;
				left join corre as cor on cor.cocod = Cli.cc051 ;
			where !isnull( Az_codlin ) and !empty( Az_codlin ) ;
			order by Cli.cliva desce, Sis.AZ_climpd, scod, grupo, sis.numreg ;
			group by Sis.AZ_climpd, scod, grupo ;
			into dbf TOT noconsole

			lbClave = .f.
			select TOT
			go top
			scan
				if isnull( TOT.CLAVE )
					lbClave = .t.
				endif
				if alltrim( upper( fCliente ) ) != 'NADA' and alltrim( upper( fCorreTxt ) ) = 'NADA'
					this.AgregarInformacion( "No se puede validar el Corredor " + alltrim( Tot.fCorre ) + " del cliente: " + alltrim( upper( fCliente ) ) )
				endif
			endscan

			select TOT
			go top
			local llExiste, lnNumfac, lcNrodeFacQueExisten
			llOk = .t.
			lnNumfac = 0
			lcNrodeFacQueExisten = ""

			set order to 1 in FAC
			scan
				lnNumfac = fNum + this.xxFnum()
				if this.GeneraFacElec
					lnNumfac = lnNumfac + ( this.talonariofacturacion * 10000000 )
				endif
				if !this.VerificarNroFactura( lnNumfac )
					replace fNum with lnNumfac, ;
						fNumE with lnNumfac, ;
						jjNum with lnNumfac, ;
						jjNu with jjNu + this.xxJjNu() in TOT
				else
					llOk = .f.
					exit
				endif
			endscan
			set order to 0 in FAC

			if !llOk
				local LcMensaje
				LcMensaje = "No se han podido generar las facturas, ya existe el comprobante " + alltrim( str( lnNumfac - 100000000 ) )  + ". Operación cancelada."
				this.AgregarInformacion( LcMensaje )
			endif

			loInfoProblemasEnFac = this.ObtenerInformacion()
			if loInfoProblemasEnFac.Count = 0
				go top
				select INFFILTR
				copy to previa for alltrim( previo ) = "S"
				copy to noprevi for alltrim( previo ) != "S"
				select 0
				use previa exclu
				select 0
				use noprevi exclu

				select TOT.fNum, ;
					az_precio4 as orden, ;
					TOT.fVen, ;
					TOT.fFch, ;
					this.CambiAcento( Az_codlin ) as fart, ;
					codcant * lnSignoMov as fcant, ;
					iif( inlist( TOT.RzSitFisca, 1, 2, 6 ), Precio, round( Precio * 1.21, 2 ) ) * lnSignoMov as fPrun, ;
					iif( inlist( TOT.RzSitFisca, 1, 2, 6 ), round( Precio * codcant, 2 ), round( ( Precio * ( 1 + ( lnIVA * .01 ) ) ) * codcant, 2 ) ) * lnSignoMov as fNeto, ;
					TOT.fTurno, ;
					Tot.fn11, ;
					Tot.fLista, ;
					TOT.fHora, ;
					iif( Indent > 0, space( Indent ) + alltrim( az_des ), this.CambiAcento( az_des ) ) as fTxt, ;
					TOT.Ftotal as fTarjeta, ;
					TOT.fCotiz, ;
					Tot.fCliente, ;
					this.CambiAcento( SIS.scod ) as fperson, ;
					TOT.FSubTot as fSubTot , ;
					TOT.Ftotal as fTotal , ;
					TOT.fIva1, ;
					TOT.fxIva1, ;
					TOT.Fd2, ;
					TOT.fMayomin, ;
					TOT.fTipo, ;
					TOT.fxIvaArt, ;
					( TOT.Ftotal - TOT.Fimp_pibr - TOT.fIva1 ) as fGravIva1, ;
					SIS.previo as previo, ;
					SIS.Numreg as Numreg, ;
					SIS.grupo, ;
					SIS.fcoTxt, ;
					SIS.Indent, ;
					SIS.fCCte ;
					from noprevi as SIS ;
						left join TOT on TOT.CLAVE = dtoc( SIS.Fecha, 1 ) + SIS.Clcod + SIS.scod + str( grupo ) ;
					where !isnull( Az_codlin ) and !empty( Az_codlin ) ;
					order by Tot.RzSitFisca desce, Sis.AZ_climpd, scod, grupo, sis.numreg ;
					into dbf CASIFAC noconsole

				* Ingresa un registro nuevo con el artículo: "  TT  xxx"
				select CASIFAC
				go top
				use in select( "noprevi" )
				delete file "noprevi.dbf"

				* Comienza el control sobre la cantidad de ítems
				if !empty( this.OrigenDeDatos ) and this.nTipoComprobante = 1
					this.ControlaLineas( this.GeneraFacElec )
				endif

				* Reordena los registros
				select CASIFAC.*, round( CASIFAC.Ftotal / CASIFAC.fCotiz, 2 ) as fAcumula, space(5) as ft051, iif( this.GeneraFacElec, .t., .f. ) as fCompFis ;
				from CASIFAC ;
				order by fNum,Numreg ;
				into table Final

				use in select( "previa" )
				delete file "previa.dbf"
				if this.nTipoComprobante = 3
					this.DiscriminarValores_CtaCte_Y_Cupones_EnDeudores()
				endif

				this.GeneraCuentaCorriente()

				use in select( "Nuevos" )
				delete file "Nuevos.dbf"
				set safety &lcSeguridad

				select Final
				lnLinea = 1
				lcCli = ""
				lcSeguridad = set( "Safety" )

				set safety off
				scan
					if lcCli != Final.fperson
						lcCli = Final.fperson
						lnLinea = 1
					else
						lnLinea = lnLinea + 1
					endif
					replace ft051 with alltrim( str( lnLinea ) )
				endscan

				set safety &lcSeguridad
				select FAC
				append from Final
				select FACM
				append from TOT
				select tot
				go top
		 		scatter name loTotDBF

				select val
				append from Tot

				select X
				replace X.hNum with this.lhNum

				if this.GeneraFacElec
					use lcCamino + "St.DBF" alias stSuc in 0 shared
					select stSuc
					set index to this.RutaIndices + "st1.IDX", this.RutaIndices + "st2.IDX"
					set order to 1

					if this.nTipoComprobante = 3
						lnPosicion = 1
					else
						lnPosicion = 0
					endif

					seek 4255 + ( ( this.talonariofacturacion ) * 6 ) + lnPosicion
					replace stn1 with this.fNumA - 4000000
					seek 4255 + ( ( this.talonariofacturacion ) * 6 ) + 3 + lnPosicion
					replace stn1 with this.fNumB - 3000000

					use in select( "stSuc" )
					select X
				else
					replace X.UltFacA with this.fNumA
					replace X.UltFacB with this.fNumB
				endif

				unlock all
				lColDetalleDeComprobantes = this.ArmarColeccionDetalleDeComprobantesGenerados()
			endif
		catch to loError
			this.AgregarInformacion( "Ha ocurrido un error en el proceso de facturación, deberá volver a realizar el proceso." + chr( 13 ) + loError.message )
		finally
			this.LoguearEnUsuDeZOO_SA( lColDetalleDeComprobantes, lcCamino )
			this.CerrarTablas()
			this.LimpiarArchivos()
		endtry

		return ( lColDetalleDeComprobantes )
	endfunc
*** NUEVO FUNC 9448 ********************************************************************************************************************************************

	
	*-----------------------------------------------------------------------------------------
	function GenerarFacturasLince() as Void
		local lColDetalleDeComprobantes as Collection 
		lColDetalleDeComprobantes = this.GenerarComprobantesLince( 1 )
		return lColDetalleDeComprobantes
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarNotasDeCreditoLince() as Collection
		local lColDetalleDeComprobantes as Collection 
		lColDetalleDeComprobantes = this.GenerarComprobantesLince( 3 )
		return lColDetalleDeComprobantes
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GenerarComprobantesLince( tnTipo as Integer ) as Collection

		Local lcCodigo,lcDescripcion,ldFecha,ltHora,lnCotiz,lcCamino,lFiltro,;
			lNumero,lprifNumA,lprifNumB,lnIVA, lcSeguridad,lcPerson,lcArt,lnCant, lnPrecio, ;
			lnGrupo, lcSerie,lnIndent,lcDescrip, lcCondPago, lcSugiereFE, lcLecturaIni, lbClave, lnFinal,;
			lnTipo, lnSignoMov, loTotDBF, lColDetalleDeComprobantes, loInfoProblemasEnFac, lYaBusqueFperson,;
			lcAZ_climpd, lnPosicion, lnDiferencia 

		lYaBusqueFperson = .f.
		lColDetalleDeComprobantes = createobject( "Collection" )
		lcPerson = ""
		lcArt = ""
		lnCant = 0
		lnPrecio = 0.00
		lcCondPago = ""
		lnFinal = 0
		this.RutaTablas = alltrim(upper(addbs( alltrim( .txtSuc ) ) + iif( "\DBF" $ alltrim( upper( .txtSuc ) ), "" , addbs( "DBF" ) )))
		this.RutaIndices = alltrim(upper(addbs( left( alltrim( .RutaTablas ),len( .RutaTablas )-4) + "IDX" )))
		lcCamino = This.RutaTablas
		this.Cotiz = this.ObtenerCotizacion()
		lcCodigo = This.txtArtTT
		lnCotiz = this.Cotiz
		ldFecha= This.txtFechaFac
		ltHora=goServicios.Librerias.Obtenerhora()
		lnTipo = iif( empty( tnTipo ), 1 , tnTipo )
		this.nTipoComprobante = lnTipo 
		lnSignoMov = iif( lnTipo = 3, -1, 1 )
		
		lcSeguridad = Set ("safety")

		try 
			this.VerificarExistenciaTablasLince( lcCamino )
			this.AbrirYBloquearTablasLince( lcCamino )
			this.ObtenerDatosParaProcesar()
 
			lnIVA = This.parIVA 

			If !Empty(this.OrigenDeDatos)

				Select Art
				Set Order To Art1
				Select FcAux

				Scan For ! Deleted()
			
					* Con la Sig. línea sólo permite agregar artículos a clientes que ya están en la selección para Facturar
					Select * From INFFILTR Where Alltrim(INFFILTR.scod) == Alltrim(FcAux.fperson) Into Cursor TabAux
					lYaBusqueFperson = (lcPerson = Alltrim(FcAux.fperson))
					lcPerson = Alltrim(FcAux.fperson)
					lcArt = Padr(Rtrim(FcAux.fart),13," ")
					lnCant = FcAux.fcant
					lnPrecio = FcAux.fPrecio
					lnGrupo = FcAux.grupo
					lcSerie = iif( THIS.nTipoComprobante = 3, FcAux.fcotxt , FcAux.serie )
					lnIndent = FcAux.Indent
					lcDescrip = FcAux.Descrip


					Go Bottom
					Scatter To RegAux
	 
					lcArtLince = lcArt

					**// Valido existencia del Cliente y obtengo la lista de precios
					lnSelect = select()
					Select Cli
					Set Order To Cli1
					Seek lcPerson
					If Found() 
						lcAZ_climpd = Cli.climpd

						if Cli.ClList !=0
							lcLista = Cli.ClList 
						else
							go top in X
							lcLista = X.XLISTA
						endif 
					
						If Empty(RegAux(2))
							RegAux(2) = ldFecha
						Endif
						RegAux(3) = Alltrim(lcPerson)
						RegAux(4) = Cli.Clnom
						RegAux(5) = Cli.Clcod

						if upper( alltrim( CLI.Clperibru ) ) = "X"
							if alltrim( CLI.Clretibrc ) = ""
								select Stdes  from stSuc where stn = 3082 into cursor STPercep								
								*select STPercep
								*seek 3082
								*locate for stn = 3082
								if _Tally = 1 &&found()
									RegAux(45) = alltrim( STPercep.Stdes )
								endif
								select PERCVTA
								locate for upper( alltrim( PERCVTA.Per_cod ) ) = alltrim( RegAux(45) )
								if found()
									RegAux(46) = PERCVTA.Per_porc
									RegAux(47) = PERCVTA.Per_mimp
								endif
							else
								select PERCVTA
								locate for upper( alltrim( PERCVTA.Per_cod ) ) = upper( alltrim( CLI.Clretibrc ) )
								if found()
									RegAux(45) = upper( alltrim( CLI.Clretibrc ) )
									RegAux(46) = PERCVTA.Per_porc
									RegAux(47) = PERCVTA.Per_mimp
								endif
							endif
							select Cli
						endif
					else
						lcAZ_climpd = ''
						go top in X
						lcLista = X.XLISTA
						if lYaBusqueFperson
						else
							this.AgregarInformacion( "No se puede validar el Cliente " + alltrim( lcPerson ) )
						endif 	
					Endif
					Set Order To
					select( lnSelect )
					**// Fin de Valido existencia del Cliente y obtengo la lista de precios


					Select Art
					Seek lcArtLince
					If Found()   && Valida el dato del xls, contra la tabla ART
						lnFinal = lnFinal + 1
						RegAux(1) = lnFinal
						RegAux(13) = lnCant
						RegAux(14) = ""   
						RegAux(15) = ""	 
						RegAux(16) = lcArtLince
						RegAux(17) = Iif(Empty(lcDescrip),Art.ArtDes,lcDescrip)
						

						Select Art
						RegAux(18) = lcLista  && Ver cuál es la Lista de Precios Activa para el cliente, ant 1
						If !Empty(lnPrecio)
							RegAux(19) = lnPrecio
						Else
							Do Case
							Case lcLista = 1
								RegAux(19) = Art.Apr2
							Case lcLista = 2
								RegAux(19) = Art.Apr3
							Case lcLista = 3
								RegAux(19) = Art.Apr4
							Case lcLista = 4
								RegAux(19) = Art.Apr5
							Case lcLista = 5
								RegAux(19) = Art.Apr6
							Endcase
						Endif
						RegAux(20) = Art.Apr2
						RegAux(21) = Art.Apr3
						RegAux(22) = Art.Apr4
						RegAux(23) = Art.Apr5
						RegAux(24) = Art.Apr6
						RegAux(33) = ""
						RegAux(34) = ""
						RegAux(35) = ""
						RegAux(36) = ""
						Select InfAux
						Append Blank
						Gather From RegAux
						Replace ;
							grupo With lnGrupo,;
							fcoTxt With lcSerie,;
							Indent With lnIndent,;
							AZ_climpd with lcAZ_climpd 

					Else  && El artículo puede no estar en el Lince
						This.AgregarInformacion( "No se puede validar el artículo: " + Alltrim(lcArtLince) )
					Endif

				Endscan
				Select Art
				Set Order To
				Use In select( "FcAux" )
				Delete File "fcaux.dbf"
			Endif

			Use in select( "STPercep")
			Use In select( "TabAux" )

			Select INFFILTR

			If !Empty(this.OrigenDeDatos)
				Append From InfAux
				Use In select( "InfAux" )
				Select INFFILTR
				Replace Numreg With Recno() For Alltrim(previo) !="S"
			Endif

			Delete File "Infaux.dbf"

			Select Dtoc(Fecha,1)+SIS.Clcod+scod+Str( grupo ) As CLAVE,; 
				100000000 * lnTipo As fNum,;
				Cli.Cliva as RzSitFisca,;
				"ZOO" As fVen,;
				ldFecha As fFch,;
				1 As fTurno,;
				ltHora As fHora,;
				Cod_Percep as Fcod_pibr,;
				Por_Percep as Fpor_pibr,;
				(ROUND(Iif(Inlist(Cli.Cliva,1,2,4,6,7),Sum(Round(Precio*codcant,2))*(iif(Sum(Round(Precio*codcant,2))>Percep_Min,Por_Percep/100,0)),Sum(Round(Precio*codcant,2))*(1+(lnIVA*.01))*(iif(Sum(Round(Precio*codcant,2))>Percep_Min,Por_Percep/100,0))),2)) As Fimp_pibr,;
				(ROUND(Iif(Inlist(Cli.Cliva,1,2,4,6,7),SUM(Round(Precio*codcant,2))*(1+(lnIVA*.01)) + round(SUM(round(Precio*codcant,2))*(iif(Sum(Round(Precio*codcant,2))>Percep_Min,Por_Percep/100,0)),2),SUM(Round(Precio*codcant,2))*(1+(lnIVA*.01)) + round(SUM(Round(Precio*codcant,2))*(1+(lnIVA*.01))*(iif(Sum(Round(Precio*codcant,2))>Percep_Min,Por_Percep/100,0)),2)),2)) * lnSignoMov As Ftotal,;
				lnCotiz As fCotiz,;
				(ROUND(Iif(Inlist(Cli.Cliva,1,2,6),Sum(Round(Precio*codcant,2)),Sum(Round(Precio*codcant,2))*(1+(lnIVA*.01))),2)) * lnSignoMov As FSubTot,;
				(ROUND(Sum(Round(Precio*codcant,2))*(1+(lnIVA*.01)),2) - SUM(Round(Precio*codcant,2))) * lnSignoMov As fIva1,;
				lnIVA As fxIva1,;
				ldFecha As Fd2,;
				"M" As fMayomin,;
				This.xxfN11(Cli.Cllist) as fN11,;
				This.xxfLista(Cli.Cllist) as flista,;
				This.CambiAcento( nvl( UPPER( Cli.Clnom ), 'Nada' )) as fCliente,;				
				1 As fTipo,;
				lnIVA As fxIvaArt,;
				100000000 * lnTipo As fNumE,;
				This.FechaVTO As fVto,;
				ALLTRIM(Space(5)) + Nvl( This.CambiAcento( Cli.cc051 ), '60' ) As fCorre,;
				ALLTRIM(Space(40)) + Nvl( Upper( This.CambiAcento( cor.conom ) ), 'Nada' ) As fCorreTxt,;   
				1 As fAgrupy,;
				ALLTRIM(Space(60))+This.CambiAcento( nvl(Cli.Clentr, "" ) ) As fEntr,;
				100000000 * lnTipo As jjNum,;
				This.Jjt( Cli.clvcod ) As Jjt,; 
				ALLTRIM(Space(5))+This.CambiAcento( iif(empty(nvl(Cli.clvcod, "")),"C",nvl(Cli.clvcod, "")) ) As jjCo,; 
				Space(5) As jjCo_Cup,; 
				Space(5) As jjCo_Cta,; 
				ldFecha As jjFe,;
				ALLTRIM(Space(40))+This.CambiAcento(SIS.scod)+" "+This.CambiAcento(lcCodigo) As jjDe,;
				0000000000 As jjNu,;
				(ROUND(Iif(Inlist(Cli.Cliva,1,2,4,6,7),ROUND(Sum(Round(Precio*codcant,2))*(1+(lnIVA*.01)),2) + SUM(Round(Precio*codcant,2))*(iif(Sum(Round(Precio*codcant,2))>Percep_Min,Por_Percep/100,0)),ROUND(Sum(Round(Precio*codcant,2))*(1+(lnIVA*.01)),2) + SUM(Round(Precio*codcant,2))*(1+(lnIVA*.01))*(iif(Sum(Round(Precio*codcant,2))>Percep_Min,Por_Percep/100,0))),2)) * lnSignoMov As jjM,;
				This.CambiAcento(SIS.scod) As jjCli,;
				ldFecha As jjFecha,;
				"ZOO" As jjVen,;
				(ROUND(Iif(Inlist(Cli.Cliva,1,2,4,6,7),(ROUND(Sum(Round(Precio*codcant,2))*(1+(lnIVA*.01)),2) + SUM(Round(Precio*codcant,2))*(iif(Sum(Round(Precio*codcant,2))>Percep_Min,Por_Percep/100,0))),(ROUND(Sum(Round(Precio*codcant,2))*(1+(lnIVA*.01)),2) + round(SUM(Round(Precio*codcant,2))*(1+(lnIVA*.01))*(iif(Sum(Round(Precio*codcant,2))>Percep_Min,Por_Percep/100,0)),2))),2)) * lnSignoMov  As jjTotFac,;
				000000000.00  As TotFac_cup,;
				000000000.00  As TotFac_cta,;	
				ALLTRIM(Space(5)) + Nvl( This.CambiAcento( Cli.cc051 ), '60' ) As jjCorre ,;
				1 As jjTurno,;
				lnCotiz As jjCotiz;
			FROM INFFILTR As SIS ;
				LEFT Outer Join Cli On  Cli.Clcod = SIS.scod and Cli.cltpo = 1;
				LEFT Outer Join corre As cor   On  cor.cocod = Cli.cc051 ;
			WHERE !Isnul(Az_codlin) And !Empty(Az_codlin);
			ORDER By Cli.cliva desce, Sis.AZ_climpd, scod, grupo, sis.numreg ; &&			ORDER By Fecha, Sis.AZ_climpd, Cli.cliva , scod 
			GROUP By Sis.AZ_climpd, scod, grupo; 
			INTO Dbf TOT Noconsole


			lbClave = .F.
			Select TOT

			Go Top
			Scan
				If Isnull( TOT.CLAVE )
					lbClave = .T.
				endif
				if alltrim(upper(fCliente)) != 'NADA' and alltrim(upper(fCorreTxt)) = 'NADA' 	
					this.AgregarInformacion( "No se puede validar el Corredor " + alltrim( Tot.fCorre ) + " del cliente: " + alltrim(upper(fCliente)))
				endif 	
			Endscan

			Select TOT
			Go Top

			Local llExiste, lnNumfac, lcNrodeFacQueExisten
			llOk = .T.
			lnNumfac = 0
			lcNrodeFacQueExisten = ""

			Set Order To 1 In FAC
			Scan

				lnNumfac = fNum+This.xxFnum()

				If this.GeneraFacElec
					lnNumfac = lnNumfac + ( This.talonariofacturacion * 10000000 )
				Endif

				If !This.VerificarNroFactura(lnNumfac)
					Replace fNum  With lnNumfac,;
						fNumE With lnNumfac,;
						jjNum With lnNumfac,;
						jjNu  With jjNu+This.xxJjNu() In TOT
				Else
					llOk = .F.
					Exit
				Endif
			Endscan
			Set Order To 0 In FAC

			If !llOk
				Local LcMensaje
				LcMensaje = "No se han podido generar las facturas, ya existe el comprobante " + Allt( Str( lnNumfac - 100000000 ) )  + ". Operación cancelada."
				this.AgregarInformacion( LcMensaje )
			Endif

			loInfoProblemasEnFac = this.ObtenerInformacion()

			if loInfoProblemasEnFac.Count = 0

				Go Top

				Select INFFILTR

				Copy To previa For Alltrim(previo) = "S"
				Copy To noprevi For Alltrim(previo) != "S"
				Select 0
				Use previa Exclu
				Select 0
				Use noprevi Exclu

				Select 	TOT.fNum,;
					az_precio4 As orden,;
					TOT.fVen,;
					TOT.fFch,;
					This.CambiAcento(Az_codlin)    As fart,;
					codcant * lnSignoMov As fcant,;
					IIF(Inlist(TOT.RzSitFisca,1,2,6),Precio,Round(Precio*1.21,2)) * lnSignoMov As fPrun,;
					IIF(Inlist(TOT.RzSitFisca,1,2,6),Round(Precio*codcant,2),Round((Precio*(1+(lnIVA*.01)))*codcant,2)) * lnSignoMov As fNeto,;
					TOT.fTurno,;
					Tot.fn11,;
					Tot.fLista,;
					TOT.fHora,;
					iif( Indent > 0, Space(Indent) + Alltrim(az_des), This.CambiAcento(az_des)) As fTxt,;
					TOT.Ftotal As fTarjeta,;
					TOT.fCotiz,;
					Tot.fCliente,;				
					This.CambiAcento(SIS.scod) As fperson,;
					TOT.FSubTot as fSubTot ,;
					TOT.Ftotal as fTotal ,;
					TOT.fIva1,;
					TOT.fxIva1,;
					TOT.Fd2,;
					TOT.fMayomin,;
					TOT.fTipo,;
					TOT.fxIvaArt,;
					(TOT.Ftotal - TOT.Fimp_pibr - TOT.fIva1) As fGravIva1, ;
					SIS.previo  As previo, ;
					SIS.Numreg As Numreg, ;
					SIS.grupo, ;
					SIS.fcoTxt, ;
					SIS.Indent, ;
					SIS.fCCte;
					, .T. as FesFcred ;
					FROM noprevi As SIS;
					LEFT Outer Join TOT    On  TOT.CLAVE = Dtoc(SIS.Fecha,1)+SIS.Clcod+SIS.scod+Str( grupo );  &&rz.RzFacsino
					WHERE !Isnul(Az_codlin) And !Empty(Az_codlin) ;
					ORDER By Tot.RzSitFisca desce, Sis.AZ_climpd, scod, grupo, sis.numreg  ;   &&az_precio4,Az_codlin;   &&ORDER By Fecha,Sis.AZ_climpd, Tot.RzSitFisca desce,scod,az_precio4, Az_codlin
					INTO Dbf CASIFAC Noconsole  &&INTO Dbf TotNoPr Noconsole

				***************************** INGRESA UN REGISTRO NUEVO CON EL ARTICULO "  TT  xxx"
				Select CASIFAC
				
				Go Top
				
				Use In select( "noprevi" )
				Delete File "noprevi.dbf"

				**Comienza el control sobre la cantidad de Items
				if !Empty(this.OrigenDeDatos) and this.nTipoComprobante = 1
					This.ControlaLineas( this.GeneraFacElec )
				Endif



				*Reordena los registros
			
				Select CASIFAC.*,;
						ROUND(CASIFAC.Ftotal/CASIFAC.fCotiz,2) As fAcumula,;
						Space(5) As ft051 , Iif( this.GeneraFacElec, .T., .F. );
						As fCompFis ;
						From CASIFAC ;
						Order By fNum,Numreg ;
						Into Table Final
						
				Use In select( "previa" )
				Delete File "previa.dbf"
			
				if this.nTipoComprobante = 3
					This.DiscriminarValores_CtaCte_Y_Cupones_EnDeudores()
				endif 
					
				This.GeneraCuentaCorriente()

				use in select("Nuevos")
				Delete File "Nuevos.dbf"

				Set Safety &lcSeguridad

				Select Final
				lnLinea = 1
				lcCli = ""
				lcSeguridad = Set("Safety")

				Set Safety Off

				Scan
					If lcCli != Final.fperson
						lcCli = Final.fperson
						lnLinea = 1
					Else
						lnLinea = lnLinea + 1
					Endif
					Replace ft051 With Alltrim(Str(lnLinea))

				Endscan

				Set Safety &lcSeguridad

				Select FAC
				Append From Final

				Select FACM
				Append From TOT

				select tot
				go top
				
		 		scatter  name loTotDBF

		 		if this.nTipoComprobante = 3 
			 		
			 		lnDiferencia = this.MontoDeudaCtaCte + this.MontoDeudaCupones -  abs( round( loTotDBF.fTotal, 2 ) )
		 		
		 			if this.MontoDeudaCtaCte <> 0
						loTotDBF.jjco = loTotDBF.jjco_Cta
						loTotDBF.jjm = (this.MontoDeudaCtaCte - lnDiferencia) * -1
						lnDiferencia = 0
						loTotDBF.jjt = 5
						insert into Val from name loTotDBF
					endif 	
					if this.MontoDeudaCupones <> 0
						loTotDBF.jjco = loTotDBF.jjco_Cup
						loTotDBF.jjm = (this.MontoDeudaCupones - lnDiferencia) * -1
						loTotDBF.jjt = 3
						loTotDBF.jjNu = 0
						loTotDBF.jjnu = this.ObtenerYActualizarNumeroInternoXJJNU()
						insert into Val from name loTotDBF
					endif	
				else
					select val
					append from Tot
				endif 

				Select X
				Replace X.hNum With This.lhNum

				If this.GeneraFacElec
					if !used( "stSuc" )
						Use lcCamino+"St.DBF" Alias stSuc In 0 Shared
					endif 	
					Select stSuc
					SET INDEX TO this.RutaIndices+"st1.IDX",this.RutaIndices+"st2.IDX"

					Set Order To 1

					if this.nTipoComprobante = 3
						lnPosicion = 1
					else	
						lnPosicion = 0
					endif 
						
					Seek 4255 + ( (  This.talonariofacturacion ) * 6 ) + lnPosicion
					Replace stn1 With This.fNumA - 4000000

					Seek 4255 + ( ( This.talonariofacturacion ) * 6 ) + 3 + lnPosicion
					Replace stn1 With This.fNumB - 3000000

					Use In Select("stSuc")

					Select X
				Else
					Replace X.UltFacA With This.fNumA
					Replace X.UltFacB With This.fNumB
				Endif

				Unlock All
				
				lColDetalleDeComprobantes = this.ArmarColeccionDetalleDeComprobantesGenerados()

			endif 
		catch to loError
			this.AgregarInformacion( "Ha ocurrido un error en el proceso de facturación, deberá volver a realizar el proceso."  + chr(13) + loError.message )
		finally		
			this.LoguearEnUsuDeZOO_SA( lColDetalleDeComprobantes, lcCamino )
			this.CerrarTablas()
			this.LimpiarArchivos()
		endtry 	

		return ( lColDetalleDeComprobantes )
		
	Endfunc
	*-----------------------------------------------------------------------------------------
	function LoguearEnUsuDeZOO_SA( tColDetalleDeComprobantes as Collection, tcCamino as String ) as Void
		local lousu as Object, loItem as Object, lnSelect as Integer, loInfoProblemasEnFac as Collection 
		
		lnSelect = select()
		Use tcCamino+"USU.DBF" in select( "USU" )
		select USU
		scatter Name lousu blank

		with lousu 
			.unum = chr(240)  &&"1"
			.ufch = date()
			.utime = time()
			.unroserie = goFormularios.Leer( 1 )

			if this.nTipoComprobante = 3
				.uLugar = "ZL - ZLRZINCOBRABLEAPROB - " + alltrim( goservicios.seGURIDAD.cusuARIOLOGUEADO ) 
			else
				.uLugar = "ZL - ZLFACTURACIONLINCE - "  + alltrim( goservicios.seGURIDAD.cusuARIOLOGUEADO )
			endif 	

			if tColDetalleDeComprobantes.Count > 0
				for each loItem in tColDetalleDeComprobantes 
					.uaccion = loItem
					insert into USU from name lousu 
				endfor
			else
				loInfoProblemasEnFac = this.ObtenerInformacion()
				if loInfoProblemasEnFac.Count > 0
					for each loItem in loInfoProblemasEnFac
						.uaccion = loItem.cmensaje
						insert into USU from name lousu 
					endfor				
				else
					.uaccion = "ERROR: Problemas al generar comprobantes desde ZL."
					insert into USU from name lousu 
				endif 
			endif 

		endwith 
		
		select( lnSelect )
	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CrearYLLenarFcAuxDeUnXLS( tcArchivo as String ) as Void

		Set Safety Off
		If !Empty( tcArchivo ) And file( tcArchivo )

			try
				this.ApendXLS = newobject( "appendxlsx" )
				Create cursor FcAux (fperson C(60),fart C(16),fcant N(10,2),fPrecio N(16,2),grupo N(3,0),serie C(20),Indent N(1,0), Descrip C(254)) 
				Dimension aWrkSht(1), aCols(1)
				this.ApendXLS.AWorkSheets( @aWrkSht, tcArchivo, .T. )
				Select FcAux
				this.ApendXLS.AppendFromExcel( tcArchivo, aWrkSht(1), "1" )
				Go Top
				If Empty(FcAux.fcant)
					Delete
				Endif
				Delete For Empty(fperson) All
			catch to loError
				this.AgregarInformacion( "El archivo excel seleccionado se esta utilizando en otra aplicación." )
				Use In Select ("fcaux")
			Endtry
		Endif
	endfunc 

	*-----------------------------------------------------------------------------------------
	function LimpiarArchivos() as Void
		delete file "tabaux.dbf"
		DELETE FILE "TOT.DBF"
		DELETE FILE "CASIFAC.DBF"
		DELETE FILE "INFFILTR.DBF"
		DELETE FILE "FINAL.DBF"
		DELETE FILE "INFAUX.DBF"	
		Delete File "TEMPSER.DBF"
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CambiAcento( tcTexto ) as  String

		tcTexto=CHRTRAN(tcTexto,"á"," ")
		tcTexto=CHRTRAN(tcTexto,"é","‚")
		tcTexto=CHRTRAN(tcTexto,"í","¡")
		tcTexto=CHRTRAN(tcTexto,"ó","¢")
		tcTexto=CHRTRAN(tcTexto,"ú","£")
		tcTexto=CHRTRAN(tcTexto,"ñ","¤")
		tcTexto=CHRTRAN(tcTexto,"Ñ","¥")
		tcTexto=CHRTRAN(tcTexto,"ü","")
		tcTexto=CHRTRAN(tcTexto,"Ü","š")
		tcTexto=CHRTRAN(tcTexto,"ª","¦")
		tcTexto=CHRTRAN(tcTexto,"º","§")
		tcTexto=CHRTRAN(tcTexto,"°","§")
		
		RETURN tcTexto 
		
	endfunc 
	*-----------------------------------------------------------------------------------------
	function ObtenerListaDePrecioLince( tcCliente ) as Number
		local lcLista, lnSelect 
		
		lnSelect = select()
		Select Cli
		Set Order To Cli1
		Seek tcCliente
		If Found() and Cli.ClList !=0
			lcLista = Cli.ClList 
		else
			go top in X
			lcLista = X.XLISTA
		Endif
		Set Order To
		select &lnSelect
		return lSalida

	endfunc 

	*-----------------------------------------------------------------------------------------
	function FormatearEntr( tcTexto ) as String 
		
		LOCAL lSalida, lcCBU ,lcDescripcion

		lcCBU  = '' 
		lSalida= tcTexto
		
		if left( alltrim( upper( tcTexto ) ), 3) =='CBU'
			lcCbu = right( alltrim(tcTexto), rat( ' ', alltrim(tcTexto) ) )
			lcCbu = strtran( lcCbu, "-", "" )
			lcCBU = substr(lcCbu,1,3) + '-' + substr(lcCbu,4,4) + '-' + substr(lcCbu,8,1) + " " + ;
					substr(lcCbu,9,2) + '-' + substr(lcCbu,11,3) + '-' + substr(lcCbu,14,3) + '-'+ ;
					substr(lcCbu,17,3) + '-' + substr(lcCbu,20,3)

			lSalida = "CBU " + lcCbu
		
		endif 	
				
		RETURN lSalida

	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function xxfnum() as Number 	

		LOCAL lSalida
		lSalida=0

		IF INLIST(TOT.RzSitFisca,1,2,6)
			This.fNumA=This.fNumA+1
			lSalida=This.fNumA
		ELSE
			This.fNumB=This.fNumB+1
			lSalida=This.fNumB
		ENDIF

		RETURN lSalida	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function jjt( lRzFtipo ) as Number 			
		LOCAL lSalida
		lSalida=0

		IF !empty(lRzFtipo)
			if inlist( alltrim(lRzFTipo), "PRE", "C", "COP" )
				lsalida = 5		
			else
				lsalida = 3	
			endif	
		ELSE
			lsalida = 5	
		ENDIF

		RETURN lSalida
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function VerificarNroFactura( tnNumeroProximaFactura ) as Boolean 
		Local llRetorno
		if seek( tnNumeroProximaFactura, "fac" )
			llRetorno = .T.
		endif

		return llRetorno
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function xxJjNu() as Number 
		LOCAL lSalida
		lSalida=0
		This.lhNum=This.lhNum+1
		lSalida=This.lhNum
		RETURN lSalida
	endfunc 
	
	*-----------------------------------------------------------------------------------------
	function ControlaLineas( lFacturacionElectronica ) as VOID 

		local lnFactura,lnPrevios,lnNoPrevia,lnMaximo,lnRestan, lnNuevaFac,lnvieNum,lnGrupo, lnNueNum, ;
			lnLinMaxA,lnLinMaxB, lcArtTotali, llNuevaFactura, llRecalcula, lnSitFiscal, ;
			lcPerson,  lnTarjeta, lnIva, lnCotiz, lnSubtot, lnTipo
		 	
		llNuevaFactura = .f.	
		llRecalcula = .f.
		lnSitFiscal = 0
		lnTipo = this.nTipoComprobante

		select imp
		set order to imp1

		seek "MFACTURAS-A"
		if found()
			lnLinMaxA = imp.rlin
		else
			lnLinMaxA = 7
		endif		
		seek "MFACTURAS-B"
		if found()
			lnLinMaxB = imp.rlin
		else
			lnLinMaxB = 7
		endif		

		lcArtTotali = rtrim(This.txtArtTT)

		select Casifac.fnum, count(casifac.fnum) as Cantidad,tot.rzSitFisca, ;
			iif(Inlist(tot.rzSitFisca,1,2,6),lnLinMaxA,lnLinMaxB) as Maximo, ;
			sum(iif(rtrim(casifac.Fart) = lcArtTotali,1,0)) as Previas, sum(iif(previo !="S",1,0)) as NoPrevia ;	
			from CasiFac ;
			inner join Tot on Casifac.Fnum == Tot.Fnum ;
			group by casifac.fnum order by casifac.fnum into table RegFac

		select RegFac
		* Procesa ahora el tema de las facturas nuevas
		scan for cantidad > Maximo and noPrevia > 0

			lnFactura = RegFac.fNum
			lnPrevios = RegFac.Previas
			lnNoPrevia = RegFac.NoPrevia
			lnMaximo = RegFac.Maximo
			lnRestan = iif(lnPrevios < lnMaximo, lnMaximo - lnPrevios,0)
			
			if lnRestan > 0
				llRecalcula = .t.	
				select Casifac		
				select *,count(grupo) as CantGrupo,0 as Nuevafac from Casifac ;
					where fnum = lnFactura and Previo != "S" ;			
					group by Grupo ;
					order by Grupo ;
					into Table RegNuevas
				replace CantGrupo with this.CalculaNoPrevia( RegNuevas.Fnum, RegNuevas.Grupo ) for Grupo>0
				select Tot
				index on Fnum to Fnum1
				select RegNuevas
				set relation to Fnum into Tot
				lnNuevaFac = 0
				
				scan
					if RegNuevas.CantGrupo + lnPrevios <= lnMaximo
						replace NuevaFac with lnNuevaFac
						lnPrevios = lnPrevios + RegNuevas.CantGrupo
						llNuevaFactura = .f.
					else
						lnNuevaFac = lnNuevaFac + 1
						replace NuevaFac with lnNuevaFac
						lnPrevios = RegNuevas.CantGrupo
						llNuevaFactura = .t.				
					endif

					if NuevaFac > 0
						lnvieNum = fnum
						lnGrupo = Grupo
						lnNueNum = iif(llNuevaFactura,100000000 * lnTipo + This.xxFnum(),lnNueNum)
						
						if lFacturacionElectronica
							lnNueNum = lnNueNum + ( this.talonariofacturacion * 10000000 )
						endif 

						select casifac				
							replace Fnum with lnNueNum for fnum = lnVieNum and grupo = lnGrupo
						select RegNuevas
					endif			
				endscan
				set Relation to
				select Tot
				use in select( "RegNuevas" )
				delete file "regnuevas.dbf"

			endif
		endscan
		use in select( "RegFac" )
		delete file "RegFac.dbf"

		if llRecalcula	
			select fnum,sum(fneto) as Total, fcotiz,fxiva1, tot.Fimp_pibr as Fimp_pibr, fperson, fTotal as TotalOrig ;
				from casifac group by fnum order by fnum into cursor Cur_Casifac
			select Cur_CasiFac
			set relation to fnum into Tot

			scan	
				lnFactura = Cur_Casifac.fnum
				lcPerson = Cur_Casifac.fperson
				
				select rzsitfisca from tot where alltrim(jjcli) == alltrim(lcPerson) into cursor curfiscal
				lnSitFiscal = curfiscal.rzsitfisca
				use in select( "curfiscal" )
				select Cur_CasiFac	

				if Inlist(lnSitFiscal,1,2,6)			
					lnTarjeta = round(Cur_casifac.Total *(1+(this.pariva*.01)) + tot.Fimp_pibr,2) && Ver
					lnIVA = round(Cur_Casifac.Total * (1+(this.pariva *.01)),2)	- Cur_Casifac.Total			
				else
					lnTarjeta = Cur_Casifac.Total + tot.Fimp_pibr
					lnIVA = Cur_Casifac.Total - round(Cur_Casifac.Total / (1+(this.pariva *.01)),2)			
				endif		

				lnCotiz = Cur_casifac.fCotiz		
				lnSubtot = Cur_casifac.Total	
				lnTotal = Cur_casifac.TotalOrig 	

				select Casifac
				replace ftarjeta with lnTarjeta, fsubtot with lnSubtot, ;
					ftotal with lnTarjeta, fiva1 with lnIVA, fgraviva1 with lnTotal - tot.Fimp_pibr - lnIVA ;  &&,facumula with iif(lnCotiz=0,0,round(lnTarjeta/lnCotiz,2))
					for casifac.fnum = lnFactura
				select Tot
				seek Cur_Casifac.fnum

				if found()
					replace ftotal with lnTarjeta, FSubtot with lnSubtot, fiva1 with lniva, ;
						jjm with lnTarjeta, jjtotfac with jjm 
				else
					select * from Tot where alltrim(jjcli) == alltrim(lcPerson) into Cursor Cur_Datos
					select Cur_Datos
					scatter to NueFac
					use in select( "Cur_Datos" )
					NueFac[2] = lnFactura
					NueFac[8] = lnTarjeta
					NueFac[10] = lnSubTot
					NueFac[11] = lnIVA
					NueFac[18] = this.nTipoComprobante  &&NueFac[2]									
					NueFac[24] = 1  &&NueFac[2]	
					NueFac[29] = This.xxJjNu()
					NueFac[30] = NueFac[8]																		
					NueFac[34] = NueFac[8]	
					select Tot		
					append blank
					gather from NueFac	
				endif
				
				select Cur_Casifac
					
			endscan
			use in select( "Cur_Casifac" )
			select tot
			set index to		
			delete file "Fnum1.idx"
		endif	
	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function GeneraCuentaCorriente() as VOID 
		local lnTipo , lnSignoMov, lcCondicionScan as String, lcCamino as String  

		lnTipo = this.nTipoComprobante
		lnSignoMov = iif( lnTipo = 3, -1, 1 )
		lcCondicionScan = iif( lnTipo = 3, "inlist(alltrim(Tot.jjco_Cta),'CCAJU')", "Tot.jjT=5" )  &&iif( lnTipo = 3, "inlist(alltrim(Tot.jjco_Cta),'C','PRE')", "Tot.jjT=5" )
		lcCamino = This.RutaTablas

		select Tot

		scan for &lcCondicionScan

			select ctb

			SCATTER TO CTBAAUX BLANK
			lnRango = 100000000 * lnTipo
			
			if this.GeneraFacElec
				lnptovtamaq = this.talonariofacturacion
			else
				lnptovtamaq = 0
			endif 
			
			lnFactura = val( substr( alltrim( str( tot.fnum ) ), 3 ) )
			CTBAAUX(1)= lnFactura + (lnRango+(lnPtovtamaq*10000000))
			CTBAAUX(2)=	tot.fven
			CTBAAUX(3)=	tot.jjcli  
			CTBAAUX(4)=	tot.ffch
			CTBAAUX(5)=	tot.ffch 
			CTBAAUX(6)=	tot.fcotiz
			CTBAAUX(7)=	tot.jjTotFac 
			*CTBAAUX(9)=	iif( lnTipo = 3, 0, tot.jjTotFac)  
			CTBAAUX(9)=	 tot.jjTotFac


			if tot.fcotiz > 0
				CTBAAUX(8)=	round(tot.jjTotFac/tot.fcotiz,2)  
				*CTBAAUX(10)= iif( lnTipo = 3, 0, round(tot.jjTotFac/tot.fcotiz,2) )
				CTBAAUX(10)= round(tot.jjTotFac/tot.fcotiz,2) 
			else 
				CTBAAUX(8)=	tot.jjTotFac
				*CTBAAUX(10)= iif( lnTipo = 3, 0, tot.jjTotFac )
				CTBAAUX(10)= tot.jjTotFac
			endif


			do case
				case between( lnFactura, 0, 2000000 )  
					CTBAAUX(11)=RIGHT("0000"+LTRIM(STR(X->XBOCAA)),4)+"-"+;
						RIGHT("00000000"+LTRIM(RIGHT(STR(lnFactura),6)),8)		

				case between( lnFactura, 3000000, 5000000 )   &&Facturacion electronica
					
					local lnTalonario, lnPtoVta
				
					lnTalonario = this.talonariofacturacion

					if !used("stSuc")
						Use lcCamino+"St.DBF" Alias stSuc In 0 Shared
					endif 	
					select stSuc
					SET INDEX TO this.RutaIndices+"st1.IDX",this.RutaIndices+"st2.IDX"

					SET ORDER TO 1
					seek 3054 + lnTalonario * 2
					lnPtoVta = stSuc.stn1

					use in select("stSuc")
				
					CTBAAUX(11)=RIGHT("0000"+LTRIM(STR( lnPtoVta )),4)+"-"+;
						RIGHT("00000000"+LTRIM(RIGHT(STR(lnFactura),6)),8)		

			endcase
			
			IF (lnFactura >1000000 AND lnfactura <2000000) or (lnFactura>4000000 and lnFactura <5000000)
				pcTipLetr="A"
			ELSE
				pcTipLetr="B"
			ENDIF
			
			CTBAAUX(11)=iif( lnTipo = 3, "N.Cr‚d. Nr. ", "Factura Nr. " ) +pcTipLetr+" "+CTBAAUX(11)
			CTBAAUX(15)=tot.jjTotFac
			CTBAAUX(16)= Tot.fIVA1 
			CTBAAUX(17)=0
			CTBAAUX(18)= Tot.fXIVA1
			CTBAAUX(19)=0
		   	CTBAAUX(20)= 0
		   	CTBAAUX(21)= 0
		   	CTBAAUX(22)= 0
		   	CTBAAUX(23)= 0
		   	CTBAAUX(24)= tot.jjTotFac  &&tot.TotFac_cta 
		   	CTBAAUX(25)= 0
		   	CTBAAUX(26)= 0
			CTBAAUX(40)= .f.
			CTBAAUX(33)= Tot.Fcorre	&& GUARDA EL CORREDOR
			CTBAAUX(44)=.F.
			
		&& Ver situación de Cliente Liberado etc para ver si este if tiene algun sentido


		*!*		************************************************************************************
		*!*		*** Determina el porcentaje que debera sacarle al monto cuando se quiere obtener
		*!*		*** el monto sin I.V.A.
		*!*		************************************************************************************

			CTBAAUX(45)=IIF(EMPTY(tot.jjTotFac),0,((Tot.fIVA1)*100)/tot.jjTotFac)

			IF .NOT. this.ControlaSecuenciales(.t.,.t.)
				lErrCtaCte=.T.
			ENDIF

			SELECT X
			GO TOP
			SCATTER TO XAAUX
			XAAUX(37)=XAAUX(37)+1
			GATHER FROM XAAUX

			SELECT CTB
			CTBAAUX(12)=XAAUX(37)
			APPEND BLANK
			GATHER FROM CTBAAUX
			
			select final
				replace final.fccte with final.ftarjeta , ftarjeta with 0 for final.fnum = tot.fnum			
			select ctb
			
		endscan

		use in select( "ctb" )

	
	endfunc 
	*-----------------------------------------------------------------------------------------
	function obtenerMedioDePagoCupon() as string
		return ( iif( this.nTipoComprobante = 3, "TJAJU", iif( inlist( alltrim( Tot.jjco ),"C","PRE" ), "", tot.jjco ) ) )
	endfunc 

	*-----------------------------------------------------------------------------------------
	function obtenerMedioDePagoCtaCte() as string
		return ( iif( this.nTipoComprobante = 3, "CCAJU", iif( inlist( alltrim( Tot.jjco ),"C","PRE" ), tot.jjco, "" ) ) )
	endfunc 
		
	*-----------------------------------------------------------------------------------------
	function DiscriminarValores_CtaCte_Y_Cupones_EnDeudores() as Void
		local lnSelcet as Integer, lcMedioDePagoCupon as String ,;
			lcMedioDePagoCtaCte as String, lnSignoMov 

		
		lnSignoMov = iif( this.nTipoComprobante = 3, -1, 1 )
		lnSelect = select()
		select Tot 		

		replace all;
				jjco_Cta	with iif( this.nTipoComprobante = 3 and this.MontoDeudaCtaCte != 0, this.obtenerMedioDePagoCtaCte(), "");
				jjCo_Cup	with iif( this.nTipoComprobante = 3 and this.MontoDeudaCupones != 0, this.obtenerMedioDePagoCupon(), "" );
				TotFac_cta	with iif( this.nTipoComprobante = 3, this.MontoDeudaCtaCte * lnSignoMov, iif( inlist( alltrim( Tot.jjco ),"C","PRE" ), tot.jjTotFac , 0 ) ) ;
				TotFac_cup	with iif( this.nTipoComprobante = 3, this.MontoDeudaCupones * lnSignoMov, iif( inlist( alltrim( Tot.jjco ),"C","PRE" ), 0, tot.jjTotFac ) ) ;
			in Tot
		
		select( lnSelect ) 
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function CalculaNoPrevia( lnFactura, lnGrupo ) as Number

		local lnContadorArt, lcAreaAnterior, lnTotalizadores

		lcAreaAnterior = select()
		lnContador = 0
		lnTotalizadores  = 0
		select fart from casifac where fnum = lnFactura and Grupo = lnGrupo into cursor CurPrevios
		select CurPrevios
		scan
			if substr(CurPrevios.fart,1,6)=="  TT  "
				lnTotalizadores = lnTotalizadores + 1
				lnContador = lnTotalizadores
			else
				lnContador = lnContador + 1
			endif

		endscan

		select (lcAreaAnterior)

		return lnContador
	endfunc

	*-----------------------------------------------------------------------------------------
	function ControlaSecuenciales( lLevCTB,lLevIDX,tlOtroX,tcTablaX ) as Boolean
		private lTodoOK,cArea,nTimeNow,nSequAux,cOrder
	
		lTodoOK=.f.
		cArea=ltrim(str(select(0)))
		cOrder=""

		if lLevCTB
			if lLevIDX
				select CTB
				cOrder=order()
			else
				select CTB
			endif
		endif

		******************************************************************************************
		*** Busca si el siguiente secuencial a generarse ya existe en el archivo
		*** de ser asi le suma uno continua buscando uno libre, cuando lo encuentra
		*** se fija si algun otro registro de la cuenta corriente hace referencia a ‚l,
		*** de ser as¡ sigue buscando otro secuencial.  En el caso de pasar un minuto y
		*** no encontrar ninguno libre se corta el 1er. proceso de busqueda de secuencial.
		******************************************************************************************
		if tlOtroX
			nSequAux=&tcTablaX->XSQC+1
		else
			nSequAux=X.XSQC+1
		endif
		nTimeNow=seconds()
		do while (.not.lTodoOk).and.(seconds()<=(nTimeNow+60))

			select CTB
			set order to 4
			seek nSequAux
			if .not.found()
				set order to 5
				seek nSequAux
				if .not.found()
					lTodoOk=.t.

					if tlOtroX
						select (tcTablaX)
					else
						select X
					endif
					scatter to XAAUX
					if (nSequAux-1)#XAAUX(37)
						XAAUX(37)=nSequAux-1
						gather from XAAUX
					endif
					exit
				endif
			endif

			nSequAux=nSequAux+1
		enddo

		******************************************************************************************
		*** No encontro todav¡a un secuencial libre de problemas incrementando de a uno, entonces
		*** procede a realizar el procedimiento anterior de la misma forma pero incrementando de
		*** a mil.
		******************************************************************************************
		if .not.lTodoOk

			nTimeNow=seconds()
			if tlOtroX
				nSequAux=&tcTablaX->XSQC+1000
			else
				nSequAux=X.XSQC+1000
			endif
			do while (.not.lTodoOk).and.(seconds()<=(nTimeNow+60))
				select CTB
				set order to 4
				seek nSequAux
				if .not.found()
					set order to 5
					seek nSequAux
					if .not.found()
						lTodoOk=.t.

						if tlOtroX
							select (tcTablaX)
						else
							select X
						endif
						scatter to XAAUX
						if (nSequAux-1)#XAAUX(37)
							XAAUX(37)=nSequAux-1
							gather from XAAUX
						endif
						exit
					endif
				endif
				nSequAux=nSequAux+1000
			enddo
		endif

		******************************************************************************************
		******************************************************************************************
		*** Si sigue sin encontrarlo recorro la tabla, desde el ultimo registro, en busca
		*** del ultimo secuencial generado y le sumo 20000 luego me fijo si ya existe, de no ser
		*** asi busco si alguno otro registro hace referencia a ese numero, de no ser asi
		*** actualizo el X con este numero - 1.
		******************************************************************************************
		******************************************************************************************
		if .not.lTodoOk
			select CTB
			set order to
			go bottom
			do while .not.bof()
				if CSEQ#0
					nSequAux=CSEQ
				endif
				skip -1
			enddo
			nSequAux=nSequAux+20000
			set order to 4
			seek nSequAux
			if .not.found()
				set order to 5
				seek nSequAux
				if .not.found()
					lTodoOk=.t.

					if tlOtroX
						select (tcTablaX)
					else
						select X
					endif
					scatter to XAAUX
					if (nSequAux-1)#XAAUX(37)
						XAAUX(37)=nSequAux-1
						gather from XAAUX
					endif
				endif
			endif
		endif

		if .not.lLevCTB
			use in select( "CTB" )
		else
			if .not.lLevIDX
				select CTB
				set index to
			else
				if .not.empty(cOrder)
					select CTB
					set order to (corder)
				endif
			endif
		endif

		select &cArea
		return lTodoOK

	endfunc 

	*-----------------------------------------------------------------------------------------
	function CerrarTablas() as Void
		UNLOCK ALL
		use in select( "INFFILTR")
		use in select( "TOT")
		use in select( "CASIFAC")
		use in select( "RZ")
		use in select( "ART")
		use in select( "CLI")
		use in select( "CORRE")
		use in select( "X")
		use in select( "VAL")
		use in select( "FAC")
		use in select( "FACM")
		use in select( "USU")
		use in select( "IND")
		use in select( "IMP")
		use in select( "CTB")
		use in select( "ST")
		use in select( "INFAUX")
		use in select( "tempser")
		use in select( "Final")
		use in select( "TabAux" )
		use in select( "FcAux")
		use in select( "PERCVTA")
		use in select( "STPercep")
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerDatosParaProcesar() as VOID 
		local lcOrigen as String, lnMontoDeuda as Number, lcCursor as String , lcCursor2 as String ,;
			loMem as Object, lnOrden as Integer, lcSql as String, lcTablaSQL as string,;
			lcfCotxt as String, lcDescrip as String, lcOrderBy as String, lcArtTot as String,;
			lcCurTmp as String , lcArticuloIncluido as String, lcWhere as String 
		
		if this.nTipoComprobante = 1
			this.CrearYLLenarFcAuxDeUnXLS( this.OrigenDeDatos )
		else
	
			lcOrigen = this.OrigenDeDatos
			lnMontoDeuda = ( this.MontoDeudaCupones + this.MontoDeudaCtaCte )
			
			lcCursor = sys( 2015 )
			
			lnOrden = 1
			lcCursor2 = sys( 2015 )

			Create cursor FcAux (fperson C(60),fart C(16),fcant N(10,2),fPrecio N(16,2),grupo N(3,0),serie C(20),Indent N(1,0), Descrip C(254), Orden N(3,0), fcotxt C(20)) 

			lcTablaSQL = this.ObtenerEsquemaTablaSQL( "fac" )
			lcOrderBy = this.ObtenerOrderByConsultaDeuda()
			lcWhere = this.ObtenerWhereAdicional()

*!*				lcSql = "select F1.ft051,F1.fnum,"+;
*!*						"F1.fperson,F1.fart,F1.fcant,"+;
*!*						"F1.fprun as fprecio,"+;
*!*						"000 as grupo,"+;
*!*						"space(20) as serie,"+;
*!*						"0 as Indent,"+;
*!*						"F1.ftxt as Descrip,"+;
*!*						"F1.fcotxt,"+;
*!*						"(F1.fneto+F1.fneto*F1.fxIva1/100) as MontoItem ,"+;
*!*						"F1.fxIva1,"+;
*!*						"000 as Orden "+;
*!*						"from " + lcTablaSQL + " as F1" +  ;
*!*						" where Floor(F1.fnum/100000000)=1 and F1.fperson='" + lcOrigen + "'" +   ;
*!*						lcOrderBy 
					
			lcSql = "select " +;
				  	  "fart, ft051, 000 as grupo" +;
					  ", space(20) as serie" +;
					  ", 0 as Indent" +;
					  ", ftxt as Descrip" +;
					  ", 000 as Orden " +;
					  ", fxIva1 " +;
					  ", fperson " +;
				      ",sum(fcant) as fcant" +;
				      ",left(fcotxt,6) as fcotxt" +;
				      ",sum(fprun) as fprecio" +;
				      ",sum(fneto+fneto*fxIva1/100) as MontoItem " +;
				      " from " + lcTablaSQL +  ;
				      " where  fperson = '" + lcOrigen + "'" +   ;  
				      lcWhere +;
				      lcOrderBy 
			
			This.EjecutarSentencia( lcSql, lcCursor, set("Datasession" ) )

			if reccount( lcCursor ) = 0
				This.AgregarInformacion( "Problema al validar uno o mas artículos."  )
			endif 	

			
			lcSql = "select F2.fart from " + lcTablaSQL + " as F2" +;
						" where Floor(F2.fnum/100000000)=3 and F2.fperson='" + lcOrigen + "'"	
			
			This.EjecutarSentencia( lcSql, lcCursor2, set("Datasession" ) )

*!*				if reccount( lcCursor2 ) > 0
*!*					
*!*					lcCurTmp = sys( 2015 )
*!*					
*!*					select * ,;
*!*						&lcCursor..fart from &lcCursor where left( alltrim( &lcCursor..fart ), 2 ) = 'IT' and ;
*!*						&lcCursor..fart not in ( select &lcCursor2..fart from &lcCursor2 );
*!*						into cursor &lcCurTmp

*!*					if _tally = 0
*!*						select max( alltrim( &lcCursor..fart ) ) as fart from &lcCursor where left( alltrim( &lcCursor..fart ), 2 ) = 'IT' ;
*!*							into cursor &lcCurTmp
*!*					endif 	
*!*						
*!*					lcArticuloIncluido =  alltrim( &lcCurTmp..fart )
*!*					use in select( lcCurTmp )
*!*					
*!*					select * ,;
*!*						val( &lcCursor..ft051 ) as Val_ft051  from &lcCursor ;
*!*							where &lcCursor..fart not in ( select &lcCursor2..fart from &lcCursor2 where alltrim(&lcCursor2..fart) <> lcArticuloIncluido );
*!*						into cursor &lcCursor  order by &lcCursor..fnum desc, Val_ft051 desc
*!*		
*!*					select( lcCursor )
*!*					locate for left(fart,2)='IT'  
*!*					if !found()
*!*						select * ,;
*!*							val( &lcCursor..ft051 ) as Val_ft051  from &lcCursor ;
*!*							into cursor &lcCursor  order by &lcCursor..fnum desc, Val_ft051 desc
*!*					endif		
*!*				endif 

			select( lcCursor )
			locate for left(fart,2)='IT'  
			
			lcfCotxt = &lcCursor..fCotxt
			
			scatter name loMem blank
			
			scan while lnMontoDeuda > 0
			
				if  fcant > 0 and left(fart,2)='IT'   
			
					scatter name loMem 
					
					if loMem.fCotxt != lcfCotxt && Pongo un totalizador
						
						loMem.Orden = lnOrden

						lcArtTot  = '  TT  A' + left( lcfCotxt, 6 )
						select fcAux
						locate for fcAux.fart = lcArtTot  

						if !found()
							insert into fcAux from name loMem
							lcDescrip = this.ObtenerDescripArticuloTotalizador( lcfCotxt, lcCursor )
							replace fart with lcArtTot ,;  &&'  TT  A' + left( lcfCotxt, 6 )
									fPrecio with 0 ,;
									fcotxt with '',;
									fcant with 1 ,;
									Descrip with lcDescrip;
								in fcAux
						endif 	
						
						select( lcCursor )
						
						lnOrden = lnOrden + 1
			
					endif 
					
					** Cargo un item
					if loMem.MontoItem <= lnMontoDeuda
						lnMontoDeuda = lnMontoDeuda - loMem.MontoItem 
					else
						loMem.fprecio = round(( lnMontoDeuda / loMem.fcant ) / ( 1 + loMem.fxIva1/100 ), 2 )  
						lnMontoDeuda = 0
					endif
					
					loMem.Orden = lnOrden
					insert into fcAux from name loMem
					lnOrden = lnOrden + 1
					lcfCotxt = &lcCursor..fCotxt
				
				endif 
					
			endscan
			
			&& Pongo el ultimo totalizador
			loMem.Orden = lnOrden
			lcArtTot  = '  TT  A' + left( lcfCotxt, 6 )
			select fcAux
			locate for fcAux.fart = lcArtTot 

			if !found()
				insert into fcAux from name loMem
				lcDescrip = this.ObtenerDescripArticuloTotalizador( lcfCotxt, lcCursor )
				replace fart with lcArtTot ,;  &&'  TT  A' + left( lcfCotxt, 6 )
						fPrecio with 0 ,;
						fcotxt with '',;
						fcant with 1 ,;
						Descrip with lcDescrip;
					in fcAux
			endif 	
			
			select( lcCursor )

	
			**Reordeno el detalle del comprobante

			select *, ;
			iif( upper( left( fart, 2 ) ) =='IT',  left( fcotxt, 6 ) + right( alltrim(Fart),7) , ;
				right( alltrim(fart), 6 ) + "ZZZZZZZ" ) as xxx_Orden ;
				from fcAux ;
				order by xxx_Orden ;
				into cursor fcAux readwrite
			
			replace all orden with recno('FcAux') in FcAux

			if lnMontoDeuda > 0   &&agrego gastos hasta completar saldo
				
				scan while lnMontoDeuda > 0 for fcant > 0 and !inlist( left(alltrim(fart),2), 'IT', 'TT' )
				
					scatter name loMem 
					
					if loMem.MontoItem <= lnMontoDeuda
						lnMontoDeuda = lnMontoDeuda - loMem.MontoItem 
					else
						loMem.fprecio = round(( lnMontoDeuda / loMem.fcant ) / ( 1 + loMem.fxIva1/100 ), 2 )  
						lnMontoDeuda = 0
					endif
					loMem.Orden = lnOrden
					insert into fcAux from name loMem
					lnOrden = lnOrden + 1
						
				endscan

			endif 

			if lnMontoDeuda > 0
				loMem.fart = 'BONAB'
				loMem.descrip = 'BONIFICACION ABONOS'
				loMem.fcant = 1
				loMem.fprecio = round(( lnMontoDeuda  ) / ( 1 + loMem.fxIva1/100 ), 2 )  
				loMem.montoitem = round(( lnMontoDeuda  ) / ( 1 + loMem.fxIva1/100 ), 2 )  
				loMem.Orden = loMem.Orden + 1 
				loMem.fcotxt = ''
				insert into fcAux from name loMem
				lnMontoDeuda = 0
			endif 
			
			use in select( lcCursor )
		
		endif 	

	endfunc	

	*-----------------------------------------------------------------------------------------
	function ObtenerWhereAdicional() as String
		return " and fart like 'IT%'  " 
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerOrderByConsultaDeuda() as String
		local lcRetorno as String 
		lcRetorno =	  "group by fart,left(fcotxt,6),ft051, ftxt, fxIva1, fperson  " +;
				      "having sum(fcant) >=1 and sum(fprun) > 0  " +;
				      "order by left(fcotxt,6) desc, fart " 
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerDescripArticuloTotalizador( tcfCotxt, tcCursor ) as String
		local lcRetorno as String, lnSelect as Integer, lcCurTemp as String 
		
		lnSelect = select()
		lcCurTemp = sys( 2015 )
		
		select Descrip from &tcCursor ;
			where right( alltrim( Descrip ), 7 ) = right( left( tcfCotxt, 6 ), 2) + "/" + left( tcfCotxt, 4 ) ;
			into cursor &lcCurTemp 
		
		if _tally = 0
			lcRetorno = "Abono mensual software Zoo Logic " + right( left( tcfCotxt, 6 ), 2) + "/" + left( tcfCotxt, 4 )
		else
			lcRetorno = &lcCurTemp..Descrip
		endif 		
		
		
		use in select( lcCurTemp )
		select( lnSelect )
		
		return lcRetorno
	
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ArmarColeccionDetalleDeComprobantesGenerados() as Collection 
		local lctexto as String, lcCursor as String, lnSelect as Integer, ;
			lColDetalleDeComprobantes as Collection, lcCompDesde as String,;
			lcCompHasta as String  

		lColDetalleDeComprobantes = newobject( "Collection" )	
		lcCompDesde = ''
		lcCompHasta = ''
		lnSelect = select()
		lcCursor = sys( 2015 )

		if  this.nTipoComprobante = 3
			select Distinct fNum, Ftotal ;
				from final where fnum <> 0 ;
				order by fNum ;
				into cursor &lcCursor 
		else
			select  ;
						min( F1.fNum ) as Menor,;
						max( F1.fNum ) as Mayor, ;
						"A" as Letra ;
					from final as F1 where substr( alltrim( transform( F1.fNum ) ), 3, 1 )="4"; 
					union select ;
					    min( F2.fNum ) as Menor,;
						max( F2.fNum ) as Mayor, ;
						"B" as Letra ;
					from final as F2 where substr( alltrim( transform( F2.fNum ) ), 3, 1 )="3";
				order by 1 ;
				into cursor &lcCursor 
		endif 		
			
		select( lcCursor )
		scan 
			if  this.nTipoComprobante = 3
				lctexto = "Nota de crédito " + ;  &&iif( this.nTipoComprobante = 3, "Nota de crédito ", "Factura " )
						  iif(substr( alltrim( transform( &lcCursor..fNum  ) ), 3, 1 )="4", "A ", "B ") +;
						  "Nº " + substr( alltrim( transform( &lcCursor..fNum  ) ), 2, 1 ) + "-" + ;
						  right( alltrim( transform( &lcCursor..fNum  ) ) , 7 )
			else 
				lcCompDesde = substr( alltrim( transform( &lcCursor..Menor ) ), 2, 1 ) + "-" + ;
						  	  right(  alltrim( transform( &lcCursor..Menor ) ) , 7 )
						  	  
				lcCompHasta = substr( alltrim( transform( &lcCursor..Mayor ) ), 2, 1 ) + "-" + ;
						  	  right(  alltrim( transform( &lcCursor..Mayor ) ) , 7 )
						  	  
				lctexto = "Factura" + ;
						  iif( menor = mayor, " " , "s " ) + Letra + " " + "Nº " + ;
						  iif( menor = mayor, ;
						  lcCompDesde ,;
						  "desde " + ;
						  lcCompDesde + ;
						  " hasta " + ;
						  lcCompHasta )
						  
			endif 			  
					  
			lColDetalleDeComprobantes.Add( lcTexto )
		endscan 
		
		use in select( lcCursor )
		select( lnSelect )
		
		return lColDetalleDeComprobantes
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function xxfN11( tnLista as integer ) as String
		LOCAL lSalida as String, lnLista as Integer 
		
		lnLista = iif( isnull( tnLista ) or empty( tnLista ), x.xlista , tnLista )

		DO CASE
			CASE lnLista=1
				lSalida=X->XN1
			CASE lnLista=2
				lSalida=X->XN2
			CASE lnLista=3
				lSalida=X->XN3
			CASE lnLista=4
				lSalida=X->XN4
			CASE lnLista=5
				lSalida=X->XN5
		ENDCASE
		
		return lSalida		

	endfunc 

	*-----------------------------------------------------------------------------------------
	function xxfLista( tnLista as integer ) as String
		LOCAL lnLista as Integer 
		
		lnLista = iif( isnull( tnLista ) or empty( tnLista ), x.xlista , tnLista )

		return lnLista 		

	endfunc 

	*-----------------------------------------------------------------------------------------	
	protected function ObtenerEsquemaTablaSQL( tcTabla as String ) as String 
		local lcRetorno as String 
		if upper( alltrim( tcTabla ) ) = "RAZONSOCIAL"
			lcRetorno = "Zl." + tcTabla
		else
			lcRetorno = "CtasCtes.Vista_ZOO_SA_" + tcTabla
		endif 
		
		return lcRetorno
		
	endfunc 

	*-----------------------------------------------------------------------------------------	
	protected function EjecutarSentencia( tcSql, tcCursor, tnIdSesion ) as VOID 
		goServicios.Datos.EjecutarSQL( tcSql, tcCursor, tnIdSesion )
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerCotizacion() as Number
		local lnRetorno as Number, lcRutaTabla as String, lcRutaIDX as String,;
			lnSelect as Integer 

		lnSelect =  select()
		lnRetorno = 1

*!*			lcRutaTabla = addbs( alltrim( this.txtSuc ) ) + iif( "\DBF" $ alltrim( upper( this.txtSuc ) ), "" , addbs( "DBF" ) )
*!*			lcRutaIDX = addbs( left( alltrim( lcRutaTabla ),len( lcRutaTabla )-4) + "IDX" )

*!*			try
*!*				use (lcRutaTabla + "IND") index ( lcRutaIDX + "Ind1.idx" ) alias Ind2 in select( "ind2" )  shared again 
*!*				select ind2
*!*				set order to Ind1 in ind2
*!*			catch to loError
*!*				loEx = _screen.zoo.crearObjeto("ZooException")
*!*				with loEx
*!*					.AgregarInformacion( "Error al abrir Ind.dbf: (" + loError.Message + ")" )
*!*				endwith
*!*				throw loEx
*!*			endtry
*!*			
*!*			if reccount( "Ind2" ) > 0
*!*				select IND2
*!*				go bottom 
*!*				lnRetorno = Ind2.indval
*!*			endif 
*!*			
*!*			use in select ( "Ind2" )
*!*			select( lnSelect ) 

		return lnRetorno
		
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerYActualizarNumeroInternoXJJNU() as Integer 
		local lnSelect, lnRet
		lnSelect = select()
		select x		
		lnRet = X.hNum + 1
		replace X.hNum with lnRet
		select( lnSelect )
		return lnRet
	endfunc

Enddefine


*********************************************************************************************************
*********************************************************************************************************
*********************************************************************************************************
Define Class AppendXLSX As Custom

	Function AppendFromExcel(tcXLSFile, tcSheet, tvWorkarea, tcExcelFieldList, tcExcelWhereExpr, tcTableFieldList, tcTableForExpr, tlNoHeaderRow)

	Local lnSelect, laErr[1], laTableFields[1], laExcelFields[1], lnFieldCounter, ;
		lcSQLAlias, lnResult, lcInsertValues, lcFieldList, lcNvlFieldList, ;
		lcFieldType, lcExcelFieldType, lcNvlFieldName, lcTempAlias, loExc, lnReturn, ;
		lcHeaderRow, llOpenedtvWorkArea

	m.lnSelect = Select(0)
	m.lnReturn = 0

	If Not File(m.tcXLSFile)
		Error 1, m.tcXLSFile
	Endif

	If !Used(m.tvWorkarea) And Type("m.tvWorkArea") = "C" And File(Defaultext(m.tvWorkarea,"DBF"))
		Select 0
		Use (Defaultext(m.tvWorkarea,"DBF")) Shared Again
		m.tvWorkarea = Alias()
		m.llOpenedtvWorkArea = .T.
	Else
		If !Used(m.tvWorkarea)
			m.tvWorkarea = Alias()
		Endif
	Endif
	If Type("m.tvWorkArea") = "N"
		m.tvWorkarea = Alias(m.tvWorkarea)
	Endif

	m.tcSheet = Alltrim(Evl(m.tcSheet,"Sheet1$"))
	If At("$",m.tcSheet) = 0
		m.tcSheet = m.tcSheet + "$"
	Endif
	m.tcExcelFieldList = Evl(m.tcExcelFieldList,"*")
	m.tcExcelWhereExpr = Evl(m.tcExcelWhereExpr,"1=1")
	m.tcTableFieldList = Evl(m.tcTableFieldList,"*")
	m.tcTableForExpr = Evl(m.tcTableForExpr,".T.")
	m.lcSQLAlias = Sys(2015)
	m.lcTempAlias = Sys(2015)
	m.lnSQL = 0
	m.lcHeaderRow = Iif(Empty(m.tlNoHeaderRow), "Yes", "No")
	Try
		Select (m.tvWorkarea)

		m.lnSQL = Sqlstringconnect("Provider=MSDASQL.1;" ;
			+"Persist Security Info=False;" ;
			+"DSN=Excel Files;" ;
			+"DBQ="+Fullpath(m.tcXLSFile)+";" ;
			+"DriverId=790;" ;
			+"MaxBufferSize=2048;" ;
			+"PageTimeout=5;")

		If m.lnSQL < 0
			m.lnSQL = Sqlstringconnect("Driver={Microsoft Excel Driver (*.xls, *.xlsx, *.xlsm, *.xlsb)};" ;
				+ "DBQ="+Fullpath(m.tcXLSFile)+";")
			If m.lnSQL < 0 And Upper(Alltrim(Justext(m.tcXLSFile))) == "XLS" && can we try using the older driver?
				If m.lnSQL < 0
					m.lnSQL = Sqlstringconnect("Driver={Microsoft Excel Driver (*.xls)};" ;
						+ "DBQ="+Fullpath(m.tcXLSFile)+";")
				Endif
			Endif
			If m.lnSQL < 0
				Aerror(m.laErr)
				Error m.laErr[2]
			Endif
		Endif

		m.lnResult = SQLExec(m.lnSQL,[SELECT ] + m.tcExcelFieldList + [ FROM "] + m.tcSheet + [" Where ] + m.tcExcelWhereExpr, m.lcSQLAlias)
		If m.lnResult < 0
			Aerror(m.laErr)
			Error m.laErr[2]
		Endif

		If Used(m.lcSQLAlias)
			m.lcFieldList = ""
			m.lcNvlFieldList = ""
			m.lnTotalExcelFields = Afields(m.laExcelFields, m.lcSQLAlias)
			Select &tcTableFieldList From (m.tvWorkarea) Where .F. Into Cursor (m.lcTempAlias)
			For m.lnFieldCounter = 1 To Min(Afields(m.laTableFields, m.lcTempAlias), m.lnTotalExcelFields)
				m.lcFieldList = m.lcFieldList + Iif(!Empty(m.lcFieldList),",","")+m.laTableFields[m.lnFieldCounter,1]
				m.lcFieldType =  Chrtran(m.laTableFields[m.lnFieldCounter,2],"NIFYD","BBBBT")
				m.lcExcelFieldType = Chrtran(m.laExcelFields[m.lnFieldCounter,2],"CVNIFYD","MMBBBBT")
				m.lcNvlFieldName = m.laExcelFields[m.lnFieldCounter,1]
				If !m.laTableFields[m.lnFieldCounter,5]
					m.lcNvlFieldName = [NVL(]+m.lcNvlFieldName+[,]+;
						ICASE(m.lcExcelFieldType="B", "0", ;
						m.lcExcelFieldType="M", "''", ;
						m.lcExcelFieldType="T", "{//}", ;
						m.lcExcelFieldType="L", ".F.", ;
						"''")+[)]
				Endif
				If Inlist(m.lcFieldType, "C", "V")
					m.lcNvlFieldName = [CAST(]+m.lcNvlFieldName+[ AS ]+m.lcFieldType+[(] + Transform(m.laTableFields[m.lnFieldCounter,3]) + [))]
				Else
					m.lcNvlFieldName = [CAST(]+m.lcNvlFieldName+[ AS ]+m.lcFieldType+[)]
				Endif
				m.lcNvlFieldList = m.lcNvlFieldList + Iif(!Empty(m.lcNvlFieldList),",","") + m.lcNvlFieldName
			Endfor
			Insert Into (m.tvWorkarea) (&lcFieldList) Select &lcNvlFieldList From (m.lcSQLAlias) Where &tcTableForExpr
			m.lnReturn = _Tally
		Endif

	Catch To m.loExc

	Finally
		If m.llOpenedtvWorkArea
			Use In Select(m.tvWorkarea)
		Endif
		If m.lnSQL > 0
			SQLDisconnect(m.lnSQL)
		Endif
		Use In Select(m.lcTempAlias)
		Use In Select(m.lcSQLAlias)
		Select (m.lnSelect)
	Endtry
	Return m.lnReturn
	Endfunc

*----------------------------------------------------------------------
	Function AWorkSheets(taArray, tcXLSFile, tlAllTables)

		Local lnSQL, laErr[1], lcSQLAlias, lnResult, lnReturn, loExc
		m.lnReturn = 0

		m.lnSQL = Sqlstringconnect("Provider=MSDASQL.1;" ;
			+"Persist Security Info=False;" ;
			+"DSN=Excel Files;" ;
			+"DBQ="+Fullpath(m.tcXLSFile)+";" ;
			+"DriverId=790;" ;
			+"MaxBufferSize=2048;" ;
			+"PageTimeout=5;")


		If m.lnSQL < 0
			If Upper(Alltrim(Justext(m.tcXLSFile))) == "XLS" && can we try using the older driver?
				m.lnSQL = Sqlstringconnect("Driver={Microsoft Excel Driver (*.xls, *.xlsx, *.xlsm, *.xlsb)};" ;
					+ "DBQ="+Fullpath(m.tcXLSFile)+";")
				If m.lnSQL < 0
					m.lnSQL = Sqlstringconnect("Driver={Microsoft Excel Driver (*.xls)};" ;
						+ "DBQ="+Fullpath(m.tcXLSFile)+";")
				Endif
			Else
				m.lnSQL = Sqlstringconnect("Driver={Microsoft Excel Driver (*.xls, *.xlsx, *.xlsm, *.xlsb)};" ;
					+ "DBQ="+Fullpath(m.tcXLSFile)+";")
			Endif
			If m.lnSQL < 0
				Aerror(m.laErr)
				Error m.laErr[2]
			Endif
		Endif

		m.lcSQLAlias = Sys(2015)
		m.lnResult = SQLTables(m.lnSQL,"VIEW,TABLE,SYSTEM TABLE",m.lcSQLAlias)

		If m.lnSQL > 0
			SQLDisconnect(m.lnSQL)
		Endif

		If m.lnResult < 0
			Aerror(m.laErr)
			Error m.laErr[2]
		Endif

		If Used(m.lcSQLAlias)
			Try
				If tlAllTables
					Select Cast(Alltrim(table_name) As V(100)), ;
						CAST(Alltrim(table_type) As V(12)) ;
						FROM (m.lcSQLAlias) ;
						INTO Array taArray
				Else
					Select Cast(Alltrim(table_name) As V(100)), ;
						CAST(Alltrim(table_type) As V(12)) ;
						FROM (m.lcSQLAlias) ;
						WHERE table_type = "SYSTEM TABLE" ;
						INTO Array taArray
				Endif
				m.lnReturn = _Tally
			Catch To m.loExc
				Throw
			Finally

			Endtry
		Endif

		Return m.lnReturn

	Endfunc

Enddefine