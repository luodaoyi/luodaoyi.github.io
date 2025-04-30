---
title: "C语言常用函数"
categories: [ "汇编","C-lang" ]
tags: [ "汇编","C" ]
draft: false
slug: "C语言常用函数-c语言常用函数"
date: "2017-12-24 12:06:00"
---



## sqrt

> 求给定值的平方根

sqrt() 用来求给定值的平方根，其原型为：

        double sqrt(double x);

【参数】`x` 为要计算平方根的值。

如果 `x < 0`，将会导致 `domain error` 错误，并把全局变量 `errno` 的值为设置为 EDOM。

【返回值】返回 `x` 平方根。

Exp:

    #include
    main(){
        double root;
        root = sqrt(200);
        printf("answer is %f\n", root);
    }

## pow

> 求x的y次方（次幂）

`pow()` 函数用来求 x 的 y 次幂（次方）,其原型为：

        double pow(double x, double y);

`pow()`用来计算以 `x` 为底的 `y` 次方值，然后将结果返回。设返回值为 `ret`，则 `ret = xy`。

可能导致错误的情况：

  * 如果底数 x 为负数并且指数 y 不是整数，将会导致 domain error 错误。
  * 如果底数 x 和指数 y 都是 0，可能会导致 domain error 错误，也可能没有；这跟库的实现有关。
  * 如果底数 x 是 0，指数 y 是负数，可能会导致 domain error 或 pole error 错误，也可能没有；这跟库的实现有关。
  * 如果返回值 ret 太大或者太小，将会导致 range error 错误。

错误代码：

  * 如果发生 domain error 错误，那么全局变量 errno 将被设置为 EDOM；
  * 如果发生 pole error 或 range error 错误，那么全局变量 errno 将被设置为 ERANGE。

Exp:

    #include
    #include
    int main ()
    {
        printf ("7 ^ 3 = %f\n", pow (7.0, 3.0) );
        printf ("4.73 ^ 12 = %f\n", pow (4.73, 12.0) );
        printf ("32.01 ^ 1.54 = %f\n", pow (32.01, 1.54) );
        return 0;
    }

## fabs

> 求浮点数的绝对值

`fabs()` 函数用来求浮点数的绝对值。在TC中原型为：

        float fabs(float x);

在VC6.0中原型为：

        double fabs( double x );

【参数】x 为一个浮点数。

【返回值】计算|x|，当x不为负时返回 x，否则返回 -x。

Exp:  
求任意一个双精度数的绝对值。

    #include
    #include
    #include
    int main(void)
    {
        char c;
        float i=-1;
        /*提示用户输入数值类型*/
        printf("I can get the float number&#039;s absolute value:\n");
        scanf("%f",&i);
        while(1)/*循环*/
        {
            printf("%f\n",fabs(i));/*求双精度绝对值并格式化*/
            scanf("%f",&i);/*等待输入*/
        }
        system("pause");
        return 0;
    }

## abs

> 求绝对值(整数)

`abs()`用来计算参数j 的绝对值，然后将结果返回。  
定义:

    int abs (int j);

返回值：返回参数j 的绝对值结果。

Exp：

    #ingclude
    main(){
        int ansert;
        answer = abs(-12);
        printf("|-12| = %d\n", answer);
    }

## atof

> 将字符串转换为double(双精度浮点数)

函数 `atof()` 用于将字符串转换为双精度浮点数(double)，其原型为：

    double atof (const char* str);

