IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Listados].[Per_138_CTACTE]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Listados].[Per_138_CTACTE];
GO;

CREATE FUNCTION [Listados].[Per_138_CTACTE]
( @BaseDeDatos varchar(8),
	@CTACTE_CODIGOCOMPROBANTE_DESDE varchar(38),
	@CTACTE_CODIGOCOMPROBANTE_HASTA varchar(38),
	@CTACTE_TIPODECOMPROBANTE_DESDE int,
	@CTACTE_TIPODECOMPROBANTE_HASTA int,
	@CTACTE_FECHA_DESDE datetime,
	@CTACTE_FECHA_HASTA datetime,
	@CTACTE_FECHAVENCIMIENTO_DESDE datetime,
	@CTACTE_FECHAVENCIMIENTO_HASTA datetime,
	@CTACTE_CLIENTE_DESDE varchar(10),
	@CTACTE_CLIENTE_HASTA varchar(10),
	@CLIENTE_NOMBRE_DESDE varchar(30),
	@CLIENTE_NOMBRE_HASTA varchar(30),
	@CTACTE_MONEDA_DESDE varchar(10),
	@CTACTE_MONEDA_HASTA varchar(10),
	@CTACTE_VENDEDOR_DESDE varchar(10),
	@CTACTE_VENDEDOR_HASTA varchar(10),
	@VENDEDOR_NOMBRE_DESDE varchar(20),
	@VENDEDOR_NOMBRE_HASTA varchar(20),
	@MONEDA_MONEDA_DESCRIPCION_DESDE varchar(40),
	@MONEDA_MONEDA_DESCRIPCION_HASTA varchar(40) )
