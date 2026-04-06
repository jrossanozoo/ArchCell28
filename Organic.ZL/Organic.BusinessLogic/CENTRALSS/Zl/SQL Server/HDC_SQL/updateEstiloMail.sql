update [ZL].[FACTURACION].[EstiloMail] set Htmlcod =
'      <style type="text/css">
        .Encabezado {
          font-family: Verdana, Arial, Helvetica, sans-serif;
          font-size: 9pt;
        }
        .style1 {
          font-family: Verdana, Arial, Helvetica, sans-serif;
          font-size: 9pt;
        }
        .ZooLogic {
          font-family: Verdana, Arial, Helvetica, sans-serif;
          font-size: 9pt;
          color: #009933;
          font-weight: bold;
        }
        table.tabla {
          font-family: verdana, Arial;
          font-size:8pt;
          border-width: 1px 1px 1px 1px;
          border-spacing: 0px;
          border-style: solid solid solid solid;
          border-color: rgb(0, 153, 51) rgb(0, 153, 51) rgb(0, 153, 51) rgb(0, 153, 51);
          border-collapse: collapse;
          background-color: transparent;
        }
        table.tabla th {
          border:1px solid white;
          background-color:#009933;
          color:#FFFFFF;
          padding:3px
        }
        .par {
			background-color: #FFFFFF;
        }
        .impar {
			background-color: #CCCCCC;
        }
        table.tabla td {
          border-width: 1px 1px 1px 1px;
          padding: 3px;
          border-style: solid solid solid solid;
          border-color: #009933;
          background-color: transparent;
        }
        .concepto {
          background-color: #009933;
          color: #FFFFFF;
          font-weight: bold;
          background-color: #009933;
          color: #FFFFFF;
        }
        .nrofactura {
          font-family: verdana, Arial;
          font-size:11pt;
        }
      </style>
' WHERE id = 1