`atof()` 的名字来源于 ascii to floating point numbers 的缩写，它会扫描参数str字符串，跳过前面的空白字符（例如空格，tab缩进等，可以通过 isspace() 函数来检测），直到遇上数字或正负符号才开始做转换，而再遇到非数字或字符串结束时(\&#8217;0\&#8217;)才结束转换，并将结果返回。参数str 字符串可包含正负号、小数点或E(e)来表示指数部分，如123. 456 或123e-2。

【返回值】返回转换后的浮点数；如果字符串 str 不能被转换为 double，那么返回 0.0

> 温馨提示：ANSI C 规范定义了 `stof()、atoi()、atol()、strtod()、strtol()、strtoul()` 共6个可以将字符串转换为数字的函数，大家可以对比学习；使用 `atof()` 与使用 `strtod(str, NULL)` 结果相同。另外在 C99 / C++11 规范中又新增了5个函数，分别是 `atoll()、strtof()、strtold()、strtoll()、strtoull()`，在此不做介绍，请大家自行学习。

Exp:

    #include
    #include
    int main(){
        char *a = "-100.23",
             *b = "200e-2",
             *c = "341",
             *d = "100.34cyuyan",
             *e = "cyuyan";
        printf("a = %.2f\n", atof(a));
        printf("b = %.2f\n", atof(b));
        printf("c = %.2f\n", atof(c));
        printf("d = %.2f\n", atof(d));
        printf("e = %.2f\n", atof(e));
        system("pause");
        return 0;
    }

## atoi

`atoi()` 函数用来将字符串转换成整数(int)，其原型为：

    int atoi (const char * str);

【函数说明】atoi() 函数会扫描参数 str 字符串，跳过前面的空白字符（例如空格，tab缩进等，可以通过 `isspace()` 函数来检测），直到遇上数字或正负符号才开始做转换，而再遇到非数字或字符串结束时(\&#8217;0\&#8217;)才结束转换，并将结果返回。

【返回值】返回转换后的整型数；如果 str 不能转换成 int 或者 str 为空字符串，那么将返回 0。

Exp:

    #include
    #include
    int main ()
    {
        int i;
        char buffer[256];
        printf ("Enter a number: ");
        fgets (buffer, 256, stdin);
        i = atoi (buffer);
        printf ("The value entered is %d.", i);
        system("pause");
        return 0;
    }

## strcat

`strcat()` 函数用来连接字符串，其原型为：

        char *strcat(char *dest, const char *src);

【参数】dest 为目的字符串指针，src 为源字符串指针。

strcat() 会将参数 src 字符串复制到参数 dest 所指的字符串尾部；dest 最后的结束字符 NULL 会被覆盖掉，并在连接后的字符串的尾部再增加一个 NULL。

注意：dest 与 src 所指的内存空间不能重叠，且 dest 要有足够的空间来容纳要复制的字符串。

【返回值】返回dest 字符串起始地址。

Exp:

    #include
    #include
    int main ()
    {
        char str[80];
        strcpy (str,"these ");
        strcat (str,"strings ");
        strcat (str,"are ");
        strcat (str,"concatenated.");
        puts (str);
        return 0;
    }

## strcmp

`strcmp()` 用来比较字符串（区分大小写），其原型为：

        int strcmp(const char *s1, const char *s2);

【参数】s1, s2 为需要比较的两个字符串。

字符串大小的比较是以ASCII 码表上的顺序来决定，此顺序亦为字符的值。strcmp()首先将s1 第一个字符值减去s2 第一个字符值，若差值为0 则再继续比较下个字符，若差值不为0 则将差值返回。例如字符串Ac和ba比较则会返回字符A(65)和\&#8217;b\'(98)的差值(－33)。

【返回值】若参数s1 和s2 字符串相同则返回0。s1 若大于s2 则返回大于0 的值。s1 若小于s2 则返回小于0 的值。

注意：strcmp() 以二进制的方式进行比较，不会考虑多字节或宽字节字符；如果考虑到本地化的需求，请使用 `strcoll()` 函数。

Exp:

    #include
    main(){
        char *a = "aBcDeF";
        char *b = "AbCdEf";
        char *c = "aacdef";
        char *d = "aBcDeF";
        printf("strcmp(a, b) : %d\n", strcmp(a, b));
        printf("strcmp(a, c) : %d\n", strcmp(a, c));
        printf("strcmp(a, d) : %d\n", strcmp(a, d));
    }

## strcpy

> 字符串拷贝

`strcpy()`会将参数src 字符串拷贝至参数dest 所指的地址。

    char *strcpy(char *dest, const char *src);

函数说明：strcpy()会将参数src 字符串拷贝至参数dest 所指的地址。

返回值：返回参数dest 的字符串起始地址。

附加说明：如果参数 dest 所指的内存空间不够大，可能会造成缓冲溢出(buffer Overflow)的错误情况，在编写程序时请特别留意，或者用strncpy()来取代。

Exp:

    #include
    main(){
        char a[30] = "string(1)";
        char b[] = "string(2)";
        printf("before strcpy() :%s\n", a);
        printf("after strcpy() :%s\n", strcpy(a, b));
    }

## strlen

`strlen()`函数用来计算字符串的长度，其原型为：

     unsigned int strlen (char *s);

【参数说明】s为指定的字符串。

`strlen()`用来计算指定的字符串s 的长度，不包括结束字符u0000。

【返回值】返回字符串s 的字符数。

注意一下字符数组，例如

        char str[100] = "http://see.xidian.edu.cn/cpp/u/biaozhunku/";

定义了一个大小为100的字符数组，但是仅有开始的11个字符被初始化了，剩下的都是0，所以 sizeof(str) 等于100，`strlen(str)` 等于11。

如果字符的个数等于字符数组的大小，那么strlen()的返回值就无法确定了，例如

        char str[6] = "abcxyz";

`strlen(str)`的返回值将是不确定的。因为str的结尾不是0，`strlen()`会继续向后检索，直到遇到\&#8217;0\&#8217;，而这些区域的内容是不确定的。

注意：`strlen()` 函数计算的是字符串的实际长度，遇到第一个\&#8217;0\&#8217;结束。如果你只定义没有给它赋初值，这个结果是不定的，它会从首地址一直找下去，直到遇到\&#8217;0\&#8217;停止。而sizeof返回的是变量声明后所占的内存数，不是实际长度，此外sizeof不是函数，仅仅是一个操作符，strlen()是函数。

Exp:

    #include
    #include
    int main()
    {
        char *str1 = "http://see.xidian.edu.cn/cpp/u/shipin/";
        char str2[100] = "http://see.xidian.edu.cn/cpp/u/shipin_liming/";
        char str3[5] = "12345";
        printf("strlen(str1)=%d, sizeof(str1)=%d\n", strlen(str1), sizeof(str1));
        printf("strlen(str2)=%d, sizeof(str2)=%d\n", strlen(str2), sizeof(str2));
        printf("strlen(str3)=%d, sizeof(str3)=%d\n", strlen(str3), sizeof(str3));
        return 0;
    }

## tolower

> 将大写字母转换为小写字母  
> 这尼玛看名字就知道是转小写

定义函数：

    int tolower(int c);

函数说明：若参数 c 为大写字母则将该对应的小写字母返回。

返回值：返回转换后的小写字母，若不须转换则将参数c 值返回。

Exp:

    #include
    main(){
        char s[] = "aBcDeFgH12345;!#$";
        int i;
        printf("before tolower() : %s\n", s);
        for(i = 0; i < sizeof(s); i++)
            s[i] = tolower(s[i]);
        printf("after tolower() : %s\n", s);
    }

> 话说上次写了个小函数来转换 其实大写变小写就是 + `0x20`

## toupper

> 将小写字母转换为大写字母

定义函数：

    int toupper(int c);

函数说明：若参数 c 为小写字母则将该对应的大写字母返回。

返回值：返回转换后的大写字母，若不须转换则将参数c 值返回。

Exp:

    #include
    main(){
        char s[] = "aBcDeFgH12345;!#$";
        int i;
        printf("before toupper() : %s\n", s);
        for(i = 0; i < sizeof(s); i++)
            s[i] = toupper(s[i]);
        printf("after toupper() : %s\n", s);
    }