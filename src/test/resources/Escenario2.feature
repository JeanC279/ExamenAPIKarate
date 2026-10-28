Feature: Transferencia del Usuario Emisor al Receptor

  Background:
    * def rutaJson = karate.properties['user.dir'] + '/src/test/resources/autenticacion.json'
    * print 'RUTA JSON => ', rutaJson
    * def authData = read('file:' + rutaJson)
    * print 'AUTH DATA => ', authData
    * match authData.emisor == '#object'
    * match authData.receptor == '#object'

  Scenario: Escenario 2 - Transferencia del emisor al receptor

    # =========================================================
    # LEER DATOS DEL ESCENARIO 1
    # =========================================================
    * def emisorId = authData.emisor.id
    * def emisorPhone = authData.emisor.phone
    * def emisorPin = authData.emisor.pin
    * def receptorId = authData.receptor.id
    * def saldoInicialEscenario1 = authData.emisor.saldoActual

    * print 'EMISOR ID => ', emisorId
    * print 'EMISOR PHONE => ', emisorPhone
    * print 'RECEPTOR ID => ', receptorId
    * print 'SALDO INICIAL ESCENARIO 1 => ', saldoInicialEscenario1

    # =========================================================
    # PUNTO 1: LOGIN DEL EMISOR
    # =========================================================
    * def loginEmisorBody =
    """
    {
      "phone": "#(emisorPhone)",
      "pin": "#(emisorPin)"
    }
    """

    * print 'BODY LOGIN EMISOR => ', loginEmisorBody

    Given url baseUrl1
    And path '/auth/v1/login'
    And header x-channel = xChannel
    And request loginEmisorBody
    When method POST
    Then status 200
    And match response.token == '#string'
    And match response.user.id == '#string'
    * print 'RESPONSE LOGIN EMISOR => ', response
    * def tokenEmisor = response.token

    # =========================================================
    # PUNTO 2: TRANSFERENCIA CON MONTO 450 Y NOTA PAGO DE SERVICIOS
    # =========================================================
    * def montoTransferencia = 450.00

    * def transferenciaBody =
    """
    {
      "recipientId": "#(receptorId)",
      "amount": 450.00,
      "description": "Pago de Servicios",
      "categoryId": "cat_services_1"
    }
    """

    * print 'BODY TRANSFERENCIA => ', transferenciaBody

    Given url baseUrl3
    And path '/transaction/v1/transfer'
    And header x-channel = xChannel
    And header Authorization = 'Bearer ' + tokenEmisor
    And request transferenciaBody
    When method POST
    Then status 200

    # =========================================================
    # PUNTO 3: VALIDAR LA TRANSACCION
    # =========================================================
    And match response.transactionId == '#string'
    And match response.referenceCode == '#string'
    And match response.status == 'COMPLETED'
    And match response.message == '#string'
    * print 'RESPONSE TRANSFERENCIA VALIDADA => ', response

    # =========================================================
    # PUNTO 4: GUARDAR EL CODIGO DE LA TRANSACCION
    # =========================================================
    * def transactionId = response.transactionId
    * def referenceCode = response.referenceCode

    * print 'TRANSACTION ID => ', transactionId
    * print 'REFERENCE CODE => ', referenceCode

    # =========================================================
    # PUNTO 5: CONSULTAR SALDO DEL EMISOR
    # =========================================================
    Given url baseUrl2
    And path '/wallet/v1/balance'
    And header x-channel = xChannel
    And header Authorization = 'Bearer ' + tokenEmisor
    When method GET
    Then status 200
    And match response.balance == '#number'
    And match response.currency == '#string'
    * print 'RESPONSE CONSULTA SALDO => ', response
    * def saldoFinalEmisor = response.balance

    # =========================================================
    # PUNTO 6: VALIDAR DISMINUCION DEL SALDO
    # =========================================================
    * match saldoFinalEmisor == saldoInicialEscenario1 - montoTransferencia

    # =========================================================
    # ACTUALIZAR autenticacion.json
    # =========================================================
    * set authData.emisor.token = tokenEmisor
    * set authData.emisor.saldoAntesTransferencia = saldoInicialEscenario1
    * set authData.emisor.saldoActual = saldoFinalEmisor

    * set authData.transaccion = {}
    * set authData.transaccion.transactionId = transactionId
    * set authData.transaccion.referenceCode = referenceCode
    * set authData.transaccion.amount = montoTransferencia
    * set authData.transaccion.description = 'Pago de Servicios'
    * set authData.transaccion.estado = 'COMPLETED'
    * set authData.transaccion.emisorId = emisorId
    * set authData.transaccion.receptorId = receptorId

    * print 'AUTENTICACION.JSON ACTUALIZADO => ', authData

    * def Files = Java.type('java.nio.file.Files')
    * def Paths = Java.type('java.nio.file.Paths')
    * def StandardCharsets = Java.type('java.nio.charset.StandardCharsets')

    * eval Files.write(Paths.get(rutaJson), karate.pretty(authData).getBytes(StandardCharsets.UTF_8))