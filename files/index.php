<?php
include('config.php');
include('functions.php');
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    include('commands.php');
} else {
    exec('ip -o -4 a | awk \'$2 == "eth0" { gsub(/\/.*/, "", $4); print $4 }\'', $localip);
    ?>
    <!DOCTYPE html>
    <html lang="de">

    <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
        <link rel="stylesheet" href="/bootstrap.css" />
        <link rel="stylesheet" href="/index.css" />
        <title>c't-Raspion</title>
        <style>
            <?php

                exec("sudo mitmstat.sh", $output, $mitmstatus);

                if ($mitmstatus == 1) {
                    echo "#mitmstart";
                } else {
                    echo "#mitmstop";
                }
                echo " { display:none; }";
                exec("sudo pgrep dumpcap", $output, $dumpcapstatus);
                if ($dumpcapstatus == 0) {
                    echo "#contcapstart";
                } else {
                    echo "#contcapstop";
                }
                echo " { display:none; }";

                ?>
        </style>
    </head>

    <body>
        <nav class="navbar navbar-expand-lg navbar-dark bg-dark mb-4" id="top">
            <a class="navbar-brand" href="#">
                <img src="/logo.png" width="30" height="30" class="d-inline-block align-top" alt="">
                c't-Raspion
            </a>
            <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbar" aria-controls="navbar" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse " id="navbar">
                <div class="navbar-nav">
                    <a class="nav-item nav-link" href="#services">Dienste</a>
                    <a class="nav-item nav-link" href="#tools">Werkzeuge</a>
                    <a class="nav-item nav-link" href="#interfaces">IP-Adressen</a>
                    <a class="btn btn-danger ml-lg-4" id="poweroff">Abschalten</a>
                </div>
            </div>
        </nav>
        <div class="container">
            <p>
                Ein Projekt aus c't 1/2020, um Datenschleudern und -Petzen zu untersuchen.
                Weitere Hinweise gibt es auf der <a href="http://ct.de/-4606645">Projektseite</a>.
            </p>
            <h5 id="services">Dienste</h5>
            <div class="card-deck card-small-width">
                <?php
                    $html_card = '
                <div class="card mb-4">
                    <h5 class="card-header">
                    <img src="%s.png" class="card-img-top" style="max-width:30px; height:auto;" alt=""/>
                    %s
                    </h5>
                <div class="card-body">
                    <p class="card-text"><small class="text-muted"> %s</small></p>
                </div>
                <div class="card-footer"> 
                    <a href="%s" target="_blank" class="btn btn-secondary">Öffnen</a>
                </div>
                </div>
                ';


                    for ($i = 0; $i < count($services); ++$i) {
                        echo sprintf(
                            $html_card,
                            $services[$i]['id'],
                            $services[$i]['title'],
                            $services[$i]['description'],
                            'http://' . $localip[0] . $services[$i]['url']
                        );
                        responsiveCardBreaks($i);
                    }
                    ?>
            </div>


            <h5 id="tools">Werkzeuge</h5>
            <div class="card-deck card-double-width toollist">


                <?php
                    // List tools
                    $html_button = '<a id="%s" class="btn command %s">%s</a>';

                    $html_input = '
                    <div class="input-group mb-3">
                        <div class="input-group-prepend">
                          <span class="input-group-text">%s</span>
                        </div>
                        <input type="%s" class="form-control parameter" value="%s" autocomplete="off">
                    </div>';

                    $html_tool = '
                        <div class="card mb-4" id="%s">
                            <div class="card-body">
                                <h5 class="card-title">
                                %s
                                </h5>
                                <p class="card-text"><small class="text-muted">%s</small></p>
                                %s
                            </div>
                            <div class="card-footer"> 
                            %s 
                            </div>
                        </div>';

                    for ($i = 0; $i < count($tools); ++$i) {
                        $tool_button_html = "";
                        $tool_input_html = "";

                        for ($j = 0; $j < count($tools[$i]['parameters']); ++$j) {
                            $parameter = $tools[$i]['parameters'][$j];

                            if ($parameter[1] == "select") {
                                $select_html = buildSelect($parameter['0'], $parameter['1'], $parameter[2]);
                                $tool_input_html .= $select_html;
                            } else {
                                $tool_input_html .= sprintf($html_input, $parameter[0], $parameter[1], $parameter[2]);
                            }
                        }

                        for ($j = 0; $j < count($tools[$i]['buttons']); ++$j) {
                            $button = $tools[$i]['buttons'][$j];
                            $tool_button_html .= sprintf($html_button, $button[0], $button[1], $button[2]);
                        }
                        echo sprintf($html_tool, $tools[$i]['id'], $tools[$i]['title'], $tools[$i]['description'], $tool_input_html, $tool_button_html);

                        echo '<div class="w-100 d-block d-sm-block d-md-block d-lg-none"></div>';
                        if (($i + 1) % 2 == 0) {
                            echo '<div class="w-100 d-none d-sm-none d-md-none d-lg-block"></div>';
                        }
                    }; ?>
            </div>
            <h5 id="interfaces">IP-Adressen</h5>
            <div class="card-deck card-full-width">

                <?php
                    //List network interfaces
                    $html_net_info = '
                        <div class="card mb-4">
                        <div class="card-body">
                            <h5 class="card-title">
                            %s
                            </h5>
                            <div class="card-text">%s</div>
                        </div>
                        </div>';


                    for ($i = 0; $i < count($interfaces); ++$i) {
                        $ips = getIPAddresses($interfaces[$i][0]);
                        echo sprintf($html_net_info, $interfaces[$i][0] . " – " . $interfaces[$i][1], $ips);
                        responsiveCardBreaks($i, 'full');
                    };
                    ?>

            </div>

            <a href="https://ct.de" target="_blank" id="footerlink" class="pb-4 text-reset text-justify text-wrap font-weight-lighter"> ©2019
                c't – magazin für computer technik </a>
        </div>

        <!-- Modal -->
        <div class="modal fade" id="commandModal" tabindex="-1" role="dialog" aria-labelledby="commandModalLabel" aria-hidden="true">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="commandModalLabel">Bitte warten...</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        Anforderung wird verarbeitet...<div class="spinner-border" role="status">
                            <span class="sr-only">Loading...</span>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-primary" data-dismiss="modal">Weiter</button>
                    </div>
                </div>
            </div>
        </div>

        <script src="/jquery.js"></script>
        <script src="/bootstrap.js"></script>
        <script src="/index.js"></script>
    </body>

    </html>
<?php
}
