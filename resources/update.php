<?php
set_time_limit(3*60);

$resources = array();
$external = array();

$resources_base = array("x_items_chaman", "x_macarons");
foreach ($resources_base as $filebase) {
	// for ($i = 1; $i <= 5; $i++) {
		// $filename = $i==1 ? "{$filebase}.swf" : "{$filebase}{$i}.swf";
		$filename = "{$filebase}.swf";
		$url = "http://www.transformice.com/images/x_bibliotheques/$filename";
		if(checkExternalFileExists($url)) {
			file_put_contents($filename, fopen($url, 'r'));
			$resources[] = $filename;
			$external[] = $url;
		}
	// }
}

// type/start number (since only new ones use this system)
$types = array(
	[1, 43], // box (small)
	[2, 47], // box (large)
	[3, 41], // plank (small)
	[4, 44], // plank (large)
	[6, 37], // ball
	[7, 10], // trampoline
	[10, 22], // anvil
	[17, 36], // cannonball
	[28, 45] // balloon
);
foreach ($types as $typedata) {
	list($type, $start) = $typedata;
	for ($i = $start; $i <= ($start+50); $i++) {
		$filename = "o{$type},$i.swf";
		$url = "http://www.transformice.com/images/x_bibliotheques/chamanes/$filename";
		if(checkExternalFileExists($url)) {
			file_put_contents($filename, fopen($url, 'r'));
			$resources[] = $filename;
			$external[] = $url;
		}
	}
}

$json = json_decode(file_get_contents("config.json"), true);
$json["packs"]["items"] = $resources;
$json["packs_external"] = $external;
$json["cachebreaker"] = time();//md5(time(), true);
file_put_contents("config.json", json_encode($json));//, JSON_PRETTY_PRINT

echo "Update Successful! Redirecting...";
echo '<script>window.setTimeout(function(){ window.location = "../"; },1000);</script>';

function checkExternalFileExists($url)
{
	$ch = curl_init($url);
	curl_setopt($ch, CURLOPT_NOBODY, true);
	curl_exec($ch);
	$retCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
	curl_close($ch);

	return $retCode == 200 || $retCode == 300;
}
?>
