define class ColaboradorDeCostosDeProduccion as Session

	#If .F.
		Local This As ColaboradorDeCostosDeProduccion As ColaboradorDeCostosDeProduccion.prg
	#Endif

	nPonderadoTaller = 2
	nPonderadoProceso = 1
	nPonderadoColor = 3
	nPonderadoTalle = 4

	*-----------------------------------------------------------------------------------------
	function ObtenerSentenciaCostoPonderado( tcLista as String, tcInsumo as String, tcTaller as String, tcProceso as String, ;
														tcColor as String, tcTalle as String, tnCantidad as Number ) as String

		local lcRetorno as String, lcSentencia as String, lcLista as String, lcInsumo as String, lcTaller as String, lcProceso as String, lcColor as String, lcTalle as String

		lcLista = alltrim(tcLista)
		lcInsumo = alltrim(tcInsumo)
		lcTaller = alltrim(tcTaller)
		lcProceso = alltrim(tcProceso)
		lcColor = alltrim(tcColor)
		lcTalle = alltrim(tcTalle)
		lcCantidad = alltrim(str(tnCantidad))
		lcRetorno = "Select Funciones.ObtenerCostoDeInsumoPonderado('"
		lcRetorno = lcRetorno + lcLista + "','"
		lcRetorno = lcRetorno + lcInsumo + "','"
		lcRetorno = lcRetorno + tcProceso + "','"
		lcRetorno = lcRetorno + lcTaller + "','"
		lcRetorno = lcRetorno + lcColor + "','"
		lcRetorno = lcRetorno + lcTalle + "',"
		lcRetorno = lcRetorno + lcCantidad + ") as cdirecto"

		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerSentenciaProductosDeGestionCotizados( tcGestion as String, tcLista as String, tcProceso as String, tcTaller as String ) as String
		local lcRetorno as String, lcLista as String, lcProceso as String, lcTaller as String
		lcLista = alltrim(tcLista)
		lcProceso = alltrim(tcProceso)
		lcTaller = alltrim(tcTaller)
		lcTextMerge = set("Textmerge")
		set textmerge on
		text to lcRetorno noshow
			Select Productos.GesProdCur Codigo, Productos.mArtDF Articulo, Productos.Insumo Insumo, Productos.CantProd CantidadProducida, 
				Productos.cColor ColorModelo, Productos.cTalle TalleModelo, Productos.codColor, Productos.codTalle, Productos.CantDesc, 
				Funciones.ObtenerCostoDeInsumoPonderado('<<lcLista>>',Productos.Insumo,'<<lcProceso>>','<<lcTaller>>',
				Productos.codColor,Productos.codTalle,Productos.CantProd) as costo, 
				Taller.Proveedor, Taller.ListaCosto, Taller.Insumos, Taller.Descartes
				from Zoologic.gespcurv Productos Left Join zoologic.gestionprod Gestion 
				on productos.GesProdCur = Gestion.Codigo
				left join Zoologic.Taller Taller ON Gestion.Taller = Taller.Codigo
				where Gestion.codigo = '<<tcGestion>>'
		endtext
		set textmerge &lcTextMerge
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerSentenciaDescartesDeGestionCotizados( tcGestion as String, tcLista as String, tcTaller as String, tcProceso as String ) as String
		local lcRetorno as String, lcLista as String, lcProceso as String, lcTaller as String
		lcLista = alltrim(tcLista)
		lcProceso = alltrim(tcProceso)
		lcTaller = alltrim(tcTaller)
		lcTextMerge = set("Textmerge")
		set textmerge on
		text to lcRetorno noshow
			Select Productos.GesProdDes Codigo, Productos.mArtDF Articulo, Productos.Insumo Insumo, Productos.CantDesc CantidadDescartada, 
				Productos.cColor ColorModelo, Productos.cTalle TalleModelo, Productos.codColor, Productos.codTalle,  
				Funciones.ObtenerCostoDeInsumoPonderado('<<lcLista>>',Productos.Insumo,'<<lcProceso>>','<<lcTaller>>',
				Productos.codColor, Productos.codTalle,Productos.CantDesc) as costo, 
				Taller.Proveedor, Taller.ListaCosto, Taller.Insumos, Taller.Descartes
				from Zoologic.gespdesc Productos Left Join zoologic.gestionprod Gestion 
				on productos.GesProdDes = Gestion.Codigo
				left join Zoologic.Taller Taller ON Gestion.Taller = Taller.Codigo
				where Gestion.codigo = '<<tcGestion>>'
		endtext
		set textmerge &lcTextMerge
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerSentenciaInsumosDeProductosDeGestionCotizados( tcGestion as String, tcLista as String, tcTaller as String, tcProceso as String ) as String
		local lcRetorno as String, lcLista as String, lcProceso as String, lcTaller as String
		lcLista = alltrim(tcLista)
		lcProceso = alltrim(tcProceso)
		lcTaller = alltrim(tcTaller)
		lcTextMerge = set("Textmerge")
		set textmerge on
		text to lcRetorno noshow
			Select Insumos.GesProdIns Codigo, Insumos.mArtDF Articulo, Insumos.Insumo Insumo, Insumos.Cantidad, 
				Insumos.cColor ColorModelo, Insumos.cTalle TalleModelo, Insumos.codColor, Insumos.codTalle, 
				Funciones.ObtenerCostoDeInsumoPonderado('<<lcLista>>',Insumos.Insumo,'<<lcProceso>>','<<lcTaller>>',
				Insumos.codColor,Insumos.codTalle,Insumos.Cantidad) as costo, 
				Taller.Proveedor, Taller.ListaCosto, Taller.Insumos, Taller.Descartes,
				Insumo.codArtLiqP ArticuloProduccion, Insumo.codArtLiqD ArticuloDescarte
				from Zoologic.gespins Insumos Left Join zoologic.gestionprod Gestion 
				on Insumos.GesProdIns = Gestion.Codigo
				left join Zoologic.Taller Taller ON Gestion.Taller = Taller.Codigo
				left join Zoologic.ins Insumo ON Insumos.mArtDF = Insumo.inscod
				where Gestion.codigo = '<<tcGestion>>'
		endtext
		set textmerge &lcTextMerge
		return lcRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerSentenciaInsumosDeDescartesDeGestionCotizados( tcGestion as String, tcLista as String, tcTaller as String, tcProceso as String ) as String
		local lcRetorno as String, lcLista as String, lcProceso as String, lcTaller as String
		lcLista = alltrim(tcLista)
		lcProceso = alltrim(tcProceso)
		lcTaller = alltrim(tcTaller)
		lcTextMerge = set("Textmerge")
		set textmerge on
		text to lcRetorno noshow
			Select Insumos.GesProdInd Codigo, Insumos.mArtDF Articulo, Insumos.Insumo Insumo, Insumos.Cantidad, 
				Insumos.cColor ColorModelo, Insumos.cTalle TalleModelo, Insumos.codColor, Insumos.codTalle, 
				Funciones.ObtenerCostoDeInsumoPonderado('<<lcLista>>',Insumos.Insumo,'<<lcProceso>>','<<lcTaller>>',
				Insumos.codColor,Insumos.codTalle,Insumos.Cantidad) as costo, 
				Taller.Proveedor, Taller.ListaCosto, Taller.Insumos, Taller.Descartes
				Insumo.codArtLiqP ArticuloProduccion, Insumo.codArtLiqD ArticuloDescarte
				from Zoologic.gespind Insumos Left Join zoologic.gestionprod Gestion 
				on Insumos.GesProdInd = Gestion.Codigo
				left join Zoologic.Taller Taller ON Gestion.Taller = Taller.Codigo
				left join Zoologic.ins Insumo ON Insumos.mArtDF = Insumo.inscod
				where Gestion.codigo = '<<tcGestion>>'
		endtext
		set textmerge &lcTextMerge
		return lcRetorno
	endfunc 

enddefine
