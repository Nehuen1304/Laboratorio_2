# Manual de Usuario: Implementación de Semáforos


## Descripción General:
Los semaforos son una herramienta de sincronización utilizada en sistemas operativos para controlar el acceso concurrente a recursos compartidos por múltiples procesos. La implementación de semáforos en este sistema sigue el modelo clásico de semáforos de valor entero.

## Funciones Disponibles:
#### 1)

```c
int get_channel_sem(void)
```
### Descripción:
get_channel_sem se utiliza para obtener un ID de semáforo disponible del conjunto de semáforos. Esta función inicializa los semáforos si es la primera vez que se llama.
Activa el semáforo y lo prepara para su uso, además de llamar a sem_open() con un valor inicial de 0.

### Retorno:

El índice del semáforo (ID) que ha sido asignado.
0 si no se ha encontrado un semáforo disponible.

Uso:

codigo en C
```c
int sem_id = get_channel_sem();
```
#### 2)

```c
int sem_open(int sem, int value)
```

### Descripción:
sem_open inicializa el semáforo identificado por el ID sem con el valor value. Solo se puede inicializar si el semáforo está activado es decir, si se ha llamado a get_channel_sem() previamente. Se utiliza para establecer un valor inicial válido.

### Parámetros:

sem: El ID del semáforo obtenido con get_channel_sem().
value: El valor inicial del semáforo (debe ser mayor o igual a 0).

### Retorno:

1 si el semáforo se inicializa correctamente.
0 si ocurre algún error (por ejemplo, ID inválido o valor inicial incorrecto).

Uso:

codigo en C
```c
 int result = sem_open(sem_id, 1);
 ```


#### 3)

```c
int sem_close(int sem)
```
### Descripción:
sem_close cierra el semáforo especificado por el ID sem. Después de cerrar un semáforo, no se puede usar más a menos que se vuelva a abrir. Libera los recursos asociados con el semáforo y lo marca como no inicializado.

### Parámetros:

sem: El ID del semáforo que se desea cerrar.
Retorno:

1 si se cierra correctamente.
0 si hay un error (por ejemplo, ID inválido o semáforo no inicializado).
Uso:

codigo en C
```c
   int result = sem_close(sem_id);
```   

#### 4)

```c
 int sem_up(int sem)
```
### Descripción:
sem_up incrementa el valor del semáforo identificado por el ID sem. Si el valor del semáforo es 0, al incrementarlo despierta a un proceso que estaba esperando en el semáforo (si lo había).

### Parámetros:

sem: El ID del semáforo.

### Retorno:

1 si la operación se realiza correctamente.
0 si ocurre un error (por ejemplo, ID inválido o semáforo no inicializado).
Uso:

código en C
```c
int result = sem_up(sem_id);
```


#### 5)
```c
int sem_down(int sem)
```
### Descripción:
sem_down decrementa el valor del semáforo identificado por el ID sem. Si el valor del semáforo es 0, el proceso que llama a sem_down entra en espera hasta que el semáforo se incremente por otro proceso. Esto permite la sincronización de procesos.

### Parámetros:

sem: El ID del semáforo.

### Retorno:

1 si la operación se realiza correctamente.
0 si hay un error o si el semáforo no está inicializado.
Uso:

codigo en C: 
```c
   int result = sem_down(sem_id);
```

## LAB 02, GRUPO 3

### Lab02: 
- Creacion e implementacion de semaforos en xv6 y una funcion "pingpong" que utiliza estos semaforos.


### Link repositorio lab2:
- (git clone git@bitbucket.org:sistop-famaf/so24lab2g03.git)


### Creacion y modificaciones de archivo fuente:
Archivos creados: 
- semaphores.c
- pingpong.c

Archivos modificados:
- usys.pl
- syscall.h
- syscall.c
- user.h


### Correr qemu:
Bash -> cd so24lab2g03/
Bash -> make qemu 


### Correr ping pong:
Bash -> cd so24lab2g03/ 
Bash -> make qemu
```bash
$pingpong 2
Ping
    Pong
Ping
    Pong

```



## Comentarios: 

### Elección de diseño:
  Creamos una función get channel en semaporhe.c que es necesaria para el uso de sem_open, están fuertemente relacionadas
  get_channel es la función necesaria para obtener el ID de un semaforo y así abrirlo, no hay libertad de elegir un ID cualesquiera del semaforo 
  a abrir.

###  Caracteristicas de get channel:
 Usamos la idea de activar ahí el semaforo y le hacemos un sem_open con valor 0. Lo que significa que cuando hacemos sem_open() de un semaforo, si se hace el uso correcto de la sintaxis planteada se hace 2 sem_open() por semaforo.

   
	