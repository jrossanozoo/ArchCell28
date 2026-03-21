Define Class ColaboradorProduccion As ZooSession Of ZooSession.prg
 
	#If .F.
		Local This As ColaboradorProduccion As ColaboradorProduccion.prg
	#Endif
	
	oCurvaDeProduccion = null

*!*		*-------------------------------------------------------------------
*!*		Function SeteosPrivados() as VOID 
*!*			dodefault()
*!*			set textmerge on
*!*		Endfunc

	*--------------------------------------------------------------------------------------------------------
	function oCurvaDeProduccion_Access() as variant
		if this.ldestroy
		else
			if !vartype( this.oCurvaDeProduccion ) = 'O' or isnull( this.oCurvaDeProduccion )
				this.oCurvaDeProduccion = _Screen.zoo.InstanciarEntidad( 'CurvaDeProduccion' )
			endif
		endif
		return this.oCurvaDeProduccion
	endfunc

	*-----------------------------------------------------------------------------------------
	Function ObtenerComboParaAtributo( tcNombreAtributo) as Collection
		local loRetorno as Collection
		loRetorno = _Screen.Zoo.CrearObjeto( "zooColeccion", "zooColeccion.prg")
		do case
		case lower(tcNombreAtributo) = "comportamientoinsumo"
			loRetorno = this.ObtenerComboInsumoComportamiento()
		case lower(tcNombreAtributo) = "tipotaller"
			loRetorno = this.ObtenerComboTipoTaller()
		case lower(tcNombreAtributo) = "tipomaquinaria"
			loRetorno = this.ObtenerComboTipoMaquinaria()
		case lower(tcNombreAtributo) = "unidaddetiempo"
			loRetorno = this.ObtenerComboUnidadDeTiempo()
		case lower(tcNombreAtributo) = "tipodeproduccion"
			loRetorno = this.ObtenerComboTipoDeProduccion()
		case lower(tcNombreAtributo) = "insumoenliquidacion"
			loRetorno = this.ObtenerComboInsumoEnLiquidacion()
		case lower(tcNombreAtributo) = "descarteenliquidacion"
			loRetorno = this.ObtenerComboDescarteEnLiquidacion()
		endcase
		return loRetorno
	EndFunc 

	*-----------------------------------------------------------------------------------------
	protected Function ObtenerComboInsumoComportamiento() as Collection
		local loRetorno as Collection, loItem as Object
		loRetorno = _Screen.Zoo.CrearObjeto( "zooColeccion", "zooColeccion.prg")
		loItem = _Screen.Zoo.CrearObjeto( "ItemComboXML", "ColaboradorProduccion.prg")
		loItem.Codigo = '7'
		loItem.Descripcion = "Insumo"
		loItem.Orden = '1'
		loRetorno.Agregar( loItem, loItem.Codigo )
		loItem = null
		loItem = _Screen.Zoo.CrearObjeto( "ItemComboXML", "ColaboradorProduccion.prg")
		loItem.Codigo = '8'
		loItem.Descripcion = "Insumo Pieza"
		loItem.Orden = '2'
		loRetorno.Agregar( loItem, loItem.Codigo )
		loItem = null
		loItem = _Screen.Zoo.CrearObjeto( "ItemComboXML", "ColaboradorProduccion.prg")
		loItem.Codigo = '9'
		loItem.Descripcion = "Semielaborado"
		loItem.Orden = '3'
		loRetorno.Agregar( loItem, loItem.Codigo )
		return loRetorno
	EndFunc 

	*-----------------------------------------------------------------------------------------
	protected Function ObtenerComboTipoTaller() as Collection
		local loRetorno as Collection, loItem as Object
		loRetorno = _Screen.Zoo.CrearObjeto( "zooColeccion", "zooColeccion.prg")
		loItem = _Screen.Zoo.CrearObjeto( "ItemComboXML", "ColaboradorProduccion.prg")
		loItem.Codigo = '1'
		loItem.Descripcion = "Interno"
		loItem.Orden = '1'
		loRetorno.Agregar( loItem, loItem.Codigo )
		loItem = null
		loItem = _Screen.Zoo.CrearObjeto( "ItemComboXML", "ColaboradorProduccion.prg")
		loItem.Codigo = '2'
		loItem.Descripcion = "Externo"
		loItem.Orden = '2'
		loRetorno.Agregar( loItem, loItem.Codigo )
		return loRetorno
	EndFunc 

	*-----------------------------------------------------------------------------------------
	protected Function ObtenerComboTipoMaquinaria() as Collection
		local loRetorno as Collection, loItem as Object
		loRetorno = _Screen.Zoo.CrearObjeto( "zooColeccion", "zooColeccion.prg")
		loItem = _Screen.Zoo.CrearObjeto( "ItemComboXML", "ColaboradorProduccion.prg")
		loItem.Codigo = '1'
		loItem.Descripcion = "Maquinaria"
		loItem.Orden = '1'
		loRetorno.Agregar( loItem, loItem.Codigo )
		loItem = null
		loItem = _Screen.Zoo.CrearObjeto( "ItemComboXML", "ColaboradorProduccion.prg")
		loItem.Codigo = '2'
		loItem.Descripcion = "Mano de obra"
		loItem.Orden = '2'
		loRetorno.Agregar( loItem, loItem.Codigo )
		return loRetorno
	EndFunc 

	*-----------------------------------------------------------------------------------------
	protected Function ObtenerComboUnidadDeTiempo() as Collection
		local loRetorno as Collection, loItem as Object
		loRetorno = _Screen.Zoo.CrearObjeto( "zooColeccion", "zooColeccion.prg")
		loItem = _Screen.Zoo.CrearObjeto( "ItemComboXML", "ColaboradorProduccion.prg")
		loItem.Codigo = '1'
		loItem.Descripcion = "Segundo"
		loItem.Orden = '1'
		loRetorno.Agregar( loItem, loItem.Codigo )
		loItem = null
		loItem = _Screen.Zoo.CrearObjeto( "ItemComboXML", "ColaboradorProduccion.prg")
		loItem.Codigo = '2'
		loItem.Descripcion = "Minuto"
		loItem.Orden = '2'
		loRetorno.Agregar( loItem, loItem.Codigo )
		loItem = null
		loItem = _Screen.Zoo.CrearObjeto( "ItemComboXML", "ColaboradorProduccion.prg")
		loItem.Codigo = '3'
		loItem.Descripcion = "Hora"
		loItem.Orden = '3'
		loRetorno.Agregar( loItem, loItem.Codigo )
		loItem = null
		loItem = _Screen.Zoo.CrearObjeto( "ItemComboXML", "ColaboradorProduccion.prg")
		loItem.Codigo = '4'
		loItem.Descripcion = "Día"
		loItem.Orden = '4'
		loRetorno.Agregar( loItem, loItem.Codigo )
		return loRetorno
	EndFunc 

	*-----------------------------------------------------------------------------------------
	protected Function ObtenerComboTipoDeProduccion() as Collection
		local loRetorno as Collection, loItem as Object
		loRetorno = _Screen.Zoo.CrearObjeto( "zooColeccion", "zooColeccion.prg")
		loItem = _Screen.Zoo.CrearObjeto( "ItemComboXML", "ColaboradorProduccion.prg")
		loItem.Codigo = '1'
		loItem.Descripcion = "Manual"
		loItem.Orden = '1'
		loRetorno.Agregar( loItem, loItem.Codigo )
		loItem = _Screen.Zoo.CrearObjeto( "ItemComboXML", "ColaboradorProduccion.prg")
		loItem.Codigo = '2'
		loItem.Descripcion = "Automática"
		loItem.Orden = '2'
		loRetorno.Agregar( loItem, loItem.Codigo )
		return loRetorno
	EndFunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerComboInsumoEnLiquidacion() as Collection
		local loRetorno as Collection, loItem as Object
		loRetorno = _Screen.Zoo.CrearObjeto( "zooColeccion", "zooColeccion.prg")
		loItem = _Screen.Zoo.CrearObjeto( "ItemComboXML", "ColaboradorProduccion.prg")
		loItem.Codigo = '0'
		loItem.Descripcion = space(30)
		loItem.Orden = '1'
		loRetorno.Agregar( loItem, loItem.Codigo )
		loItem = _Screen.Zoo.CrearObjeto( "ItemComboXML", "ColaboradorProduccion.prg")
		loItem.Codigo = '1'
		loItem.Descripcion = "Incluir en la liquidación"
		loItem.Orden = '2'
		loRetorno.Agregar( loItem, loItem.Codigo )
		loItem = _Screen.Zoo.CrearObjeto( "ItemComboXML", "ColaboradorProduccion.prg")
		loItem.Codigo = '2'
		loItem.Descripcion = "No incluir en la liquidación"
		loItem.Orden = '3'
		loRetorno.Agregar( loItem, loItem.Codigo )
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	protected function ObtenerComboDescarteEnLiquidacion() as Collection
		local loRetorno as Collection, loItem as Object
		loRetorno = _Screen.Zoo.CrearObjeto( "zooColeccion", "zooColeccion.prg")
		loItem = _Screen.Zoo.CrearObjeto( "ItemComboXML", "ColaboradorProduccion.prg")
		loItem.Codigo = '0'
		loItem.Descripcion = space(30)
		loItem.Orden = '1'
		loRetorno.Agregar( loItem, loItem.Codigo )
		loItem = _Screen.Zoo.CrearObjeto( "ItemComboXML", "ColaboradorProduccion.prg")
		loItem.Codigo = '1'
		loItem.Descripcion = "Incluir en la liquidación"
		loItem.Orden = '2'
		loRetorno.Agregar( loItem, loItem.Codigo )
		loItem = _Screen.Zoo.CrearObjeto( "ItemComboXML", "ColaboradorProduccion.prg")
		loItem.Codigo = '2'
		loItem.Descripcion = "No incluir en la liquidación"
		loItem.Orden = '3'
		loRetorno.Agregar( loItem, loItem.Codigo )
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerInformacionDeCombinacionesFueraDeCurva( toInformacion as ZooInformacion of zooInformacion.prg, tcCurva as String, toDetalle as detalle OF detalle.prg, tcVariantePrincipal as String, tcVarianteSecundaria as String) as Collection
		local loRetorno as zooInformacion of zooInformacion.prg, loCurva as Object, loComb as Object
		loRetorno = iif(vartype(toInformacion) = 'O' and lower(toInformacion.class)='zooinformacion',toInformacion,_Screen.zoo.crearobjeto( "zooInformacion" ))
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	Protected function esDetalleDeProduccionConCurva(toDetalle as detalle OF detalle.prg) as Boolean
		local llRetorno
		llRetorno = vartype( toDetalle ) = 'O' and !isnull( toDetalle ) and ;
				pemstatus( toDetalle , 'esDetalleEnProduccion', 5 ) and pemstatus( toDetalle , 'esDetalleConCurvaDeProduccion', 5 ) ;
				and toDetalle.esDetalleEnProduccion and toDetalle.esDetalleConCurvaDeProduccion
		return llRetorno
	EndFunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerCurvaDeProduccion( tcCurvaDeProduccion as String ) as Collection
		local loRetorno as Collection, loCurva as Object, loItem As Object
		loRetorno = _Screen.Zoo.CrearObjeto('zooColeccion', 'zooColeccion.prg')
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function ObtenerModeloDeProduccion( tcModelo as String ) as Object
		local loRetorno as Object
		loRetorno = _Screen.Zoo.InstanciarEntidad( "ModeloDeProduccion" )
		if vartype( 'tcModelo' ) = 'C' and !empty( tcModelo )
			try
				loRetorno.Codigo = tcModelo
			catch
			endtry
		endif
		return loRetorno
	endfunc 

	*-----------------------------------------------------------------------------------------
	function EsComodinEnVariantePricinpal( tcVariante as String ) as Boolean
		local llRetorno as Boolean
		llRetorno = .f.
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function EsComodinEnVarianteSecundaria( tcVariante as String ) as Void
		local llRetorno as Boolean
		llRetorno = .f.
		return llRetorno
	endfunc

	*-----------------------------------------------------------------------------------------
	function ValidarTallerParaLiquidacion( tcTaller as String, tcProceso as String, toInformacion as Collection ) as Collection
		return .t.
	endfunc 

enddefine

*-----------------------------------------------------------------------------------------
*-----------------------------------------------------------------------------------------
Define Class ItemComboXML as Custom
	Codigo = ''
	Descripcion = ""
	Orden = ''
EndDefine

*-----------------------------------------------------------------------------------------
Define Class ItemCurvaXML as Custom
	VariantePrincipal = ''
	VarianteSecundaria = ""
	Cantidad = 0
EndDefine

