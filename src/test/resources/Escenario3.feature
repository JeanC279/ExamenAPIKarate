Feature: Validacion de Transferencia en Receptor

  Background:
    * def rutaJson = karate.properties['user.dir'] + '/src/test/resources/autenticacion.json'
    * print 'RUTA JSON => ', rutaJson
    * def authData = read('file:' + rutaJson)
    * print 'AUTH DATA => ', authData
    * match authData.receptor == '#object'
    * match authData.transaccion == '#object'

  Scenario: Escenario 3 - Validacion de transferencia en receptor

    # =========================================================
    # LEER DATOS PREVIOS
    # =========================================================
    * def receptorId = authData.receptor.id
    * def receptorPhone = authData.receptor.phone
    * def receptorPin = authData.receptor.pin
    * def saldoInicialReceptor = authData.receptor.saldoInicial
    * def montoTransferencia = authData.transaccion.amount
    * def transactionIdEscenario2 = authData.transaccion.transactionId

    * print 'RECEPTOR ID => ', receptorId
    * print 'RECEPTOR PHONE => ', receptorPhone
    * print 'SALDO INICIAL RECEPTOR => ', saldoInicialReceptor
    * print 'MONTO TRANSFERENCIA => ', montoTransferencia
    * print 'TRANSACTION ID ESCENARIO 2 => ', transactionIdEscenario2

    # =========================================================
    # PUNTO 1: LOGIN DEL RECEPTOR
    # =========================================================
    * def loginReceptorBody =
    """
    {
      "phone": "#(receptorPhone)",
      "pin": "#(receptorPin)"
    }
    """

    * print 'BODY LOGIN RECEPTOR => ', loginReceptorBody

    Given url baseUrl1
    And path '/auth/v1/login'
    And header x-channel = xChannel
    And request loginReceptorBody
    When method POST
    Then status 200
    And match response.token == '#string'
    And match response.user.id == '#string'
    * print 'RESPONSE LOGIN RECEPTOR => ', response
    * def tokenReceptor = response.token

    # =========================================================
    # PUNTO 2: CONSULTA DE SALDO DEL RECEPTOR
    # =========================================================
    Given url baseUrl2
    And path '/wallet/v1/balance'
    And header x-channel = xChannel
    And header Authorization = 'Bearer ' + tokenReceptor
    When method GET
    Then status 200
    And match response.balance == '#number'
    And match response.currency == '#string'
    * print 'RESPONSE CONSULTA SALDO RECEPTOR => ', response
    * def saldoActualReceptor = response.balance

    # =========================================================
    # PUNTO 3: VALIDAR INCREMENTO DE MONTO
    # =========================================================
    * match saldoActualReceptor == saldoInicialReceptor + montoTransferencia

    # =========================================================
    # ACTUALIZAR JSON
    # =========================================================
    * set authData.receptor.token = tokenReceptor
    * set authData.receptor.saldoActual = saldoActualReceptor

    * print 'AUTENTICACION.JSON ACTUALIZADO => ', authData

    * def Files = Java.type('java.nio.file.Files')
    * def Paths = Java.type('java.nio.file.Paths')
    * def StandardCharsets = Java.type('java.nio.charset.StandardCharsets')

    * eval Files.write(Paths.get(rutaJson), karate.pretty(authData).getBytes(StandardCharsets.UTF_8))