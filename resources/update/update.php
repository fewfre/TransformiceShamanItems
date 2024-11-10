<?php
require_once 'utils.php';
define('URL_TO_CHECK_IF_SCRIPT_HAS_ACCESS_TO_ASSETS', "http://www.transformice.com/images/x_bibliotheques/x_macarons.swf");

setProgress('starting');

// Check if Atelier801 server can be accessed
$isA801ServerOnline = fetchHeadersOnly(URL_TO_CHECK_IF_SCRIPT_HAS_ACCESS_TO_ASSETS);
if(!$isA801ServerOnline['exists']) {
	setProgress('error', [ 'message' => "Update script cannot currently access the Atelier 801 servers - it may either be down, or script might be blocked/timed out" ]);
	exit;
}

////////////////////////////////////
// Core Logic
////////////////////////////////////

// Basic Resources

list($resourcesBasic, $externalBasic) = updateBasicResources();
list($resourcesSingles, $externalSingles) = updateShamanItemSingleItemFiles();

setProgress('updating');
$json = getConfigJson();
$json["packs"]["items"] = array_merge($resourcesBasic, $resourcesSingles);
$json["packs_external"] = array_merge($externalBasic, $externalSingles);
saveConfigJson($json);

// Badges

$badges = updateBadges();
	
setProgress('updating');
$json = getConfigJson();
$json["badges"] = $badges;
saveConfigJson($json);

// Finished

setProgress('completed');
echo "Update Successful!";

sleep(10);
setProgress('idle');

////////////////////////////////////
// Update Functions
////////////////////////////////////

function updateBasicResources() {
	$resources = array();
	$external = array();

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
	
	return [$resources, $external];
}

function updateShamanItemSingleItemFiles() {
	$resources = array();
	$external = array();
	
	function makeDataFromFileIndex_chamanes($type, $i) {
		$filename = "o{$type},$i.swf";
		$filenameLocal = "items/$filename";
		return [
			'filename' => $filename,
			'filenameLocal' => $filenameLocal,
			'localFilePath' => "../$filenameLocal",
			'url' => "http://www.transformice.com/images/x_bibliotheques/chamanes/$filename",
		];
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
		
		// Fetch headers and download any files that need downloading
		$headerCheckUrlDataList = array_map(fn($i) => makeDataFromFileIndex_chamanes($type, $i), range($start, $max));
		fetchHeadersOnlyMulti_inChunksWithDataList_downloadIfNeeded($headerCheckUrlDataList, $typeName);
		
		// Check local file before adding to list, so that if there's a load issue the update script still uses the current saved version
		setProgress('updating', [ 'message'=>"Generating list of all $typeName items" ]);
		
		$breakCount = 0; // quit early if enough 404s in a row
		for ($i = $start; $i <= $max; $i++) {
			setProgress('updating', [ 'message'=>"Item Type: $type [$typeName]", 'value'=>$i-$start+1, 'max'=>$max-$start ]);
			
			list('url' => $url, 'localFilePath' => $file, 'filenameLocal' => $filenameLocal) = makeDataFromFileIndex_chamanes($type, $i);
		
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
	
	return [$resources, $external];
}

function updateBadges() {
	setProgress('updating', [ 'message'=>"Badges" ]);
	$badgeDataList = array(); // Array<"filename.png", headers>
	
	$CHUNK = 50;
	$originalStart = 352;
	$BREAK_NUM = 5;
	
	function makeDataFromFileIndex_badges($i) {
		$filename = "x_{$i}L.png"; $filenameSmall = "x_{$i}.png";
		return [
			'filename' => $filename,
			'filenameSmall' => $filenameSmall,
			'localFilePath' => "../badges/$filename",
			'localFilePathSmall' => "../badges/$filenameSmall",
			'url' => "http://www.transformice.com/images/x_transformice/x_badges/$filename",
			'urlSmall' => "http://www.transformice.com/images/x_transformice/x_badges/$filenameSmall"
		];
	}
	
	$breakCount = 0; // quit early if enough 404s in a row
	$start = $originalStart;
	$end = $start+$CHUNK;
	// fetch multiple urls in large chunks then part them
	do {
		setProgress('updating', [ 'message'=>"Checking for badge updates: $start-$end" ]);
		$urls = array();
		$urlsSmall = array();
		$chunkedDataList = array();
		for ($i = $start; $i < $end; $i++) {
			$data = makeDataFromFileIndex_badges($i);
			$chunkedDataList[] = $data;
			$urls[] = $data['url'];
			$urlsSmall[] = $data['urlSmall'];
		}
		// Fetch all the headers for the urls, then add them to the list if they exist
		$chunkHeadersList = fetchHeadersOnlyMulti($urls);
		$chunkHeadersListSmall = fetchHeadersOnlyMulti($urlsSmall);
		$len = min(count($chunkedDataList), count($chunkHeadersList));
		for ($i = 0; $i < $len; $i++) {
			$data = $chunkedDataList[$i];
			$data['headers'] = $chunkHeadersList[$i];
			$data['headersSmall'] = $chunkHeadersListSmall[$i];
			
			if($chunkHeadersList[$i] && $chunkHeadersList[$i]['exists'] && $chunkHeadersListSmall[$i] && $chunkHeadersListSmall[$i]['exists']) {
				$badgeDataList[] = $data;
				$breakCount = 0;
			} else {
				$breakCount++;
				if($breakCount > $BREAK_NUM) { break; }
			}
		}
		// Setup values for new chunk range
		$start = $end;
		$end = $start+$CHUNK;
	} while($breakCount <= $BREAK_NUM);
	
	// loop through returned headers and download the missing ones / ones that have been updated
	foreach ($badgeDataList as $data) {
		setProgress('updating', [ 'message'=>"Downloading file if needed: {$data['filename']}" ]);
		downloadFileIfHeadersAreNewer($data['url'], $data['localFilePath'], $data['headers']);
		downloadFileIfHeadersAreNewer($data['urlSmall'], $data['localFilePathSmall'], $data['headersSmall']);
	}
	
	// Check local file before adding to list, so that if there's a load issue the update script still uses the current saved version
	setProgress('updating', [ 'message'=>"Generating list of all badges" ]);
	$badges = array();
	$start = $originalStart;
	$breakCount = 0; // quit early if enough 404s in a row
	for ($i = $start; $i <= 1000; $i++) {
		list('localFilePath' => $file, 'filename' => $filename) = makeDataFromFileIndex_badges($i);
		
		// Check local file so that if there's a load issue the update script still uses the current saved version
		if(file_exists($file)) {
			$badges[] = $filename;
			$breakCount = 0;
		} else {
			$breakCount++;
			if($breakCount > $BREAK_NUM) { break; }
		}
	}
	
	return $badges;
}