<html>
  <head>
    <title>
      Zoo Logic. The Software Solution
    </title>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <link rel="stylesheet" href="ss.css" type="text/css">
  </head>

  <body bgcolor="#CCCCCC" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
    <table width="870" height="100%" border="0" align="center" cellpadding="0" cellspacing="0" class="bg_tabla_gral">
      <tr>
        <td align="center" valign="top">
          <table width="830" height="100%" border="0" cellpadding="0" cellspacing="0">
            <tr>
              <td height="100">
                <!--#include file="inc_header.asp"-->
              </td>
            </tr>
            <tr>
              <td valign="top">
                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                  <tr>
                    <td width="19%" valign="top">
                      <!--#include file="inc_usuarios.asp"-->
                    </td>
                    <td width="81%" align="right" valign="top">
                      <table width="648" border="0" cellspacing="0" cellpadding="0">
                        <!--DWLayoutTable-->
                        <tr>
                          <td width="648">
                            <object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=7,0,19,0" width="648" height="121">
                              <param name="movie" value="../swf/head_usuarios.swf">
                              <param name="quality" value="high">
                              <embed src="../swf/head_usuarios.swf" quality="high" pluginspage="http://www.macromedia.com/go/getflashplayer" type="application/x-shockwave-flash" width="648" height="121">
                              </embed>
                            </object>
                          </td>
                        </tr>
                        <tr>
                          <td>&nbsp;</td>
                        </tr>
                        <tr>
                          <td class="texto_titulos">
                            <font color="#006600">Restauraci&oacute;n de clave de Administrador</font>
                          </td>
                        </tr>
                        <tr>
                          <td>&nbsp;</td>
                        </tr>
                        <tr>
                          <td align="left" valign="top" nowrap>
                            <table cellSpacing="1" cellPadding="1" width="100%" border="0">
                              <!--DWLayoutTable-->
                              <tr>
                                <td width="100%" valign="top" align="left">
                                  <form method="post" name="formSerieVersion" id="formSerieVersion" >
                                    <table border="0" cellspacing="0" cellpadding="0" width="100%">
                                      <tr>
                                        <td width="50%" align="right" class="texto_contenido_01" style="padding-right: 3px; border: 1px none;border-radius: 4px; height: 30px;">
                                          <b>N&uacute;mero de Serie:</b>
                                        </td>
                                        <td width="50%" align="left" style="padding-left: 3px;border: 1px none;">
                                          <input type="text" name="nroserie" id="nroserie" >
                                        </td>
                                      </tr>
                                      <tr>
                                        <td align="right" class="texto_contenido_01" style="padding-right: 3px; border: 1px none;border-radius: 4px; height: 30px;">
<!--
                                          <b>Versi&oacute;n:</b>
-->
                                        </td>
                                        <td align="left" style="padding-left: 3px;border: 1px none;">
<!--
                                          <input type="text" name="version" id="version" ><br />
                                          <span class="texto_notas" style="font-size: xx-small;">Ejemplo: 02.0003.01850</span>
-->
                                        </td>
                                      </tr>
                                      <tr>
                                        <td>&nbsp;</td>
                                        <td align="left" style="padding-left: 3px;" height="50" width="100%">
                                          <input type="button" name="boton" id="boton" value="Enviar" onclick="validarSerieVersionOrganic(1);" >
                                        </td>
                                      </tr>
                                      <tr>
                                        <td class="aviso" height="80" id="aviso" colspan="2" align="center" width="100%">
                                          &nbsp;
                                        </td>
                                      </tr>
                                    </table>
                                  </form>
                                </td>
                              </tr>
                            </table>
                          </td>
                          <td></td>
                        </tr>
                        <tr>
                          <td align=right COLSPAN=2>
                            <a href="http://www.zoologic.com.ar/usuarios.asp" class="texto_menu_foot">
                              Volver
                            </a>
                          </td>
                          <td></td>
                        </tr>
                      </table>
                    </td>
                  </tr>
                  <tr>
                    <td height="19">&nbsp;</td>
                  </tr>
                </table>
              </td>
            </tr>
          </table>
        </td>
      </tr>
      <tr>
        <td height="35">&nbsp;</td>
      </tr>
      <tr>
        <td height="70" valign="bottom">
          <!--#include file="inc_foot.asp"-->
        </td>
      </tr>
    </table>
	</td>
      </tr>
    </table>
  </body>
</html>
<%
If Err.Number <> 0 then
	Err.clear
end if
%>