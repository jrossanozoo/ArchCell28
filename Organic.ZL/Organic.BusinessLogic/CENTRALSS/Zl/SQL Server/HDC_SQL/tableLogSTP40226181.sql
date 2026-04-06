USE [ZL]
GO

/****** Object:  Table [dbo].[logEnvioClavesProductos]    Script Date: 01/02/2013 12:38:41 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[logEnvioClavesProductos]') AND type in (N'U'))
DROP TABLE [dbo].[logEnvioClavesProductos]
GO

USE [ZL]
GO

/****** Object:  Table [dbo].[logEnvioClavesProductos]    Script Date: 01/02/2013 12:38:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[logEnvioClavesProductos](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[accion] [varchar](100) NULL,
	[serie] [varchar](50) NULL,
	[destino] [varchar](100) NULL,
	[fecha] [datetime] NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


