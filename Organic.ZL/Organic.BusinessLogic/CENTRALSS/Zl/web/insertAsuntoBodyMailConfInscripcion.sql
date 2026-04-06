insert into [ZL].[FACTURACION].[FormatoMail]
([id], [Descrip], [asuntoMail], [bodyMail])
values
(
18,
'Confirmación de inscripción',
'Zoo Logic - Confirmación de inscripción', 
'
    <p class="style1">
      Estimado Cliente,
    </p>
    <p class="style1">
      por medio del presente mensaje le confirmamos la creaci&oacute;n de su nuevo 
      usuario para acceder al Campus Virtual de capacitaci&oacute;n de Zoo Logic:
    </p>
    <p class="style1">
      Usuario: [[USUARIO]]<br />
      Contrase&ntilde;a: [[CLAVE]]
    </p>
    <p class="style1">
      La contrase&ntilde;a podr&aacute; ser modificada luego de realizar el primer 
      ingreso al campus.
    </p>
    <p class="style1">
      Le recordamos que la direcci&oacute;n para acceder al Campus Virtual es 
      <a href="http://campus.zoologic.com.ar">http://campus.zoologic.com.ar</a><br>
      Descargue el manual de introducci&oacute;n al Campus haciendo click 
      <a href="http://campus.zoologic.com.ar/introcampus.pdf">aqu&iacute;</a>.
    </p>
    <p class="style1">
      Atentamente, el equipo de Documentaci&oacute;n y Capacitaci&oacute;n
    </p>
    <p class="style1">
      <img src="http://pbx01/Web%20Zoologic/aspcodes/capacitacion.jpg" border="0" />
    </p>
    <p class="style1">
    </p>
')