Feature: Flujo de trabajo de regresion

  Background:
    * def generarCelular = read('classpath:utils/generador.js')
    * def pinComun = '123456'
    * def rutaJson = karate.properties['user.dir'] + '/src/test/resources/autenticacion.json'
    * def Files = Java.type('java.nio.file.Files')
    * def Paths = Java.type('java.nio.file.Paths')
    * def StandardCharsets = Java.type('java.nio.charset.StandardCharsets')

  Scenario: Escenario 1 - Registro de Usuario Emisor y Receptor con saldo inicial


    * print '========== INICIO FASE 1/5: Escenario 1 - Registro de Usuario Emisor y Receptor con saldo inicial =========='

    # =========================================================
    # GENERAR DATOS DINAMICOS
    # =========================================================
    * def phoneEmisor = call generarCelular
    * def phoneReceptor = call generarCelular
    * def emisorEmail = 'emisor_' + phoneEmisor + '@test.com'
    * def receptorEmail = 'receptor_' + phoneReceptor + '@test.com'

    * print 'PHONE EMISOR => ', phoneEmisor
    * print 'PHONE RECEPTOR => ', phoneReceptor
    * print 'EMAIL EMISOR => ', emisorEmail
    * print 'EMAIL RECEPTOR => ', receptorEmail

    # =========================================================
    # PUNTO 1: REGISTRO DE USUARIO EMISOR
    # =========================================================
    * def emisorInfo =
    """
    {
      "phone": "#(phoneEmisor)",
      "fullName": "Juan Emisor QA",
      "email": "#(emisorEmail)",
      "pin": "123456"
    }
    """

    * print 'BODY REGISTRO EMISOR => ', emisorInfo

    Given url baseUrl1
    And path '/auth/v1/register'
    And header x-channel = xChannel
    And request emisorInfo
    When method POST
    Then status 201
    And match response.message == 'Usuario creado exitosamente'
    And match response.user.id == '#string'
    And match response.user.status == 'ACTIVE'
    * print 'RESPONSE REGISTRO EMISOR => ', response
    * def emisorId = response.user.id

    # =========================================================
    # PUNTO 1: REGISTRO DE USUARIO RECEPTOR
    # =========================================================
    * def receptorInfo =
    """
    {
      "phone": "#(phoneReceptor)",
      "fullName": "Maria Receptora QA",
      "email": "#(receptorEmail)",
      "pin": "123456"
    }
    """

    * print 'BODY REGISTRO RECEPTOR => ', receptorInfo

    Given url baseUrl1
    And path '/auth/v1/register'
    And header x-channel = xChannel
    And request receptorInfo
    When method POST
    Then status 201
    And match response.message == 'Usuario creado exitosamente'
    And match response.user.id == '#string'
    And match response.user.status == 'ACTIVE'
    * print 'RESPONSE REGISTRO RECEPTOR => ', response
    * def receptorId = response.user.id

    # =========================================================
    # PUNTO 2: LOGIN DEL EMISOR
    # =========================================================
    * def loginEmisorBody =
    """
    {
      "phone": "#(phoneEmisor)",
      "pin": "123456"
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
    And match response.expiresIn == '#number'
    And match response.user.id == '#string'
    * print 'RESPONSE LOGIN EMISOR => ', response
    * def tokenEmisor = response.token
    * def saldoInicialEmisor = response.user.balance ? response.user.balance : 0

    # =========================================================
    # PUNTO 2: LOGIN DEL RECEPTOR
    # =========================================================
    * def loginReceptorBody =
    """
    {
      "phone": "#(phoneReceptor)",
      "pin": "123456"
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
    And match response.expiresIn == '#number'
    And match response.user.id == '#string'
    * print 'RESPONSE LOGIN RECEPTOR => ', response
    * def tokenReceptor = response.token
    * def saldoInicialReceptor = response.user.balance ? response.user.balance : 0

    # =========================================================
    # PUNTO 2: ASIGNAR SALDO SUFICIENTE AL EMISOR
    # =========================================================
    * def montoRecarga = 500

    * def depositBody =
    """
    {
      "amount": 500
    }
    """

    * print 'BODY DEPOSITO => ', depositBody

    Given url baseUrl2
    And path '/wallet/v1/deposit'
    And header x-channel = xChannel
    And header Authorization = 'Bearer ' + tokenEmisor
    And request depositBody
    When method POST
    Then status 200
    And match response.success == true
    And match response.newBalance == saldoInicialEmisor + montoRecarga
    * print 'RESPONSE DEPOSITO => ', response
    * def saldoActualEmisor = response.newBalance

    # =========================================================
    # PUNTO 3: GUARDAR SALDOS ACTUALES EN VARIABLES
    # =========================================================
    * def autenticacionData =
    """
    {
      "emisor": {
        "id": "#(emisorId)",
        "phone": "#(phoneEmisor)",
        "fullName": "Juan Emisor QA",
        "email": "#(emisorEmail)",
        "pin": "123456",
        "token": "#(tokenEmisor)",
        "saldoInicial": #(saldoInicialEmisor),
        "saldoActual": #(saldoActualEmisor)
      },
      "receptor": {
        "id": "#(receptorId)",
        "phone": "#(phoneReceptor)",
        "fullName": "Maria Receptora QA",
        "email": "#(receptorEmail)",
        "pin": "123456",
        "token": "#(tokenReceptor)",
        "saldoInicial": #(saldoInicialReceptor),
        "saldoActual": #(saldoInicialReceptor)
      }
    }
    """

    * print 'AUTENTICACION.JSON => ', autenticacionData
    * eval Files.write(Paths.get(rutaJson), karate.pretty(autenticacionData).getBytes(StandardCharsets.UTF_8))

  Scenario: Escenario 1 - Validar usuario duplicado


    * print '========== INICIO FASE 2/5: Escenario 1 - Validar usuario duplicado =========='

    # =========================================================
    # PUNTO 4: VALIDAR USUARIO DUPLICADO
    # =========================================================
    * def authData = read('file:' + rutaJson)
    * print 'AUTH DATA ESCENARIO 1 => ', authData
    * match authData.emisor == '#object'
    * match authData.emisor.phone == '#string'

    * def usuarioDuplicadoBody =
    """
    {
      "phone": "#(authData.emisor.phone)",
      "fullName": "Juan Emisor QA Duplicado",
      "email": "duplicado_#(authData.emisor.phone)@test.com",
      "pin": "123456"
    }
    """

    * print 'BODY USUARIO DUPLICADO => ', usuarioDuplicadoBody

    Given url baseUrl1
    And path '/auth/v1/register'
    And header x-channel = xChannel
    And request usuarioDuplicadoBody
    When method POST
    Then status 409

  Scenario: Escenario 2 - Transferencia del Usuario Emisor al Receptor


    * print '========== INICIO FASE 3/5: Escenario 2 - Transferencia del Usuario Emisor al Receptor =========='

    # =========================================================
    # LEER DATOS DEL ESCENARIO 1
    # =========================================================
    * def authData = read('file:' + rutaJson)
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
    # PUNTO 2: REALIZAR TRANSFERENCIA
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
    # PUNTO 4: GUARDAR CODIGO DE LA TRANSACCION
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
    * print 'RESPONSE CONSULTA SALDO EMISOR => ', response
    * def saldoFinalEmisor = response.balance

    # =========================================================
    # PUNTO 6: VALIDAR DISMINUCION DEL SALDO
    # =========================================================
    * match saldoFinalEmisor == saldoInicialEscenario1 - montoTransferencia

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

    * print 'AUTENTICACION.JSON ACTUALIZADO ESCENARIO 2 => ', authData
    * eval Files.write(Paths.get(rutaJson), karate.pretty(authData).getBytes(StandardCharsets.UTF_8))

  Scenario: Escenario 3 - Validación de Transferencia en Receptor


    * print '========== INICIO FASE 4/5: Escenario 3 - Validación de Transferencia en Receptor =========='

    # =========================================================
    # LEER DATOS DEL ESCENARIO 2
    # =========================================================
    * def authData = read('file:' + rutaJson)
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
    # PUNTO 4 Y 5: TRAZABILIDAD DE TRANSACCION DEL RECEPTOR
    # =========================================================
    * print 'NUMERO DE TRANSACCION ESCENARIO 2 => ', transactionIdEscenario2

    * set authData.receptor.token = tokenReceptor
    * set authData.receptor.saldoActual = saldoActualReceptor

    * print 'AUTENTICACION.JSON ACTUALIZADO ESCENARIO 3 => ', authData
    * eval Files.write(Paths.get(rutaJson), karate.pretty(authData).getBytes(StandardCharsets.UTF_8))

  Scenario: Feature 3 - Flujo Administrador


    * print '========== INICIO FASE 5/5: Feature 3 - Flujo Administrador =========='

    # =========================================================
    # LEER DATOS PREVIOS
    # =========================================================
    * def authData = read('file:' + rutaJson)
    * def baseUrl4Local = 'http://134.209.211.10:4004'
    * def transactionIdEscenario2 = authData.transaccion.transactionId
    * def emisorId = authData.transaccion.emisorId
    * def receptorId = authData.transaccion.receptorId
    * def montoTransferencia = authData.transaccion.amount

    * print 'TRANSACTION ID ESCENARIO 2 => ', transactionIdEscenario2
    * print 'EMISOR ID => ', emisorId
    * print 'RECEPTOR ID => ', receptorId
    * print 'MONTO TRANSFERENCIA => ', montoTransferencia

    # =========================================================
    # LOGIN ADMIN
    # =========================================================
    * def loginAdminBody =
    """
    {
      "username": "admin",
      "password": "superpassword"
    }
    """

    * print 'BODY LOGIN ADMIN => ', loginAdminBody

    Given url baseUrl4Local
    And path '/admin/v1/login'
    And header x-channel = xChannel
    And request loginAdminBody
    When method POST
    Then status 200
    And match response.token == '#string'
    And match response.type == 'Bearer'
    And match response.expiresIn == '#number'
    * print 'RESPONSE LOGIN ADMIN => ', response
    * def tokenAdmin = response.token

    # =========================================================
    # CONSULTA GLOBAL DE TRANSACCIONES
    # =========================================================
    Given url baseUrl4Local
    And path '/admin/v1/transactions'
    And header x-channel = xChannel
    And header Authorization = 'Bearer ' + tokenAdmin
    When method GET
    Then status 200
    And match response == '#[]'
    * print 'RESPONSE TRANSACCIONES ADMIN => ', response
    * print 'CANTIDAD TRANSACCIONES ADMIN => ', response.length
    * print 'VALIDACION ADMIN DE LA OPERACION EJECUTADA COMPLETADA'