Feature: Flujo Administrador

    Background:
        * def rutaJson = karate.properties['user.dir'] + '/src/test/resources/autenticacion.json'
        * def baseUrl4 = 'http://134.209.211.10:4004'
        * def authData = read('file:' + rutaJson)
        * match authData.transaccion == '#object'

    Scenario: Feature 3 - Validar la transaccion de la operacion

        * def transactionIdEscenario2 = authData.transaccion.transactionId
        * def emisorId = authData.transaccion.emisorId
        * def receptorId = authData.transaccion.receptorId
        * def montoTransferencia = authData.transaccion.amount

        * print 'TRANSACTION ID ESCENARIO 2 => ', transactionIdEscenario2
        * print 'EMISOR ID => ', emisorId
        * print 'RECEPTOR ID => ', receptorId
        * print 'MONTO TRANSFERENCIA => ', montoTransferencia

        * def loginAdminBody =
    """
    {
      "username": "admin",
      "password": "superpassword"
    }
    """

        Given url baseUrl4
        And path '/admin/v1/login'
        And header x-channel = xChannel
        And request loginAdminBody
        When method POST
        Then status 200
        And match response.token == '#string'
        And match response.type == 'Bearer'
        And match response.expiresIn == '#number'
        * def tokenAdmin = response.token

        Given url baseUrl4
        And path '/admin/v1/transactions'
        And header x-channel = xChannel
        And header Authorization = 'Bearer ' + tokenAdmin
        When method GET
        Then status 200
        And match response == '#[]'

        * print 'RESPONSE TRANSACCIONES ADMIN => ', response
        * print 'CANTIDAD TRANSACCIONES ADMIN => ', response.length