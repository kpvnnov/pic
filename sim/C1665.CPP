#include <dos.h>
#include <io.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <STDARG.H>
extern char CodeSeg[0x2000];
extern char StrPr1[80];
extern char StrPr2[80];
extern char Linia;
extern unsigned int Timens;
extern unsigned int Timemks;
extern unsigned int Timems;
extern unsigned int Timesec;
char MuzicNonStop=1;
char Animation=0;
unsigned int CounterNonStop;
void ResetCPU();
void Drawing();
int HookOneCommand();
int vspf(char* buffer,char *fmt, ...)
{
   va_list argptr;
   int cnt;

   va_start(argptr, fmt);
   cnt = vsprintf(buffer, fmt, argptr);
   va_end(argptr);

   return(cnt);
}

void DrawingMonitor()
{
vspf(StrPr1,"%2d sec,%3d ms,%3d.%d mks",Timesec,Timems,Timemks,Timens);
Drawing();
}
void FillFFArray()
{
for (int x=0;x<0x2000;x++) CodeSeg[x]=255;
}
char Shift()
{
union REGS regs;

regs.h.ah = 2;  /* set cursor position */
int86(0x16, &regs, &regs);
if ((regs.h.al&3)==0) return 0;
 else return 1;
}



void main( int argc, char *argv[] )
{
 int handle;
 if ((handle = _open(argv[1], O_RDONLY)) == -1)
  {
  perror("Error:");
  exit(1);
  }
 FillFFArray();
 long L=lseek(handle,0,SEEK_END);
 lseek(handle,0,SEEK_SET);
 _read(handle,CodeSeg,L);
 close(handle);
textmode(C4350);
//window(1, 1, 80, 50);

ResetCPU();
Drawing();
char c=0;
while (HookOneCommand()==0&&c!='q'&&c!='Q')
 {
  if (MuzicNonStop==0)
   {
   CounterNonStop++;
   if (CounterNonStop>=0)
    {
     CounterNonStop=0;
     if (Animation!=0) DrawingMonitor();
     if (kbhit()!=0)
      {c=getch();
       if (c!=0)
	{
	 MuzicNonStop=1;
	 DrawingMonitor();
	}
       else
	{
	c=getch();
	DrawingMonitor();
	switch(c)
	 {
	  case 59:break;
	  case 60:break;
	  case 61:break;
	  case 62:break;
	  case 63:Animation=0;break;
	  case 64:Animation=1;break;
	  case 65:break;
	  case 66:break;
	  case 67:break;
	 }
	}
      }
    }
   }
  else
   {
   char Step=0;
   while (Step==0)
   {
   while (kbhit()==0)
    {
     gotoxy(1,25);
     if (Shift()==0)
      vsprintf(StrPr2,"F1-Step F2-     F3-Run F4     F5-AnimOff F6-AnimON Q-Exit",NULL);
     else
      vsprintf(StrPr2,"F1-     F2-     F3-    F4     F5-Logic0  F6-Logic1 Q-Exit",NULL);
     DrawingMonitor();

    }

   c=getch();
   if (c==0)
    {
     c=getch();
     switch(c)
      {
       case 59:Step=1;break;
       case 60:break;
       case 61:Step=1;MuzicNonStop=0;break;
       case 62:break;
       case 63:break;
       case 64:break;
       case 65:break;
       case 66:break;
       case 67:break;
       case 88:Linia=0;break;
       case 89:Linia=1;break;

      }
    }
    else
     switch(c)
      {
      case 'q':
      case 'Q':exit(0);break;
      }
   }
   }

 }
}
