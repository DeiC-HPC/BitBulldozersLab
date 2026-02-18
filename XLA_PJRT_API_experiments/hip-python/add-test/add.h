typedef struct { int u, v; } vec;
typedef struct { vec *vec; } cnt;

int add(int, int);
vec *adddiff(int, int);
cnt *get_container( void );
