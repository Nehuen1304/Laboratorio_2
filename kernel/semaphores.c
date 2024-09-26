
#include "types.h"
#include "param.h"
#include "riscv.h"
#include "spinlock.h"
#include "defs.h"

#define MAX_SEMAPHORES 64

struct semaphore {
    int value; //valor >= 0
    struct spinlock lock; //indicador si el semaphore esta bloqueado
    int init_value;
};

// Declaración del arreglo de semáforos
struct semaphore semaphores[MAX_SEMAPHORES];


int sems_pointers[MAX_SEMAPHORES];

//for (unsigned int i = 0; i < MAX_SEMAPHORES; i++) {
//   initlock(&semaphores[i].lock, "semaforito");
//   semaphores[i].value = -1;  // -1 indica no inicializado
//}

int sem_open(int sem, int value) {

    if (sem >= MAX_SEMAPHORES || sem < 0) {
        printf("Error: sem ID invalido\n");
        return -1;  // Indicando error
    }

    acquire(&(semaphores[sem].lock));


  static int initialized = 0;
    if (!initialized) {
        for (int i = 0; i < MAX_SEMAPHORES; i++) {
            initlock(&semaphores[i].lock, "semaforito");
            semaphores[i].value = -1;  // -1 indica no inicializado
        }
        initialized = 1;
    }
  
  int res;
    if (semaphores[sem].value == -1) {
        // solo inicializa si el semáforo no ha sido usado aún
        semaphores[sem].value = value;
        semaphores[sem].init_value = value;
        res = 1;
    } 
    else {
        res = 0; // semaforo ya estaba inicializado
    }

    release(&(semaphores[sem].lock));

    return res;
  }

int
sem_close(int sem);

int
sem_up(int sem);

int
sem_down(int sem){
    int value  = semaphores[sem].value;
    acquire(&(semaphores[sem].lock));
    if(value>0){
        semaphores[sem].value--;


    }else if(value < 0){
        printf("Semaforo no inicializado");
        release(&(semaphores[sem].lock));
        return 0;

    }  
    while (value == 0) {
        sleep(&semaphores[sem], &(semaphores[sem].lock));
    }
  

    release(&(semaphores[sem].lock));
}
