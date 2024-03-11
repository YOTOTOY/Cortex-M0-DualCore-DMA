#include "systick.h"
#include "core_cm0.h"

void CMSDK_Delay_ms(uint16_t ms)
{
	for(uint16_t i=0;i<ms;i++){
			int32_t temp; 
			SysTick->LOAD = ((SystemCoreClock/1000)-1); 
      SysTick->CTRL=0X05;
			SysTick->VAL=0X00;
			do 
			{ 
					 temp=SysTick->CTRL;
			}
			while((temp&0x01)&&(!(temp&(1<<16))));
			SysTick->CTRL=0x00; 
			SysTick->VAL =0X00; 
	}
	return;
}

void CMSDK_Delay_us(uint16_t us)
{
	for(uint16_t i=0;i<us;i++){
			int32_t temp; 
			SysTick->LOAD = ((SystemCoreClock/100000)-1); 
			SysTick->VAL=0X00;
			SysTick->CTRL=0X05;
			do 
			{ 
					 temp=SysTick->CTRL;
			}
			while((temp&0x01)&&(!(temp&(1<<16))));
			SysTick->CTRL=0x00; 
			SysTick->VAL =0X00; 
	}
	return;
}
