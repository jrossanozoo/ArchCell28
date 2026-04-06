USE [ZL]
GO

/****** Object:  UserDefinedFunction [ZL].[AdmEstadoRS]    Script Date: 12/29/2009 17:03:24 ******/
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[AdmEstadoRS]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
	EXECUTE ('CREATE function [ZL].[AdmEstadoRS] ( ) returns table as return select '''' AS cestado,'''' as [Estado RS Descripción],'''' as [Código Foto Zoo Logic],0 as [Facturable],0 as [Dar Código],0 as [Obtener Servicio MDA],''19000101'' AS fecha')

END

GO

USE [ZL]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER function [ZL].[AdmEstadoRS] ( ) returns table as return


select zl.ASESTRZAD.nrz
                             ,zl.ASESTRZAD.cestado
                             ,ZL.Funciones.Alltrim(zl.Estado.Nombre) as [Estado RS Descripción]
                             ,zl.Estado.Codfz as [Código Foto Zoo Logic]
                             ,zl.Estado.Inclfac as [Facturable]
                             ,case when IsNull(Ltrim(rtrim(zl.Estado.fRAENT)),'')='' then 0 else 1 end as [Dar Código]
                             ,zl.Estado.Observmda as [Obtener Servicio MDA]
                             ,zl.ASESTRZAD.fecha
          from zl.ASESTRZAD  
                  inner join 
                             /*se cruza con los últimos comprobantes de asignación de estado*/
                             (     select nrz as RS, max(numero) as ultimoComprobante   
                                   from zl.ASESTRZAD  
                                   group by nrz
                             ) as RsUltimoEstado
                             on zl.ASESTRZAD.numero = RsUltimoEstado.ultimoComprobante 
                          left join zl.Estado  on zl.ASESTRZAD.cestado =  zl.Estado.codigo

GO


