#include <string.h>
#include <dos.h>
#include <dir.h>
#include <io.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#if !defined( __FSTREAM_H )
#include <fstream.h>
#endif  // __FSTREAM_H
#include <conio.h>
#include <sys\stat.h>
//#define NotFound 100000L
unsigned char DataBuffer[0x2000];
unsigned char DataBuffer1[0x10];
char IDspec[8];
char Config[2];
int CheckPlate();
int ReadDataFromPic();
void ErrorReport();
void FillFFArray();
void ReadIdInformation();
void WriteIdInformation();
void WriteIdInformationProt();
  int handle=-1;
  int handle1=-1;
void delay100mks();
void delay5mks();
void delay10mks();
int Answer()
{
char c=0;
cout<<"Pic not clean.Begin Programming?(Y/N)";
    while (c!='Y'&&c!='y'&&c!='N'&&c!='n')
     c=getch();
    cout<<endl;
if (c=='N'||c=='n') return(1);
 else return(0);
}

int CheckClean()
{
int NotFill=0;
 if (ReadDataFromPic()==1) {ErrorReport();NotFill=2;}
  else
for (int x=0;x<0x2000;x++) if (DataBuffer[x]!=0xFF) NotFill=1;
return(NotFill);
}
void FillFFArray()
{
for (int x=0;x<0x2000;x++) DataBuffer[x]=255;
}

void ReadAllData();
static unsigned long multiplier = 2L;

static void near dummy (void) {}

static unsigned near readtimer (void)
{
  asm pushf                    /* Save interrupt flag                       */
  asm cli                      /* Disable interrupts                        */
  asm mov  al,0h               /* Latch timer 0                             */
  asm out  43h,al
      dummy();                 /* Waste some time */
  asm in   al,40h              /* Counter --> bx                            */
  asm mov  bl,al               /* LSB in BL                                 */
      dummy();                 /* Waste some time */
  asm in   al,40h
  asm mov  bh,al               /* MSB in BH                                 */
  asm not  bx                  /* Need ascending counter                    */
  asm popf                     /* Restore interrupt flag                    */
  return( _BX );
}

static void timer_init(void)
{
    int i;

    for (i = 0; i < 100; i++)
	if ((readtimer() & 1) == 0)     /* readtimer() returns complement */
	    {
	    multiplier = 1L;
	    return;
	    }
}

#pragma startup timer_init 65

#define CONST100mks	119L	//одна единица 840ns
void delay100mks()
{
    unsigned long stop;
    unsigned cur, prev;

    stop = (prev = readtimer()) + (CONST100mks * multiplier);

    while ((cur = readtimer()) < stop)
	{
	if (cur < prev)     /* Check for timer wraparound */
	    {
	    if (stop < 0x10000L)
		break;
	    stop -= 0x10000L;
	    }
	prev = cur;
	}
}
#define	CONST5mks	30L
void delay5mks()
{
    unsigned long stop;
    unsigned cur, prev;

    stop = (prev = readtimer()) + (CONST5mks * multiplier);

    while ((cur = readtimer()) < stop)
	{
	if (cur < prev)     /* Check for timer wraparound */
	    {
	    if (stop < 0x10000L)
		break;
	    stop -= 0x10000L;
	    }
	prev = cur;
	}
}
#define	CONST10mks	30L
void delay10mks()
{
    unsigned long stop;
    unsigned cur, prev;

    stop = (prev = readtimer()) + (CONST10mks * multiplier);

    while ((cur = readtimer()) < stop)
	{
	if (cur < prev)     /* Check for timer wraparound */
	    {
	    if (stop < 0x10000L)
		break;
	    stop -= 0x10000L;
	    }
	prev = cur;
	}
}

int WriteAllData();
int ReadDataFromPic()
{
if (CheckPlate()==0) return(1);
ReadAllData();
return(0);
}
void WriteDataToPic()
{
int Ask=0;
if (CheckClean()==1) Ask=Answer();
if (Ask==0)
 {
 FillFFArray();
 long L=lseek(handle,0,SEEK_END);
 lseek(handle,0,SEEK_SET);
 _read(handle,DataBuffer,L);
 if (WriteAllData()!=0) cout<<"Error Programming"<<endl;
 }
}
void ErrorReport()
{
cout<<"Can't find the plate."<<endl;
cout<<"I am sorry"<<endl;
}

