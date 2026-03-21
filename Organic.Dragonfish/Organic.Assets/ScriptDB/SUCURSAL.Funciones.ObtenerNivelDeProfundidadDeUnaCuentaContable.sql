IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerNivelDeProfundidadDeUnaCuentaContable]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[ObtenerNivelDeProfundidadDeUnaCuentaContable];
GO;

CREATE FUNCTION [Funciones].[ObtenerNivelDeProfundidadDeUnaCuentaContable]
	( 
	@CodigoDeCuentaContable char(30)
	)
RETURNS int
AS
BEGIN
	declare @retorno int;

	with NivelDeCuentaContable( Nivel, CuentaMayor, Cuenta) as  
	(
		select 0 as Nivel, CTAMAYOR, CTACODIGO from ZooLogic.PLANCUENTA where coalesce( CTAMAYOR, '' ) = ''
		union all
		select Padre.Nivel + 1, Hijo.CTAMAYOR, Hijo.CTACODIGO from NivelDeCuentaContable as Padre
		inner join ZooLogic.PLANCUENTA as Hijo on Padre.Cuenta = Hijo.CTAMAYOR
	)
	select @retorno = Nivel from NivelDeCuentaContable where Cuenta = @CodigoDeCuentaContable

	return cast( coalesce( @retorno, 0 ) as int)
END