var ok = true;
var serie;
var intervalo;

function validarSerieLince() {
  ok = true;	
  serie = parseInt(document.formSerie.nroserie.value);
  if ( /^([0-9])*$/.test(serie) ) {
    if (serie > 101000 && serie < 609999) {
    	
      var validacion = document.createElement("script");
      validacion.setAttribute("type", "text/javascript");
      validacion.setAttribute("language", "javascript");
   
	      
//	      $.get( "blanqueoClaveLince_ajx.asp?serie=" + serie)
//		  .done(function( resultado ) {
//		    alert( "succeeded" );
//		  })
//		  .fail(function( resultado ) {
//		    alert( "failed!" );
//		  });
  
      validacion.setAttribute("src", "blanqueoClaveLince_ajx.asp?serie=" + serie);
      document.body.appendChild(validacion);
      
    } else {
      ok = false;
    }
  } else {
    ok = false;
  }
  if (!ok) {
    document.getElementById('aviso').innerHTML = '<p><span style="color: red; font-weight: bold; font-family: Verdana, Arial, sans-serif;">El serie ingresado no es v&aacute;lido.</span></p>';
	document.getElementById("boton").style.visibility = 'hidden';
    espera(3);
  }
  return ok;
}


function espera(nEspera) {
  intervalo = setInterval("limpiar("+nEspera+")", 10000);
  return true;
}

function limpiar(nEspera) {
  switch (nEspera) {
    case 1:
      //document.forms[1].version.value = "";
      break;
  }
  document.forms[1].nroserie.value = "";
  document.getElementById("aviso").innerHTML = "";
  clearInterval(intervalo);
  document.forms[1].nroserie.focus();
  return true;
}