int main( int argc, char *argv[] )
{
    char s[MAXPATH];
    char drive[MAXDRIVE];
    char dir[MAXDIR];
    char file[MAXFILE];
    char ext[MAXEXT];
  _fmode=O_BINARY;
CheckPlate();
if (argc==4)
 strncpy(IDspec,argv[3],8);
if (strcmpi(argv[1],"-r")==0)
 {
  if ((handle = _open(argv[2], O_RDONLY)) == -1)
    {
   if ((handle1 = creat(argv[2], S_IWRITE)) == -1)
     {
     perror("Error:");
     exit(1);
     }
    }
   else
   {cout<<"File "<<argv[2]<<" alredy exist.Overwrite?(Y/N)";
    char c=0;
    while (c!='Y'&&c!='y'&&c!='N'&&c!='n')
     c=getch();
    cout<<endl;
    if (c=='N'||c=='n') exit(1);
    close(handle);
    if ((handle1 = creat(argv[2], S_IWRITE)) == -1)
     {
     perror("Error:");
     exit(1);
     }
   }

  if (ReadDataFromPic()==1) ErrorReport();
  _write(handle1,DataBuffer,0x2000);
 }
else
if (strcmpi(argv[1],"-w")==0)
 {
 if ((handle = _open(argv[2], O_RDONLY)) == -1)
  {
  perror("Error:");
  exit(1);
  }
  WriteDataToPic();
 }
else
if (strcmpi(argv[1],"-rc")==0)
 {
 ReadIdInformation();
 printf("2000H - %X%X \n",DataBuffer1[1],DataBuffer1[0]);
 printf("2001H - %X%X \n",DataBuffer1[3],DataBuffer1[2]);
 printf("2002H - %X%X \n",DataBuffer1[5],DataBuffer1[4]);
 printf("2003H - %X%X \n",DataBuffer1[7],DataBuffer1[6]);
 printf("2004H - %X%X \n",DataBuffer1[9],DataBuffer1[8]);
 printf("2005H - %X%X \n",DataBuffer1[11],DataBuffer1[10]);
 printf("2006H - %X%X \n",DataBuffer1[13],DataBuffer1[12]);
 printf("2007H - %X%X \n",DataBuffer1[15],DataBuffer1[14]);
 }
else
if (strcmpi(argv[1],"-wc")==0)
 {
  cout<<"Write configuration, Begin? (Y/N)";
  char c=0;
  while (c!='Y'&&c!='y'&&c!='N'&&c!='n') c=getch();
  cout<<endl;
  if (c=='N'||c=='n') exit(1);
 WriteIdInformation();
 }
else
if (strcmpi(argv[1],"-wp")==0)
 {
  cout<<"Are you sure in protected?(Y/N)";
  char c=0;
  while (c!='Y'&&c!='y'&&c!='N'&&c!='n') c=getch();
  cout<<endl;
  if (c=='N'||c=='n') exit(1);
  cout<<"You not may be back result. It is very DANGEROUS! (P)rotect?(P/N)";
  c=0;
  while (c!='P'&&c!='p'&&c!='N'&&c!='n') c=getch();
  cout<<endl;
  if (c=='N'||c=='n') exit(1);
 WriteIdInformationProt();

 }
else
 {
 cout<<"_______________________________________"<<endl;
 cout<<" BigPit Programming. Ver 0.01. 1996(c)."<<endl;
 cout<<"Programming PIC16C65."<<endl;
 cout<<" Use PICPROG -key file <ID>"<<endl;
 cout<<"  -key  -r - read from PIC to file"<<endl;
 cout<<"        -w - write to PIC from file"<<endl;
 cout<<"        -rc - read configuration from PIC"<<endl;
 cout<<"        -wc - write configuration to PIC"<<endl;
 cout<<"        -wp - protect program memory in PIC"<<endl;
 cout<<"  file     - file name for write or read"<<endl;
 cout<<" Addition:For write operation to PIC you may be type"<<endl;
 cout<<"          ID info to write in special area"<<endl;
 cout<<"          (eight symbol on English)."<<endl;
 }
close(handle);
close(handle1);
CheckPlate();
return(0);

}


