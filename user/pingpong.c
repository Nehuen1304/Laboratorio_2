#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include <stdarg.h>
#include "kernel/param.h"
#include "kernel/fs.h"
#include "kernel/fcntl.h"
#include "kernel/syscall.h"
#include "kernel/memlayout.h"
#include "kernel/riscv.h"
// #include <stdlib.h>




int main(int argc, char *argv[]) {
    int valid_args_count = (argc == 2);	

    if (!valid_args_count) {
        printf("Cantidad invalida de argumentos\n");
        exit(0);
    }   
int ciclillo = atoi(argv[1]);
if(ciclillo<1){
    printf("Cantidad invalida de ping pongs\n");
    exit(0);
}

sem_open(0, 1);
sem_open(1,0);
int rc = fork();
    if(rc<0){
        printf("Error en el fork\n");
        exit(0);
    }
    while(ciclillo--){
    if(rc==0){ //Hijijto
        sem_down(0);
        printf("Ping\n");
        sem_up(1);
    }
    else {  //Padresillo
        sem_down(0);
        printf("    Pong\n");
        sem_up(0);
        
    }
    }
     if (rc == 0) {  // Proceso hijo
        sem_close(0);  // Cerrar el semáforo de Ping
    } else {  // Proceso padre
        sem_close(1);  // Cerrar el semáforo de Pong
    }
return 0;
}