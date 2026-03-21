IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[EsLaUltimaReposicionALaFecha]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION [Funciones].[EsLaUltimaReposicionALaFecha];
GO;

CREATE FUNCTION [Funciones].[EsLaUltimaReposicionALaFecha]
( 
  @CodigoPk char(20),
  @CodigoArticulo char(15),
  @CodigoColor char(6), 
  @CodigoTalle char(5),
  @FechaParaVigencia datetime )

RETURNS bit
AS
BEGIN
	declare @Retorno bit = 0 ;


	if ( @FechaParaVigencia is null or @FechaParaVigencia = '' ) 
		set @FechaParaVigencia = GETDATE()


	select top 1 @retorno = case when c.Codigo = @CodigoPk then 1 else 0 end
	from ZOOLOGIC.minrepodet d
	inner join [ZooLogic].[MINREPO] c on c.CODIGO = d.CODIGO 
	where d.CODART = @CodigoArticulo  
		and ( (@CodigoColor is null) or (d.CODCOL = @CodigoColor) ) 
		and ( (@CodigoTalle is null) or (d.CODTAL = @CodigoTalle) ) 
		and c.FECHAVIG <= @FechaParaVigencia
	order by c.FECHAVIG desc ,
				c.TIMESTAMP desc

				 
	return @retorno

end
	