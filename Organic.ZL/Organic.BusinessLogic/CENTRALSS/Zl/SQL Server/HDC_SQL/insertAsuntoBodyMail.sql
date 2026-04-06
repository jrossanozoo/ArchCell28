insert into [ZL].[FACTURACION].[FormatoMail]
([id], [Descrip], [asuntoMail], [bodyMail])
values
(
15,
'Mail para blanqueo de clave Lince',
'Zoo Logic - Solicitud de restauración de clave', 
'      <p class="encabezado">
        [[Contacto]]
        <br />
        [[Cliente]] ([[CodigoCliente]])
        <br />
        [[Razonsocial]] ([[CodigoRZ]])
      </p>
      <p class="style1">
        Estimado Cliente,
      </p>
      <p class="style1">
        Nos ponemos en contacto con Usted para comunicarle que hemos recibido 
        una solicitud de restauraci&oacute;n de clave para el serie N&deg; 
        <b>[[Serie]]</b> a trav&eacute;s de la p&aacute;gina web de 
        <span class=zoologic>Zoo Logic</span>. Para proceder a la restauraci&oacute;n, 
        debe abrir Lince Indumentaria registrado con el n&uacute;mero de serie 
        indicado. Seleccione una sucursal y acceda al men&uacute; &quot;Herramientas&quot;, 
        &quot;V Cambiar Clave&quot;. En el espacio &quot;Ingrese clave anterior:&quot;, 
        introduzca la siguiente clave: <b>[[Retorno]]</b>. Luego siga las indicaciones 
        en pantalla.
      </p>
      <p class="style1">
        En caso de no haber solicitado Ud. esta restauraci&oacute;n, simplemente 
        ignore este mensaje. 
      </p>
      <p class="style1">
        Si necesita asistencia adicional, comun&iacute;quese con nosotros telef&oacute;nicamente 
        al (011) 4896-3111 o v&iacute;a e-mail a <a href="mailto:mesadeayuda@zoologic.com.ar">mesadeayuda@zoologic.com.ar</a>.
      </p>
      <p class="style1">
        Atentamente,
      </p>
      <p class="style1">
        <img src="http://pbx01/Web%20Zoologic/aspcodes/mesadeayuda.jpg" border="0" />
      </p>
      <p class="style1">
      </p>')