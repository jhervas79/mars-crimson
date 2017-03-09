% Construye un objeto que sirve de interfaz con la placa:
placaMotores = MarsCrimson();

% Conecta con la placa f�sica:
placaMotores.conectar('COM4');

VALOR_ESCALON    = 2.3;  % volts
PERIODO_LECTURA_MS = 1;  % milisecs

% Generar un escal�n:
% 1) Asegurar que el motor est� parado:
placaMotores.escribir_voltaje(0);
pause(0.2);

% 2) Empezar a medir de forma continua:
placaMotores.iniciar_medicion_continua(PERIODO_LECTURA_MS);
pause(0.1);

% 3) Generar escal�n:
fprintf('Cambiando velocidad de motores a %.02f V...\n',VALOR_ESCALON);
placaMotores.escribir_voltaje(VALOR_ESCALON);

% 4) Adquirir datos:
Vs=[]; Ts=[];
for i=1:1000,
    [volt, tim] = placaMotores.leer_velocidad();
    Vs=[Vs, volt];
    Ts=[Ts, tim];
end

% 5) Parar motores:
fprintf('Parando motores...\n');
placaMotores.escribir_voltaje(0);

fprintf('Periodo medio de medidas: %.02f ms\n', 1e3*(Ts(end)-Ts(1))/length(Ts) );

% Mostrar grafica de la respuesta a escal�n:
figure;
plot(Ts - Ts(1),Vs,'.');
xlabel('Tiempo (s)'); 
ylabel('Volt (s)');
grid on;
