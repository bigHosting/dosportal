<?php

$TIME_PERIOD = 1800;
$MIN_HITS = 400;
$output = "# TOP IP SCRIPT VARIABLES: \n";

if ( isset($_GET['time']) && is_numeric($_GET['time']) && ($_GET['time'] > 300) && ($_GET['time'] < 2000) ){
    $TIME_PERIOD = $_GET['time'];
    $output .= "# using custom value for time: last $TIME_PERIOD seconds \n";
} else {
    $output .= "# using default value for time: last $TIME_PERIOD seconds (300-2000 allowed range)\n";
}
if ( isset($_GET['hits']) && is_numeric($_GET['hits']) && ($_GET['hits'] > 100) && ($_GET['hits'] < 5000) ){
    $MIN_HITS = $_GET['hits'];
    $output .= "# using custom value for hits: minimum $MIN_HITS hits per IP \n";
} else {
    $output .= "# using default value for hits: minimum $MIN_HITS hits per IP (100-5000 allowed range)\n";
}

function getGraylogMessages($range){

    $query = 'Message:Mail Authentication Log AND ResponseCode:[300 TO 600]';
    $e_query = urlencode($query);

    $url = 'http://206.225.90.72:12900/search/universal/relative/terms?field=SourceIP&query='.$e_query.'&range='.$range;
    echo $url;
    $curl = curl_init();

    $opt = array(
        CURLOPT_URL=>$url,
        CURLOPT_USERAGENT => "Mozilla",
        CURLOPT_CUSTOMREQUEST =>"GET",
        CURLOPT_RETURNTRANSFER=>true,
        CURLOPT_FOLLOWLOCATION=>false,
        CURLOPT_CONNECTTIMEOUT=>10,
        CURLOPT_USERPWD=>"USER:PASS",
        CURLOPT_HTTPAUTH,
        CURLAUTH_ANY,
    );
    curl_setopt_array($curl, $opt);
    $output = curl_exec($curl);
    $http_status = curl_getinfo($curl, CURLINFO_HTTP_CODE);
    curl_close($curl);

    return $output;

}



$gl_json = json_decode(getGraylogMessages($TIME_PERIOD), true);


$list = $gl_json['terms'];
arsort($list);

$output .= "\n";
foreach ($list as $ip => $hits) {

    if ($hits > $MIN_HITS){
        $output .= "$hits $ip \n";
    }

}

if (php_sapi_name() == "cli") {
    echo $output;
} else {
    echo "<pre>$output<pre>";
}



?>

