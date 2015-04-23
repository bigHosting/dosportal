<?php

// (c) George Bolo
// (c) Security Guy

// http://stackoverflow.com/questions/26855692/reading-ini-file-from-php-which-contains-semicolons
function parse_ini ( $filepath ) {
        $ini = file( $filepath );
        if ( count( $ini ) == 0 ) { return array(); }
        $sections = array();
        $values = array();
        $globals = array();
        $i = 0;
        foreach( $ini as $line ){
                $line = trim( $line );
                // Comments
                if ( $line == '' || $line{0} == ';' || $line{0} == '#' ) { continue; }
                // Sections
                if ( $line{0} == '[' ) {
                        $sections[] = substr( $line, 1, -1 );
                        $i++;
                        continue;
                }
                // Key-value pair
                list( $key, $value ) = explode( '=', $line, 2 );
                $key = trim( $key );
                $value = trim( $value );
                if ( $i == 0 ) {
                        // Array values
                        if ( substr( $line, -1, 2 ) == '[]' ) {
                                $globals[ $key ][] = $value;
                        } else {
                                $globals[ $key ] = $value;
                        }
                } else {
                        // Array values
                        if ( substr( $line, -1, 2 ) == '[]' ) {
                                $values[ $i - 1 ][ $key ][] = $value;
                        } else {
                                $values[ $i - 1 ][ $key ] = $value;
                        }
                }
        }
        for( $j=0; $j<$i; $j++ ) {
                $result[ $sections[ $j ] ] = $values[ $j ];
        }
    return $result + $globals;
}

$arr = parse_ini('/etc/dosportal-graylog-web.conf');
$graylog_sec = $arr['graylog']['sec'];
$graylog_api_user = $arr['graylogapi']['user'];
$graylog_api_pass = $arr['graylogapi']['pass'];

$TIME_PERIOD = 1800;
$MIN_HITS = 400;
$METHOD = "POST";
$FILENAME = "wp-login.php";
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
if ( isset($_GET['method']) && !is_numeric($_GET['method']) && (strtoupper($_GET['method']) === 'GET' || strtoupper($_GET['method']) === 'POST') ){
    $METHOD = strtoupper($_GET['method']);
    $output .= "# using custom value for method: $METHOD \n";
} else {
    $output .= "# using default value for method: $METHOD (possible values: get,post) \n";
}
if ( isset($_GET['filename']) && !is_numeric($_GET['filename']) ){
    $FILENAME = $_GET['filename'];
    $output .= "# using custom value for filename: $FILENAME \n";
} else {
    $output .= "# using default value for filename: $FILENAME \n";
}

function getGraylogMessages($range,$method,$filename){
        global $graylog_sec;
        global $graylog_api_user;
        global $graylog_api_pass;


        $query = 'http_method:'.$method.' AND http_request_path:\/*'.$filename;
        $e_query = urlencode($query);

        $url = 'http://'.$graylog_sec.':12900/search/universal/relative/terms?field=source_ip&query='.$e_query.'&range='.$range;
        echo $url;
        $curl = curl_init();

        $opt = array(
                CURLOPT_URL=>$url,
                CURLOPT_USERAGENT => "Mozilla",
                CURLOPT_CUSTOMREQUEST =>"GET",
                CURLOPT_RETURNTRANSFER=>true,
                CURLOPT_FOLLOWLOCATION=>false,
                CURLOPT_CONNECTTIMEOUT=>10,
                CURLOPT_USERPWD=>"$graylog_api_user:$graylog_api_pass",
                CURLOPT_HTTPAUTH,
                CURLAUTH_ANY,
        );
        curl_setopt_array($curl, $opt);
        $output = curl_exec($curl);
        $http_status = curl_getinfo($curl, CURLINFO_HTTP_CODE);
        curl_close($curl);

        return $output;

}



$gl_json = json_decode(getGraylogMessages($TIME_PERIOD,$METHOD,$FILENAME), true);


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

