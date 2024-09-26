
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
};

// Declaración del arreglo de semáforos
struct semaphore semaphores[MAX_SEMAPHORES];

// Variable para el primer sem open
int initialized = 0;


int sem_open(int sem, int value)
{

    if (sem >= MAX_SEMAPHORES || sem < 0)
    {
        printf("Error: sem ID invalido\n");
        return 0; // Indicando error
    }

    acquire(&(semaphores[sem].lock));

    if (!initialized)
    {
        for (int i = 0; i < MAX_SEMAPHORES; i++)
        {
            initlock(&semaphores[i].lock, "semaforito");
            semaphores[i].value = -1;     // -1 indica no inicializado
            semaphores[i].init_value = 0; // 0 indica que no tiene valor inicial
        }
        initialized = 1;
    }

    int res;
    if (semaphores[sem].value == -1)
    {
        // solo inicializa si el semáforo no ha sido usado aún
        semaphores[sem].value = value;
        semaphores[sem].init_value = value;
        res = 1;
    }
    else
    {
        res = 0; // semaforo ya estaba inicializado
    }

    release(&(semaphores[sem].lock));

    return res;
}

int sem_close(int sem)
{

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
        wakeup(&semaphores[sem]);
        semaphores[sem].value = -1;
        semaphores[sem].init_value = 0;
        res = 1;
    }

    release(&(semaphores[sem].lock));

    return res;
}

int sem_up(int sem)
{
    int res;
    int value = semaphores[sem].value;
    acquire(&(semaphores[sem].lock));
    if (value >= semaphores[sem].init_value)
    {
        res = 0; // ERROR, intenta habilitar más procesos que los inicializados por el semaforo
    }
    else if (value > 0)
    {
        semaphores[sem].value++;
        res = 1;
    }
    else if (value == -1)
    {
        res = 0; // Error semaforo no inicializado
    }
    else if (value == 0)
    {
        semaphores[sem].value++;
        wakeup(&semaphores[sem]); // Se rehabilita el semaforo
        res = 1;
    }
    else
    {
        res = 0; // ERROR Value no esperado
    }
    release(&(semaphores[sem].lock));
    return res;
}

int sem_down(int sem)
{
    int value = semaphores[sem].value;
    acquire(&(semaphores[sem].lock));
    int res;
    if (value > 0)
    {
        semaphores[sem].value--;
        res =1;
    }
    else if( value == -1)
    {
        res= 0; // Semaforo no inicializado
    }
    else if( value == 0){
        res = 0; //intenta decrementar un semaforo que no tiene valor para decrementar
    }
    else{ 
        res =0; //Valor inesperado
    }
    while (value == 0)
    {
        sleep(&semaphores[sem], &(semaphores[sem].lock));
    }

    release(&(semaphores[sem].lock));
    return res;
}
