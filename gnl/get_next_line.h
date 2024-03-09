#ifndef GET_NEXT_LINE_H
# define GET_NEXT_LINE_H

# include <unistd.h> 
# include <fcntl.h> 
# include <stdio.h> 
# include <stdlib.h>
# include <string.h>

# ifndef BUFFER_SIZE
#  define BUFFER_SIZE 42
# endif 

char	*get_next_line(int fd);
char	*strjoin_line(char *s1, char *s2);
size_t	clean_line(char *buffer);
size_t	ft_strlen(char *s);

#endif