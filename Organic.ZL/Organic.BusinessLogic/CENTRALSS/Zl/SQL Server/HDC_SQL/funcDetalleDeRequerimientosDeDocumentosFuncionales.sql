USE [ZL]
GO

/****** Object:  UserDefinedFunction [ZL].[funcDetalleDeRequerimientosDeDocumentosFuncionales]    Script Date: 08/28/2013 15:24:14 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ZL].[funcDetalleDeRequerimientosDeDocumentosFuncionales]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [ZL].[funcDetalleDeRequerimientosDeDocumentosFuncionales]
GO

USE [ZL]
GO

/****** Object:  UserDefinedFunction [ZL].[funcDetalleDeRequerimientosDeDocumentosFuncionales]    Script Date: 08/28/2013 15:24:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Héctor Daniel Correa
-- Create date: 28/08/2013
-- Description:	Retorna
-- =============================================
CREATE FUNCTION [ZL].[funcDetalleDeRequerimientosDeDocumentosFuncionales]
(
	@docfun as integer
)
RETURNS TABLE 
AS
RETURN 
(
		with docfunreq as (
			select
				zl.AsDocaReq.docfun
				, zl.AsDocaReq.func
				, zl.AsDocaReq.bug
				, zl.AsDocaReq.incid
				, zl.AsDocaReq.issues
				, zl.AsDocaReq.iydreq
				, zl.AsDocaReq.ssi
				, zl.AsDocaReq.pncereq
				, zl.AsDocaReq.req
			from
				zl.AsDocaReq
			where
				case 
					when @docfun = 0 then zl.AsDocaReq.docfun
					else @docfun
				end = zl.AsDocaReq.docfun
			)
		, productos as (
			select
				ccod
				, descr
			from
				zl.prodzl
			)
		, clientes as (
			select
				cmpcodigo
				, cmpnombre
			from
				zl.clientes
			)
		select 
			'Funcionalidad' as tipo
			, codigo as numero
			, ltrim(rtrim(convert(varchar(max),nombre))) as descripcion
			, faltafw as fecha
			, regpor as regpor
			, 0 as cliente
			, '' as nomcliente
			, 0 as codproducto
			, '' as producto
			, docfunreq.docfun as Doc
		from 
			zl.fcomer
			inner join docfunreq on docfunreq.func = zl.fcomer.codigo
		union all
		select
			'Requerimiento de cliente'
			, codin
			, ltrim(rtrim(convert(varchar(max),asunto)))
			, faltafw
			, regpor
			, ccliente
			, clientes.cmpnombre
			, cpcod
			, productos.descr
			, docfunreq.docfun as Doc
		from 
			zl.pncereq
			inner join docfunreq on docfunreq.pncereq = zl.pncereq.codin
			left join productos on productos.ccod = zl.pncereq.cpcod
			left join clientes on clientes.cmpcodigo = zl.pncereq.ccliente
		union all
		select
			'Incidente'
			, codin
			, ltrim(rtrim(convert(varchar(max),cmpconsult)))
			, faltafw
			, regpor
			, ccliente
			, clientes.cmpnombre
			, cprod
			, productos.descr
			, docfunreq.docfun as Doc
		from 
			ZL.Incids
			inner join docfunreq on docfunreq.incid = zl.Incids.codin
			left join productos on productos.ccod = zl.Incids.cprod
			left join clientes on clientes.cmpcodigo = zl.Incids.ccliente
		where
			zl.incids.codin <> 0
		union all
		select
			'Issue'
			, codin
			, ltrim(rtrim(convert(varchar(max),titulo)))
			, faltafw
			, regpor
			, ''
			, ''
			, codprod
			, productos.descr
			, docfunreq.docfun as Doc
		from 
			ZL.REGISSU
			inner join docfunreq on docfunreq.issues = ZL.REGISSU.codin
			left join productos on productos.ccod = zl.REGISSU.codprod
		union all
		select
			'Requerimiento I+D'
			, codigo
			, ltrim(rtrim(convert(varchar(max),titulo)))
			, faltafw
			, regpor
			, ''
			, ''
			, 0
			, ''
			, docfunreq.docfun as Doc
		from 
			ZL.requer
			inner join docfunreq on docfunreq.iydreq = ZL.requer.codigo
		union all
		select
			'Bug'
			, codin
			, ltrim(rtrim(convert(varchar(max),titulo)))
			, faltafw
			, regpor
			, ''
			, ''
			, codprod
			, productos.descr
			, docfunreq.docfun as Doc
		from 
			ZL.regbug
			inner join docfunreq on docfunreq.bug = ZL.regbug.codin
			left join productos on productos.ccod = zl.regbug.codprod
		union all
		select
			'Solicitud de servicio'
			, numero
			, ltrim(rtrim(convert(varchar(max),descr)))
			, fechai
			, regpor
			, ''
			, ''
			, 0
			, ltrim(rtrim(zl.tipsse.[des]))
			, docfunreq.docfun as Doc
		from 
			ZL.solserv
			inner join docfunreq on docfunreq.ssi = ZL.solserv.numero
			left join zl.tipsse on zl.tipsse.cod = ZL.solserv.ctipo
)

GO
