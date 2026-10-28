# Examen practico: Karate API - Flujo completo y reporte HTML

**Requisitos:** JDK 17 o superior; se recomienda **JDK 21 LTS**. Maven 3.8+.
El POM compila el runner para Java 17. `mvn -version` muestra con que Java
Maven ejecutara las pruebas, que puede ser diferente del JDK elegido en IntelliJ.

## Instrucciones en IntelliJ IDEA / Windows

1. Descomprime el ZIP en una carpeta y abre la subcarpeta `Karate`, donde esta `pom.xml`.
2. Si abriste un proyecto anterior, usa el boton **Reload All Maven Projects** (Reload Maven).
3. Abre Terminal, dentro de `Karate`, y comprueba:

       java -version
       mvn -version

4. Ejecuta:

       mvn -U clean test

   `-U` fuerza la comprobacion de artefactos Maven si el proyecto tenia dependencias
   antiguas en cache. En ejecuciones posteriores basta con `mvn clean test`.

5. Al terminar, abre **target/karate-reports/karate-summary.html**.
   Los detalles de cada escenario y sus intercambios HTTP aparecen en los HTML
   de `target/karate-reports`.

   Para abrirlo desde Git Bash de Windows:

       cmd.exe /c start "" "target\karate-reports\karate-summary.html"

   O haz doble clic en `ejecutar_y_abrir_reporte.bat` (usa Maven y abre el informe).

## Que se ejecuta

- `src/test/java/qa/RegresionTest.java` es el runner JUnit5, detectado por Maven Surefire.
- Ejecuta **solo `Regresion.feature`**, que contiene 5 escenarios en el orden
  que tenias: alta de emisor/receptor, usuario duplicado, transferencia,
  comprobacion del receptor y administracion.
- Los `.feature` auxiliares se incluyen como material de trabajo, pero NO se ejecutan
  de nuevo por separado. No se alteraron las rutas, payloads ni asserts del flujo.
- `logback-test.xml` habilita DEBUG de Karate: muestra peticiones/respuestas
  y mensajes `print` en consola; el reporte HTML incluye los pasos.

  