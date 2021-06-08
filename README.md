# mars-crimson
Prácticas motores compatibles version MATLAB 2016 y superiores

# STM32: 

  * Programa para microcontrolador: 
    * HEX para programar: [project.hex](https://github.com/ual-arm/mars-crimson/blob/master/firmware/24-STM32F429_USB_VCP/Targets/STM32F4_Discovery/project.hex)
    * Programar con el .exe que hay en el directorio "Programming Utility"
    * Código fuente: Abrir con Keil el proyecto `firmware/24-STM32F429_USB_VCP/project.uvprojx`
    * Lo principal está en este fichero: [firmware/24-STM32F429_USB_VCP/User/main.c](https://github.com/ual-arm/mars-crimson/blob/master/firmware/24-STM32F429_USB_VCP/User/main.c)

  * El procedimiento sería el siguiente:
    * Instalar el programa para simular el puerto serie en el USB (STM32-VirtualCOM-Dvr-64bit.exe).
    * Descarga el mapa de memoria del mcu (fichero project.hex).
    * Descarga el ST Link que está en: https://github.com/ual-arm/mars-crimson/tree/master/firmware/Programming%20utility
    * Conectar la Discovery por el USB de programación (es el conector mini USB, el conector micro USB solo es para comunicación y transferencia de datos). 
    * Abrir el ST Link y cargarle el project.hex.
    * Conectar con la Discovery (TargetConnect)
    * Transferirle el programa ya cargado mediante el archivo project.hex (Program & Verify)
    * OPCIONAL. Chequear que se ha grabado correctamente (Compare device memory with…)
    * Actualizar el firmware de la placa a la versión V2J27M15 (ST Link  Firmware update) Por defecto la versión del firmware es la V2J25M14 que no permite la comunicación de datos por el puerto micro USB.
![image](https://user-images.githubusercontent.com/28442296/121183500-6ca57680-c864-11eb-8c7c-39250bcde905.png)

  
  * Frames: uC -> PC
  
```
Type = 0x10: Leer ADCs
				  --------------------------------------------------------------------------------------------------
	CAMPO:        |   HEADER (=0x69)  |  TYPE (=0x10) |  TIMESTAMP_MILLISECS    |    ADC readings   |   TAIL (0x96 |
	NUM BYTES:    |       1           |         1     |            4            |   2 * int16_t     |     1        |
				  --------------------------------------------------------------------------------------------------
```
  
  * Frames: PC -> uC
  
```
  Type = 0x00: Cambiar valores de DACs, y enviar de vuelta un frame tipo 0x10 con lecturas ADCs:
  
				  -------------------------------------------------------------------------
	CAMPO:        |   HEADER (=0x69)  |  TYPE (=0x00) |      DAC values    |   TAIL (0x96 |
	NUM BYTES:    |       1           |         1     |     2 * int16_t    |     1        |
				  -------------------------------------------------------------------------

  Type = 0x01: Cambiar valores de DACs (y no hacer nada más)
  
				  -------------------------------------------------------------------------
	CAMPO:        |   HEADER (=0x69)  |  TYPE (=0x01) |      DAC values    |   TAIL (0x96 |
	NUM BYTES:    |       1           |         1     |     2 * int16_t    |     1        |
				  -------------------------------------------------------------------------

  Type = 0x02: Activa/desactiva modo de medición continuo de alta frecuencia (periodo de muestreo de ADCs configurable a XX millisecs.)
  
				  -----------------------------------------------------------------------
	CAMPO:        |   HEADER (=0x69)  |  TYPE (=0x02) |  ADC period (ms) |   TAIL (0x96 |
	NUM BYTES:    |       1           |         1     |       1          |     1        |
				  -----------------------------------------------------------------------
```


# Simulink:

  * Opción 1: Usar bloques [SerialReceive](https://es.mathworks.com/help/instrument/serialreceive.html) y [SerialSend](https://es.mathworks.com/help/instrument/serialsend.html) disponibles desde Matlab R2008a en Toolbox `Instrument Control`. **Opción 2:** diseñar código propio en un `.m` aparte (leer abajo motivación). [doc MATLAB](https://es.mathworks.com/videos/incorporating-matlab-algorithms-into-a-simulink-model-69028.html)
  * Tipo de dato para enviar y recibir: diría de usar `int16_t`, escalado en MATLAB al rango `[+5,-5]` para quitarle el trabajo de manejar números flotantes al micro. 
  * Añadir un campo timestamp a cada dato ENVIADO desde el STM32: de esa manera el muestreo tendrá precisión siempre, aunque se formen pequeñas colas al recibir. Es decir, el formato de "trama" enviado desde el STM32 debería ser así: 


  * ¿Qué ocurre? Que es muy fácil que por saturación del bucle de recepción en el PC, o por errores, etc. se pierda la "sincronía", es decir, no podemos DAR POR HECHO que cuando vaya a leer, va a estar esperándome justo el primer byte de una nueva trama, podría ser una uno de **mitad**, y si leemos interpretando como trama, leeremos basura. Solución sencilla que llevo usando casi 20 años: añadir bytes de flags de inicio y de final. Por eso los bytes HEADER y TAIL arriba. 
  * Procesar estas tramas se me hace difícil a base de un dibujo de bloques en Simulink, por eso propongo hacerlo en `.m`, al que se acceda desde un bloque simulink.
    
  


