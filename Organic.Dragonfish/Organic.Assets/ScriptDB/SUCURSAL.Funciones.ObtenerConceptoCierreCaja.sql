IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Funciones].[ObtenerConceptoCierreCaja]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [Funciones].[ObtenerConceptoCierreCaja];
GO;
SET ANSI_NULLS ON
GO;
SET QUOTED_IDENTIFIER ON
GO;
CREATE FUNCTION [Funciones].[ObtenerConceptoCierreCaja]()
RETURNS varchar(254)
AS 
	begin
		Declare @cRetorno varchar(254)
		Set @cRetorno = (select top 1 Funciones.Alltrim( p.valor ) from Parametros.Puesto p where p.IDUNICO = '1E2A988161335714B0F1917010698007638759')
		--goParametros.Felino.GestionDeVentas.ConceptoSugeridoParaElCierreDeCaja

		return case when Funciones.empty(@cRetorno) = 1 then 'CIERRE' else @cRetorno end		
	End
 
