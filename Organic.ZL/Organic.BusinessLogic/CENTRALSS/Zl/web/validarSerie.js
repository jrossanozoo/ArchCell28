var ok = true;
var serie;
var intervalo;
function validarSerieLince() {
  serie = parseInt(document.formSerie.nroserie.value);
  if ( /^([0-9])*$/.test(serie) ) {
    if (serie > 101000 && serie < 609999) {
      var validacion = document.createElement("script");
      validacion.setAttribute("type", "text/javascript");
      validacion.setAttribute("language", "javascript");
      validacion.setAttribute("src", "blanqueoClaveLince_ajx.asp?serie=" + serie);
      document.body.appendChild(validacion);
    } else {
      ok = false;
    }
  } else {
    ok = false;
  }
  if (!ok) {
    document.getElementById('aviso').innerHTML = '<p><span style="color: red; font-weight: bold;">El dato solicitado es inv&aacute;lido.</span></p>';
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