#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"





int main(int argc, char *argv[]) {
    int valid_args_count = (argc == 2);	

    if (!valid_args_count) {
        printf("ERROR: Cantidad invalida de argumentos\n");
        exit(0);
    }   
int ciclillo = atoi(argv[1]);
    if (ciclillo  <= 0){
      printf("ERROR: Se necesita un argumento >= 0 para el numero de rondas.\n");
      return 0;
    }

int ping_sem = get_channel_sem();
int pong_sem = get_channel_sem();
sem_open(ping_sem, 1);
sem_open(pong_sem,1);
sem_down(pong_sem);
int rc = fork();
    if(rc<0){
        printf("Error en el fork\n");
        exit(0);
    }
    // while(ciclillo--){
    if(rc==0){ //Hijijto
    for (int i = 0; i < ciclillo; i++) {
        sem_down(ping_sem); 
        printf("Ping\n");
        sem_up(pong_sem); 
    }
    sem_down(ping_sem);
    }
    else {  //Padresillo
    for (int i = 0; i < ciclillo; i++) {
        sem_down(pong_sem); 
        printf("\tPong\n");
        sem_up(ping_sem); 
    }
    }
  sem_close(ping_sem);
  sem_close(pong_sem);

return 0;
}
