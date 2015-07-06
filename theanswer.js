document.onreadystatechange = function(){
  if (document.readyState === "interactive"){
    document.body.innerHTML = "42";
	  document.body.style.color = "red";
	  document.body.style.fontSize = "4000%";
	  document.body.style.fontFamily = "monospace";
  }
}
