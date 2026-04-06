IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[Spu_DefragmentarPrecios]') AND type in (N'P'))
DROP PROCEDURE [Funciones].[Spu_DefragmentarPrecios]
GO;

CREATE PROCEDURE [Funciones].[Spu_DefragmentarPrecios]
	@Tope int = 10000
	as
	begin
		SET NOCOUNT OFF
		DELETE TOP (@Tope) precios
		FROM [ZL].[PRECIOAR] precios
		WHERE precios.PDIRECTO IN( SELECT TOP 1 PDIRECTO
			FROM [ZL].[PRECIOAR] subp
			WHERE
				subp.ARTICULO = precios.ARTICULO
				AND subp.LISTAPRE = precios.LISTAPRE
				AND subp.FECHAVIG <= precios.FECHAVIG
				AND IIF( subp.FECHAVIG = precios.FECHAVIG, precios.TIMESTAMPA-subp.TIMESTAMPA, 0 ) >= 0
				AND subp.CODIGO != precios.CODIGO
			ORDER BY subp.FECHAVIG DESC
		)
		AND precios.FECHAVIG < CONVERT(date, getdate())
		SELECT @@ROWCOUNT as cantidad
	end

GO;
