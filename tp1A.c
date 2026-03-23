#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>

#define FILAS 5
#define COLUMNAS 5
#define MAX_DISPAROS 10
#define ARCHIVO_RANKING "ranking.txt"

// ---------------------------------------------------------
// Esta funcion llena todo el tablero con '-'.
// El '-' significa que en esa casilla todavia no paso nada.
// ---------------------------------------------------------
void inicializarTablero(char tablero[FILAS][COLUMNAS]) {
    int i, j;

    for (i = 0; i < FILAS; i++) {
        for (j = 0; j < COLUMNAS; j++) {
            tablero[i][j] = '-';
        }
    }
}

// ---------------------------------------------------------
// Esta funcion muestra el tablero en pantalla.
// Si mostrarBarco = 0, el barco no se ve.
// Si mostrarBarco = 1, el barco se muestra con 'B'.
// Esto sirve para:
// - durante el juego: ocultar el barco
// - al final: mostrarlo
// ---------------------------------------------------------
void mostrarTablero(char tablero[FILAS][COLUMNAS], int filaBarco, int colBarco, int mostrarBarco) {
    int i, j;

    printf("\n   0 1 2 3 4\n");
    for (i = 0; i < FILAS; i++) {
        printf("%d  ", i);
        for (j = 0; j < COLUMNAS; j++) {
            // Si se quiere mostrar el barco y estamos justo en su posicion
            if (mostrarBarco == 1 && i == filaBarco && j == colBarco) {
                // Si en esa casilla no hay nada escrito, mostramos B
                if (tablero[i][j] == '-') {
                    printf("B ");
                } else {
                    // Si ya habia algo (por ejemplo el jugador acertó),
                    // igual mostramos lo que haya en el tablero
                    printf("%c ", tablero[i][j]);
                }
            } else {
                printf("%c ", tablero[i][j]);
            }
        }
        printf("\n");
    }
    printf("\n");
}

// ---------------------------------------------------------
// Esta funcion genera una posicion aleatoria para el barco.
// Como el tablero es 5x5, las filas y columnas van de 0 a 4.
// ---------------------------------------------------------
void generarBarcoAleatorio(int *filaBarco, int *colBarco) {
    *filaBarco = rand() % FILAS;
    *colBarco = rand() % COLUMNAS;
}

// ---------------------------------------------------------
// Esta funcion revisa si la fila y la columna que ingreso
// el usuario estan dentro del tablero.
// Devuelve:
// 1 si esta bien
// 0 si esta mal
// ---------------------------------------------------------
int posicionValida(int fila, int columna) {
    if (fila >= 0 && fila < FILAS && columna >= 0 && columna < COLUMNAS) {
        return 1;
    }
    return 0;
}

// ---------------------------------------------------------
// Esta funcion revisa si ya se disparó en esa casilla.
// Si hay 'A', significa agua ya disparada.
// Si hay 'X', significa que ahi estaba el barco y fue hundido.
// Devuelve:
// 1 si ya se habia disparado
// 0 si todavia no
// ---------------------------------------------------------
int yaSeDisparo(char tablero[FILAS][COLUMNAS], int fila, int columna) {
    if (tablero[fila][columna] == 'A' || tablero[fila][columna] == 'X') {
        return 1;
    }
    return 0;
}

// ---------------------------------------------------------
// Esta funcion hace el disparo.
// Si acierta al barco, marca 'X' y devuelve 1.
// Si falla, marca 'A' y devuelve 0.
// ---------------------------------------------------------
int realizarDisparo(char tablero[FILAS][COLUMNAS], int fila, int columna, int filaBarco, int colBarco) {
    if (fila == filaBarco && columna == colBarco) {
        tablero[fila][columna] = 'X'; // X = barco hundido
        return 1;
    } else {
        tablero[fila][columna] = 'A'; // A = agua
        return 0;
    }
}

// ---------------------------------------------------------
// Esta funcion guarda en un archivo el nombre del jugador
// y la cantidad de disparos que necesitó para ganar.
// Se usa modo "append" para agregar al final del archivo.
// ---------------------------------------------------------
void guardarEnRanking(char nombre[], int disparos) {
    FILE *archivo = fopen(ARCHIVO_RANKING, "a");

    if (archivo == NULL) {
        printf("No se pudo abrir el archivo de ranking.\n");
        return;
    }

    fprintf(archivo, "%s %d\n", nombre, disparos);
    fclose(archivo);
}

// ---------------------------------------------------------
// Esta funcion busca el mejor puntaje del ranking.
// El mejor puntaje es el menor numero de disparos.
// Si encuentra datos, los guarda en:
// - mejorNombre
// - mejorDisparos
// Devuelve:
// 1 si encontro ranking
// 0 si no habia archivo o estaba vacio
// ---------------------------------------------------------
int obtenerMejorRanking(char mejorNombre[], int *mejorDisparos) {
    FILE *archivo = fopen(ARCHIVO_RANKING, "r");
    char nombre[50];
    int disparos;
    int encontroAlgo = 0;

    if (archivo == NULL) {
        return 0;
    }

    while (fscanf(archivo, "%49s %d", nombre, &disparos) == 2) {
        if (encontroAlgo == 0 || disparos < *mejorDisparos) {
            strcpy(mejorNombre, nombre);
            *mejorDisparos = disparos;
            encontroAlgo = 1;
        }
    }

    fclose(archivo);
    return encontroAlgo;
}

