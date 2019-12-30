<?php

//Array of linked services
$services = array(
    array(
        'id' => 'pihole',
        'url' => '/admin',
        'title' => 'Pi-hole',
        'description' => 'DNS-Anfragen zeigen<br>Einstellungen ändern'
    ),

    array(
        'id' => 'ntopng',
        'url' => ':3000',
        'title' => 'ntopng',
        'description' => 'Live-Netzwerkverkehr anzeigen'
    ),

    array(
        'id' => 'wireshark',
        'url' => ':10000',
        'title' => 'Wireshark',
        'description' => 'Mitschnitt und Analyse'
    ),

    array(
        'id' => 'mitm',
        'url' => ':9090',
        'title' => 'mitmproxy',
        'description' => 'HTTP(S)-Verkehr einsehen<br><a href=#tools>ein/ausschalten</a>'
    ),

    array(
        'id' => 'caps',
        'url' => '/caps',
        'title' => 'pcap-Dateien',
        'description' => 'Gespeicherte Mitschnitte'
    ),

    array(
        'id' => 'console',
        'url' => ':4200',
        'title' => 'Konsole',
        'description' => 'Kommandozeile öffnen'
    ),

);

$interfaces = array(array('eth0', 'Uplink zum Internet'), array('br0', 'Testnetzwerk'));

//array of controllable systemd services
$systemd_services = array('hostapd', 'wireshark', 'broadwayd', 'mitmweb', 'shellinabox');

//array of integrated tools
$tools = array(
    array(
        'id' => 'mitmon',
        'title' => 'mitm-Proxy aktivieren',
        'description' => 'Firewall-Regeln für Umleitung von Webzugriffen (Port 80 und 443) auf mitmproxy',
        'parameters' => array(),
        'buttons' => array(
            //id, class, title
            array('mitmstart', 'btn-success mr-3', 'Aktivieren'),
            array('mitmstop', 'btn-danger', 'Deaktivieren'),
        ),
    ),

    array(
        'id' => 'contcap',
        'title' => 'Schnüffeln im Hintergrund',
        'description' => 'Paketmitschnitt anstoßen',
        'parameters' => array(
            //title, text, default value
            array('Dateiname', 'text', date('d_m_Y-h_i_s', time())),
            array('Laufzeit', 'number', 600)
        ),
        'buttons' => array(
            array('contcapstart', 'btn-success mr-3', 'Starten'),
            array('contcapstop', 'btn-danger', 'Abbrechen'),
        ),
    ),
    array(
        'id' => 'systemd',
        'title' => 'Dienste beeinflussen',
        'description' => 'Vorübergehend beenden oder neu starten',
        'parameters' => array(
            array('Dienst', 'select', $systemd_services)
        ),
        'buttons' => array(
            array('systemdstart', 'btn-success mr-3', 'Start'),
            array('systemdstop', 'btn-danger mr-3', 'Stop'),
            array('systemdrestart', 'btn-warning', 'Neustart'),
        ),
    ),
);
