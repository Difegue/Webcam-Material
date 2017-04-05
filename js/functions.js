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

function rotateCurrentCamera()
{
	//angle1/2 are initialized 
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


	newElement.src="./cam.jpg?"+ new Date().getTime();

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
					Materialize.toast(data.message,1000);
                    if (data.result){
                    	//wipe text field on successful message
					    document.getElementById("textarea1").value="";
			    //refresh history immediately
                        getLastMessages();
                        }
					});
	//});

	return false;
}

function getLastMessages()
{
	jQuery.get("history.pl?messages=10&html=1",
		function(data){
		document.getElementById("history").innerHTML=data;
		});
}

function getViewers()
{
	//viewerID is initialized in index.html
	jQuery.ajax({
		method: "GET",
		url: "viewercount.pl",
		data: {VIEWERID: viewerID},
		}).always(function(data) {

			document.getElementById("viewers").innerHTML=data.viewers;
			viewerID = data.vid;
			//Save in localStorage for ID conservation
			localStorage.setItem('viewerID',viewerID);
		});

}

function refreshPicture(externalstr)
{
	//old version - handles camera with javascript and v4l2-ctl serverside
	if (!externalstr)
		jQuery.ajax({
			method: "GET",
			url: "stream.pl",
			data: {},
			}).always(function(data) {

				if (data.result){
					document.getElementById("camjpg1").src="./cam.jpg?"+ new Date().getTime();
					cam1Timer = setTimeout("refreshPicture(false)", 200);
					document.getElementById("stream_indic").innerHTML="Quality: "+data.w+"x"+data.h;
				}
				else{
					//longer timer if camera is offline
					document.getElementById("camjpg1").setAttribute('src', offlineImage);
					cam1Timer = setTimeout("refreshPicture(false)", 10000);
				}
			});
	else
	{
		//streameye version - source image is a reverse proxied apache file pointing to port 8080
		document.getElementById("camjpg1").src="./camstream";
		document.getElementById("stream_indic").innerHTML="Quality: 1920x1080";
		jQuery.ajax({
			method: "GET",
			url: "./camstream",
			data: {},
			}).done(function() {
					document.getElementById("camjpg1").src="./camstream";
					document.getElementById("stream_indic").innerHTML="Quality: 1920x1080";
				}).fail(function () {
					//longer timer if camera is offline
					document.getElementById("camjpg1").setAttribute('src', offlineImage);
					cam1Timer = setTimeout("refreshPicture(true)", 10000);
				});
	}
}
