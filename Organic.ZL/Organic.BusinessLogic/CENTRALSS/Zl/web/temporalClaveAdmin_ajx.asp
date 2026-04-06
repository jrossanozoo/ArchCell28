<%
    resultado = true
    mensaje = "document.getElementById('aviso').innerHTML = '';"
    mensaje = mensaje + "document.getElementById('aviso').innerHTML = '"
    set Componente = Server.CreateObject("ZlTools.ZlTools")
    serie = request.Querystring("serie")
'    version = request.Querystring("version")
    version = ""
    resultado = Componente.temporalClaveAdmin(cStr(version), serie)
    if resultado then
        mensaje = mensaje + "<p>Usted recibir&aacute; en su casilla de mail de seguridad<br />"
        mensaje = mensaje + "los pasos a seguir para completar esta operaci&oacute;n.</p>"
    else
        mensaje = mensaje + "<p><span style='color: red;'><b>Ocurri&oacute; un error inesperado</b><br />"
        mensaje = mensaje + "favor de comunicarse con Mesa de Ayuda</span></p>"
    end if
    mensaje = mensaje + "'; espera(1);"
    response.write(mensaje)
%>