<%
    mensaje = "document.getElementById('aviso').innerHTML = '';"
    mensaje = mensaje + "document.getElementById('aviso').innerHTML = '"
    serie = request.Querystring("serie")
    version = "1.1.1."
    Set Componente = Server.CreateObject("ZlTools.ZlTools")    
    respuestadelcomponente = Componente.blanqueoClaveLince(version, serie)   
    
    if left( respuestadelcomponente,2 ) = "OK" then
        mensaje = mensaje + "<p>Usted recibir&aacute; en su casilla de mail de seguridad<br />"
        mensaje = mensaje + "los pasos a seguir para completar esta operaci&oacute;n.</p>"
    else
        if left( respuestadelcomponente,11 ) = "ADVERTENCIA" then
	   		mensaje = mensaje + "<p><span style='color: red;'><b>El cliente no cuenta con un mail de Administrador de sistemas registrado en Zoo Logic.<br />"
	   		mensaje = mensaje + "Por favor comunicarse con Atenci&oacute;n al cliente al 4896-8100 o por mail a atencionalcliente@zoologic.com.ar</b><br />"
	    else
	        mensaje = mensaje + "<p><span style='color: red;'><b>Ocurri&oacute; un error inesperado</b><br />"
	    	mensaje = mensaje + + "favor de comunicarse con Mesa de Ayuda.</span></p>"	
	    end if
		
	end if    
   
    mensaje = mensaje + "'; espera();"
    response.write(mensaje)
%>