IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Contabilidad].[CMV_ObtenerStockYPrecioInicialesEnAperturaEjercicio]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP function [Contabilidad].[CMV_ObtenerStockYPrecioInicialesEnAperturaEjercicio];
GO;

CREATE FUNCTION [Contabilidad].[CMV_ObtenerStockYPrecioInicialesEnAperturaEjercicio]
(
	@EjercicioAnterior numeric(8,0)
)
RETURNS TABLE
AS
RETURN
(
	/* Busco los registros para agregar a la tabla CMVFACCOMPRA con los stocks iniciales al realizar la apertura del siguiente ejercicio */
	
	SELECT BASE as BD, CODCOMP as CompCodigo, FACTTIPO as CompTipo, FARTICULO as Articulo, FCOLOR as Color, FTALLE as Talle, FDESC as Descrip, FFECHA as Fecha, 
		FNUMINT as NumInt, FLETRA as Letra, FPTOVENEX as PtoVenExt, FNUMCOMP as NumComp, FPTOVEN as PtoVen, FSTOCK as Cantidad, FPRECIO as CostoUnitario
	FROM [ZooLogic].[CMVFACCOMPRA] as CMV
	WHERE EJERCICIO = @EjercicioAnterior and FSTOCK <> 0

)
