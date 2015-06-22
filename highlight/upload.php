<?php
$client_id="d8aa6a9263ff166";
$albumId = "TceDl";
if(isset($_POST['imgData'])){
	$imgData = $_POST['imgData'];
	$justPngData = substr($imgData, strpos($imgData, ",") + 1);
	$pvars   = array('image' => $justPngData, 'album' => $albumId);
	$pvars   = array('image' => $justPngData);
	$timeout = 30;
	$curl = curl_init();
	curl_setopt($curl, CURLOPT_URL, 'https://api.imgur.com/3/image.json');
	curl_setopt($curl, CURLOPT_TIMEOUT, $timeout);
	curl_setopt($curl, CURLOPT_HTTPHEADER, array('Authorization: Client-ID ' . $client_id));
	curl_setopt($curl, CURLOPT_POST, 1);
	curl_setopt($curl, CURLOPT_RETURNTRANSFER, 1);
	curl_setopt($curl, CURLOPT_POSTFIELDS, $pvars);
	$out = curl_exec($curl);
	curl_close ($curl);
	echo $out;

	$obj = json_decode($out);
	$to = "joetww@gmail.com";
	$subject = "[HIGHLIGHT001]IMGUR記錄 " .date("YmdHis");
	$headers = 'From: MasterJoe<joe_yue@gamemag.com.tw>' . "\r\n" .
		'X-Mailer: PHP/' . phpversion() .
		"MIME-Version: 1.0\r\n" . "Content-Type: text/html; charset=utf-8\r\n";

	$message = '<html><body>';

	$message .= '<img src="' . $obj->{'data'}->{'link'}. '" />';
	$message .= '<span style="font-family: monospace;  font-size: x-large; display: block; margin-top: 20px;">ip address from ' . get_client_ip() . '</span>';
	$message .= '<pre>' . print_r(json_decode($out), true) . '</pre>';
	$message .= '</body></html>';

	mail($to, $subject, $message, $headers);
}
else{
	echo "{\"status\": \"not image Data\"}";
}

function get_client_ip() {
    $ipaddress = '';
    if ($_SERVER['HTTP_CLIENT_IP'])
        $ipaddress = $_SERVER['HTTP_CLIENT_IP'];
    else if($_SERVER['HTTP_X_FORWARDED_FOR'])
        $ipaddress = $_SERVER['HTTP_X_FORWARDED_FOR'];
    else if($_SERVER['HTTP_X_FORWARDED'])
        $ipaddress = $_SERVER['HTTP_X_FORWARDED'];
    else if($_SERVER['HTTP_FORWARDED_FOR'])
        $ipaddress = $_SERVER['HTTP_FORWARDED_FOR'];
    else if($_SERVER['HTTP_FORWARDED'])
        $ipaddress = $_SERVER['HTTP_FORWARDED'];
    else if($_SERVER['REMOTE_ADDR'])
        $ipaddress = $_SERVER['REMOTE_ADDR'];
    else
        $ipaddress = 'UNKNOWN';
    return $ipaddress;
}
?>
