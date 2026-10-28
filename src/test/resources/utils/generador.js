function fn() {
    var numero = '9';
    for (var i = 0; i < 8; i++) {
        numero += Math.floor(Math.random() * 10);
    }
    return numero;
}