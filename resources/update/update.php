<?php
ini_set('display_errors', '1');
ini_set('display_startup_errors', '1');
error_reporting(E_ALL);

ini_set('max_execution_time', 5*60);
set_time_limit(5*60);

$resources = array();
$external = array();

setProgress('starting');

// file_put_contents("testing.json", json_encode(array()));
// function ADD_LOG($msg) {
// 	$json = json_decode(file_get_contents("testing.json"), true);
// 	$json[] = $msg;
// 	file_put_contents("testing.json", json_encode($json, JSON_PRETTY_PRINT));
// }
// // Ping to confirm if server is booting us
// function ping($host, $port, $timeout) { $tB = microtime(true); $fP = fSockOpen($host, $port, $errno, $errstr, $timeout); if (!$fP) { return "down"; } $tA = microtime(true); return round((($tA - $tB) * 1000), 0)." ms"; }
// ADD_LOG( ping('www.transformice.com', 80, 100) );

//
// Multi-item pack Loading
//
$resources_base = array("x_items_chaman", "x_macarons");
foreach ($resources_base as $filebase) {
	setProgress('updating', [ 'message'=>"Resource: $filebase", 'value'=>1, 'max'=>1 ]);
	$filename = "{$filebase}.swf";
	$url = "http://www.transformice.com/images/x_bibliotheques/$filename";
	$file = "../$filename";
	downloadFileIfNewer($url, $file);
	
	// Check local file so that if there's a load issue the update script still uses the current saved version
	if(file_exists($file)) {
		$resources[] = $filename;
		$external[] = $url;
	}
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
		$filenameLocal = "items/$filename";
		$file = "../$filenameLocal";
		downloadFileIfNewer($url, $file);
	
		// Check local file so that if there's a load issue the update script still uses the current saved version
		if(file_exists($file)) {
			$resources[] = $filenameLocal;
			$external[] = $url;
			$breakCount = 0;
		} else {
			$breakCount++;
			if($breakCount > 5) { break; }
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
	$url = "https://www.transformice.com/images/x_transformice/x_badges/$filename";
	$file = "../badges/$filename";
	$resp = fetchUrlMetaData($url);
	if($resp['exists'] && checkIfUrlLastModifiedNewerThanFile($resp['lastModified'], $file)) {
		// We only want to check if small exists after we confirm big exists (for efficiency)
		$filenameSmall = "x_{$i}.png";
		$urlSmall = "https://www.transformice.com/images/x_transformice/x_badges/$filenameSmall";
		$fileSmall = "../badges/$filenameSmall";
		$respSmall = fetchUrlMetaData($urlSmall);
		if($resp['exists'] && $respSmall['exists']) {
			ifUrlIsNewerThenDownloadToFile($url, $resp['lastModified'], $file);
			ifUrlIsNewerThenDownloadToFile($urlSmall, $respSmall['lastModified'], $fileSmall);
		}
	}
	
	// Check local file so that if there's a load issue the update script still uses the current saved version
	if(file_exists($file)) {
		$badges[] = $filename;
		$breakCount = 0;
	} else {
		$breakCount++;
		if($breakCount > 5) { break; }
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

function downloadFileIfNewer($url, $file) {
	$resp = fetchUrlMetaData($url);
	if($resp['exists']) {
		ifUrlIsNewerThenDownloadToFile($url, $resp['lastModified'], $file);
	}
}

function ifUrlIsNewerThenDownloadToFile($url, $urlLastModified, $file) {
	if(checkIfUrlLastModifiedNewerThanFile($urlLastModified, $file)) {
		downloadUrlToFile($url, $file);
		return true;
	}
	return false;
}
function downloadUrlToFile($url, $file) { file_put_contents($file, fopen($url, 'r')); }
function checkIfUrlLastModifiedNewerThanFile($urlLastModified, $file) {
	$fileTime = getFileLastModifiedDateTime($file);
	return $fileTime ? $urlLastModified > $fileTime : true; // If file doesn't exist then url is newer
}
function getFileLastModifiedDateTime($file) {
	$timestamp = filemtime($file);
	return $timestamp ? new \DateTime("@$timestamp") : null;
}
function fetchUrlMetaData($url) {
	$h = fetchHeadersOnly($url);
	$statusCode = $h && isset($h[0]) ? explode(" ", $h[0])[1] : 0;
	return [
		'exists' => $statusCode == 200 || $statusCode == 300,
		'statusCode' => $statusCode,
		'lastModified' => $h && isset($h['Last-Modified']) ? new \DateTime($h['Last-Modified']) : null,
	];
}
function fetchHeadersOnly($url) {
	$context = stream_context_create([ 'http' => array('method' => 'HEAD') ]); // Fetch only head to make it faster and to be friendly to server
	return get_headers($url, true, $context);
}

function setProgress($state, $data = array()) {
	$data['state'] = $state;
	$date_utc = new \DateTime("now", new \DateTimeZone("UTC"));
	$data['timestamp'] = $date_utc->format('Y-m-d\TH:i:s\Z');
	file_put_contents("progress.json", json_encode($data));
}