// ---------------------------------------------------------
// Esta funcion muestra el menu principal.
// ---------------------------------------------------------
void mostrarMenu() {
    printf("===== BATALLA NAVAL SIMPLE =====\n");
    printf("1. Inicializar tablero e iniciar juego\n");
    printf("2. Mostrar tablero\n");
    printf("3. Realizar un disparo\n");
    printf("4. Salir\n");
    printf("Seleccione una opcion: ");
}

// ---------------------------------------------------------
// Programa principal.
// ---------------------------------------------------------
int main() {
    char tablero[FILAS][COLUMNAS];

    // Variables para guardar la posicion del barco
    int filaBarco, colBarco;

    // Variables para controlar el juego
    int disparosRealizados = 0;
    int juegoIniciado = 0;
    int barcoHundido = 0;

    // Variable para el menu
    int opcion;

    // Variables para el disparo del jugador
    int fila, columna;

    // Variables para ranking
    char nombreJugador[50];
    char mejorNombre[50];
    int mejorDisparos = 0;

    // Semilla para numeros aleatorios
    srand(time(NULL));

    do {
        // Antes de mostrar el menu, mostramos el mejor ranking si existe
        printf("\n");
        if (obtenerMejorRanking(mejorNombre, &mejorDisparos)) {
            printf("Mejor puntaje: %s con %d disparo(s)\n", mejorNombre, mejorDisparos);
        } else {
            printf("Mejor puntaje: aun no hay jugadores en el ranking\n");
        }

        printf("Disparos realizados en la partida actual: %d de %d\n\n", disparosRealizados, MAX_DISPAROS);

        mostrarMenu();
        scanf("%d", &opcion);

        switch (opcion) {
            case 1:
                // Iniciar o reiniciar partida
                inicializarTablero(tablero);
                generarBarcoAleatorio(&filaBarco, &colBarco);
                disparosRealizados = 0;
                juegoIniciado = 1;
                barcoHundido = 0;

                printf("\nJuego iniciado correctamente.\n");
                printf("Se genero un nuevo barco oculto en el tablero.\n");
                break;

            case 2:
                // Mostrar tablero
                if (juegoIniciado == 0) {
                    printf("\nPrimero debe iniciar el juego con la opcion 1.\n");
                } else {
                    printf("\nTablero actual:\n");
                    // Durante el juego el barco no se muestra
                    if (barcoHundido == 0 && disparosRealizados < MAX_DISPAROS) {
                        mostrarTablero(tablero, filaBarco, colBarco, 0);
                    } else {
                        // Si el juego termino, mostramos el barco
                        mostrarTablero(tablero, filaBarco, colBarco, 1);
                    }
                }
                break;

            case 3:
                // Realizar disparo
                if (juegoIniciado == 0) {
                    printf("\nPrimero debe iniciar el juego con la opcion 1.\n");
                    break;
                }

                if (barcoHundido == 1) {
                    printf("\nEl barco ya fue hundido. Inicie una nueva partida.\n");
                    break;
                }

                if (disparosRealizados >= MAX_DISPAROS) {
                    printf("\nYa se realizaron los %d disparos permitidos.\n", MAX_DISPAROS);
                    printf("Partida terminada.\n");
                    printf("Tablero final:\n");
                    mostrarTablero(tablero, filaBarco, colBarco, 1);
                    break;
                }

                printf("\nIngrese fila (0 a 4): ");
                scanf("%d", &fila);
                printf("Ingrese columna (0 a 4): ");
                scanf("%d", &columna);

                if (!posicionValida(fila, columna)) {
                    printf("Posicion invalida. Debe ingresar valores entre 0 y 4.\n");
                    break;
                }

                if (yaSeDisparo(tablero, fila, columna)) {
                    printf("Ya se disparo en esa posicion. Elija otra.\n");
                    break;
                }

                disparosRealizados++;

                if (realizarDisparo(tablero, fila, columna, filaBarco, colBarco)) {
                    printf("\n¡Impacto! ¡Hundiste el barco!\n");
                    barcoHundido = 1;

                    printf("Tablero final:\n");
                    mostrarTablero(tablero, filaBarco, colBarco, 1);

                    printf("Ganaste en %d disparo(s).\n", disparosRealizados);

                    printf("Ingrese su nombre para el ranking: ");
                    scanf("%49s", nombreJugador);

                    guardarEnRanking(nombreJugador, disparosRealizados);
                    printf("Puntaje guardado en el ranking.\n");
                } else {
                    printf("\nAgua.\n");
                    printf("Disparos realizados: %d de %d\n", disparosRealizados, MAX_DISPAROS);

                    // Si despues de fallar llegó al maximo de disparos, termina
                    if (disparosRealizados >= MAX_DISPAROS) {
                        printf("\nSe acabaron los disparos. Perdiste.\n");
                        printf("Tablero final:\n");
                        mostrarTablero(tablero, filaBarco, colBarco, 1);

                        // Si el barco no fue hundido, al final se muestra como B
                        if (fila != filaBarco || columna != colBarco) {
                            printf("El barco NO fue hundido.\n");
                        }
                    }
                }
                break;

            case 4:
                printf("\nSaliendo del programa...\n");
                break;

            default:
                printf("\nOpcion invalida.\n");
        }

    } while (opcion != 4);

    return 0;
}