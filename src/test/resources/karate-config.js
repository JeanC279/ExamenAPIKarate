function fn() {
    var config = {
        baseUrl1: 'http://134.209.211.10:4001',
        baseUrl2: 'http://134.209.211.10:4002',
        baseUrl3: 'http://134.209.211.10:4003',
        baseUrl4: 'http://134.209.211.10:4004',
        xChannel: 'POSTMAN'
    };
    // Karate 1.5.2: presentar todos los pasos y registrar la traza HTTP
    // tanto en la consola (logback-test.xml) como en el reporte HTML.
    karate.configure('logPrettyRequest', true);
    karate.configure('logPrettyResponse', true);
    karate.configure('report', { showLog: true, showAllSteps: true });
    return config;
}