Feature: Registro de usuarios y asignacion de saldo

  Background:
    * def generarCelular = read('classpath:utils/generador.js')
    * def pinComun = '123456'

  Scenario: Escenario 1 - Registro de Usuario Emisor y Receptor con saldo inicial

    # =========================================================
    # GENERAR DATOS DINAMICOS
    # =========================================================
    * def phoneEmisor = call generarCelular
    * def phoneReceptor = call generarCelular
    * def emisorEmail = 'emisor_' + phoneEmisor + '@test.com'
    * def receptorEmail = 'receptor_' + phoneReceptor + '@test.com'

    # =========================================================
    # BODY REGISTRO EMISOR
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
    * def emisorId = response.user.id

    # =========================================================
    # BODY REGISTRO RECEPTOR
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
    * def receptorId = response.user.id

    # =========================================================
    # LOGIN EMISOR
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
    # LOGIN RECEPTOR
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
    # DEPOSITO AL EMISOR
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
    * def saldoActualEmisor = response.newBalance

    # =========================================================
    # GUARDAR JSON EN RESOURCES
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

    * def rutaJson = karate.properties['user.dir'] + '/src/test/resources/autenticacion.json'
    * print 'RUTA JSON GUARDAR => ', rutaJson
    * print 'AUTENTICACION.JSON => ', autenticacionData

    * def Files = Java.type('java.nio.file.Files')
    * def Paths = Java.type('java.nio.file.Paths')
    * def StandardCharsets = Java.type('java.nio.charset.StandardCharsets')

    * eval Files.write(Paths.get(rutaJson), karate.pretty(autenticacionData).getBytes(StandardCharsets.UTF_8))

  Scenario: Escenario 1 - Validar usuario duplicado

    * def rutaJson = karate.properties['user.dir'] + '/src/test/resources/autenticacion.json'
    * print 'RUTA JSON LEER => ', rutaJson

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