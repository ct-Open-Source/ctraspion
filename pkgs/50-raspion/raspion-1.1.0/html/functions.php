<?php
// parse output of ip commands for given network device to get ip-addresses
function getIPAddresses($device)
{
    exec('ip -o -4 a | awk \'$2 == "' . $device . '" { gsub(/\/.*/, "", $4); print $4 }\'', $ipv4_addr);
    exec('ip -o -6 a | awk \'$2 == "' . $device . '" { gsub(/\/.*/, "", $4); print $4 }\'', $ipv6_addr);

    $ipv4_addr = '<th class="thead-light">IPv4:</th><td>' . implode('</td><td>', $ipv4_addr) . '</td>';
    $ipv6_addr = '<th class="thead-light">IPv6:</th><td>' . implode('</td><td>', $ipv6_addr) . '</td>';
    return '<table class="table table-bordered"><tbody><tr>' . $ipv4_addr . '</tr><tr>' . $ipv6_addr . '</tr></tbody></table>';
}

// echo divs that cause breaks in the card groups for certain screen widths
function responsiveCardBreaks($i, $w = 'small')
{
    if ($w == 'small') {
        echo '<div class="w-100 d-block d-sm-none d-md-none d-lg-none"></div>';
        if (($i + 1) % 2 == 0) {
            echo '<div class="w-100 d-none d-sm-block d-md-none d-lg-none"></div>';
        }
        if (($i + 1) % 3 == 0) {
            echo '<div class="w-100 d-none d-sm-none d-md-block d-lg-none"></div>';
        }
        if (($i + 1) % 4 == 0) {
            echo '<div class="w-100 d-block d-sm-none d-md-none d-lg-block d-xl-block"></div>';
        }
    };
    if ($w == 'wide') {
        echo '<div class="w-100 d-block d-sm-block d-md-block d-lg-none"></div>';
        if (($i + 1) % 2 == 0) {
            echo '<div class="w-100 d-none d-sm-none d-md-none d-lg-block"></div>';
        }
    };
    if ($w == 'full') {
        echo '<div class="w-100 d-block"></div>';
    };
}

//create a select form from given data
function buildSelect($title, $id, $options)
{
    $html_select = '<div class="form-group">
    <label>%s</label>
    <select class="form-control parameter" id="%s">
      %s
    </select>
  </div>';
    $options_html = "";
    for ($i = 0; $i < count($options); ++$i) {
        $options_html .= '<option value="' . $options[$i] . '">
      ' . $options[$i] . '
    </option>';
    };

    return sprintf($html_select, $title, $id, $options_html);
};

function sanitizeSystemdService($string)
{
    global $systemd_services;
    $sservice = preg_replace('/[^a-z_\-0-9]/i', '', $string);
    if (in_array($sservice, $systemd_services)) {
        return $sservice;
    }
}

function executeCommand($command)
{
    exec($command, $output, $return);
    if ($return != 0) {
        http_response_code(500);
        echo "Fehler beim Ausführen von: " . $command;
    } else {
        http_response_code(200);
    };
    echo (implode("<br/>", $output));
}
