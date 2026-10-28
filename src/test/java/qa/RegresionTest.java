package qa;

import com.intuit.karate.junit5.Karate;

/**
 * Ejecuta solamente Regresion.feature: contiene todos los escenarios
 * enlazados de Auth, Wallet, Transaction y Admin, en su orden original.
 * No se seleccionan por separado los feature auxiliares para evitar
 * repetir registros/transferencias o romper las dependencias de datos.
 */
public class RegresionTest {

    @Karate.Test
    Karate ejecutarFlujoCompleto() {
        return Karate.run("classpath:Regresion.feature");
    }
}
