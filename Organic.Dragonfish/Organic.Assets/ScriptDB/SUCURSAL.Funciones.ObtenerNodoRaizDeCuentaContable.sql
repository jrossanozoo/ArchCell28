IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerNodoRaizDeCuentaContable]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[ObtenerNodoRaizDeCuentaContable];
GO;

CREATE FUNCTION [Funciones].[ObtenerNodoRaizDeCuentaContable]
	( 
	@CodigoDeCuentaContable char(30)
	)
RETURNS varchar(30)
AS
BEGIN
	declare @retorno varchar(30);

	with NodoDeCuentaContable( Descripcion, CuentaMayor, CuentaInicial) as  
	(
		select DESCRIP, CTAMAYOR, CTACODIGO from ZooLogic.PLANCUENTA  where CTAIMPUT = 1
		union all
		select Padre.DESCRIP, Padre.CTAMAYOR, Hijo.CuentaInicial from NodoDeCuentaContable as Hijo
		inner join ZooLogic.PLANCUENTA as Padre on Hijo.CuentaMayor = Padre.CTACODIGO
	)
	select @retorno = Descripcion from NodoDeCuentaContable 
	where CuentaMayor = '' 
		and CuentaInicial = @CodigoDeCuentaContable

	return cast( coalesce( @retorno, @CodigoDeCuentaContable ) as varchar(30))
END