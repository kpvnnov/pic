if exist pitsim.obj goto BCC
call asm pitsim
:BCC
bcc -I\INCLUDE -ml -L\LIB c1665