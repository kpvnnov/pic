typedef unsigned char  u08;
typedef          char  s08;
typedef unsigned short u16;
typedef          short s16;

#define  OLEN  32		/* размер буфера приема данных */
unsigned char  ostart;          /* transmission buffer start index      */
unsigned char  oend;            /* transmission buffer end index        */
ushort  outbuf[OLEN];           /* storage for transmission buffer      */

#define  SERIAL_OUT_LEN  32	/* размер буфера передачи данных */
unsigned char  ser_ostart;      /* transmission buffer start index      */
unsigned char  ser_oend;        /* transmission buffer end index        */
ushort  ser_outbuf[SERIAL_OUT_LEN]; /* storage for transmission buffer      */

#define  SERIAL_IN_LEN  32	/* размер буфера приема данных */
unsigned char  ser_istart;      /* receive buffer start index      */
unsigned char  ser_iend;        /* receive buffer end index        */
ushort  ser_inbuf[SERIAL_IN_LEN]; /* storage for receive buffer      */

#define NUM_KANALS	16

long filter[NUM_KANALS];
char one_input[NUM_KANALS];
char speed_channel[NUM_KANALS];
char speed_divisor[NUM_KANALS];
char state_receive[NUM_KANALS];
char data_receive[NUM_KANALS];
char counter_bits[NUM_KANALS];
char counter_position[NUM_KANALS];
enum receive_position{
  FIND_START,
  FIND_BITS,
  FIND_STOP,
  FIND_ONE};

void put_data (ushort c)  {
      outbuf[oend++ & (OLEN-1)] = c;  /* transfer char to transmission buffer */
}
ushort get_data(){
    if (ostart != oend)  {           /* if characters in buffer and           */
	return outbuf[ostart++ & (OLEN-1)];      /* transmit character        */
    }
}

void shift_filter(ushort c){
 char x;
 for (x=0;x<NUM_KANALS;x++){
  speed_channel[x]--;
  if (speed_divisor[x]==0){
   speed_divisor[x]=speed_channel[x];
   filter[x]=filter[x]<<1;
   filter[x]|=c&1;
   if (c&1) one_input[x]++;
   if (filter[x]&(1<<50)) one_input[x]--;
   if (one_input[x]<0) one_input[x]=0;
   if (one_input[x]>50) one_input[x]=50;
   switch(state_receive[x]){
    case FIND_START:
     if (one_input[x]<26){
      state_receive[x]=FIND_BITS;
      counter_position[x]=75;
      counter_bits[x]=5;
      }
     break;
    case FIND_BITS:
     counter_position[x]--;
     if (counter_position[x]==0){
      data_receive[x]<<=1;
      if (one_input[x]>=25) data_receive[x]|=1;
      counter_bits[x]--;
      counter_position[x]=50;
      if (counter_bits[x]==0){
       state_receive[x]=FIND_STOP;
      }
     }
     break;
    case FIND_STOP:
     counter_position[x]--;
     if (counter_position[x]==0){
      //стоп сигнал настал
      if (one_input[x]>=25){ //хороший стоп
       //необходимо передать полученный байт в очередь передачи
       state_receive[x]=FIND_START;
       }
      else{
       //необходимо сообщить об ошибке стопа
       state_receive[x]=FIND_ONE;
      }
     break;
    case FIND_ONE:
     if (one_input[x]>=25) //единицу дождались
      state_receive[x]=FIND_START;
     break;
    default: state_receive[x]=FIND_START;
     break;
    }//switch
   }//if (speed_divisor[x]==0)
  }//for (x=0;x<NUM_KANALS;x++)
}



#define F_CPU            4000000      /* 4Mhz */
#define UART_BAUD_RATE      9600      /* 9600 baud */


#define UART_BAUD_SELECT (F_CPU/(UART_BAUD_RATE*16l)-1)




/* uart globals */
static volatile u08 *uart_data_ptr;
static volatile u08 uart_counter;


SIGNAL(SIG_UART_TRANS)      
/* signal handler for uart txd ready interrupt */
{
    uart_data_ptr++;

    if (--uart_counter)
        outp(*uart_data_ptr, UDR);       /* write byte to data buffer */
}
SIGNAL(SIG_UART_TRANS)      
/* signal handler for uart txd ready interrupt */
{
    uart_data_ptr++;
    uart_counter--;

    if (uart_counter>0)
        outp(*uart_data_ptr, UDR);       /* write byte to data buffer */
    else
        uart_ready = 1;        /* ready to send */
}


void uart_send(u08 *buf, u08 size)
/* send buffer <buf> to uart */
{
    /* write first byte to data buffer */
    if (!uart_ready) return;
    uart_ready = 0;        /* not ready to send */
    uart_data_ptr  = buf;
    uart_counter   = size;
    outp(*buf, UDR);
}


SIGNAL(SIG_UART_RECV)      
/* signal handler for receive complete interrupt */
{
    register char led;

    led = inp(UDR);        /* read byte for UART data buffer */
    outp(~led, PORTB);     /* output received byte to PortB (LEDs) */
}




void uart_init(void)
/* initialize uart */
{
    /* enable RxD/TxD and ints */
    outp((1<<RXCIE)|(1<<TXCIE)|(1<<RXEN)|(1<<TXEN),UCR);       
    /* set baud rate */
    outp((u08)UART_BAUD_SELECT, UBRR);          
}


int main(void)
{
    outp(0xff ,DDRB);      /* PortB output */
    outp(0x00, PORTB);     /* switch LEDs on */

    uart_init();
    sei();                 /* enable interrupts */

    for (;;) {             /* loop forever */
        uart_send("Serial Data from AVR received###", 32);
    }            
}
u08 __attribute__ ((progmem)) leds[]={0xff, 0xe7, 0xc3, 0x81, 0x00, 0x81, 0xc3, 0xe7};        

int main(void)
{
    u08 i, j, k, l;

    outp(0xff,DDRB);                /* use all pins on PortB for output */

    for (;;) {
        for (l=0; l<sizeof(leds); l++) {
            outp(PRG_RDB(&leds[l]), PORTB);

            for (i=0; i<255; i++)   /* outer delay loop */
                for(j=0; j<255;j++) /* inner delay loop */
                    k++;            /* just do something - could also be a NOP */
       }
    }
}
