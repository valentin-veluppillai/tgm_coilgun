/*
 * Coil
 *
 * Created: 2017
 * Author : Moser, Veluppillai
 */

/*	Timers:
	-timer_0: 8_bit_timer for coil-counting, prescaler = 1, compare match at 160, ovf_int not enabled
	-timer_1: 16_bit_timer for time-measurements, prescaler = 1, only ovf_int enabled, no compare match

	USART:
	-BAUD_RATE = 9600, UBRR = 103
*/

#define FOSC 16000000	// Clock Speed
#define BAUD 9600
#define MYUBRR FOSC/16/BAUD-1

#include <avr/io.h>
#include <avr/interrupt.h>

uint32_t time[3] = {0};		//store timings for coils (moser 2lazy4arrays)

uint32_t ovf_count_t0 = 0; 	//chk size
uint32_t ovf_count_t1 = 0;		//here 2

uint32_t bullet_time = 0;		//var for bullet travel time

char pos = 0;	//indicates position of serial reception
char vcount = 0;	//counter for time-variabbles

char usart_status = 0;	//0-idle/1-need to send shit/2-need to receive shit

char usart_bytecount = 0;	//position of transmission for 32 bit integers


//bullet speed interrupts

ISR(INT0_vect) {		//lower light barrier triggered
	TCCR1B = 1;		//start timer
	return;
}

ISR(INT1_vect) {		//upper light barrier triggered
	TCCR1B = 0;		//stop timer 1 and save value
	bullet_time = 4096 * ovf_count_t1 * 1000 + TCNT1 * 625 / 10;	//1 ovf = 4096us, 100 tics = 6.35us => 1 tic = 63.5ns --- that whole shit is in nanoseconds, with a 32 bit integer, unsigned, that should be enough
	return;
}

ISR(TIMER1_OVF_vect) {
	ovf_count_t1++;
}

//coi timing interrupts

ISR(TIMER0_COMP_vect) {
	if(ovf_count_t0 * 10 <= time[1]) {
		PORTB &= ~(0<<PORTB0);
	}
	if(ovf_count_t0 * 10 <= time[2]) {
		PORTB &= ~(0<<PORTB1);
	}
	if(ovf_count_t0 * 10 <= time[3]) {
		PORTB &= ~(0<<PORTB1);
		TCCR0 &= ~(1<<CS00||1<<CS01||1<<CS02);		//stop timer 0
	}
	ovf_count_t0++;
	return;
}

void USART_Init() {
	UBRRL = 0x67;
	UCSRC = 0x06;
	UCSRB = 0x18;
}

int main(void) {
	
	//setup timers
	OCR0 = 160;
	OCR1A = 1600;
	
	//setup USART
	DDRA = 0x00;
	DDRA |= (1<<PD0)|(1<<PD1);
	USART_Init();
	
	//beginn reception of data
	for(int i = 0; i < 3; i++) {
		for(int j = 0; j < 4; j++) {
			while(!(UCSRA & (1<<RXC)));
			time[i] |= (UDR<<(8*j));
		}
	}
	
	//start launch
	//activate timer 0
	TCCR0 = 1;
	TIMSK |= (1<<OCIE0);
	
	//enable pin interrupts
	MCUCR |= 0x0F;
	
	//setup coil-pins
	DDRB = 0xFF;
	PORTB = 0x00;
	
	//wait till timer 1 was stopped
	//transmit the nanosecond time
	while (1) {
		time[1] = 0;
		time[2] = 0;
		time[3] = 0;
		bullet_time = 0;
  }
}
