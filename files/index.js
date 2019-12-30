window.addEventListener('load', function () {
  // get all buttons and add executeCommand as an eventlistener for click
  var tool_buttons = document.querySelectorAll('.toollist .command');
  tool_buttons.forEach(command => {
    command.addEventListener('click', function () {
      executeCommand(command);
    });
  });

  $('#commandModal').on('hidden.bs.modal', function (e) {
    location.reload();
  })

  // send command as a post request including all of it's parameters. the
  // parameters are not ordered.
  function executeCommand(elem) {
    var dataArray = [elem.id]
    command_parent = elem.closest('.card');
    parameter_elements = command_parent.querySelectorAll('.parameter');
    parameter_elements.forEach(element => { dataArray.push(element.value) });
    sendRequest(dataArray);
  }

  // send the data via xhr
  function sendRequest(params) {
    $('#commandModal').modal('show');
    var body = document.querySelector('#commandModal .modal-body');
    var xhr = new XMLHttpRequest();
    var url = '/index.php';
    xhr.onreadystatechange = function () {
      if (this.readyState == 4) {
        if (this.status == 200) {
          body.innerHTML = "Befehl erfolgreich ausgeführt. <br/><pre>" + this.responseText + "</pre>"
        } else if (this.status == 500 || this.status == 404) {
          body.innerHTML = "Ausführung fehlgeschlagen. <br/><pre>" + this.responseText + "</pre>"
        }
      }
    };
    xhr.open('POST', url, true);
    xhr.setRequestHeader('Content-Type', 'application/json');
    data = JSON.stringify(params);
    xhr.send(data);
  }

  var power_button = this.document.getElementById('poweroff');
  power_button.addEventListener('click', function () {
    sendRequest(['poweroff']);
  });

})
