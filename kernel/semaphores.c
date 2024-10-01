
#include "types.h"
#include "param.h"
#include "riscv.h"
#include "spinlock.h"
#include "defs.h"

#define MAX_SEMAPHORES 64

struct semaphore
{
    int value;            // valor >= 0 o -1 si no esta inicializado
    struct spinlock lock; // indicador si el semaphore esta bloqueado
    int init_value;       // siempre >= 0, y 0 si no esta inicializado
    int active;           // indica si el semaforo esta activado o no
};

// Declaración del arreglo de semáforos
struct semaphore semaphores[MAX_SEMAPHORES];

// Variable para el primer sem open
int initialized = 0;

int
get_channel_sem(void)
{
  int found_index = 0;
  int index = 100000;

    if (!initialized)
    {
        for (int i = 0; i < MAX_SEMAPHORES; i++)
        {
            initlock(&semaphores[i].lock, "semaforito");
            semaphores[i].value = -1;     // -1 indica no inicializado
            semaphores[i].init_value = 0; // 0 indica que no tiene valor inicial
            semaphores[i].active = 0;     // 0 indica no activado

        }
        initialized = 1;
    }

  for (int i = 0; i < MAX_SEMAPHORES && !found_index; i++){
    if (semaphores[i].active != 0){
        
    }
    if (semaphores[i].active == 0){

      sem_open(i,0);
      semaphores[i].active = 1;
      index = i;
      found_index = 1;
    }
  }
 if(found_index){
    return index;
  }
  else{
    return 0;
  }
}

int
sem_open(int sem, int value)
{

    if (sem >= MAX_SEMAPHORES || sem < 0)
    {
        printf("Error: sem ID invalido\n");
        return 0; // Indicando error
    }

    acquire(&(semaphores[sem].lock));

    if (value < 0) 
    {
        printf("Error: valor inicial invalido\n");
        return 0;
    }

    int res;
        // solo inicializa si el semáforo no ha sido usado aún
        semaphores[sem].value = value;
        semaphores[sem].init_value = value;
        res = 1;


    release(&(semaphores[sem].lock));

    return res;
}

int
sem_close(int sem)
{

    if (sem >= MAX_SEMAPHORES || sem < 0)
    {
        printf("ERROR: sem ID invalido\n");
        return 0; // Indicando error
    }

    int value = semaphores[sem].value;
    int res;
    acquire(&(semaphores[sem].lock));

    if (value == -1)
    {
        res = 0; // el semaforo no ha sido inicializado
    }
    else if (value < 0 || value > semaphores[sem].init_value)
    {
        res = 0; // valores invalidos
    }
    else
    {
        semaphores[sem].value = -1;
        semaphores[sem].init_value = 0;
        semaphores[sem].active = 0;
        res = 1;
    }

    release(&(semaphores[sem].lock));

    return res;
}

int
sem_up(int sem)
{

    if (sem >= MAX_SEMAPHORES || sem < 0)
    {
        printf("ERROR: sem ID invalido\n");
        return 0; // Indicando error
    }

    if (semaphores[sem].active == 0) {
        printf("ERROR: semáforo cerrado\n");
        return 0; // Error: semáforo cerrado
    }

    int res=0;
    int value = semaphores[sem].value;
    acquire(&(semaphores[sem].lock));

    if (value >= semaphores[sem].init_value)
    {
    printf("ERROR: inrementa indebidamente\n");
    res = 0; // ERROR, intenta habilitar más procesos que los inicializados por el semaforo
    }
    else if (value == -1)
    {
        printf("ERROR: semaforo no init\n");    
        res = 0; // Error semaforo no inicializado
    }
    else if (value >= 0)
    {
        semaphores[sem].value++;
        wakeup(&semaphores[sem]); // Se rehabilita el semaforo
        res = 1;
    }

    release(&(semaphores[sem].lock));
    return res;
}


int
sem_down(int sem) {

    if (sem >= MAX_SEMAPHORES || sem < 0)
    {
        printf("ERROR: sem ID invalido\n");
        return 0; // Indicando error
    }

    if (semaphores[sem].active == 0) 
    {
        printf("ERROR: semáforo cerrado\n");
        return 0; // Error: semáforo cerrado
    }

    acquire(&(semaphores[sem].lock));

    while (semaphores[sem].value == 0) {
        sleep(&semaphores[sem], &(semaphores[sem].lock));  // duerme hasta que haya un valor
    }
    if (semaphores[sem].value > 0) {
        semaphores[sem].value--;  // disminuye el valor del semáforo
        release(&(semaphores[sem].lock));
        return 1;
    } else {
        release(&(semaphores[sem].lock));
        return 0;  // Error: semáforo no inicializado o valor inesperado
    }
}

