<?php
set_time_limit(5*60);

$resources = array();
$external = array();

setProgress('starting');

//
// Multi-item pack Loading
//
$resources_base = array("x_items_chaman", "x_macarons");
foreach ($resources_base as $filebase) {
	// for ($i = 1; $i <= 5; $i++) {
		setProgress('updating', [ 'message'=>"Resource: $filebase", 'value'=>1, 'max'=>1 ]);
		// $filename = $i==1 ? "{$filebase}.swf" : "{$filebase}{$i}.swf";
		$filename = "{$filebase}.swf";
		$url = "http://www.transformice.com/images/x_bibliotheques/$filename";
		if(checkExternalFileExists($url)) {
			file_put_contents("../$filename", fopen($url, 'r'));
			$resources[] = $filename;
			$external[] = $url;
		}
	// }
}

//
// Single item swf Loading
//

// type/start number (since only new ones use this system)
$types = array(
	[1, 43, "box (small)"],
	[2, 47, "box (large)"],
	[3, 41, "plank (small)"],
	[4, 44, "plank (large)"],
	[6, 37, "ball"],
	[7, 10, "trampoline"],
	[10, 22, "anvil"],
	[17, 36, "cannonball"],
	[28, 45, "balloon"]
);
foreach ($types as $typedata) {
	list($type, $start, $typeName) = $typedata;
	$max = ($start+100);
	$breakCount = 0; // quit early if enough 404s in a row
	for ($i = $start; $i <= $max; $i++) {
		setProgress('updating', [ 'message'=>"Item Type: $type [$typeName]", 'value'=>$i-$start+1, 'max'=>$max-$start ]);
		
		$filename = "o{$type},$i.swf";
		$url = "http://www.transformice.com/images/x_bibliotheques/chamanes/$filename";
		if(checkExternalFileExists($url)) {
			file_put_contents("../$filename", fopen($url, 'r'));
			$resources[] = $filename;
			$external[] = $url;
			$breakCount = 0;
		} else {
			$breakCount++;
			if($breakCount > 5) {
				break;
			}
		}
	}
}

//
// Badge Loading
//
$badges = array();
$start = 352;
$max = ($start+1000);
$breakCount = 0; // quit early if enough 404s in a row
for ($i = $start; $i <= $max; $i++) {
	setProgress('updating', [ 'message'=>"Badge: $i", 'value'=>$i-$start+1, 'max'=>$max-$start ]);
	$filename = "x_{$i}L.png";
	$filenameSmall = "x_{$i}.png";
	$url = "https://www.transformice.com/images/x_transformice/x_badges/$filename";
	$urlSmall = "https://www.transformice.com/images/x_transformice/x_badges/$filenameSmall";
	$localFile = "../badges/$filename";
	$localFileSmall = "../badges/$filenameSmall";
	// Don't re-download local one if it exists
	if(file_exists($localFile) && file_exists($localFileSmall)) {
		$badges[] = $filename;
		$breakCount = 0;
	} else {
		if(checkExternalFileExists($url) && checkExternalFileExists($urlSmall)) {
			file_put_contents($localFile, fopen($url, 'r'));
			file_put_contents($localFileSmall, fopen($urlSmall, 'r'));
			$badges[] = $filename;
			$breakCount = 0;
		} else {
			$breakCount++;
			if($breakCount > 5) {
				break;
			}
		}
	}
}

setProgress('updating');

$json_path = "../config.json";
$json = json_decode(file_get_contents($json_path), true);
$json["packs"]["items"] = $resources;
$json["packs_external"] = $external;
$json["badges"] = $badges;
$json["cachebreaker"] = time();//md5(time(), true);
file_put_contents($json_path, json_encode($json));//, JSON_PRETTY_PRINT

setProgress('completed');
echo "Update Successful!";

sleep(10);
setProgress('idle');
// echo "Update Successful! Redirecting...";
// echo '<script>window.setTimeout(function(){ window.location = "../"; },1000);</script>';

function checkExternalFileExists($url)
{
	$ch = curl_init($url);
	curl_setopt($ch, CURLOPT_NOBODY, true);
	curl_exec($ch);
	$retCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
	curl_close($ch);

	return $retCode == 200 || $retCode == 300;
}

function setProgress($state, $data = array()) {
	$data['state'] = $state;
	$date_utc = new \DateTime("now", new \DateTimeZone("UTC"));
	$data['timestamp'] = $date_utc->format('Y-m-d\TH:i:s\Z');
	file_put_contents("progress.json", json_encode($data));
}
?>
