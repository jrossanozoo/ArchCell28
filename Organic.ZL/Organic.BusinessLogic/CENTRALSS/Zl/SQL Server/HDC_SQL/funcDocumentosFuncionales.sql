USE [ZL]
GO

/****** Object:  UserDefinedFunction [ZL].[funcDocumentosFuncionales]    Script Date: 08/27/2013 10:27:29 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[funcDocumentosFuncionales]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [ZL].[funcDocumentosFuncionales]
GO

USE [ZL]
GO

/****** Object:  UserDefinedFunction [ZL].[funcDocumentosFuncionales]    Script Date: 08/27/2013 10:27:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- ==============================================
-- Author:		Daniel Correa
-- Create date: 27/08/2013
-- Description:	Devuelve datos sobre uno o varios
--              documentos funcionales
-- ==============================================
CREATE FUNCTION [ZL].[funcDocumentosFuncionales]
(	@docfun as integer )
RETURNS TABLE 
AS
RETURN 
(
	with 
		legajoalta as (
			select
				ccod
				, ccortesia
			from
				 zl.legops
		)
		, legajomodi as (
			select
				ccod
				, ccortesia
			from
				 zl.legops
		)
		, Estados as (
		select
			codin
			, dfest
			, dfestdes
			, fmodifw
			, docfun
			, regpor
			, umodifw
		from 
			zl.AsEsDocFun          
		)
		, allestados as (
			select 
				codigo, 
				rtrim(descr) as Estado 
			from 
				zl.DFEst   
			union all
			select 
				0 as codigo
				, 'Sin Estado' as Estado
		)
		, tiposdoc as (
			select 
				codigo
				, ltrim(rtrim(convert(varchar(max), descr))) as descr 
			from 
				ZL.TIPODOC
		)
		, afus as (
			select 
				distinct
				zl.DFAsis.codigo
				, Asistentes.Legajos
			FROM
				zl.DFAsis
				left join (	Select 
								afus.codigo 
								, (select LTRIM(RTRIM(zl.DFAsis.Legajo )) + ', ' From zl.DFAsis where zl.DFAsis.codigo = afus.codigo and LTRIM(RTRIM(zl.DFAsis.Legajo)) <> '' FOR XML PATH('')) as Legajos 
							from 
								zl.DFAsis as afus
							group by codigo
							) as Asistentes on Asistentes.codigo = zl.DFAsis.codigo

		)
	select
		docfun.codigo as DOCCOD
		, ltrim(rtrim(docfun.docurl)) AS DOCURL
		, docfun.fmodifw AS DOCMODIF
		, docfun.hmodifw AS DOCHORA
		, docfun.regpor AS DOCREGPOR
		, ltrim(rtrim(CONVERT(VARCHAR(250), docfun.titulo))) AS DOCTITULO
		, docfun.umodifw AS DOCOPE
		, docfun.tipodoc AS DOCTIPO
		, legajoalta.ccortesia as DOCOPEALTA
		, legajomodi.ccortesia as DOCNOMBALTA
		, Estados.codin AS ESTDOCNUM
		, estados.dfest AS ESTDOCCODEST
		, allestados.Estado AS ESTDOCDESCEST
		, estados.fmodifw AS ESTDOCFECHA
		, estados.regpor AS ESTDOCREGPOR
		, estados.umodifw AS ESTDOCOPE
		, requerimientos.*
		, tipodoc.descr
		, ltrim(rtrim(convert(varcHar(max), docfun.analobs))) as OBS
		, afus.legajos
	from
		zl.dfun as docfun
		cross apply zl.[funcDetalleDeRequerimientosDeDocumentosFuncionales](docfun.codigo) as requerimientos
		left join Estados on Estados.docfun = docfun.codigo
		left join legajoalta on legajoalta.ccod = docfun.umodifw
		left join legajomodi on legajomodi.ccod = docfun.regpor
		left join allestados on allestados.codigo = estados.dfest
		left join tipodoc on tipodoc.codigo = docfun.tipodoc
		left join afus on afus.codigo = docfun.codigo
	where
		docfun.codigo = @docfun
)

GO

--SELECT * FROM ZL.funcDocumentosFuncionales(317)
