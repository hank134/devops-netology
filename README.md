1.	Какой системный вызов делает команда cd? В прошлом ДЗ мы выяснили, что cd не является самостоятельной программой, это shell builtin, поэтому запустить strace непосредственно на cd не получится. Тем не менее, вы можете запустить strace на /bin/bash -c 'cd /tmp'. В этом случае вы увидите полный список системных вызовов, которые делает сам bash при старте. Вам нужно найти тот единственный, который относится именно к cd. Обратите внимание, что strace выдаёт результат своей работы в поток stderr, а не в stdout.
chdir("/tmp")

2.	Попробуйте использовать команду file на объекты разных типов на файловой системе. Например:
vagrant@netology1:~$ file /dev/tty
/dev/tty: character special (5/0)
vagrant@netology1:~$ file /dev/sda
/dev/sda: block special (8/0)
vagrant@netology1:~$ file /bin/bash
/bin/bash: ELF 64-bit LSB shared object, x86-64
Используя strace выясните, где находится база данных file на основании которой она делает свои догадки.
openat(AT_FDCWD, "/usr/share/misc/magic.mgc", O_RDONLY) = 3
3.	Предположим, приложение пишет лог в текстовый файл. Этот файл оказался удален (deleted в lsof), однако возможности сигналом сказать приложению переоткрыть файлы или просто перезапустить приложение – нет. Так как приложение продолжает писать в удаленный файл, место на диске постепенно заканчивается. Основываясь на знаниях о перенаправлении потоков предложите способ обнуления открытого удаленного файла (чтобы освободить место на файловой системе).
После удаления файла в который пишется программа, через Lsof находим в какой дескриптор пишется результат, отчищаем и перенаправляем его в новый файл
vagrant@vagrant:~$ ping 8.8.8.8 > /tmp/pingya &
[3] 2175
vagrant@vagrant:~$ rm /tmp/pingya
vagrant@vagrant:~$ sudo lsof -p 2175 | grep pingya
ping    2175 vagrant    1w   REG  253,0     5537 3670028 /tmp/pingya (deleted)
vagrant@vagrant:~$ echo “” > /proc/2175/fd/1
vagrant@vagrant:~$ sudo cat /proc/2175/fd/1 > /tmp/ping2

4.	Занимают ли зомби-процессы какие-то ресурсы в ОС (CPU, RAM, IO)?
Процесс после завершения освобождает свои ресурсы о ним в таблице процессов храниться информация о статусе завершения до тех пор пока родительский процесс не прочитает его, после этого запись о зомби процессе удалятся из таблицы 

5.	В iovisor BCC есть утилита opensnoop:
root@vagrant:~# dpkg -L bpfcc-tools | grep sbin/opensnoop
/usr/sbin/opensnoop-bpfcc
На какие файлы вы увидели вызовы группы open за первую секунду работы утилиты? Воспользуйтесь пакетом bpfcc-tools для Ubuntu 20.04. Дополнительные сведения по установке.
vagrant@vagrant:~$ sudo opensnoop-bpfcc -d 1
PID    COMM               FD ERR PATH
810    vminfo              4   0 /var/run/utmp
594    dbus-daemon        -1   2 /usr/local/share/dbus-1/system-services
594    dbus-daemon        18   0 /usr/share/dbus-1/system-services
594    dbus-daemon        -1   2 /lib/dbus-1/system-services
594    dbus-daemon        18   0 /var/lib/snapd/dbus-1/system-services/
614    irqbalance          6   0 /proc/interrupts
614    irqbalance          6   0 /proc/stat
614    irqbalance          6   0 /proc/irq/20/smp_affinity
614    irqbalance          6   0 /proc/irq/0/smp_affinity
614    irqbalance          6   0 /proc/irq/1/smp_affinity
614    irqbalance          6   0 /proc/irq/8/smp_affinity
614    irqbalance          6   0 /proc/irq/12/smp_affinity
614    irqbalance          6   0 /proc/irq/14/smp_affinity
614    irqbalance          6   0 /proc/irq/15/smp_affinity /



6.	Какой системный вызов использует uname -a? Приведите цитату из man по этому системному вызову, где описывается альтернативное местоположение в /proc, где можно узнать версию ядра и релиз ОС.
uname({sysname="Linux", nodename="vagrant", ...}) = 0
системный вызов uname
Part of the utsname information is also accessible via /proc/sys/kernel/{ostype, hostname, osrelease, version, domainname}.
7.	Чем отличается последовательность команд через ; и через && в bash? Например:
root@netology1:~# test -d /tmp/some_dir; echo Hi
Hi
root@netology1:~# test -d /tmp/some_dir && echo Hi
root@netology1:~#
Есть ли смысл использовать в bash &&, если применить set -e?
Оператор ; выполнить команды последовательно и выведет результат каждой комнды на экран
&& опертаор выполнить вторую конадй только с лучае успеха первой 
 Set –e завершит скрипт если любая из команд выйдет с ошибкой,  если в нашем скрипт както обрабатывает ошибку то set –e не подойдет

8.	Из каких опций состоит режим bash set -euxo pipefail и почему его хорошо было бы использовать в сценариях?
-e завершит скрипт если любая из комнад будет с ошибкой,
-u проверяет переменные, если переменнйо не будет то выдась ошибку
-x будет помимо резултатов выводить на экран все команды из скрипта
-o pipefail выведет ошибку если хоть одна команда в конвейере будет с ошибкой

Такие парамеры запуска помогают получит больше информации при отладке скрипта.  

9.	Используя -o stat для ps, определите, какой наиболее часто встречающийся статус у процессов в системе. В man ps ознакомьтесь (/PROCESS STATE CODES) что значат дополнительные к основной заглавной буквы статуса процессов. Его можно не учитывать при расчете (считать S, Ss или Ssl равнозначными).
vagrant@vagrant:~$ ps ax -o stat | grep R |wc -l
1
vagrant@vagrant:~$ ps ax -o stat | grep S |wc -l
55
vagrant@vagrant:~$ ps ax -o stat | grep I |wc -l
48
vagrant@vagrant:~$ ps ax -o stat | grep D |wc -l
0
vagrant@vagrant:~$ ps ax -o stat | grep Z |wc -l
0
vagrant@vagrant:~$ ps ax -o stat | grep T |wc -l
1
vagrant@vagrant:~$ ps ax -o stat | grep W |wc -l
0
Наиболее частый статус у процесса S - процесс ожидает спит 20 секунд
Доп символы означают приоритет процесса и опции процесса 
