#include "CMSDK_CM0.h"
#include "core_cm0.h"
#include "stdlib.h"
#include "stdio.h"
#include "math.h"
#include "systick.h"
#include "CMSDK_driver.h"
#include "system_CMSDK_CM0.h"

unsigned int i, j;
char rxbuf;
unsigned char ch_flag = 0;
char cpu1_flag, cpu2_flag;

#define MCLK            (50*1000*1000)
#define UART_BUAD       (9600)
#define UART            ((CMSDK_UART_TypeDef   *) 0x40000000   )
#define TIMER           ((CMSDK_TIMER_TypeDef   *) 0x40001000   )
#define core_id         (*(volatile int *)0x50000004)
#define core2_en        (*(volatile int *)0x50000000)

unsigned int SDRAM = 0x20000000+0x10000;
unsigned int DMA_BASE = 0x10000000;
int data, addr, write, read, error, addr2, read2;

int fputc(int ch, FILE *f)
{
    if('\n' == ch){
      CMSDK_uart_SendChar(UART, '\r');
    }
    CMSDK_uart_SendChar(UART, ch);
    
    return ch;
}

void CPU1_main(void)
{
  
//  (*(volatile unsigned int *)(DMA_BASE + 0x00)) = 0x00000002;
  (*(volatile unsigned int *)(DMA_BASE + 0x04)) = 0x20010000;
  (*(volatile unsigned int *)(DMA_BASE + 0x08)) = 0x20040000;
  (*(volatile unsigned int *)(DMA_BASE + 0x0C)) = 65535;
  
  CMSDK_Delay_ms(500);
  
  for(i = 0;i < 65535;i++)
  {
    addr = SDRAM + (i << 2);
    write = rand();
    (*(volatile unsigned int *)addr) = write;
  }
  
  (*(volatile unsigned int *)(DMA_BASE + 0x00)) = 0x00000003;
  
//  CMSDK_Delay_ms(2000);
  
//  for(i = 0;i < 100;i++)
//  {
//    addr = SDRAM + (i << 2);
//    addr2 = addr + 0x30000;
//    read = (*(volatile unsigned int *)addr);
//    read2 = (*(volatile unsigned int *)addr2);
//    if(read != read2)
//    {
//      error += 1;
//    }
//  }  
  
  while(1)
  {
    ch_flag++;
  }
}

void CPU2_main(void)
{
  while(1)
  {
    rxbuf++;
    CMSDK_Delay_ms(500);
    cpu2_flag = 1;
    while(cpu2_flag);
  }
}

int main(void)
{
  NVIC_EnableIRQ(TIMER0_IRQn);
  NVIC_EnableIRQ(UARTRX0_IRQn);
  NVIC_EnableIRQ(DMA_IRQn);
  CMSDK_uart_init(UART, MCLK/UART_BUAD, 1, 1, 0, 1, 0, 0);
  CMSDK_timer_SetReload(TIMER, 0xffff);
  CMSDK_timer_SetValue(TIMER, 0xffff);
  CMSDK_timer_EnableIRQ(TIMER);
  CMSDK_timer_StartTimer(TIMER);
  core2_en = 1;

  CPU1_main();
  for(;;);
}

void UARTRX0_Handler(void)
{
  rxbuf = CMSDK_uart_ReceiveChar(UART);
  ch_flag = 1;
  CMSDK_uart_ClearRxIRQ(UART);
}

void TIMER0_Handler(void)
{
  if(cpu1_flag)
  {
    cpu1_flag = 0;
    CMSDK_uart_SendChar(UART, 'a');
  }
  if(cpu2_flag)
  {
    cpu2_flag = 0;
    CMSDK_uart_SendChar(UART, 'b');
  }
  CMSDK_timer_ClearIRQ(TIMER);
}

void DMA_Handler(void)
{
  CMSDK_uart_SendChar(UART, 'D');
  for(j = 0;j < 65535;j++)
  {
    addr = SDRAM + (j << 2);
    addr2 = addr + 0x30000;
    read = (*(volatile unsigned int *)addr);
    read2 = (*(volatile unsigned int *)addr2);
    if(read != read2)
    {
      error += 1;
    }
  }
}
