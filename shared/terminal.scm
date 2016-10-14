(declare (unit terminal))
(foreign-declare "#include <termios.h>")
(foreign-declare "#include <unistd.h>")

(define echo-off!
  (foreign-lambda* void ([int fd])
    "struct termios attr;
     tcgetattr(fd, &attr);
     attr.c_lflag &= ~ECHO;
     tcsetattr(fd, TCSAFLUSH, &attr);"))

(define echo-on!
  (foreign-lambda* void ([int fd])
    "struct termios attr;
     tcgetattr(fd, &attr);
     attr.c_lflag |= ECHO;
     tcsetattr(fd, TCSAFLUSH, &attr);"))