RETURNS TABLE
AS
RETURN
(
select cast( funciones.padr( @basededatos, 8, ' ' ) + funciones.padr( c_ctacte.codigo, 38, ' ' ) as varchar( 46 ) ) as CTACTE__Grupo,
	@basededatos as CTACTE__BD,
	C_CLIENTE.CLCOD as CLIENTE_CLCOD,
	C_FACTURA.FVEN as FACTURA_FVEN,
	C_RECIBO.FVEN as RECIBO_FVEN,
	c_CTACTE.CLIENTE as CTACTE_CLIENTE,
	c_CTACTE.CODIGO as CTACTE_CODIGO,
	c_CTACTE.TOTALCC as CTACTE_TOTALCC,
	C_CLIENTE.CLNOM as CLIENTE_CLNOM,
	cast( funciones.obtenercodigovendedor(c_ctacte.tipocomp , c_recibo.fven , c_factura.fven) as varchar( 10 ) ) as CTACTE_VENDEDOR,
	c_CTACTE.SIGNO as CTACTE_SIGNO,
	case when c_ctacte.fecha = '01/01/1900 00:00:00' then null else c_ctacte.fecha end as CTACTE_FECHA,
	case when c_ctacte.fechaven = '01/01/1900 00:00:00' then null else c_ctacte.fechaven end as CTACTE_FECHAVEN,
	c_CTACTE.COMPROB as CTACTE_COMPROB,
	c_CTACTE.MONEDA as CTACTE_MONEDA,
	cast( case when c_ctacte.signo> 0 then   c_ctacte.totalcc else  0 end as numeric( 15, 2 ) ) as CTACTE_DEBE,
	cast( case when c_ctacte.signo< 0 then   c_ctacte.totalcc else  0 end as numeric( 15, 2 ) ) as CTACTE_HABER,
	c_CTACTE.SALDOCC as CTACTE_SALDOCC,
	C_CLIENTE.CLTLF as CLIENTE_CLTLF,
	cast( 0 as numeric( 15, 2 ) ) as CTACTE_SALDOTOTAL,
	c_CTACTE.CODCOMP as CTACTE_CODCOMP,
	c_CTACTE.TIPOCOMP as CTACTE_TIPOCOMP,
	c_CTACTE.VALOR as CTACTE_VALOR,
	C_VENDEDOR.CLNOM as VENDEDOR1016_CLNOM,
	c_CTACTE.LETRA as CTACTE_LETRA,
	c_CTACTE.PTOVTA as CTACTE_PTOVTA,
	c_CTACTE.NUMERO as CTACTE_NUMERO,
	cast( Funciones.IdentificadorDeComprobanteParaListado(c_ctacte.tipocomp, c_ctacte.letra, c_ctacte.ptovta, c_ctacte.numero) as varchar( 20 ) ) as CTACTE_COMPCORTOVIRTUAL,
	C_MONEDA.DESCRIP as MONEDA_DESCRIP,
	C_VALOR.CLNOM as VALOR_CLNOM,
	C_FACTURA.CODIGO as FACTURA_CODIGO,
	C_MONEDA.CODIGO as MONEDA_CODIGO,
	C_RECIBO.CODIGO as RECIBO_CODIGO,
	C_VALOR.CLCOD as VALOR_CLCOD,
	C_VENDEDOR.CLCOD as VENDEDOR1016_CLCOD
 from ZooLogic.CTACTE as c_CTACTE
 left join ZooLogic.CLI as C_CLIENTE on C_CLIENTE.CLCOD = c_CTACTE.CLIENTE and 0 = Funciones.empty( c_CTACTE.CLIENTE )
 left join ZooLogic.COMPROBANTEV as C_FACTURA on C_FACTURA.CODIGO = c_CTACTE.CODCOMP and 0 = Funciones.empty( c_CTACTE.CODCOMP )
 left join ZooLogic.MONEDA as C_MONEDA on C_MONEDA.CODIGO = c_CTACTE.MONEDA and 0 = Funciones.empty( c_CTACTE.MONEDA )
 left join ZooLogic.RECIBO as C_RECIBO on C_RECIBO.CODIGO = c_CTACTE.CODCOMP and 0 = Funciones.empty( c_CTACTE.CODCOMP )
 left join ZooLogic.XVAL as C_VALOR on C_VALOR.CLCOD = c_CTACTE.VALOR and 0 = Funciones.empty( c_CTACTE.VALOR )
 left join ZooLogic.VEN as C_VENDEDOR on C_VENDEDOR.CLCOD = isnull( cast( funciones.obtenercodigovendedor(c_ctacte.tipocomp , c_recibo.fven , c_factura.fven) as varchar( 10 ) ) , '' ) and 0 = isnull( Funciones.empty( cast( funciones.obtenercodigovendedor(c_ctacte.tipocomp , c_recibo.fven , c_factura.fven) as varchar( 10 ) ) ),'')
 where ( not 1 = funciones.empty( c_ctacte.codigo ) ) and 
	( ( @CTACTE_CODIGOCOMPROBANTE_DESDE is null ) OR ( c_CTACTE.CodComp >= @CTACTE_CODIGOCOMPROBANTE_DESDE ) ) and 
	( ( @CTACTE_CODIGOCOMPROBANTE_HASTA is null ) OR ( c_CTACTE.CodComp <= @CTACTE_CODIGOCOMPROBANTE_HASTA ) ) and 
	( ( @CTACTE_TIPODECOMPROBANTE_DESDE is null ) OR ( c_CTACTE.TipoComp >= @CTACTE_TIPODECOMPROBANTE_DESDE ) ) and 
	( ( @CTACTE_TIPODECOMPROBANTE_HASTA is null ) OR ( c_CTACTE.TipoComp <= @CTACTE_TIPODECOMPROBANTE_HASTA ) ) and 
	( ( @CTACTE_FECHA_DESDE is null ) OR ( c_CTACTE.Fecha >= @CTACTE_FECHA_DESDE ) ) and 
	( ( @CTACTE_FECHA_HASTA is null ) OR ( c_CTACTE.Fecha <= @CTACTE_FECHA_HASTA ) ) and 
	( ( @CTACTE_FECHAVENCIMIENTO_DESDE is null ) OR ( c_CTACTE.fechaven >= @CTACTE_FECHAVENCIMIENTO_DESDE ) ) and 
	( ( @CTACTE_FECHAVENCIMIENTO_HASTA is null ) OR ( c_CTACTE.fechaven <= @CTACTE_FECHAVENCIMIENTO_HASTA ) ) and 
	( ( @CTACTE_CLIENTE_DESDE is null ) OR ( c_CTACTE.Cliente >= @CTACTE_CLIENTE_DESDE ) ) and 
	( ( @CTACTE_CLIENTE_HASTA is null ) OR ( c_CTACTE.Cliente <= @CTACTE_CLIENTE_HASTA ) ) and 
	( ( @CLIENTE_NOMBRE_DESDE is null ) OR ( C_CLIENTE.CLNOM >= @CLIENTE_NOMBRE_DESDE ) ) and 
	( ( @CLIENTE_NOMBRE_HASTA is null ) OR ( C_CLIENTE.CLNOM <= @CLIENTE_NOMBRE_HASTA ) ) and 
	( ( @CTACTE_MONEDA_DESDE is null ) OR ( c_CTACTE.Moneda >= @CTACTE_MONEDA_DESDE ) ) and 
	( ( @CTACTE_MONEDA_HASTA is null ) OR ( c_CTACTE.Moneda <= @CTACTE_MONEDA_HASTA ) ) and 
	( ( @CTACTE_VENDEDOR_DESDE is null ) OR ( cast( funciones.obtenercodigovendedor(c_ctacte.tipocomp , c_recibo.fven , c_factura.fven) as varchar( 10 ) ) >= @CTACTE_VENDEDOR_DESDE ) ) and 
	( ( @CTACTE_VENDEDOR_HASTA is null ) OR ( cast( funciones.obtenercodigovendedor(c_ctacte.tipocomp , c_recibo.fven , c_factura.fven) as varchar( 10 ) ) <= @CTACTE_VENDEDOR_HASTA ) ) and 
	( ( @VENDEDOR_NOMBRE_DESDE is null ) OR ( isnull(C_VENDEDOR.CLNOM,'') >= @VENDEDOR_NOMBRE_DESDE ) ) and 
	( ( @VENDEDOR_NOMBRE_HASTA is null ) OR ( isnull(C_VENDEDOR.CLNOM,'') <= @VENDEDOR_NOMBRE_HASTA ) ) and 
	( ( @MONEDA_MONEDA_DESCRIPCION_DESDE is null ) OR ( C_MONEDA.Descrip >= @MONEDA_MONEDA_DESCRIPCION_DESDE ) ) and 
	( ( @MONEDA_MONEDA_DESCRIPCION_HASTA is null ) OR ( C_MONEDA.Descrip <= @MONEDA_MONEDA_DESCRIPCION_HASTA ) )
	

)