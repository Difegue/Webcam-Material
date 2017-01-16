function onBlur() {
	focused=false;
};

function onFocus(){
	focused=true;
}; 


if (/*@cc_on!@*/false) { // check for Internet Explorer
	document.onfocusin = onFocus;
	document.onfocusout = onBlur;
} else {
	window.onfocus = onFocus;
	window.onblur = onBlur;
} 

/*function streamSwitch(showToast)
{
	clearInterval(cam1Timer);
	clearInterval(cam2Timer);

	if (stream=="mjpeg")
	{
		stream="javascript";
		document.getElementById("stream_indic").innerHTML="Stream: JS";
		cam1Timer = setInterval("refreshPicture(1)", 150);
		cam2Timer = setInterval("refreshPicture(2)", 150);
		if(showToast)
			Materialize.toast('Stream switched to Javascript.', 2000);

	}
	else
	{
		stream="mjpeg";
		document.getElementById("stream_indic").innerHTML="Stream: MJPEG";
		cam1Timer = setInterval("refreshPicture(1)", 30000);
		cam2Timer = setInterval("refreshPicture(2)", 30000);
		if(showToast)
			Materialize.toast('Stream switched to MJPEG.', 2000);
	}

	refreshPicture(1);
	refreshPicture(2);
	
}*/

function refreshPicture(camNumb)
{

	//console.log(camNumb);
	var wb = document.getElementById("cam"+camNumb);

	if (wb.style.display!="none")
	{
		//if (stream=="javascript")
		document.getElementById("camjpg"+camNumb).src="./stream/cam_"+camNumb+".jpg?"+ new Date().getTime();
		//else
		//	document.getElementById("camjpg"+camNumb).src="./stream/cam_"+camNumb+".cgi?"+ new Date().getTime();
	}

}

function rotateCurrentCamera()
{
	var wb1 = document.getElementById("cam1");
	var wb2 = document.getElementById("cam2");

	if (wb1.style.display!="none")
	{
		angle1 +=180;
		$("#camjpg1").rotate(angle1);
	}

	if (wb2.style.display!="none")
	{
		angle2+=180;
		$("#camjpg2").rotate(angle2);
	}


}

function savePicture()
{

	var wb1 = document.getElementById("cam1");

	var wb2 = document.getElementById("cam2");

	var newElement = document.createElement('img');

	newElement.style.width="20%"; 
	newElement.style.marginRight="5px";

	if (wb1.style.display=="none")
		newElement.src="./stream/cam_2.jpg?"+ new Date().getTime();
	else
		newElement.src="./stream/cam_1.jpg?"+ new Date().getTime();
		newElement.class="z-depth-1";
		document.getElementById("screenshots").appendChild(newElement);
		Materialize.toast('Screenshot Saved!', 1000);

}

function sendMessage()
{
	//jQuery.get("http://noctur.me/jsonip/",
		//function(data){

		Materialize.toast("Sending....",2000);
		var mess = document.getElementById("textarea1").value;
		var login = document.getElementById("textarea2").value;		
		if (mess.length >100)
			Materialize.toast("Message exceeds 100 characters.",1000);
		else	
			jQuery.ajax({
				method: "POST",
				url: "msg.pl",
				data: {message: mess, login:login, passw:document.getElementById("password").value},
				}).always(function(data) {
					Materialize.toast(data,1000);
                                            if (data != "Audio message already playing."){
					     document.getElementById("textarea1").value="";
                                            }
					});
	//});

	return false;
}

function getLastMessages()
{
	jQuery.get("history.pl",
		function(data){
		document.getElementById("history").innerHTML=data;
		});
}