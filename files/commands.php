<?php
$json = file_get_contents('php://input');
$data = json_decode($json);

switch ($data[0]) {
    case 'mitmstart':
        executeCommand('sudo mitmon.sh');
        break;

    case 'mitmstop':
        executeCommand('sudo mitmoff.sh');
        break;

    case 'contcapstart':
        $filename = preg_replace('/[^\w-]/', '_', $data[1]);
        if ($filename == "") {
            $filename = date('d_m_Y-h_i_s', time());
        }
        $time = filter_var($data[2], FILTER_SANITIZE_NUMBER_INT);
        if ((int) $time !== $time) {
            $time = 600;
        };
        executeCommand("sudo contcap.sh " . $filename . " " . $time);
        break;

    case 'contcapstop':
        executeCommand("sudo killall dumpcap");
        break;

    case 'systemdstart':
        $service = sanitizeSystemdService($data[1]);
        executeCommand("sudo systemctl start " . $service);
        break;

    case 'systemdstop':
        $service = sanitizeSystemdService($data[1]);
        executeCommand("sudo systemctl stop " . $service);
        break;

    case 'systemdrestart':
        $service = sanitizeSystemdService($data[1]);
        executeCommand("sudo systemctl restart " . $service);
        break;

    case 'poweroff':
        executeCommand("sudo systemctl poweroff");
        break;

    default:
        http_response_code(404);
        echo "Unbekannter Befehl.";
        break;
}
